#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"
#include "kthread.h"

void cleanTread (struct thread *t);

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

struct {
  struct thread thread[MAX_NTHREAD];
} ttable;

struct {
  struct spinlock lock;
  struct mutex mutex[MAX_MUTEXES];
} mtable;


static struct proc *initproc;

int nextpid = 1;
int nexttid = 500;
int nextmid = 1000;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

void
pinit(void)
{
  struct proc *p;
  struct mutex *m;
  uint i = 0;
//   struct thread * t;
  
  initlock(&ptable.lock, "ptable");
  initlock(&mtable.lock, "mtable");
//   initlock(&ttable.lock, "ttable");
  
   for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
     initlock(&p->pLock, "pLock"); 
   }
   
   for(m = mtable.mutex; m < &mtable.mutex[MAX_MUTEXES]; m++) {
     initlock(&m->mutexLock, "mLock");
     initlock(&m->queueLock, "qLock");
     m->tid = -1;
     m->state = M_NOT_ALLOCATED;
     
     m->currentHolder 		= 0;
     m->nextInLineHolder 	= 0;
     m->arrayIndex 		= i++;
   }
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
allocthread(int createProc)
{
  struct proc *p;
  struct thread *t;
  char *sp;

  acquire(&ptable.lock);
  for(t = ttable.thread; t < &ttable.thread[MAX_NTHREAD]; t++) {
     if(t->state == ZOMBIE) {
       cleanTread(t);
     }
    if(t->state == UNUSED) {
      goto found;
    }
  }
  release(&ptable.lock);
  return 0;

found:
  t->state = EMBRYO;
  t->tid = nexttid++;
  t->killed = 0;
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
  
  if (createProc) {
    p = allocproc();
    t->proc = p;
    p->numberOfThreads = 1;
  }

  return t;
}


//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
  struct thread *t;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  t = allocthread(1);
    
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

  t->state = RUNNABLE;
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  
  acquire(&PROC->pLock);
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
  release(&PROC->pLock);

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
  if((nt = allocthread(1)) == 0)
    return -1;
  
  np = nt->proc;

  // Copy process state from p.
  if((np->pgdir = copyuvm(PROC->pgdir, PROC->sz)) == 0){
    kfree(nt->kstack);
    nt->kstack = 0;
    nt->state = UNUSED;
    np->state = UNUSED;
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
  nt->state = RUNNABLE;
  release(&ptable.lock);
  
  return pid;
}


void
cleanTread (struct thread *t) {
   if (t->kstack) 
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
	p->numberOfThreads = 0;
}


void
exit(void) {
  kthread_exit();
}
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit1(void)
{
  struct proc *p;
  int fd;

  if(PROC == initproc)
    panic("init exiting");
  
  // Go over all threads of curent proccess, and kill them.
  killThreadsOfCurrentProcExceptMe();

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
	if(p != t->proc || t->state != RUNNABLE)
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
    if(t->state == SLEEPING && t->chan == chan) {
      t->state = RUNNABLE;
    }
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
  int found = -1;

  acquire(&ptable.lock);
  for(t = ttable.thread; t < &ttable.thread[MAX_NTHREAD]; t++){
    if(t->proc->pid == pid){
      found = 0;
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
  
  return found;
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

// Threads

void killThreadsOfCurrentProcExceptMe() {
    struct thread *t;
    acquire(&ptable.lock);
    for(t = ttable.thread; t < &ttable.thread[MAX_NTHREAD]; t++) {
	if (t->tid != thread->tid && t->proc == PROC) { // Not the current thread, but of the same process.
	  t->killed = 1;
	  if(t->state == SLEEPING)
	    t->state = RUNNABLE;
	}
    }
    release(&ptable.lock);
    for(t = ttable.thread; t < &ttable.thread[MAX_NTHREAD]; t++) {
	if (t->proc == PROC && t->tid != thread->tid) { // Not the current thread, but of the same process.
	    kthread_join(t->tid);
	}
    }
}

int kthread_create( void*(*start_func)(), void* stack, uint stack_size ) {
  struct thread *t;
  
  if (thread->proc->numberOfThreads == NTHREADS) {
      return -1;
  }
  
  if((t = allocthread(0)) == 0)
    return -1;
  
  acquire(&ptable.lock);
  memmove(t->tf, thread->tf, sizeof(*t->tf));
  t->tf->eip=(uint)start_func;
  t->tf->esp=(uint)stack+stack_size;
  t->proc = PROC;
  t->state = RUNNABLE;
  t->proc->numberOfThreads++;
  release(&ptable.lock);
  
  return t->tid;
}

int kthread_id(void) {
 return thread->tid; 
}

void kthread_exit(void) {
  acquire(&ptable.lock);

//   cprintf("Thread %d called kthread_exit \n", thread->tid);
  
       wakeup1(thread);

  // If no other threads - kill the proc.
  if (PROC->numberOfThreads != 1) {
     // Other threads might have called join on us.
     
      PROC->numberOfThreads--;
      thread->state = ZOMBIE;
      sched();
  }
  else {
    release(&ptable.lock);
    exit1();
  }
}

int kthread_join(int thread_id) {
  struct thread *t;
//   struct mutex *m;
//   int i;
  int threadExists = 0;

  acquire(&ptable.lock);
 
  
  for(;;){
     for(t = ttable.thread; t < &ttable.thread[MAX_NTHREAD]; t++) {
      if(t->tid != thread_id)
        continue;
      threadExists = 1;
      if(t->state == ZOMBIE){
	cleanTread(t);
        release(&ptable.lock);
        return 0;
      }
      
      break;
    }

    // No point waiting if we don't have any children.
    if(!threadExists || thread->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(t, &ptable.lock);  //DOC: wait-sleep
  }
  release(&ptable.lock);
  return 0;
}


//--------------------- mutexes ----------------
int kthread_mutex_alloc() {
  struct mutex *m;
  int found = -1, i;
  acquire(&mtable.lock);
  
  for(m = mtable.mutex; m < &mtable.mutex[MAX_MUTEXES]; m++) {
    if ( m->state == M_NOT_ALLOCATED ) {
      m->state = M_ALLOCATED;
      m->mId = nextmid++;
      m->tid = -1;
      found = m->mId;
      break;
    }
   }
   
   for (i = 0; i < MAX_NTHREAD ; i++) {
     m->threadIDInQueue[i] = -1;
   }
   
   release(&mtable.lock);
   
   return found;
}

int kthread_mutex_dealloc(int mutex_id) {
  struct mutex *m;
  int found = -1;
  acquire(&mtable.lock);
  
  for(m = mtable.mutex; m < &mtable.mutex[MAX_MUTEXES]; m++) {
    if ( m->state == M_ALLOCATED && m->mId == mutex_id && -1 == m->tid) {
      m->state = M_NOT_ALLOCATED;
      m->mId = -1;
      found = 0;
      break;
    }
   }
   
   release(&mtable.lock);
   
   return found;
}
int kthread_mutex_lock(int mutex_id) {
  struct mutex *m;
  int found = 0;
//   int i;
  int sleepNum = 0;
  struct spinlock *lk;
  acquire(&mtable.lock);
  
  for(m = mtable.mutex; m < &mtable.mutex[MAX_MUTEXES]; m++) {
    if ( m->state == M_ALLOCATED && m->mId == mutex_id ) { //&& -1 == m->tid) {
      found = 1;
      break;
    }
   }
   
   if ( found == 0 ) {   // case no such mutex
     release(&mtable.lock);
     return -1;
   }
   
   acquire(&m->queueLock);
   
   if ( m->tid == thread->tid ) {   // case we already own the lock
     release(&m->queueLock);
     release(&mtable.lock);
     return -1;
   }
  
  release(&mtable.lock);
  
  // prepare sleep
  sleepNum = (m->arrayIndex*MAX_NTHREAD + m->nextInLineHolder);
  m->threadIDInQueue[m->nextInLineHolder] = thread->tid;
  m->nextInLineHolder = (m->nextInLineHolder + 1);
  m->nextInLineHolder = m->nextInLineHolder % MAX_NTHREAD;

  lk = &m->mutexLock;
  
  while(xchg(&lk->locked, 1) != 0) {
    if(thread->killed){
      release(&m->queueLock);
      return -1;
    }
    sleep((void*)sleepNum, &m->queueLock);
  }
  
  m->tid = thread->tid;

  
  release(&m->queueLock);
  
  return 0;
}
int kthread_mutex_unlock(int mutex_id) {
  struct mutex *m;
  int found = 0;
//   int i;
  struct spinlock *lk;
  int sleepNum = 0;
  
  acquire(&mtable.lock);
  
  for(m = mtable.mutex; m < &mtable.mutex[MAX_MUTEXES]; m++) {
    if ( m->state == M_ALLOCATED && m->mId == mutex_id ) { //&& -1 == m->tid) {
      found = 1;
      break;
    }
   }
   
   if ( found == 0  || m->tid == -1) {   // case no such mutex or it is not owned
     release(&mtable.lock);
     return -1;
   }
      
  acquire(&m->queueLock);
  
  release(&mtable.lock);
  
  // free the lock
  lk = &m->mutexLock;
  m->tid = -1;
  m->threadIDInQueue[m->currentHolder] = -1;
    
  xchg(&lk->locked, 0);
  
  m->currentHolder = (m->currentHolder + 1) % MAX_NTHREAD;
 
  sleepNum = m->arrayIndex*MAX_NTHREAD + m->currentHolder;
  wakeup((void*) sleepNum);
  release(&m->queueLock);
  
  return 0;
}

int kthread_mutex_yieldlock(int mutex_id1, int mutex_id2) {
  struct mutex* m;
  struct mutex* m1;
  struct mutex* m2;
  int found1 = 0, found2 = 0;
//   int i;
//   struct spinlock *lk;
  
  acquire(&mtable.lock);
  
  for(m = mtable.mutex; m < &mtable.mutex[MAX_MUTEXES]; m++) {
    if ( m->state == M_ALLOCATED && m->mId == mutex_id1 ) { //&& -1 == m->tid) {
      found1 = 1;
      m1 = m;
    }
    if ( m->state == M_ALLOCATED && m->mId == mutex_id2 ) { //&& -1 == m->tid) {
      found2 = 1;
      m2 = m;
    }
   }
   
   release(&mtable.lock);
   m = 0;
   
   if ( found1 == 0  || found2 == 0) {   // case no such locks
     return -1;
   }
   
  acquire(&m1->queueLock);
   
  if ( m1->tid != thread->tid ) {   // case we don't have the lock
     release(&m1->queueLock);
     return -1;
   } else {
     if (mutex_id1 == mutex_id2) {
	// special case - we want just to give it up
	m1->tid = -2;
	release(&m1->queueLock);
	return 0;
     }
   }
  
  // Find a thread which is waiting on lock 2
  acquire(&m2->queueLock);
   
   if ( !( (m2->nextInLineHolder - m2->currentHolder) == 1 ||
	((m2->currentHolder == MAX_NTHREAD-1) && (m2->nextInLineHolder == 0))    )) {   // case at least one is waiting
          
     m1->tid = m2->threadIDInQueue[(m2->currentHolder+1) % MAX_NTHREAD];
     m1->threadIDInQueue[m1->currentHolder] = m1->tid;
     release(&m2->queueLock);
     release(&m1->queueLock);
     kthread_mutex_unlock(m2->mId);
   } else {
     // no one is waiting
     release(&m2->queueLock);
     release(&m1->queueLock);
     kthread_mutex_unlock(m1->mId);
   }
   
  return 0;
}