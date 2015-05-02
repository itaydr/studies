#include "types.h"
#include "user.h"

int main(int argc, char *argv[])
{
  int i = 0;
  int j = 0;
  //for ( i = 0; i < 1000000; i++ ) {
    for(;;){
      for ( i = 0; i < 1000000; i++ ) {
	i = i;
      }
      //sleep(1);
    j=2;
    j = j;
    //printf(1, "2: %d",i);
  }
  printf(1, "2\n");
  exit(0);
}