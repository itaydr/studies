#include "types.h"
#include "user.h"

#include "hoare_slots_monitor.h"

/*
typedef struct hoare_slots_monitor {
  hoare_cond seats_avaliable;
  hoare_cond all_seats_taken;
  int seats;
  int is_done_flag;
  int monitor_mutex;
} hoare_slots_monitor_t;
*/

hoare_slots_monitor_t* hoare_slots_monitor_alloc() {
  hoare_slots_monitor_t* monitor = (hoare_slots_monitor_t*) malloc(sizeof(hoare_slots_monitor_t));
   
  if (0 == monitor) {
    goto cleanup;
  }
  
  if ((int)(monitor->seats_avaliable= hoare_cond_alloc()) == -1){
    goto cleanup;
  }
  
  if ((int)(monitor->all_seats_taken= hoare_cond_alloc()) == -1){
    goto cleanup;
  }
  
  if( (int)(monitor->monitor_mutex = kthread_mutex_alloc()) == -1){
    goto cleanup;
  }
  
  monitor->seats = 0;
  monitor->is_done_flag = 0;
  
  return monitor;
  
cleanup:
  if (monitor && -1 != monitor->monitor_mutex) {
    kthread_mutex_dealloc(monitor->monitor_mutex);
  }
  if (monitor && -1 != (int)monitor->seats_avaliable) {
    hoare_cond_dealloc(monitor->seats_avaliable);
  }
  if (monitor && -1 != (int)monitor->all_seats_taken) {
    hoare_cond_dealloc(monitor->all_seats_taken);
  }
  if (monitor) {
    free(monitor);
  }
  
  return 0;
}

int hoare_slots_monitor_dealloc(hoare_slots_monitor_t* monitor) {  
  int temp;
  
  if ( 0 == monitor ) {
    return -1;
  }
  
  kthread_mutex_lock(monitor->monitor_mutex);
  if ( 0 == monitor->is_done_flag ) {
    kthread_mutex_unlock(monitor->monitor_mutex);
    return -1;
  }
  
  hoare_cond_dealloc(monitor->seats_avaliable);
  hoare_cond_dealloc(monitor->all_seats_taken);
  
  temp = monitor->monitor_mutex;
  
  free(monitor);
  
  kthread_mutex_unlock(temp);
  kthread_mutex_dealloc(temp);
  
  return 0;
}

int hoare_slots_monitor_addslots(hoare_slots_monitor_t* monitor,int seats) {
  // called by the grader only
  kthread_mutex_lock(monitor->monitor_mutex);
    
  if (1 == monitor->is_done_flag) {
    kthread_mutex_unlock(monitor->monitor_mutex);
    return 0;
  }
  
  if (monitor->seats > 0) {
    hoare_cond_wait(monitor->all_seats_taken, monitor->monitor_mutex);
  } 
  
  if (0 == monitor->is_done_flag) {
    monitor->seats += seats;
  } else {
    kthread_mutex_unlock(monitor->monitor_mutex);
    return 0;
  }
  
  hoare_cond_signal(monitor->seats_avaliable, monitor->monitor_mutex);
    
  kthread_mutex_unlock(monitor->monitor_mutex);
  return 0;
}

int hoare_slots_monitor_takeslot(hoare_slots_monitor_t* monitor) {
  kthread_mutex_lock(monitor->monitor_mutex);
  if ( 0 == monitor->seats) {
    hoare_cond_wait(monitor->seats_avaliable, monitor->monitor_mutex);
  } 
  
  --monitor->seats;

  if ( 0 == monitor->seats) {
    hoare_cond_signal(monitor->all_seats_taken, monitor->monitor_mutex);
  } else {
    hoare_cond_signal(monitor->seats_avaliable, monitor->monitor_mutex);
  }
  kthread_mutex_unlock(monitor->monitor_mutex);
  
  return 0;
}

int hoare_slots_monitor_stopadding(hoare_slots_monitor_t* monitor) {
  kthread_mutex_lock(monitor->monitor_mutex);
  
  monitor->is_done_flag = 1;
  hoare_cond_signal(monitor->all_seats_taken, monitor->monitor_mutex);
  
  kthread_mutex_unlock(monitor->monitor_mutex);
  return 0;
}