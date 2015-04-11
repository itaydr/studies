void scheduler(void)
{
  struct proc *p;
  
  cprintf("LOADED SCHEDFLAG == DEFAULT\n");
  
  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    //cprintf("test1111\n");
    acquire(&ptable.lock);
    //cprintf("test2222\n");
    
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
       // cprintf("LOOP %d !\n", p->pid);
      }
    release(&ptable.lock);
  }
}
