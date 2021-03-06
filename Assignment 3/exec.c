#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "defs.h"
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
  char *s, *last;
  int i, off;
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

//   cprintf("EXEC IS RUNNING!!!, path = %x\n", path);
  //cprintf("0	WTF!!!!!\n");
  
  begin_op();
  //cprintf("1	WTF!!!!!\n");
  if((ip = namei(path)) == 0){
    end_op();
    return -1;
  }
  //cprintf("2	WTF!!!!!\n");
  ilock(ip);
  //cprintf("3	WTF!!!!!\n");
  pgdir = 0;
//cprintf("\na\n");
  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
  if(elf.magic != ELF_MAGIC)
    goto bad;
//cprintf("\nb\n");
  if((pgdir = setupkvm()) == 0)
    goto bad;
//cprintf("\nc\n");
  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
  end_op();
  ip = 0;
//cprintf("\nd\n");
  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
//   cprintf("\n\n\ncurrent page of sz: %x\n", PGROUNDDOWN(sz));
  sz = PGROUNDUP(sz);
//   cprintf("\n\n\naddress to guard: %x\n\n\n", sz);
  // TASK2 create fake mapping to page guard
  proc->guardPage = sz;
  sz += 1*PGSIZE;
  if((sz = allocuvm(pgdir, sz, sz + 1*PGSIZE)) == 0) // Task2 alloc only 1 page
  //if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0) // Task2 alloc only 1 page
    goto bad;
  
  //clearpteuTask2(pgdir, (char*)(sz - 2*PGSIZE));
  //clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;
//   cprintf("\ninitial sp addr is: %x\n", sp);
//cprintf("\ne\n");
  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    //cprintf("\nbefore copyout\n");
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    //cprintf("\nafter copyout\n");
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
//cprintf("\nf\n");
  ustack[0] = 0xfffdeadf;  // fake return PC
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer
//cprintf("\ng\n");
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
//cprintf("\nh\n");
  // Save program name for debugging.
  for(last=s=path; *s; s++)
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
//cprintf("\ni\n");
  // Commit to the user image.
  oldpgdir = proc->pgdir;
  proc->pgdir = pgdir;
  proc->sz = sz;
  proc->tf->eip = elf.entry;  // main
  proc->tf->esp = sp;
  switchuvm(proc);
  //cprintf("\nj\n");
  freevm(oldpgdir);
  //cprintf("\nk\n");
//   cprintf("EXEC IS DONE!!!\n");
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
    iunlockput(ip);
    end_op();
  }
  return -1;
}
