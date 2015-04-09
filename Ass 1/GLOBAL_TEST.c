#include "types.h"
#include "user.h"
#include "sched.c"

void print_nonsense(void){

  printf(1, "a\n");
}

int
main(int argc, char *argv[])
{
	int wtime, rtime, iotime;
	int i;							//uncomment to check runnning time (1)
	int x = 0;

#ifdef SCHEDFLAG
	
	printf(1,"sdvsd %d", XX);
	exit(1);
#endif
	
	x = uptime();
	printf(1, "%d\n", x);
	if(fork() == 0){
		sleep(100);
		for(i=0; i<=5000; i++)		//uncomment to check runnning time (2)
			i=i;//print_nonsense();			//uncomment to check runnning time (3)
		//char buf[3];					//uncomment to check sleeping time (1)
		//printf(1, "Enter a sole char (any char) and press enter: (the longer you wait, the bigger sleeping time will be)\n");		//uncomment to check sleeping time (2)
		//read(0, buf, 3);				//uncomment to check sleeping time (3)
		exit(0);
	}
	wait_stat(&wtime, &rtime, &iotime);
	x = uptime();
	printf(1, "%d\n", x);	
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