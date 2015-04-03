
_GLOBAL_TEST:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
int pid;
int status;
int npid;

if (!(pid = fork()))
   9:	e8 fa 02 00 00       	call   308 <fork>
   e:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  12:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  17:	75 0c                	jne    25 <main+0x25>
{
exit(0x7f);
  19:	c7 04 24 7f 00 00 00 	movl   $0x7f,(%esp)
  20:	e8 eb 02 00 00       	call   310 <exit>
}
else
{
npid =  wait(&status);
  25:	8d 44 24 14          	lea    0x14(%esp),%eax
  29:	89 04 24             	mov    %eax,(%esp)
  2c:	e8 e7 02 00 00       	call   318 <wait>
  31:	89 44 24 18          	mov    %eax,0x18(%esp)
printf(2, "status = %d\n", status);
  35:	8b 44 24 14          	mov    0x14(%esp),%eax
  39:	89 44 24 08          	mov    %eax,0x8(%esp)
  3d:	c7 44 24 04 4b 08 00 	movl   $0x84b,0x4(%esp)
  44:	00 
  45:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  4c:	e8 36 04 00 00       	call   487 <printf>
printf(2, "pid = %d\n", npid);
  51:	8b 44 24 18          	mov    0x18(%esp),%eax
  55:	89 44 24 08          	mov    %eax,0x8(%esp)
  59:	c7 44 24 04 58 08 00 	movl   $0x858,0x4(%esp)
  60:	00 
  61:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  68:	e8 1a 04 00 00       	call   487 <printf>
  
}
if (status == 0x7f)
  6d:	8b 44 24 14          	mov    0x14(%esp),%eax
  71:	83 f8 7f             	cmp    $0x7f,%eax
  74:	75 16                	jne    8c <main+0x8c>
{
printf(1, "OK\n");
  76:	c7 44 24 04 62 08 00 	movl   $0x862,0x4(%esp)
  7d:	00 
  7e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  85:	e8 fd 03 00 00       	call   487 <printf>
  8a:	eb 14                	jmp    a0 <main+0xa0>
}
else
{
printf(1, "FAILED\n");
  8c:	c7 44 24 04 66 08 00 	movl   $0x866,0x4(%esp)
  93:	00 
  94:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  9b:	e8 e7 03 00 00       	call   487 <printf>
}
exit(700);
  a0:	c7 04 24 bc 02 00 00 	movl   $0x2bc,(%esp)
  a7:	e8 64 02 00 00       	call   310 <exit>

000000ac <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  ac:	55                   	push   %ebp
  ad:	89 e5                	mov    %esp,%ebp
  af:	57                   	push   %edi
  b0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  b4:	8b 55 10             	mov    0x10(%ebp),%edx
  b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  ba:	89 cb                	mov    %ecx,%ebx
  bc:	89 df                	mov    %ebx,%edi
  be:	89 d1                	mov    %edx,%ecx
  c0:	fc                   	cld    
  c1:	f3 aa                	rep stos %al,%es:(%edi)
  c3:	89 ca                	mov    %ecx,%edx
  c5:	89 fb                	mov    %edi,%ebx
  c7:	89 5d 08             	mov    %ebx,0x8(%ebp)
  ca:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  cd:	5b                   	pop    %ebx
  ce:	5f                   	pop    %edi
  cf:	5d                   	pop    %ebp
  d0:	c3                   	ret    

000000d1 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  d1:	55                   	push   %ebp
  d2:	89 e5                	mov    %esp,%ebp
  d4:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  d7:	8b 45 08             	mov    0x8(%ebp),%eax
  da:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  dd:	90                   	nop
  de:	8b 45 0c             	mov    0xc(%ebp),%eax
  e1:	0f b6 10             	movzbl (%eax),%edx
  e4:	8b 45 08             	mov    0x8(%ebp),%eax
  e7:	88 10                	mov    %dl,(%eax)
  e9:	8b 45 08             	mov    0x8(%ebp),%eax
  ec:	0f b6 00             	movzbl (%eax),%eax
  ef:	84 c0                	test   %al,%al
  f1:	0f 95 c0             	setne  %al
  f4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  f8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  fc:	84 c0                	test   %al,%al
  fe:	75 de                	jne    de <strcpy+0xd>
    ;
  return os;
 100:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 103:	c9                   	leave  
 104:	c3                   	ret    

00000105 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 105:	55                   	push   %ebp
 106:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 108:	eb 08                	jmp    112 <strcmp+0xd>
    p++, q++;
 10a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 10e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 112:	8b 45 08             	mov    0x8(%ebp),%eax
 115:	0f b6 00             	movzbl (%eax),%eax
 118:	84 c0                	test   %al,%al
 11a:	74 10                	je     12c <strcmp+0x27>
 11c:	8b 45 08             	mov    0x8(%ebp),%eax
 11f:	0f b6 10             	movzbl (%eax),%edx
 122:	8b 45 0c             	mov    0xc(%ebp),%eax
 125:	0f b6 00             	movzbl (%eax),%eax
 128:	38 c2                	cmp    %al,%dl
 12a:	74 de                	je     10a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 12c:	8b 45 08             	mov    0x8(%ebp),%eax
 12f:	0f b6 00             	movzbl (%eax),%eax
 132:	0f b6 d0             	movzbl %al,%edx
 135:	8b 45 0c             	mov    0xc(%ebp),%eax
 138:	0f b6 00             	movzbl (%eax),%eax
 13b:	0f b6 c0             	movzbl %al,%eax
 13e:	89 d1                	mov    %edx,%ecx
 140:	29 c1                	sub    %eax,%ecx
 142:	89 c8                	mov    %ecx,%eax
}
 144:	5d                   	pop    %ebp
 145:	c3                   	ret    

00000146 <strlen>:

uint
strlen(char *s)
{
 146:	55                   	push   %ebp
 147:	89 e5                	mov    %esp,%ebp
 149:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 14c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 153:	eb 04                	jmp    159 <strlen+0x13>
 155:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 159:	8b 45 fc             	mov    -0x4(%ebp),%eax
 15c:	03 45 08             	add    0x8(%ebp),%eax
 15f:	0f b6 00             	movzbl (%eax),%eax
 162:	84 c0                	test   %al,%al
 164:	75 ef                	jne    155 <strlen+0xf>
    ;
  return n;
 166:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 169:	c9                   	leave  
 16a:	c3                   	ret    

0000016b <memset>:

void*
memset(void *dst, int c, uint n)
{
 16b:	55                   	push   %ebp
 16c:	89 e5                	mov    %esp,%ebp
 16e:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 171:	8b 45 10             	mov    0x10(%ebp),%eax
 174:	89 44 24 08          	mov    %eax,0x8(%esp)
 178:	8b 45 0c             	mov    0xc(%ebp),%eax
 17b:	89 44 24 04          	mov    %eax,0x4(%esp)
 17f:	8b 45 08             	mov    0x8(%ebp),%eax
 182:	89 04 24             	mov    %eax,(%esp)
 185:	e8 22 ff ff ff       	call   ac <stosb>
  return dst;
 18a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 18d:	c9                   	leave  
 18e:	c3                   	ret    

0000018f <strchr>:

char*
strchr(const char *s, char c)
{
 18f:	55                   	push   %ebp
 190:	89 e5                	mov    %esp,%ebp
 192:	83 ec 04             	sub    $0x4,%esp
 195:	8b 45 0c             	mov    0xc(%ebp),%eax
 198:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 19b:	eb 14                	jmp    1b1 <strchr+0x22>
    if(*s == c)
 19d:	8b 45 08             	mov    0x8(%ebp),%eax
 1a0:	0f b6 00             	movzbl (%eax),%eax
 1a3:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1a6:	75 05                	jne    1ad <strchr+0x1e>
      return (char*)s;
 1a8:	8b 45 08             	mov    0x8(%ebp),%eax
 1ab:	eb 13                	jmp    1c0 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1ad:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1b1:	8b 45 08             	mov    0x8(%ebp),%eax
 1b4:	0f b6 00             	movzbl (%eax),%eax
 1b7:	84 c0                	test   %al,%al
 1b9:	75 e2                	jne    19d <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1c0:	c9                   	leave  
 1c1:	c3                   	ret    

000001c2 <gets>:

char*
gets(char *buf, int max)
{
 1c2:	55                   	push   %ebp
 1c3:	89 e5                	mov    %esp,%ebp
 1c5:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1cf:	eb 44                	jmp    215 <gets+0x53>
    cc = read(0, &c, 1);
 1d1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 1d8:	00 
 1d9:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1dc:	89 44 24 04          	mov    %eax,0x4(%esp)
 1e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1e7:	e8 3c 01 00 00       	call   328 <read>
 1ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1ef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1f3:	7e 2d                	jle    222 <gets+0x60>
      break;
    buf[i++] = c;
 1f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f8:	03 45 08             	add    0x8(%ebp),%eax
 1fb:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 1ff:	88 10                	mov    %dl,(%eax)
 201:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 205:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 209:	3c 0a                	cmp    $0xa,%al
 20b:	74 16                	je     223 <gets+0x61>
 20d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 211:	3c 0d                	cmp    $0xd,%al
 213:	74 0e                	je     223 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 215:	8b 45 f4             	mov    -0xc(%ebp),%eax
 218:	83 c0 01             	add    $0x1,%eax
 21b:	3b 45 0c             	cmp    0xc(%ebp),%eax
 21e:	7c b1                	jl     1d1 <gets+0xf>
 220:	eb 01                	jmp    223 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 222:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 223:	8b 45 f4             	mov    -0xc(%ebp),%eax
 226:	03 45 08             	add    0x8(%ebp),%eax
 229:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 22c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 22f:	c9                   	leave  
 230:	c3                   	ret    

00000231 <stat>:

int
stat(char *n, struct stat *st)
{
 231:	55                   	push   %ebp
 232:	89 e5                	mov    %esp,%ebp
 234:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 237:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 23e:	00 
 23f:	8b 45 08             	mov    0x8(%ebp),%eax
 242:	89 04 24             	mov    %eax,(%esp)
 245:	e8 06 01 00 00       	call   350 <open>
 24a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 24d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 251:	79 07                	jns    25a <stat+0x29>
    return -1;
 253:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 258:	eb 23                	jmp    27d <stat+0x4c>
  r = fstat(fd, st);
 25a:	8b 45 0c             	mov    0xc(%ebp),%eax
 25d:	89 44 24 04          	mov    %eax,0x4(%esp)
 261:	8b 45 f4             	mov    -0xc(%ebp),%eax
 264:	89 04 24             	mov    %eax,(%esp)
 267:	e8 fc 00 00 00       	call   368 <fstat>
 26c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 26f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 272:	89 04 24             	mov    %eax,(%esp)
 275:	e8 be 00 00 00       	call   338 <close>
  return r;
 27a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 27d:	c9                   	leave  
 27e:	c3                   	ret    

0000027f <atoi>:

int
atoi(const char *s)
{
 27f:	55                   	push   %ebp
 280:	89 e5                	mov    %esp,%ebp
 282:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 285:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 28c:	eb 23                	jmp    2b1 <atoi+0x32>
    n = n*10 + *s++ - '0';
 28e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 291:	89 d0                	mov    %edx,%eax
 293:	c1 e0 02             	shl    $0x2,%eax
 296:	01 d0                	add    %edx,%eax
 298:	01 c0                	add    %eax,%eax
 29a:	89 c2                	mov    %eax,%edx
 29c:	8b 45 08             	mov    0x8(%ebp),%eax
 29f:	0f b6 00             	movzbl (%eax),%eax
 2a2:	0f be c0             	movsbl %al,%eax
 2a5:	01 d0                	add    %edx,%eax
 2a7:	83 e8 30             	sub    $0x30,%eax
 2aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
 2ad:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2b1:	8b 45 08             	mov    0x8(%ebp),%eax
 2b4:	0f b6 00             	movzbl (%eax),%eax
 2b7:	3c 2f                	cmp    $0x2f,%al
 2b9:	7e 0a                	jle    2c5 <atoi+0x46>
 2bb:	8b 45 08             	mov    0x8(%ebp),%eax
 2be:	0f b6 00             	movzbl (%eax),%eax
 2c1:	3c 39                	cmp    $0x39,%al
 2c3:	7e c9                	jle    28e <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2c8:	c9                   	leave  
 2c9:	c3                   	ret    

000002ca <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2ca:	55                   	push   %ebp
 2cb:	89 e5                	mov    %esp,%ebp
 2cd:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2d0:	8b 45 08             	mov    0x8(%ebp),%eax
 2d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2dc:	eb 13                	jmp    2f1 <memmove+0x27>
    *dst++ = *src++;
 2de:	8b 45 f8             	mov    -0x8(%ebp),%eax
 2e1:	0f b6 10             	movzbl (%eax),%edx
 2e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2e7:	88 10                	mov    %dl,(%eax)
 2e9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2ed:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 2f5:	0f 9f c0             	setg   %al
 2f8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 2fc:	84 c0                	test   %al,%al
 2fe:	75 de                	jne    2de <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 300:	8b 45 08             	mov    0x8(%ebp),%eax
}
 303:	c9                   	leave  
 304:	c3                   	ret    
 305:	90                   	nop
 306:	90                   	nop
 307:	90                   	nop

00000308 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 308:	b8 01 00 00 00       	mov    $0x1,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <exit>:
SYSCALL(exit)
 310:	b8 02 00 00 00       	mov    $0x2,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <wait>:
SYSCALL(wait)
 318:	b8 03 00 00 00       	mov    $0x3,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <pipe>:
SYSCALL(pipe)
 320:	b8 04 00 00 00       	mov    $0x4,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <read>:
SYSCALL(read)
 328:	b8 05 00 00 00       	mov    $0x5,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <write>:
SYSCALL(write)
 330:	b8 10 00 00 00       	mov    $0x10,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <close>:
SYSCALL(close)
 338:	b8 15 00 00 00       	mov    $0x15,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <kill>:
SYSCALL(kill)
 340:	b8 06 00 00 00       	mov    $0x6,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <exec>:
SYSCALL(exec)
 348:	b8 07 00 00 00       	mov    $0x7,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <open>:
SYSCALL(open)
 350:	b8 0f 00 00 00       	mov    $0xf,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <mknod>:
SYSCALL(mknod)
 358:	b8 11 00 00 00       	mov    $0x11,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <unlink>:
SYSCALL(unlink)
 360:	b8 12 00 00 00       	mov    $0x12,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <fstat>:
SYSCALL(fstat)
 368:	b8 08 00 00 00       	mov    $0x8,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <link>:
SYSCALL(link)
 370:	b8 13 00 00 00       	mov    $0x13,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <mkdir>:
SYSCALL(mkdir)
 378:	b8 14 00 00 00       	mov    $0x14,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <chdir>:
SYSCALL(chdir)
 380:	b8 09 00 00 00       	mov    $0x9,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <dup>:
SYSCALL(dup)
 388:	b8 0a 00 00 00       	mov    $0xa,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <getpid>:
SYSCALL(getpid)
 390:	b8 0b 00 00 00       	mov    $0xb,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <sbrk>:
SYSCALL(sbrk)
 398:	b8 0c 00 00 00       	mov    $0xc,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <sleep>:
SYSCALL(sleep)
 3a0:	b8 0d 00 00 00       	mov    $0xd,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <uptime>:
SYSCALL(uptime)
 3a8:	b8 0e 00 00 00       	mov    $0xe,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3b0:	55                   	push   %ebp
 3b1:	89 e5                	mov    %esp,%ebp
 3b3:	83 ec 28             	sub    $0x28,%esp
 3b6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b9:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3bc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3c3:	00 
 3c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3c7:	89 44 24 04          	mov    %eax,0x4(%esp)
 3cb:	8b 45 08             	mov    0x8(%ebp),%eax
 3ce:	89 04 24             	mov    %eax,(%esp)
 3d1:	e8 5a ff ff ff       	call   330 <write>
}
 3d6:	c9                   	leave  
 3d7:	c3                   	ret    

000003d8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3d8:	55                   	push   %ebp
 3d9:	89 e5                	mov    %esp,%ebp
 3db:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3de:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3e5:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3e9:	74 17                	je     402 <printint+0x2a>
 3eb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3ef:	79 11                	jns    402 <printint+0x2a>
    neg = 1;
 3f1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3f8:	8b 45 0c             	mov    0xc(%ebp),%eax
 3fb:	f7 d8                	neg    %eax
 3fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
 400:	eb 06                	jmp    408 <printint+0x30>
  } else {
    x = xx;
 402:	8b 45 0c             	mov    0xc(%ebp),%eax
 405:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 408:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 40f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 412:	8b 45 ec             	mov    -0x14(%ebp),%eax
 415:	ba 00 00 00 00       	mov    $0x0,%edx
 41a:	f7 f1                	div    %ecx
 41c:	89 d0                	mov    %edx,%eax
 41e:	0f b6 90 b4 0a 00 00 	movzbl 0xab4(%eax),%edx
 425:	8d 45 dc             	lea    -0x24(%ebp),%eax
 428:	03 45 f4             	add    -0xc(%ebp),%eax
 42b:	88 10                	mov    %dl,(%eax)
 42d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 431:	8b 55 10             	mov    0x10(%ebp),%edx
 434:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 437:	8b 45 ec             	mov    -0x14(%ebp),%eax
 43a:	ba 00 00 00 00       	mov    $0x0,%edx
 43f:	f7 75 d4             	divl   -0x2c(%ebp)
 442:	89 45 ec             	mov    %eax,-0x14(%ebp)
 445:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 449:	75 c4                	jne    40f <printint+0x37>
  if(neg)
 44b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 44f:	74 2a                	je     47b <printint+0xa3>
    buf[i++] = '-';
 451:	8d 45 dc             	lea    -0x24(%ebp),%eax
 454:	03 45 f4             	add    -0xc(%ebp),%eax
 457:	c6 00 2d             	movb   $0x2d,(%eax)
 45a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 45e:	eb 1b                	jmp    47b <printint+0xa3>
    putc(fd, buf[i]);
 460:	8d 45 dc             	lea    -0x24(%ebp),%eax
 463:	03 45 f4             	add    -0xc(%ebp),%eax
 466:	0f b6 00             	movzbl (%eax),%eax
 469:	0f be c0             	movsbl %al,%eax
 46c:	89 44 24 04          	mov    %eax,0x4(%esp)
 470:	8b 45 08             	mov    0x8(%ebp),%eax
 473:	89 04 24             	mov    %eax,(%esp)
 476:	e8 35 ff ff ff       	call   3b0 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 47b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 47f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 483:	79 db                	jns    460 <printint+0x88>
    putc(fd, buf[i]);
}
 485:	c9                   	leave  
 486:	c3                   	ret    

00000487 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 487:	55                   	push   %ebp
 488:	89 e5                	mov    %esp,%ebp
 48a:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 48d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 494:	8d 45 0c             	lea    0xc(%ebp),%eax
 497:	83 c0 04             	add    $0x4,%eax
 49a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 49d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4a4:	e9 7d 01 00 00       	jmp    626 <printf+0x19f>
    c = fmt[i] & 0xff;
 4a9:	8b 55 0c             	mov    0xc(%ebp),%edx
 4ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4af:	01 d0                	add    %edx,%eax
 4b1:	0f b6 00             	movzbl (%eax),%eax
 4b4:	0f be c0             	movsbl %al,%eax
 4b7:	25 ff 00 00 00       	and    $0xff,%eax
 4bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4bf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4c3:	75 2c                	jne    4f1 <printf+0x6a>
      if(c == '%'){
 4c5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4c9:	75 0c                	jne    4d7 <printf+0x50>
        state = '%';
 4cb:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4d2:	e9 4b 01 00 00       	jmp    622 <printf+0x19b>
      } else {
        putc(fd, c);
 4d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4da:	0f be c0             	movsbl %al,%eax
 4dd:	89 44 24 04          	mov    %eax,0x4(%esp)
 4e1:	8b 45 08             	mov    0x8(%ebp),%eax
 4e4:	89 04 24             	mov    %eax,(%esp)
 4e7:	e8 c4 fe ff ff       	call   3b0 <putc>
 4ec:	e9 31 01 00 00       	jmp    622 <printf+0x19b>
      }
    } else if(state == '%'){
 4f1:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4f5:	0f 85 27 01 00 00    	jne    622 <printf+0x19b>
      if(c == 'd'){
 4fb:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4ff:	75 2d                	jne    52e <printf+0xa7>
        printint(fd, *ap, 10, 1);
 501:	8b 45 e8             	mov    -0x18(%ebp),%eax
 504:	8b 00                	mov    (%eax),%eax
 506:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 50d:	00 
 50e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 515:	00 
 516:	89 44 24 04          	mov    %eax,0x4(%esp)
 51a:	8b 45 08             	mov    0x8(%ebp),%eax
 51d:	89 04 24             	mov    %eax,(%esp)
 520:	e8 b3 fe ff ff       	call   3d8 <printint>
        ap++;
 525:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 529:	e9 ed 00 00 00       	jmp    61b <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 52e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 532:	74 06                	je     53a <printf+0xb3>
 534:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 538:	75 2d                	jne    567 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 53a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 53d:	8b 00                	mov    (%eax),%eax
 53f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 546:	00 
 547:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 54e:	00 
 54f:	89 44 24 04          	mov    %eax,0x4(%esp)
 553:	8b 45 08             	mov    0x8(%ebp),%eax
 556:	89 04 24             	mov    %eax,(%esp)
 559:	e8 7a fe ff ff       	call   3d8 <printint>
        ap++;
 55e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 562:	e9 b4 00 00 00       	jmp    61b <printf+0x194>
      } else if(c == 's'){
 567:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 56b:	75 46                	jne    5b3 <printf+0x12c>
        s = (char*)*ap;
 56d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 570:	8b 00                	mov    (%eax),%eax
 572:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 575:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 579:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 57d:	75 27                	jne    5a6 <printf+0x11f>
          s = "(null)";
 57f:	c7 45 f4 6e 08 00 00 	movl   $0x86e,-0xc(%ebp)
        while(*s != 0){
 586:	eb 1e                	jmp    5a6 <printf+0x11f>
          putc(fd, *s);
 588:	8b 45 f4             	mov    -0xc(%ebp),%eax
 58b:	0f b6 00             	movzbl (%eax),%eax
 58e:	0f be c0             	movsbl %al,%eax
 591:	89 44 24 04          	mov    %eax,0x4(%esp)
 595:	8b 45 08             	mov    0x8(%ebp),%eax
 598:	89 04 24             	mov    %eax,(%esp)
 59b:	e8 10 fe ff ff       	call   3b0 <putc>
          s++;
 5a0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 5a4:	eb 01                	jmp    5a7 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5a6:	90                   	nop
 5a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5aa:	0f b6 00             	movzbl (%eax),%eax
 5ad:	84 c0                	test   %al,%al
 5af:	75 d7                	jne    588 <printf+0x101>
 5b1:	eb 68                	jmp    61b <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5b3:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5b7:	75 1d                	jne    5d6 <printf+0x14f>
        putc(fd, *ap);
 5b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5bc:	8b 00                	mov    (%eax),%eax
 5be:	0f be c0             	movsbl %al,%eax
 5c1:	89 44 24 04          	mov    %eax,0x4(%esp)
 5c5:	8b 45 08             	mov    0x8(%ebp),%eax
 5c8:	89 04 24             	mov    %eax,(%esp)
 5cb:	e8 e0 fd ff ff       	call   3b0 <putc>
        ap++;
 5d0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5d4:	eb 45                	jmp    61b <printf+0x194>
      } else if(c == '%'){
 5d6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5da:	75 17                	jne    5f3 <printf+0x16c>
        putc(fd, c);
 5dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5df:	0f be c0             	movsbl %al,%eax
 5e2:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e6:	8b 45 08             	mov    0x8(%ebp),%eax
 5e9:	89 04 24             	mov    %eax,(%esp)
 5ec:	e8 bf fd ff ff       	call   3b0 <putc>
 5f1:	eb 28                	jmp    61b <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5f3:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5fa:	00 
 5fb:	8b 45 08             	mov    0x8(%ebp),%eax
 5fe:	89 04 24             	mov    %eax,(%esp)
 601:	e8 aa fd ff ff       	call   3b0 <putc>
        putc(fd, c);
 606:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 609:	0f be c0             	movsbl %al,%eax
 60c:	89 44 24 04          	mov    %eax,0x4(%esp)
 610:	8b 45 08             	mov    0x8(%ebp),%eax
 613:	89 04 24             	mov    %eax,(%esp)
 616:	e8 95 fd ff ff       	call   3b0 <putc>
      }
      state = 0;
 61b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 622:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 626:	8b 55 0c             	mov    0xc(%ebp),%edx
 629:	8b 45 f0             	mov    -0x10(%ebp),%eax
 62c:	01 d0                	add    %edx,%eax
 62e:	0f b6 00             	movzbl (%eax),%eax
 631:	84 c0                	test   %al,%al
 633:	0f 85 70 fe ff ff    	jne    4a9 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 639:	c9                   	leave  
 63a:	c3                   	ret    
 63b:	90                   	nop

0000063c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 63c:	55                   	push   %ebp
 63d:	89 e5                	mov    %esp,%ebp
 63f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 642:	8b 45 08             	mov    0x8(%ebp),%eax
 645:	83 e8 08             	sub    $0x8,%eax
 648:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 64b:	a1 d0 0a 00 00       	mov    0xad0,%eax
 650:	89 45 fc             	mov    %eax,-0x4(%ebp)
 653:	eb 24                	jmp    679 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 655:	8b 45 fc             	mov    -0x4(%ebp),%eax
 658:	8b 00                	mov    (%eax),%eax
 65a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 65d:	77 12                	ja     671 <free+0x35>
 65f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 662:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 665:	77 24                	ja     68b <free+0x4f>
 667:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66a:	8b 00                	mov    (%eax),%eax
 66c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 66f:	77 1a                	ja     68b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 671:	8b 45 fc             	mov    -0x4(%ebp),%eax
 674:	8b 00                	mov    (%eax),%eax
 676:	89 45 fc             	mov    %eax,-0x4(%ebp)
 679:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 67f:	76 d4                	jbe    655 <free+0x19>
 681:	8b 45 fc             	mov    -0x4(%ebp),%eax
 684:	8b 00                	mov    (%eax),%eax
 686:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 689:	76 ca                	jbe    655 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 68b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68e:	8b 40 04             	mov    0x4(%eax),%eax
 691:	c1 e0 03             	shl    $0x3,%eax
 694:	89 c2                	mov    %eax,%edx
 696:	03 55 f8             	add    -0x8(%ebp),%edx
 699:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69c:	8b 00                	mov    (%eax),%eax
 69e:	39 c2                	cmp    %eax,%edx
 6a0:	75 24                	jne    6c6 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 6a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a5:	8b 50 04             	mov    0x4(%eax),%edx
 6a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ab:	8b 00                	mov    (%eax),%eax
 6ad:	8b 40 04             	mov    0x4(%eax),%eax
 6b0:	01 c2                	add    %eax,%edx
 6b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b5:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bb:	8b 00                	mov    (%eax),%eax
 6bd:	8b 10                	mov    (%eax),%edx
 6bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c2:	89 10                	mov    %edx,(%eax)
 6c4:	eb 0a                	jmp    6d0 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 6c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c9:	8b 10                	mov    (%eax),%edx
 6cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ce:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d3:	8b 40 04             	mov    0x4(%eax),%eax
 6d6:	c1 e0 03             	shl    $0x3,%eax
 6d9:	03 45 fc             	add    -0x4(%ebp),%eax
 6dc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6df:	75 20                	jne    701 <free+0xc5>
    p->s.size += bp->s.size;
 6e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e4:	8b 50 04             	mov    0x4(%eax),%edx
 6e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ea:	8b 40 04             	mov    0x4(%eax),%eax
 6ed:	01 c2                	add    %eax,%edx
 6ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f2:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f8:	8b 10                	mov    (%eax),%edx
 6fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fd:	89 10                	mov    %edx,(%eax)
 6ff:	eb 08                	jmp    709 <free+0xcd>
  } else
    p->s.ptr = bp;
 701:	8b 45 fc             	mov    -0x4(%ebp),%eax
 704:	8b 55 f8             	mov    -0x8(%ebp),%edx
 707:	89 10                	mov    %edx,(%eax)
  freep = p;
 709:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70c:	a3 d0 0a 00 00       	mov    %eax,0xad0
}
 711:	c9                   	leave  
 712:	c3                   	ret    

00000713 <morecore>:

static Header*
morecore(uint nu)
{
 713:	55                   	push   %ebp
 714:	89 e5                	mov    %esp,%ebp
 716:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 719:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 720:	77 07                	ja     729 <morecore+0x16>
    nu = 4096;
 722:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 729:	8b 45 08             	mov    0x8(%ebp),%eax
 72c:	c1 e0 03             	shl    $0x3,%eax
 72f:	89 04 24             	mov    %eax,(%esp)
 732:	e8 61 fc ff ff       	call   398 <sbrk>
 737:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 73a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 73e:	75 07                	jne    747 <morecore+0x34>
    return 0;
 740:	b8 00 00 00 00       	mov    $0x0,%eax
 745:	eb 22                	jmp    769 <morecore+0x56>
  hp = (Header*)p;
 747:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 74d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 750:	8b 55 08             	mov    0x8(%ebp),%edx
 753:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 756:	8b 45 f0             	mov    -0x10(%ebp),%eax
 759:	83 c0 08             	add    $0x8,%eax
 75c:	89 04 24             	mov    %eax,(%esp)
 75f:	e8 d8 fe ff ff       	call   63c <free>
  return freep;
 764:	a1 d0 0a 00 00       	mov    0xad0,%eax
}
 769:	c9                   	leave  
 76a:	c3                   	ret    

0000076b <malloc>:

void*
malloc(uint nbytes)
{
 76b:	55                   	push   %ebp
 76c:	89 e5                	mov    %esp,%ebp
 76e:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 771:	8b 45 08             	mov    0x8(%ebp),%eax
 774:	83 c0 07             	add    $0x7,%eax
 777:	c1 e8 03             	shr    $0x3,%eax
 77a:	83 c0 01             	add    $0x1,%eax
 77d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 780:	a1 d0 0a 00 00       	mov    0xad0,%eax
 785:	89 45 f0             	mov    %eax,-0x10(%ebp)
 788:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 78c:	75 23                	jne    7b1 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 78e:	c7 45 f0 c8 0a 00 00 	movl   $0xac8,-0x10(%ebp)
 795:	8b 45 f0             	mov    -0x10(%ebp),%eax
 798:	a3 d0 0a 00 00       	mov    %eax,0xad0
 79d:	a1 d0 0a 00 00       	mov    0xad0,%eax
 7a2:	a3 c8 0a 00 00       	mov    %eax,0xac8
    base.s.size = 0;
 7a7:	c7 05 cc 0a 00 00 00 	movl   $0x0,0xacc
 7ae:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b4:	8b 00                	mov    (%eax),%eax
 7b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bc:	8b 40 04             	mov    0x4(%eax),%eax
 7bf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7c2:	72 4d                	jb     811 <malloc+0xa6>
      if(p->s.size == nunits)
 7c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c7:	8b 40 04             	mov    0x4(%eax),%eax
 7ca:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7cd:	75 0c                	jne    7db <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d2:	8b 10                	mov    (%eax),%edx
 7d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d7:	89 10                	mov    %edx,(%eax)
 7d9:	eb 26                	jmp    801 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7de:	8b 40 04             	mov    0x4(%eax),%eax
 7e1:	89 c2                	mov    %eax,%edx
 7e3:	2b 55 ec             	sub    -0x14(%ebp),%edx
 7e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ef:	8b 40 04             	mov    0x4(%eax),%eax
 7f2:	c1 e0 03             	shl    $0x3,%eax
 7f5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7fb:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7fe:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 801:	8b 45 f0             	mov    -0x10(%ebp),%eax
 804:	a3 d0 0a 00 00       	mov    %eax,0xad0
      return (void*)(p + 1);
 809:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80c:	83 c0 08             	add    $0x8,%eax
 80f:	eb 38                	jmp    849 <malloc+0xde>
    }
    if(p == freep)
 811:	a1 d0 0a 00 00       	mov    0xad0,%eax
 816:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 819:	75 1b                	jne    836 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 81b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 81e:	89 04 24             	mov    %eax,(%esp)
 821:	e8 ed fe ff ff       	call   713 <morecore>
 826:	89 45 f4             	mov    %eax,-0xc(%ebp)
 829:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 82d:	75 07                	jne    836 <malloc+0xcb>
        return 0;
 82f:	b8 00 00 00 00       	mov    $0x0,%eax
 834:	eb 13                	jmp    849 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 836:	8b 45 f4             	mov    -0xc(%ebp),%eax
 839:	89 45 f0             	mov    %eax,-0x10(%ebp)
 83c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83f:	8b 00                	mov    (%eax),%eax
 841:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 844:	e9 70 ff ff ff       	jmp    7b9 <malloc+0x4e>
}
 849:	c9                   	leave  
 84a:	c3                   	ret    
