#include "types.h"
#include "user.h"
#include "hoare_slots_monitor.h"
#define USER_MODE_STACK_SIZE 4000

int m;
hoare_slots_monitor_t* hoare_monitor;
int slots_cycle;

void print(char* str) {
  kthread_mutex_lock(m);
  printf(1, str);
  kthread_mutex_unlock(m);
}

void * student() {
  
  if ( 0 != hoare_slots_monitor_takeslot(hoare_monitor)) {
  } 
  
  sleep(50);
  kthread_exit();
  return (void*)0;
}

void * grader() {
  while( 0 == hoare_monitor->is_done_flag ) {
    if ( -1 == hoare_slots_monitor_addslots( hoare_monitor ,slots_cycle) ){
    } else {
      if (0 == hoare_monitor->is_done_flag){
      }
    }
  }
  kthread_exit();
  return (void*)0;
}


int
main(int argc, char **argv)
{
  void* grader_stack;
  int i;
  int number_of_students = 12;
  int* students_array;
  int* students_stacks;
  int graders_tid;
  
    
  if(argc < 4){
    printf(2, "usage: -m <student> -n <slots>\n");
    exit();
  }
  for(i=1; i<argc; i++) {
    if (strcmp(argv[i], "m") == 0) {
      number_of_students = atoi(argv[i+1]);
    }
    
    if (strcmp(argv[i], "n") == 0) {
      slots_cycle = atoi(argv[i+1]);
    }
  }
  
  printf(1,"stu: %d, slots: %d\n", number_of_students, slots_cycle);
  
//   slots_cycle = 1;
  m = kthread_mutex_alloc();
  
  students_array = (int*)malloc(number_of_students * sizeof (int));
  students_stacks = (int*)malloc(number_of_students * sizeof (int));
  grader_stack = (void*)malloc(USER_MODE_STACK_SIZE);
  
  
  
  hoare_monitor = hoare_slots_monitor_alloc();
  
  graders_tid = kthread_create(grader, grader_stack, USER_MODE_STACK_SIZE);	// create grader
  
  for( i= 0 ; i < number_of_students; i++ ) {
    students_stacks[i] = (int)malloc(USER_MODE_STACK_SIZE);
    students_array[i] = kthread_create(student, (void*)students_stacks[i], USER_MODE_STACK_SIZE);
  }
  
  for( i= 0 ; i < number_of_students; i++ ) {
    kthread_join(students_array[i]);
    free((void*)students_stacks[i]);
  }
  
  hoare_slots_monitor_stopadding(hoare_monitor);
  kthread_join(graders_tid);

  free(grader_stack);
  
  hoare_slots_monitor_dealloc(hoare_monitor);

  kthread_mutex_dealloc(m);
  exit();
}
