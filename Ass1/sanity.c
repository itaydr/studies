#include "types.h"
#include "stat.h"
#include "user.h"

int 
main(int argc, char *argv[])
{

  int numOfProcs = 20,i,status, wtime, rtime, iotime, pid;
  int initial_ticks = 0;
  long j,dummy;
  double temp = 0.5;
  int avgW=0, avgR=0, avgTurnaroundTime=0;
  
  set_priority(P_HIGH);
  
  for (i = 0 ; i < numOfProcs ; i++ ) {
    if (fork() == 0) {
      
      set_priority(((i % 3) + 1) * P_HIGH);
      
      initial_ticks = uptime();
      // Check if this is 30 ticks
      for (j = 1 ; ; j++) {
	 dummy = temp * 2;
	 dummy = dummy;
	 temp++;
	 temp--;
	 if ( initial_ticks + 30 < uptime() ){
	   break;
	 }
      }
      
      exit(getpid());
      printf(1, "Should never get here\n");
      break;
    }
  }
  
  for (i = 0 ; i < numOfProcs; i++) {
     pid = wait_stat(&status, &wtime, &rtime, &iotime);
     
     if (pid != status) {
       printf(3,"Bad status -%d for process with id %d\n", status, pid);
     }
     
     printf(1, "Pid:%d, priority: %d) Wait Time = %d, Running Time = %d, Turnaround Time = %d.\n", status, ((i % 3) + 1) * P_HIGH, wtime, rtime, (wtime + rtime + iotime));
     avgW += wtime;
     avgR += rtime;
     avgTurnaroundTime += (wtime + rtime + iotime);
  }
  
  avgW = avgW / numOfProcs;
  avgR = avgR / numOfProcs;
  avgTurnaroundTime = avgTurnaroundTime / numOfProcs;
  
  printf(1,"Averages - Wait=%d, Running=%d, Turnaround=%d .\n", avgW, avgR, avgTurnaroundTime);
  
  exit(EXIT_STATUS_OK);
}