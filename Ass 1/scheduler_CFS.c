void scheduler(void)
{
  struct proc *p;
  
  struct proc *selected_p = NULL;
  selected_p = selected_p;
  
  cprintf("LOADED SCHEDFLAG == CFS\n");
  
  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    //cprintf("test1111\n");
    acquire(&ptable.lock);
    //cprintf("test2222\n");
    //#include "sched.c"
    
    
    
    release(&ptable.lock);

  }
}
