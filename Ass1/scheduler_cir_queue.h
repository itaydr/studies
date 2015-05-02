// entry in scheduler queue
#define MAX_QUEUE_SIZE 64

struct runnable_queue_entry {
  int pid;
  //int vruntime;
  //int valid_entry;
};

void sched_q_enqueue(int pid);
int  sched_q_dequeue(void);
//void sched_q_peek(void);
void sched_q_display(void);
