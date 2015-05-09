#include "types.h"
#include "stat.h"
#include "user.h"

void * thread1 (void){
	//printf(1, "I am thread %d\n", kthread_id());
	//kthread_mutex_lock(lock);
	//kthread_cond_wait(cond, lock);
	//printf(1, "im came alive!! %d\n", kthread_id());
	//kthread_mutex_unlock(lock);
	printf(2, "thread going to sleep\n");
	sleep(500);// * kthread_id());
	//printf(2,"%d - usermode wakeup, going to kthread kill (tid = %d)\n", kthread_id(), kthread_id());
	printf(2, "done sleep\n");
	kthread_exit();
	printf(2, "%d - should not get here (tid = %d)\n", kthread_id(), kthread_id());
	return (void *) 0;
}

void * thread2 (void){
	//kthread_mutex_lock(lock);
	printf(1,"I will wake him up!! %d", kthread_id());
	//kthread_cond_signal(cond);
	kthread_exit();
	return (void *) 0;
}


int main(void){
  /*
  int i = 0;
  int status;void *stack ;
	for (;i<20;i++) {
	    stack = (void*)malloc(4000);

	  status = kthread_create(thread1, stack, 4000); 
	  printf(2,"Thread %d was created with status %d\n", i, status);
	}
	
	
	sleep(2000);
	
	printf(1,"\n\nAfter sleep \n\n\n");
	
	for (i = 0;i<20;i++) {
	   stack = (void*)malloc(4000);

	  status = kthread_create(thread1, stack, 4000); 
	  printf(2,"Thread %d was created with status %d\n", i, status);
	}
*/	
	void* stack = (void*)malloc(4000);

	printf(2, "creating thread\n");
	  kthread_create(thread1, stack, 4000); 
    printf(2, "main sleeps\n");
// 	  sleep(2000);
	  printf(2, "main alive\n");
	exit();
}
