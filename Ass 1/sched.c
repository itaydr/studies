#define DEFAULT 1
#define FRR 2
#define FCFS 3
#define CFS 4

#if SCHEDFLAG == DEFAULT
cprintf("SCHEDFLAG == DEFAULT\n");
for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
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

#elif SCHEDFLAG == FRR
cprintf("SCHEDFLAG == FRR\n");
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


#elif SCHEDFLAG == FCFS
cprintf("SCHEDFLAG == FCFS\n");
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

cprintf("choose to switch to: %s\n", selected_p->name);
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


#elif SCHEDFLAG == CFS
cprintf("SCHEDFLAG == CFS\n");


#endif