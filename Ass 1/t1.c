#include "types.h"
#include "user.h"

int main(int argc, char *argv[])
{
  int i = 0;
  int j = 0;
  for ( i = 0; i < 1000000; i++ ) {
    //for (;;){
    
    j=1;
    j = j;
    //printf(1, "1: %d",i);
  }
  
  printf(1, "1\n");
  exit(0);
}