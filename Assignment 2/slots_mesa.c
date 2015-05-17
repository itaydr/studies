#include "types.h"
#include "user.h"
#include "mesa_slots_monitor.h"
#define USER_MODE_STACK_SIZE 4000

int m;
mesa_slots_monitor_t* mesa_monitor;
int slots_cycle;

void print(char* str) {
  kthread_mutex_lock(m);
  printf(1, str);
  kthread_mutex_unlock(m);
}

void * student() {
//   char a[500];
//   gets(a, 100);
   printf(1,"========================================= student going for the shit: %d  \n",kthread_id());  
  
  if ( 0 != mesa_slots_monitor_takeslot(mesa_monitor)) {
//     print("Failed to take seat!\n");
  } else {
//     print("Seat taken :)\n");
  }
  
  kthread_exit();
  return (void*)0;
}

void * grader() {
  while( 0 == mesa_monitor->is_done_flag ) {
    if ( -1 == mesa_slots_monitor_addslots( mesa_monitor ,slots_cycle) ){
      print("Grader failed to add seats!\n");
    } else {
      if (0 == mesa_monitor->is_done_flag){
	print("Grader added seats!\n");
      }
    }
    print("LP!\n");
  }
  print("grader_out_of_while!\n");
  kthread_exit();
  return (void*)0;
}


int
main(int argc, char **argv)
{
  void* grader_stack;
  int i;
  int number_of_students = 10;
  int* students_array;
  int* students_stacks;
  int graders_tid;
  int zain;
  
  slots_cycle = 6;
  m = kthread_mutex_alloc();
  
  students_array = (int*)malloc(number_of_students * sizeof (int));
  students_stacks = (int*)malloc(number_of_students * sizeof (int));
  grader_stack = (void*)malloc(USER_MODE_STACK_SIZE);
  
  
  
  mesa_monitor = mesa_slots_monitor_alloc();
  
  graders_tid = kthread_create(grader, grader_stack, USER_MODE_STACK_SIZE);	// create grader
  
  for( i= 0 ; i < number_of_students; i++ ) {
    students_stacks[i] = (int)malloc(USER_MODE_STACK_SIZE);
    zain = kthread_create(student, (void*)students_stacks[i], USER_MODE_STACK_SIZE);
//     kthread_join(zain);
    printf(2,"creted thread: %d created\n", zain);    
    students_array[i] = zain;
    
//     printf(2,"student number %d created\n", students_array[i]);
  }
  
  for( i= 0 ; i < number_of_students; i++ ) {
    zain = students_array[i];
    printf(2,"going to join on thread: %d created\n", students_array[i]);
    kthread_join(zain);
    free((void*)students_stacks[i]);
//      printf(2,"student number %d finished\n", students_array[i]);
  }
  
  printf(2,"Done! b\n");
  mesa_slots_monitor_stopadding(mesa_monitor);
  printf(2,"Done!c - main: %d, grader: %d\n", kthread_id(), graders_tid);
  kthread_join(graders_tid);

  free(grader_stack);
  
  printf(2,"Done!d\n");
  mesa_slots_monitor_dealloc(mesa_monitor);

  kthread_mutex_dealloc(m);
  exit();
}
