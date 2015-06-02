#include "types.h"
#include "stat.h"
#include "user.h"

#define KB (1024)
#define PGSIZE (4*KB)

#define KERNBASE 0x80000000         // First kernel virtual address

int infinite_rec() {
  int i = 0;
  i = infinite_rec();
  printf(1, "infinite_rec %d\n",i);
  return -1;
}

int
main(int argc, char *argv[])
{
  char* str;
  
  printf(1,"doing malloc of %d\n", 400*KB*KB);
  str = (char*)malloc(400*KB*KB);
  printf(1,"malloc returned: %d\n", str);
  printf(1,"after malloc of %d\n", 400*KB*KB);
  printf(1,"writing to posision %x\n", &str[400*KB*KB-90]);
  memmove(&str[400*KB*KB-90], "hello world",12);
  printf(1,"%s\n", &str[400*KB*KB-90]);
  printf(1,"writing to posision %x\n", &str[300*KB*KB-90]);
  memmove(&str[300*KB*KB-90], "hello world",12);
  printf(1,"%s\n", &str[300*KB*KB-90]);
  printf(1,"writing to posision %x\n", &str[200*KB*KB-90]);
  memmove(&str[200*KB*KB-90], "hello world",12);
  printf(1,"%s\n", &str[200*KB*KB-90]);
  printf(1,"writing to posision %x\n", &str[100*KB*KB-90]);
  memmove(&str[100*KB*KB-90], "hello world",12);
  printf(1,"%s\n", &str[100*KB*KB-90]);

  // try to malloc up to the KERNEL
  printf(1,"malloc up to kernel (KERNBASE-400*KB*KB) returned: ");
  printf(1,"%d\n", malloc(0x80000000-400*KB*KB));
  
  printf(1,"checking stack bouderies with infinite recursion. should never return...\n");
  infinite_rec();
  
  exit();
}
