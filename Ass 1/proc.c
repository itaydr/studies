#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"

#define SHELL_ID	2

#define DEFAULT 1
#define FRR 2
#define FCFS 3
#define CFS 4

//------- helper funcs -----------
int get_current_ticks(void);
void update_counters();
int shared_wait(int *status ,int *wtime, int *rtime, int *iotime);
void on_state_set_to_runnable(struct proc *cur_proc);
void on_state_set_to_sleeping(struct proc *cur_proc);
void on_state_set_to_zombi(struct proc *cur_proc);
void on_state_set_to_running(struct proc *cur_proc);
void sched_q_enqueue(int pid);
int  sched_q_dequeue(void);
void sched_q_display(void);
int  sched_q_peek(void);


int front = -1;
int rear  = -1;

// Processes table
struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;


// Jobs table
struct {
  struct spinlock lock;
  struct job jobs[NPROC];
} jtable;

// scheduler queue
struct {
  //struct spinlock lock;
  struct runnable_queue_entry queue[NPROC];
} scheduler_queue;


static struct proc *initproc;

int nextpid = 1;
int nextjid = 1;
extern void forkret(void);
extern void trapret(void);

int cleanJobIfNeeded(void);
static void wakeup1(void *chan);

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
  initlock(&jtable.lock, "jtable");
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
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->priority = P_MED;
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}

static struct job*
allocjob(void)
{
  struct job *j;
  int index = 0;
  acquire(&jtable.lock);
  for(j = jtable.jobs; j < &jtable.jobs[NPROC]; j++) {
    if(j->state == JOB_S_UNUSED) {
      goto found;
    }
    index++;
  }
  release(&jtable.lock);
  return 0;

found:
  j->state = JOB_S_EMBRYO;
  j->jid = nextjid++;
  release(&jtable.lock);
  
  return j;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;
  on_state_set_to_runnable(p);
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  
  sz = proc->sz;
  if(n > 0){
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  proc->sz = sz;
  switchuvm(proc);
  return 0;
}

struct job*
createJob(char *command) {
  struct job *nj;
  char *last, *s;
    
  // Allocate job.
  if((nj = allocjob()) == NULL)
    return NULL;
  
  
  for(last=s=command; *s; s++)
    if(*s == '/')
      last = s+1;
  
  safestrcpy(nj->commandName, last, sizeof(nj->commandName));
  
  return nj;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
    return -1;
  
  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  
  if (proc->job == NULL && proc->pid >= SHELL_ID) {
      cprintf("Error - Forking new process from a process which don't have a job!.\n");
  }
  
  np->job = proc->job;
    
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;
  
  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);

  safestrcpy(np->name, proc->name, sizeof(proc->name));

  pid = np->pid;

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
  np->state = RUNNABLE;
  on_state_set_to_runnable(np);
  
  // set initial creation time
  np->stime	 = 0;
  np->retime 	 = 0;
  np->rutime 	 = 0;
  np->ctime = get_current_ticks();
  
  
  release(&ptable.lock);
  
  return pid;
}

// Same as fork, but creates a new job.
int
forkjob(char *command)
{
  int i, pid;
  struct proc *np;
  struct job *nj;

  // Allocate process.
  if((np = allocproc()) == 0)
    return -1;
  
  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  
  // Create a new job.
  if ((nj = createJob(command)) == NULL) {
    panic("Failed creating a job");
  }
  
  np->job = nj;
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;
  
  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);

  safestrcpy(np->name, proc->name, sizeof(proc->name));

  pid = np->pid;

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
  np->state = RUNNABLE;
  on_state_set_to_runnable(np);
  
  // initial creation time
  np->stime	 = 0;
  np->retime 	 = 0;
  np->rutime 	 = 0;
  np->ctime = get_current_ticks();
  
  release(&ptable.lock);
  
  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(int status)
{
  //cprintf("enterted: exit, %d\n", status);
  struct proc *p;
  int fd;
  
  // set termination time
  proc->ttime = get_current_ticks();
  
  
  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }
  
  proc->exitStatus = status;
  cleanJobIfNeeded();

  begin_op();
  iput(proc->cwd);
  end_op();
  proc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
  wakeup1(proc);
  
  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
  on_state_set_to_zombi(proc);
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(int *status)
{
  return shared_wait(status, NULL, NULL, NULL);
}

int wait_stat(int *wtime, int *rtime, int *iotime) {
  return shared_wait(NULL, wtime, rtime, iotime); 
}


int shared_wait(int *status ,int *wtime, int *rtime, int *iotime) {

  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
	
	if (status != NULL) {
	   *status = p->exitStatus;
	} else {
	  *status = -2;
	}
	
	if (wtime != NULL)
	  *wtime = proc->retime;
	if (rtime != NULL)
	  *rtime = proc->rutime;
	if (iotime != NULL)
	  *iotime = proc->stime;
	
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);
        p->state = UNUSED;
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
	p->job = 0;
	p->ctime = 0;
	p->ttime = 0;
	p->retime = 0;
	p->rutime = 0;
	p->stime = 0;
	p->sched_time = 0;
	p->priority = P_UNDEF;
        release(&ptable.lock);
	
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }  
}


// if BLOCKING - Wait for a process with id: pid to exit and return its status.
// if BLOCKING - return its status or -1.
// Return -1 if this process has no children.
int 
waitpid(int pid, int *status, int options)
{
  struct proc *p, *foundProc;
  int is_exists = 0;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if (p-> pid == pid) {
	is_exists = 1;
	foundProc = p;
	if(p->state == ZOMBIE){
	  // Found one.
	  pid = p->pid;
	
	  if (status != NULL) {
	    *status = p->exitStatus;
	  } else {
	    *status = -2;
	  }
	  
	  kfree(p->kstack);
	  p->kstack = 0;
	  freevm(p->pgdir);
	  p->state = UNUSED;
	  p->pid = 0;
	  p->parent = 0;
	  p->name[0] = 0;
	  p->killed = 0;
	  p->job = 0;
	  p->ctime = 0;
	  p->ttime = 0;
	  p->retime = 0;
	  p->rutime = 0;
	  p->stime = 0;
	  p->sched_time = 0;
	  p->priority = P_UNDEF;
	  release(&ptable.lock);
	  
	  return pid;
	}
	
	if (options == NON_BLOCKING) {
	  release(&ptable.lock);
	  return -1;
	}
      }
    }

    // No point waiting if we don't have any children.
    if(!is_exists || proc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(foundProc, &ptable.lock);  //DOC: wait-sleep
    foundProc = NULL;is_exists = FALSE;
  }
}


int cleanJobIfNeeded(void) {
   int jid = proc->job->jid;
   struct proc *p;
   struct job *j;
   
    for (p = ptable.proc ; p < &ptable.proc[NPROC] ; p++ ) {
	if (p->pid != proc->pid &&  // If it's not the current process
	    p->job->jid == jid &&   // Current process and p share the sam job.
	    p->state != UNUSED) {   // p is still alive.
	 
	   return 0;
	}
    }
    
   // If we reached here we need to kill the job.
   j = proc->job;
   j->jid = 0;
   j->state = JOB_S_UNUSED;
   j->commandName[0] = NULL;
   
   return 1;
}

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.

#if SCHEDFLAG == DEFAULT
  #include "scheduler_DEFAULT.c"
  
#elif SCHEDFLAG == FRR
  #include "scheduler_FRR.c"
  
#elif SCHEDFLAG == FCFS
  #include "scheduler_FCFS.c"
  
#elif SCHEDFLAG == CFS
  #include "scheduler_CFS.c"
  
#endif

/*
void scheduler(void)
{
  struct proc *p;
  
  struct proc *selected_p = NULL;
  
  cprintf("LOADED SCHEDFLAG == FRR\n");
  
  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    //cprintf("test1111\n");
    acquire(&ptable.lock);
    //cprintf("test2222\n");
    
    selected_p = NULL;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
	continue;
      
      if (selected_p == NULL) {
	selected_p = p;
	continue;
      }

      if ( selected_p->sched_time > p->sched_time ) {
	selected_p = p;
      }
    }

    
if (selected_p == NULL) {
  release(&ptable.lock);
  continue;
}

    
      cprintf("choose to switch to: %d\n", selected_p->pid);
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
	    
      proc = selected_p;
      switchuvm(selected_p);
      selected_p->state = RUNNING;
      on_state_set_to_running(p);
      swtch(&cpu->scheduler, proc->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    
    
    //cprintf("LOOP %d !\n", selected_p->pid);
    selected_p = NULL;
    release(&ptable.lock);
  }
}
*/


/*
void
scheduler(void)
{
  struct proc *p;
  
  struct proc *selected_p = NULL;
  selected_p = selected_p;
  
  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    //cprintf("test1111 - acquire scheduler\n");
    acquire(&ptable.lock);
    //cprintf("test2222\n");
    
    //#include "sched.c"
    selected_p = NULL;for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
	
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
      on_state_set_to_running(p);
      swtch(&cpu->scheduler, proc->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
      cprintf("LOOP %d !\n", p->pid);
}


    
    
    //cprintf("test1111 - release scheduler\n");
    release(&ptable.lock);

  }
}

*/
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
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = cpu->intena;
  swtch(&proc->context, cpu->scheduler);
  cpu->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  //cprintf("test1111 - acquire yield\n");
  acquire(&ptable.lock);  //DOC: yieldlock
  proc->state = RUNNABLE;
  on_state_set_to_runnable(proc);
  sched();
  //cprintf("test1111 - release yield\n");
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
  if(proc == 0)
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
  proc->chan = chan;
  proc->state = SLEEPING;
  on_state_set_to_sleeping(proc);
  sched();

  // Tidy up.
  proc->chan = 0;

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
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan){
      p->state = RUNNABLE;
      on_state_set_to_runnable(p);
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
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING) {
        p->state = RUNNABLE;
	on_state_set_to_runnable(p);
      }
      release(&ptable.lock);
      return 0;
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
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}

int jobs() {
  
  struct job *j;
  struct proc *p;
  int foundJobs = FALSE, isJobAlive = FALSE, liveJobIndex = 0;
    
  for (j = jtable.jobs ; j < &jtable.jobs[NPROC] ; j++ ) {
    isJobAlive = 0;
    for (p = ptable.proc ; p < &ptable.proc[NPROC] ; p++ ) {
      if (p->job->jid == j->jid && 				// If the process belongs to the job.
	  p->state != UNUSED					// If the process is alive.
	 ) {		
	if (isJobAlive == FALSE) {
	    cprintf("Job %d: %s \n", ++liveJobIndex, j->commandName);
	}
	
	cprintf("%d: %s\n", p->pid, p->name);
	
	isJobAlive = TRUE;
        foundJobs = TRUE;
      }
    }
   }
  
  if (foundJobs == FALSE) {
    cprintf("There are no Jobs\n");
  }
    
  return 1;
}

int fg(int jid) {
  
 struct job *j;
 struct proc *p;
 int jobExists = FALSE;
 
 if (jid == NULL) {
   for (j = jtable.jobs ; j < &jtable.jobs[NPROC] ; j++ )  {
     if (j->state != JOB_S_UNUSED && proc->job->jid != j->jid) {
       jid = j->state; 
       break;
     }
   }
 }
 
  for (p = ptable.proc ; p < &ptable.proc[NPROC] ; p++ )  {
    if (p->job->jid == jid) {
      jobExists = TRUE;
      waitpid(p->pid, NULL, BLOCKING);
    }
  }
  
  if (jobExists == FALSE) {
   cprintf("Could'nt find job - %d\n", jid); 
  }
  
 return 1; 
}


//----------------------------------------- helper functions ---------------
int get_current_ticks(void)
{
  uint xticks;
  
  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

void update_counters()
{
  struct proc *p;
  
  //acquire(&ptable.lock);
  for (p = ptable.proc ; p < &ptable.proc[NPROC] ; p++ )  {
    switch(p->state) {
      case RUNNING:
	p->rutime++;
	break;
      case SLEEPING:
	p->stime++;
	break;
      case RUNNABLE:
	p->retime++;
	break;
      default:
	//cprintf("ERROR update_counters - state: %d", proc->state);
	break;
    };
    //cprintf("RUN: %d, SLEEP: %d\n", p->rutime, p->stime);
  }
  //release(&ptable.lock);
}

//void update_sched_time_based_on_method(struct proc *cur_proc)
void on_state_set_to_runnable(struct proc *cur_proc)
{  
// cur_proc->sched_time = get_current_ticks();/* - BUGGGGGGGGGGGGGGGGG
#if SCHEDFLAG == DEFAULT
#elif SCHEDFLAG == FRR
  sched_q_enqueue(cur_proc->pid);
#elif SCHEDFLAG == FCFS
  sched_q_enqueue(cur_proc->pid);
#elif SCHEDFLAG == CFS  
#endif
  
  return;
}

void on_state_set_to_sleeping(struct proc *cur_proc)
{
  
#if SCHEDFLAG == DEFAULT
#elif SCHEDFLAG == FRR
#elif SCHEDFLAG == FCFS
  if ( cur_proc->pid == sched_q_peek() )
    sched_q_dequeue();
#elif SCHEDFLAG == CFS
#endif
  //cur_proc->sched_time = get_current_ticks();
  return;
}

void on_state_set_to_zombi(struct proc *cur_proc)
{
  
#if SCHEDFLAG == DEFAULT
#elif SCHEDFLAG == FRR
#elif SCHEDFLAG == FCFS
  if ( cur_proc->pid == sched_q_peek() )
    sched_q_dequeue();
#elif SCHEDFLAG == CFS
#endif
  //cur_proc->sched_time = get_current_ticks();
  return;
}


void on_state_set_to_running(struct proc *cur_proc)
{ 
#if SCHEDFLAG == DEFAULT
#elif SCHEDFLAG == FRR
#elif SCHEDFLAG == FCFS
#elif SCHEDFLAG == CFS
#endif
  //cur_proc->sched_time = get_current_ticks();
  return;
}


//----------------QUEUE-----------

void sched_q_enqueue(int pid)
{
  //struct runnable_queue_entry *p;
  if((front==0&&rear==NPROC-1)||(front==rear+1)) {                         //condition for full Queue
    panic("Queue is overflow\n");
  }
  if(front==-1) {
    front=rear=0;
  } else {
    
    if(rear==NPROC-1) {
      rear=0;
    } else {
      rear++;
    }
    
  }
  scheduler_queue.queue[rear].pid = pid;
  cprintf("%d succ. inserted\n",pid);
  return;
}
int sched_q_dequeue(void)
{
  int y;
  if(front==-1) {
    cprintf("q is underflow\n");
    return 0;
  }
  y=scheduler_queue.queue[front].pid;
  if(front==rear) {
    front=rear=-1;
  } else {
    if(front==NPROC-1) {
      front=0;
    } else {
      front++;
    }
  }
  cprintf("%d succ. deleted\n",y);
  return y;
}

void sched_q_display(void)
{
  int i;
  if(front==-1 && rear==-1) {
    cprintf("q is empty\n");return;
  }
  cprintf("elements are :\n");
  for(i=front;i!=rear;i=(i+1)%NPROC) {
    cprintf("%d ",scheduler_queue.queue[i]);
  }
  cprintf("%d\n",scheduler_queue.queue[rear]);
  return; 
}
int sched_q_peek(void)
{
  int y;
  y=scheduler_queue.queue[front].pid;
  cprintf("%d peeked (not deleted)\n",y);
  return y;
}
