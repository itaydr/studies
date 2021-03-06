#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
  return fork();
}

int
sys_forkjob(void)
{
  char* command;
  argptr(0, (char**) &command, sizeof(char*));
  
  return forkjob(command);
}

int
sys_exit()
{
  int status;
  argint(0, &status);
  //cprintf("enterted: sys_exit, %d\n", status);
  exit(status);
  return 0;  // not reached
}

int
sys_wait(void)
{
  int* status;
  argptr(0, (char**) &status, sizeof(int*));
  return wait(status);
}


int
sys_waitpid(void)
{
  int 	pid;
  int* 	status;
  int 	options;
  
  argint(0, &pid);
  argptr(1, (char**) &status, sizeof(int*));
  argint(2, &options);
  
  cprintf("inside sys_waitpid => waiting for pid = %d, options = %d\n", pid, options );
  
  return waitpid(pid, status, options);
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return proc->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = proc->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(proc->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;
  
  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

int sys_jobs(void) {
  jobs();
   return 3;
}

int sys_fg(void) {
 
  int jid;
  argint(0, &jid);
  fg(jid);
  
  return 1;
}

int sys_wait_stat(void) {
 
  int *status, *wtime, *rtime, *iotime;
 
  argptr(0, (char**) &status, sizeof(int*));
  argptr(1, (char**) &wtime, sizeof(int*));
  argptr(2, (char**) &rtime, sizeof(int*));
  argptr(3, (char**) &iotime, sizeof(int*));
  
  wait_stat(status, wtime, rtime, iotime);
  
  return 1;
}

int sys_set_priority(void) {
    int priority;
    argint(0, &priority);
    
    if (priority != P_HIGH && priority != P_MED && priority != P_LOW) {
      cprintf("Cannot set priority %d, please use one of the given priorities\n", priority); 
    }
    else {
      proc->priority = priority;
    }
    
    
    
    return 1;
}
