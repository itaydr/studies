#include "types.h"
#include "stat.h"
#include "user.h"

#include "hoare_slots_monitor.h"

int
main(int argc, char *argv[])
{
//   hoare_slots_monitor_t* b = hoare_slots_monitor_alloc();
//   printf(1,"this is a fucking test!   %d", b->is_done_flag);
  
//   printf(1,"\n\n%d\n\n", hoare_slots_monitor_dealloc(b));
  int m1 = kthread_mutex_alloc();
  int m2 = kthread_mutex_alloc();
  
  kthread_mutex_lock(m1);
  kthread_mutex_lock(m2);
  kthread_mutex_lock(m1);

  exit();
}
