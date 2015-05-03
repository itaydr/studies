#include "types.h"
#include "stat.h"
#include "user.h"

void * thread1 (void){
	printf(1, "I am thread %d\n", kthread_id());
	//kthread_mutex_lock(lock);
	//kthread_cond_wait(cond, lock);
	//printf(1, "im came alive!! %d\n", kthread_id());
	//kthread_mutex_unlock(lock);
	kthread_exit();
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
	//lock = kthread_mutex_alloc();
	//cond = kthread_cond_alloc();
	int i = 0;
	char *res;
	for (i = 0 ; i < 20 ; i ++) {
	  res = sbrk(500);
	  printf(2, "SBRK = %s\n", res);
	}
	
	
	return 0;
	int  tid;
	void* stack;// =malloc(4000);
	for(i = 0; i< 20; i++){
		stack =malloc(4000);
		tid = kthread_create(thread1,stack,4000);
		tid = tid;
		//kthread_join(tid);
		printf(1,"Woke up!! %d", kthread_id());
	}
	
// 	for(i = 0; i< 20; i++){
// 		stack =malloc(4000);
// 		kthread_create(thread2,stack,4000);
// 	}
	
	
	exit();
	//return (void *) 0;
}
