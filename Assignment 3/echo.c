#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
  int i;
  
//   char* str;
  
  printf(1,"echo started\n");
  for(i = 1; i < argc; i++)
    printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
  
  /*
  printf(1,"doing malloc\n");
  str = (char*)malloc(400*1024*1024);
  printf(1,"after malloc\n");
  memmove(&str[400*1024*1024-90], "hello world",12);
  printf(1,"%s\n", &str[400*1024*1024-90]);
  */
  
  exit();
}
