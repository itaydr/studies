#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
  //int i;

//  for(i = 1; i < argc; i++)
//    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  printf(1, "before fg");
  fg(2);
  printf(1, "afer fg");
  exit(EXIT_STATUS_OK);
    
   // return -3;
}
