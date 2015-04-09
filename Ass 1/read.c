#include "types.h"
#include "user.h"

int
main(int argc, char *argv[])
{
  char c = 0;
  
  read(0, &c, 1);
  while ( c != 'q' ) {
    printf(1, "%c", c);
    read(0, &c, 1);
  }

  return 0;
}