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

	sbrk(32768);
	
	exit();
}
