#include "types.h"
#include "user.h"

void print_nonsense(void){

  printf(1, "a\n");
}

int
main(int argc, char *argv[])
{
	int status, wtime, rtime, iotime;						//uncomment to check runnning time (1)
	
	//for (;;)
	//printf(2, "pid - %d\n", getpid());
	
	set_priority(P_LOW);
	
	wait_stat(&status, &wtime, &rtime, &iotime);
	printf(2, "ready (runnable) time is: %d\n", wtime);
	printf(2, "running time is: %d\n", rtime);
	printf(2, "sleeping (waiting for io) time is: %d\n", iotime);
	exit(0);
}

/*

#include "types.h"
#include "user.h"

int
main(int argc, char *argv[])
{
int pid;
int w,r,io;
int npid = 0;
npid = npid;

if (!(pid = fork()))
{
  printf(1, "intermediate child\n");
  if (!(pid = fork())) {
    printf(1,"child getting to sleep 500\n");
    sleep(500); 
    printf(1,"child getting out from sleep 500, exit (123)\n");
  } else {
    printf(1, "intermediate child is going to die\n");
  }

  
  exit(123);
}
else
{
  
   printf(1, "parent waiting for child %d\n", pid);
   wait_stat(&w,&r,&io);
   printf(1, "Stats: w:%d r:%d io:%d\n", w,r,io);
}
exit(4444);
}

*/