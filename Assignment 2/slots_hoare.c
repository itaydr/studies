#include "types.h"
#include "user.h"
#include "hoare_slots_monitor.h"
#define USER_MODE_STACK_SIZE 4000

hoare_slots_monitor_t* hoare_monitor;
int slots_cycle;
void * student() {
  if ( 0 != hoare_slots_monitor_takeslot(hoare_monitor)) {
    printf(1, "Failed to take seat!\n");
  } else {
    printf(1, "Seat taken :)\n");
  }
  kthread_exit();
  return (void*)0;
}

void * grader() {
  while( 0 == hoare_monitor->is_done_flag ) {
    if ( -1 == hoare_slots_monitor_addslots( hoare_monitor ,slots_cycle) ){
      printf(1, "Grader failed to add seats!\n");
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
  int number_of_students = 20;
  int* students_array;
  int* students_stacks;
  int graders_tid;
  
  slots_cycle = 6;
  
  students_array = (int*)malloc(number_of_students * sizeof (int));
  students_stacks = (int*)malloc(number_of_students * sizeof (int));
  grader_stack = (void*)malloc(USER_MODE_STACK_SIZE);
  
  
  
  hoare_monitor = hoare_slots_monitor_alloc();
  
  graders_tid = kthread_create(grader, grader_stack, USER_MODE_STACK_SIZE);	// create grader
  
  for( i= 0 ; i < number_of_students; i++ ) {
    students_stacks[i] = (int)malloc(USER_MODE_STACK_SIZE);
    students_array[i] = kthread_create(student, (void*)students_stacks[i], USER_MODE_STACK_SIZE);
    printf(2,"student number %d created\n", students_array[i]);
  }
  
  for( i= 0 ; i < number_of_students; i++ ) {
    kthread_join(students_array[i]);
    free((void*)students_stacks[i]);
    printf(2,"student number %d finished\n", students_array[i]);
  }
  
  hoare_slots_monitor_stopadding(hoare_monitor);
  
  kthread_join(graders_tid);
  free(grader_stack);
  printf(2,"Done!\n");
  
  hoare_slots_monitor_dealloc(hoare_monitor);
  
  exit();
}
