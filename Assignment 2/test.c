#include "types.h"
#include "stat.h"
#include "user.h"

int mid;


void * 
thread1() {
  int res;
  printf(2,"Thread exec - %d\n", kthread_id());
  res = kthread_mutex_lock(mid);
  printf(2,"Thread locked - %d with response - %d\n", kthread_id(), res);
  res = kthread_mutex_unlock(mid);
  printf(2,"Thread unlocked - %d with response - %d\n", kthread_id(),res);
  
  
  kthread_exit();
  
  return (void *) 0;
}

int
main(int argc, char *argv[])
{
  int i, tid;
  void* stack;
  
  mid = kthread_mutex_alloc();
  
  for(i = 1; i < 10; i++){
    stack = (void*)malloc(4000);
    tid = kthread_create(thread1, stack, 4000);
    printf(2,"Created thread - %d\n", tid);
  }
  
  printf(1,"main thread sleep\n");
//   sleep(1000);
  printf(1,"main thread wokeup\n");
  i = kthread_mutex_dealloc(mid);
  printf(1,"main thread dealloc with response %d\n", i);
  
  exit();
}
