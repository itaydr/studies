#include "types.h"
#include "user.h"

#include "mesa_slots_monitor.h"

/*
typedef struct mesa_slots_monitor {
  mesa_cond_t *seats_avaliable;
  mesa_cond_t *all_seats_taken;
  int seats;
  int is_done_flag;
  int monitor_mutex;
} mesa_slots_monitor_t;
*/

mesa_slots_monitor_t* mesa_slots_monitor_alloc() {
  mesa_slots_monitor_t* monitor = (mesa_slots_monitor_t*) malloc(sizeof(mesa_slots_monitor_t));
//    mesa_cond_t * temp;
  if (0 == monitor) {
    goto cleanup;
  }
  
  if ((int)(monitor->seats_avaliable= mesa_cond_alloc()) == -1){
    goto cleanup;
  }
  
  if ((int)(monitor->all_seats_taken= mesa_cond_alloc()) == -1){
    goto cleanup;
  }
  
  if( (int)(monitor->monitor_mutex = kthread_mutex_alloc()) == -1){
    goto cleanup;
  }
  /*
  temp = monitor->seats_avaliable;
  printf("\n\n\t\t seats_avaliable: %d", temp->mutexId);
  temp = monitor->all_seats_taken;
  printf("\tall_seats_taken: %d", temp->mutexId);
  printf(", \t monitor mutex: %d\n\n", monitor.monitor_mutex);
  */
  monitor->seats = 0;
  monitor->is_done_flag = 0;
  
  return monitor;
  
cleanup:
  if (monitor && -1 != monitor->monitor_mutex) {
    kthread_mutex_dealloc(monitor->monitor_mutex);
  }
  if (monitor && -1 != (int)monitor->seats_avaliable) {
    mesa_cond_dealloc(monitor->seats_avaliable);
  }
  if (monitor && -1 != (int)monitor->all_seats_taken) {
    mesa_cond_dealloc(monitor->all_seats_taken);
  }
  if (monitor) {
    free(monitor);
  }
  
  return 0;
}

int mesa_slots_monitor_dealloc(mesa_slots_monitor_t* monitor) {  
  int temp;
  
  if ( 0 == monitor ) {
    return -1;
  }
  
  kthread_mutex_lock(monitor->monitor_mutex);
  if ( 0 == monitor->is_done_flag ) {
    kthread_mutex_unlock(monitor->monitor_mutex);
    return -1;
  }
  
  mesa_cond_dealloc(monitor->seats_avaliable);
  mesa_cond_dealloc(monitor->all_seats_taken);
  
  temp = monitor->monitor_mutex;
  
  free(monitor);
  
  kthread_mutex_unlock(temp);
  kthread_mutex_dealloc(temp);
  
  return 0;
}

int mesa_slots_monitor_addslots(mesa_slots_monitor_t* monitor,int seats) {
  // called by the grader only
  kthread_mutex_lock(monitor->monitor_mutex);
    
  if (1 == monitor->is_done_flag) {
    kthread_mutex_unlock(monitor->monitor_mutex);
    return 0;
  }
  
  while (0 == monitor->is_done_flag && monitor->seats > 0) {
    mesa_cond_wait(monitor->all_seats_taken, monitor->monitor_mutex);
  } 
  
  if (0 == monitor->is_done_flag) {
    monitor->seats += seats;
  } else {
    kthread_mutex_unlock(monitor->monitor_mutex);
    return 0;
  }
  
  mesa_cond_signal(monitor->seats_avaliable);
    
  kthread_mutex_unlock(monitor->monitor_mutex);
  return 0;
}

int mesa_slots_monitor_takeslot(mesa_slots_monitor_t* monitor) {
  kthread_mutex_lock(monitor->monitor_mutex);
  while ( 0 == monitor->seats) {
    mesa_cond_wait(monitor->seats_avaliable, monitor->monitor_mutex);
  } 
  
  --monitor->seats;
  
  if ( 0 == monitor->seats) {
    mesa_cond_signal(monitor->all_seats_taken);
  } else {
    mesa_cond_signal(monitor->seats_avaliable);
  }
  kthread_mutex_unlock(monitor->monitor_mutex);
  
  return 0;
}

int mesa_slots_monitor_stopadding(mesa_slots_monitor_t* monitor) {
  kthread_mutex_lock(monitor->monitor_mutex);
  
  monitor->is_done_flag = 1;
  mesa_cond_signal(monitor->all_seats_taken);
  
  kthread_mutex_unlock(monitor->monitor_mutex);
  return 0;
}