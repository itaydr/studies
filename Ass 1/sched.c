#define DEFAULT 1
#define FRR 2
#define FCFS 3
#define CFS 4

#if SCHEDFLAG == DEFAULT

for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
	
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
      swtch(&cpu->scheduler, proc->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
      cprintf("LOOP %d !\n", p->pid);
}

#elif SCHEDFLAG == FRR



#elif SCHEDFLAG == FCFS



#elif SCHEDFLAG == CFS



#endif