#include "types.h"
#include "user.h"

#include "hoare_cond.h"

hoare_cond_t* hoare_cond_alloc() {
  hoare_cond_t* hoare_cv = (hoare_cond_t*) malloc( sizeof(hoare_cond_t));
  
  hoare_cv->mutexId = kthread_mutex_alloc();
  if ( -1 ==hoare_cv->mutexId  || (hoare_cv->counts_mutex = kthread_mutex_alloc()) == -1) {
    if (-1 != hoare_cv->mutexId) {
      kthread_mutex_dealloc(hoare_cv->mutexId);
    }
    free(hoare_cv);
    return 0;
  }

  hoare_cv->counts = 0;
  kthread_mutex_lock(hoare_cv->mutexId);
  
  return hoare_cv;
}

int hoare_cond_dealloc(hoare_cond_t* hoare_cv) {
  if ( 0 == hoare_cv ) {
    return -1;
  }
  int temp;
  kthread_mutex_lock(hoare_cv->counts_mutex);
  if ( hoare_cv->counts == 0 ) {
    kthread_mutex_unlock(hoare_cv->mutexId);
    kthread_mutex_dealloc(hoare_cv->mutexId);
    temp = hoare_cv->counts_mutex;
    free(hoare_cv);
    kthread_mutex_unlock(temp);
    kthread_mutex_dealloc(temp);
    return 0;
  } else {
    kthread_mutex_unlock(hoare_cv->counts_mutex);
    return -1;
  }  
}

int hoare_cond_wait(hoare_cond_t* hoare_cv, int monitor_mutex) {
  if ( 0 == hoare_cv ) {
    return -1;
  }
  
  kthread_mutex_lock(hoare_cv->counts_mutex);
  ++hoare_cv->counts;
  
  kthread_mutex_unlock(monitor_mutex);
  kthread_mutex_unlock(hoare_cv->counts_mutex);
  kthread_mutex_lock(hoare_cv->mutexId);
  kthread_mutex_yieldlock(hoare_cv->mutexId, hoare_cv->mutexId); // give up the lock
  
  kthread_mutex_lock(hoare_cv->counts_mutex);
  --hoare_cv->counts;
  kthread_mutex_unlock(hoare_cv->counts_mutex);
  return 0;
}

int hoare_cond_signal(hoare_cond_t* hoare_cv, int monitor_mutex) {
    if ( 0 == hoare_cv ) {
    return -1;
  }
  
  kthread_mutex_lock(hoare_cv->counts_mutex);
  
  if ( hoare_cv->counts > 0 ) {
    kthread_mutex_unlock(hoare_cv->counts_mutex);
    if ( -1 == kthread_mutex_yieldlock(monitor_mutex, hoare_cv->mutexId) ) {
      return -1;
    }

    kthread_mutex_lock(monitor_mutex);
  } else {
    kthread_mutex_unlock(hoare_cv->counts_mutex);
  }
  
  return 0;
}