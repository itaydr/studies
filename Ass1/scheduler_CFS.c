void scheduler(void)
{
  struct proc *p;
  struct proc *chosen_p = NULL;
    
  //cprintf("LOADED SCHEDFLAG == CFS\n");
  
  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    //cprintf("test1111\n");
    acquire(&ptable.lock);
    //cprintf("test2222\n");
    
    chosen_p = NULL;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      //cprintf("process, running_time: %d sleeping_time: %d ready_time_time: %d\n", p->rutime, p->stime,p->retime);
        if(p->state != RUNNABLE)
            continue;
	//cprintf("RUNNABLE process, pid:%d      pri: %d  running_time: %d   vruntime: %d\n", p->pid, p->priority, p->rutime, (p->priority *p->rutime));
	if( NULL == chosen_p ) {
	  chosen_p = p;
	  continue;
	}
	
	if( (p->priority * p->rutime) <  (chosen_p->priority * chosen_p->rutime) ){
	  chosen_p = p;
	}	
    }
    
    if (chosen_p != NULL) {
      //cprintf("pid: %d WON!\n", chosen_p->pid );
        // Switch to chosen process.  It is the process's job
        // to release ptable.lock and then reacquire it
        // before jumping back to us.
        proc = chosen_p;
        switchuvm(chosen_p);
        chosen_p->state = RUNNING;
        on_state_set_to_running(chosen_p);
        swtch(&cpu->scheduler, proc->context);
        switchkvm();

        // Process is done running for now.
        // It should have changed its chosen_p->state before coming back.
        proc = 0;
        //cprintf("LOOP %d !\n", chosen_p->pid);
      }
    release(&ptable.lock);
  }
}