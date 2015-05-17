#include "types.h"
#include "user.h"

#include "mesa_cond.h"

mesa_cond_t* mesa_cond_alloc() {
  mesa_cond_t* mesa_cv = (mesa_cond_t*) malloc( sizeof(mesa_cond_t));
  
  mesa_cv->mutexId = kthread_mutex_alloc();
  if ( -1 ==mesa_cv->mutexId  || (mesa_cv->counts_mutex = kthread_mutex_alloc()) == -1) {
    if (-1 != mesa_cv->mutexId) {
      kthread_mutex_dealloc(mesa_cv->mutexId);
    }
    free(mesa_cv);
    return 0;
  }

  mesa_cv->counts = 0;
  kthread_mutex_lock(mesa_cv->mutexId);
  
  return mesa_cv;
}

int mesa_cond_dealloc(mesa_cond_t* mesa_cv) {
  if ( 0 == mesa_cv ) {
    return -1;
  }
  int temp;
  kthread_mutex_lock(mesa_cv->counts_mutex);
  if ( mesa_cv->counts == 0 ) {
    kthread_mutex_unlock(mesa_cv->mutexId);
    kthread_mutex_dealloc(mesa_cv->mutexId);
    temp = mesa_cv->counts_mutex;
    free(mesa_cv);
    kthread_mutex_unlock(temp);
    kthread_mutex_dealloc(temp);
    return 0;
  } else {
    kthread_mutex_unlock(mesa_cv->counts_mutex);
    return -1;
  }
}
int mesa_cond_wait(mesa_cond_t* mesa_cv, int monitor_mutex) {
  if ( 0 == mesa_cv ) {
    return -1;
  }
  
  kthread_mutex_lock(mesa_cv->counts_mutex);
  ++mesa_cv->counts;
  
  kthread_mutex_unlock(monitor_mutex);
  kthread_mutex_unlock(mesa_cv->counts_mutex);
  
  kthread_mutex_lock(mesa_cv->mutexId);
  kthread_mutex_lock(monitor_mutex);
  kthread_mutex_yieldlock(mesa_cv->mutexId, mesa_cv->mutexId);
  
  kthread_mutex_lock(mesa_cv->counts_mutex);
  --mesa_cv->counts;
  kthread_mutex_unlock(mesa_cv->counts_mutex);
  return 0;
}
int mesa_cond_signal(mesa_cond_t* mesa_cv) {
  if ( 0 == mesa_cv ) {
    return -1;
  }
  
  kthread_mutex_lock(mesa_cv->counts_mutex);
  if ( mesa_cv->counts > 0 ) {
    kthread_mutex_unlock(mesa_cv->mutexId);
  }
  
  kthread_mutex_unlock(mesa_cv->counts_mutex);
  
  return 0;
}