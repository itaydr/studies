void scheduler(void)
{
  struct proc *p;
  int chosen_pid = 0;
  cprintf("LOADED SCHEDFLAG == FCFS\n");
  
  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    
    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
        if(p->state != RUNNABLE)
            continue;
	
	cprintf("-----------------------------\n");
	sched_q_display();
	cprintf("-----------------------------\n");
	
	chosen_pid = sched_q_peek();
	cprintf("chosen_pid is - %d\n", chosen_pid);
	
	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
	  if(p->pid != chosen_pid) {
	    continue;
	  } else {
	    break;
	  }
	}
	
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
    release(&ptable.lock);
  }
}
