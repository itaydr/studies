#include "types.h"
#include "user.h"

int
main(int argc, char *argv[])
{
int pid;
int status;
int npid;

if (!(pid = fork()))
{
exit(0x7f);
}
else
{
npid =  wait(&status);
printf(2, "status = %d\n", status);
printf(2, "pid = %d\n", npid);
  
}
if (status == 0x7f)
{
printf(1, "OK\n");
}
else
{
printf(1, "FAILED\n");
}
exit(0);
}