#include "asm.h"
#include "memlayout.h"
#include "syscall.h"
#include "traps.h"

.globl EXEC_COPY_EXIT
EXEC_COPY_EXIT:
  pushl %eax
  pushl %eax
  movl $SYS_exit, %eax
  int $T_SYSCALL
  ret
  
.globl EXEC_COPY_EXIT_END
EXEC_COPY_EXIT_END:
