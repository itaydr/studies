#include "scheduler_cir_queue.h"

int front = -1;
int rear  = -1;
//int q[MAX_QUEUE_SIZE];
/*
void main(void)
{
     int c;
     clrscr();
     front=rear=-1;
     do
     {
          printf("1:insert\n2:deletion\n3:display\n4:exit\nenter choice:");
          scanf("%d",&c);
          switch(c)
          {
               case 1:enqueue();break;
               case 2:dequeue();break;
               case 3:qdisplay();break;
               case 4:printf("pgm ends\n");break;
               default:printf("wrong choice\n");break;
          }
     }while(c!=4);
     getch();
}*/
void sched_q_enqueue(int pid)
{
  struct runnable_queue_entry *p;
  if((front==0&&rear==MAX_QUEUE_SIZE-1)||(front==rear+1)) {                         //condition for full Queue
    panic("Queue is overflow\n");
  }
  if(front==-1) {
    front=rear=0;
  } else {
    
    if(rear==MAX_QUEUE_SIZE-1) {
      rear=0;
    } else {
      rear++;
    }
    
  }
  scheduler_queue.queue[rear]=pid;
  //printf("%d succ. inserted\n",pid);
  return;
}
int dequeue(void)
{
  int y;
  if(front==-1) {
    printf("q is underflow\n");
    return;
  }
  y=scheduler_queue.queue[front];
  if(front==rear) {
    front=rear=-1;
  } else {
    if(front==MAX_QUEUE_SIZE-1) {
      front=0;
    } else {
      front++;
    }
  }
  //printf("%d succ. deleted\n",y);
  return;
}

void qdisplay(void)
{
  int i;
  if(front==rear==-1) {
    printf("q is empty\n");return;
  }
  printf("elements are :\n");
  for(i=front;i!=rear;i=(i+1)%MAX_QUEUE_SIZE) {
    printf("%d\n",scheduler_queue.queue[i]);
  }
  printf("%d\n",scheduler_queue.queue[rear]);
  return; 
}