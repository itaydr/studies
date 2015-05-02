#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"

#define MAX_NTHREAD NTHREADS * NPROC


struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

struct {
  struct spinlock lock;
  struct thread thread[MAX_NTHREAD];
} ttable;

static struct proc *initproc;

int nextpid = 1;
int nexttid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
  initlock(&ttable.lock, "ttable");
}

//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
  release(&ptable.lock);
  return p;
}

static struct thread*
allocthread(void)
{
  struct proc *p;
  struct thread *t;
  char *sp;

  acquire(&ptable.lock);
  for(t = ttable.thread; t < &ttable.thread[MAX_NTHREAD]; t++)
    if(t->state == UNUSED)
      goto found;
  release(&ptable.lock);
  return 0;

found:
  t->state = EMBRYO;
  t->tid = nexttid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((t->kstack = kalloc()) == 0){
      t->state = UNUSED;
    return 0;
  }
  sp = t->kstack + KSTACKSIZE;
  
  // Leave room for trap frame.
  sp -= sizeof *t->tf;
  t->tf = (struct trapframe*)sp;
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *t->context;
  t->context = (struct context*)sp;
  memset(t->context, 0, sizeof *t->context);
  t->context->eip = (uint)forkret;
  
  p = allocproc();
  t->proc = p;

  return t;
}


//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
  struct thread *t;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  t = allocthread();
    
  initproc = t->proc;
  if((t->proc->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(t->proc->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  t->proc->sz = PGSIZE;
  memset(t->tf, 0, sizeof(*t->tf));
  t->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  t->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  t->tf->es = t->tf->ds;
  t->tf->ss = t->tf->ds;
  t->tf->eflags = FL_IF;
  t->tf->esp = PGSIZE;
  t->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(t->proc->name, "initcode", sizeof(t->proc->name));

  t->proc->cwd = namei("/");

  t->proc->state = RUNNABLE;
  // Never Reached
  t->state = RUNNABLE;
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  
  sz = PROC->sz;
  if(n > 0){
    if((sz = allocuvm(PROC->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(PROC->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  PROC->sz = sz;
  switchuvm(PROC);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct thread *nt;
  // Allocate process.
  if((nt = allocthread()) == 0)
    return -1;
  
  np = nt->proc;

  // Copy process state from p.
  if((np->pgdir = copyuvm(PROC->pgdir, PROC->sz)) == 0){
    kfree(nt->kstack);
    nt->kstack = 0;
    nt->state = UNUSED;
    return -1;
  }
  np->sz = PROC->sz;
  np->parent = PROC;
  *nt->tf = *thread->tf;

  // Clear %eax so that fork returns 0 in the child.
  nt->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(PROC->ofile[i])
      np->ofile[i] = filedup(PROC->ofile[i]);
  np->cwd = idup(PROC->cwd);

  safestrcpy(np->name, PROC->name, sizeof(PROC->name));
  safestrcpy(nt->name, thread->name, sizeof(thread->name));
  
  pid = np->pid;

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
  np->state = RUNNABLE;
  nt->state = RUNNABLE;
  release(&ptable.lock);
  
  return pid;
}


void
cleanTread (struct thread *t) {
   kfree(t->kstack);
   t->kstack = 0;
   t->state = UNUSED;
   t->tid = 0;
   t->proc = 0;
   t->name[0] = 0;
   t->killed = 0;
}

void cleanProccess(struct proc *p) {
        freevm(p->pgdir);
        p->state = UNUSED;
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  struct proc *p;
  struct thread *t;
  int fd;

  if(PROC == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(PROC->ofile[fd]){
      fileclose(PROC->ofile[fd]);
      PROC->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(PROC->cwd);
  end_op();
  PROC->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(PROC->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == PROC){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }
  
  // Go over all threads of curent proccess, and kill them.
  for (t = ttable.thread; t < &ttable.thread[MAX_NTHREAD]; t++) {
    if (t->proc == PROC) {
      if (t != thread) {
	if (t->state == RUNNING) {
	  // TODO: this thread maybe running on a different CPU.
	}
	cleanTread(t);
      }
    }
  }
  // Jump into the scheduler, never to return.
  PROC->state = ZOMBIE;
  thread->state = ZOMBIE;
  sched();
  panic("zombie exit");
}


// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != PROC)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        cleanProccess(p);
	// TODO: when should the current thread be cleared?
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || PROC->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(PROC, &ptable.lock);  //DOC: wait-sleep
  }
}

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
  struct thread *t;
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
      for(t = ttable.thread; t < &ttable.thread[MAX_NTHREAD]; t++){
	if(p != t->proc || p->state != RUNNABLE || t->state != RUNNABLE)
	  continue;
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      thread = t;
      switchuvm(t->proc);
      t->state = RUNNING;
      swtch(&cpu->scheduler, t->context);
      switchkvm();
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      thread = 0;
     
    }
    }
    
    release(&ptable.lock);

  }
}

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
  int intena;

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(thread->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = cpu->intena;
  swtch(&thread->context, cpu->scheduler);
  cpu->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
  thread->state = RUNNABLE;
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
    initlog();
  }
  
  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  if(PROC == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }

  // Go to sleep.
  thread->chan = chan;
  thread->state = SLEEPING;
  sched();

  // Tidy up.
  thread->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}

//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct thread *t;

  for(t = ttable.thread; t < &ttable.thread[MAX_NTHREAD]; t++)
    if(t->state == SLEEPING && t->chan == chan)
      t->state = RUNNABLE;
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  struct thread *t;

  acquire(&ptable.lock);
  for(t = ttable.thread; t < &ttable.thread[MAX_NTHREAD]; t++){
    if(t->proc->pid == pid){
      t->proc->killed = 1;
      t->killed = 1;
      // Wake process from sleep if necessary.
      if(t->state == SLEEPING)
        t->state = RUNNABLE;
      release(&ptable.lock);
      //return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}

//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  int i;
  struct proc *p;
  char *state;
  //uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    
    // @itay - cacelled for now.
    //if(p->state == SLEEPING){
    //  getcallerpcs((uint*)p->context->ebp+2, pc);
    //  for(i=0; i<10 && pc[i] != 0; i++)
    //    cprintf(" %p", pc[i]);
    //}
    i=i;
    cprintf("\n");
  }
}
