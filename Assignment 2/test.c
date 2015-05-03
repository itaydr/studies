#include "types.h"
#include "stat.h"
#include "user.h"

void *
test() {
  printf(1, "This is a test string\n"); 
    
  kthread_exit();
  return (void *)0;
}

void *
test2() {
  printf(1, "This is a test string\n"); 
    
  return (void *)0;
}

void *
test3() {
  printf(1, "This is a test string\n"); 
    
  return (void *)0;
}

int
main(int argc, char *argv[])
{
  int tid;
  void*(*f)(void);
  f = test;
  
  //(*f)();
  //printf(2, "f is - %p", f);
  
  printf(2,"Creating thread with func - %p\n", test);
  //printf(2,"func main is at - %p\n", main);
  //printf(2,"func test is at - %p\n", test);
  //printf(2,"func test2 is at - %p\n", test2);
  //printf(2,"func test3 is at - %p\n", test3);
  void* stack = malloc(4000);
  printf(2,"stack - %d\n", stack);
  tid = kthread_create(f, stack, 4000);
  printf(1, "TID = %d\n", tid); 
  kthread_join(tid);
  printf(1, "Joined = %d\n", tid); 
  exit();
}

