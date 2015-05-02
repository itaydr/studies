#include "types.h"
#include "stat.h"
#include "user.h"

int 
main(int argc, char *argv[])
{

  if (argc == 1) {
    fg(NULL); 
  }
  else if (argc == 2){
    fg(atoi(argv[1]));
  }
  else {
    printf(1, "Too much arguments for FG."); 
  }
  
  exit(EXIT_STATUS_OK);
}