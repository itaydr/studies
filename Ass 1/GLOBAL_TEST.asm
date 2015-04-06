
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
   9:	e8 3e 03 00 00       	call   34c <fork>
   e:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  12:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  17:	75 40                	jne    59 <main+0x59>
{
  printf(2, "getting into sleep\n");
  19:	c7 44 24 04 9f 08 00 	movl   $0x89f,0x4(%esp)
  20:	00 
  21:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  28:	e8 ae 04 00 00       	call   4db <printf>
  sleep(500);
  2d:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
  34:	e8 ab 03 00 00       	call   3e4 <sleep>
  printf(2, "getting out from sleep\n");
  39:	c7 44 24 04 b3 08 00 	movl   $0x8b3,0x4(%esp)
  40:	00 
  41:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  48:	e8 8e 04 00 00       	call   4db <printf>
  exit(123);
  4d:	c7 04 24 7b 00 00 00 	movl   $0x7b,(%esp)
  54:	e8 fb 02 00 00       	call   354 <exit>
}
else
{
npid =  waitpid(pid, &status, NON_BLOCKING);
  59:	c7 44 24 08 65 00 00 	movl   $0x65,0x8(%esp)
  60:	00 
  61:	8d 44 24 14          	lea    0x14(%esp),%eax
  65:	89 44 24 04          	mov    %eax,0x4(%esp)
  69:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  6d:	89 04 24             	mov    %eax,(%esp)
  70:	e8 7f 03 00 00       	call   3f4 <waitpid>
  75:	89 44 24 18          	mov    %eax,0x18(%esp)
printf(2, "status = %d\n", status);
  79:	8b 44 24 14          	mov    0x14(%esp),%eax
  7d:	89 44 24 08          	mov    %eax,0x8(%esp)
  81:	c7 44 24 04 cb 08 00 	movl   $0x8cb,0x4(%esp)
  88:	00 
  89:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  90:	e8 46 04 00 00       	call   4db <printf>
printf(2, "pid = %d\n", npid);
  95:	8b 44 24 18          	mov    0x18(%esp),%eax
  99:	89 44 24 08          	mov    %eax,0x8(%esp)
  9d:	c7 44 24 04 d8 08 00 	movl   $0x8d8,0x4(%esp)
  a4:	00 
  a5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  ac:	e8 2a 04 00 00       	call   4db <printf>
  
}
if (status == 123)
  b1:	8b 44 24 14          	mov    0x14(%esp),%eax
  b5:	83 f8 7b             	cmp    $0x7b,%eax
  b8:	75 16                	jne    d0 <main+0xd0>
{
printf(1, "OK\n");
  ba:	c7 44 24 04 e2 08 00 	movl   $0x8e2,0x4(%esp)
  c1:	00 
  c2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c9:	e8 0d 04 00 00       	call   4db <printf>
  ce:	eb 14                	jmp    e4 <main+0xe4>
}
else
{
printf(1, "FAILED\n");
  d0:	c7 44 24 04 e6 08 00 	movl   $0x8e6,0x4(%esp)
  d7:	00 
  d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  df:	e8 f7 03 00 00       	call   4db <printf>
}
exit(4444);
  e4:	c7 04 24 5c 11 00 00 	movl   $0x115c,(%esp)
  eb:	e8 64 02 00 00       	call   354 <exit>

000000f0 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  f0:	55                   	push   %ebp
  f1:	89 e5                	mov    %esp,%ebp
  f3:	57                   	push   %edi
  f4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  f8:	8b 55 10             	mov    0x10(%ebp),%edx
  fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  fe:	89 cb                	mov    %ecx,%ebx
 100:	89 df                	mov    %ebx,%edi
 102:	89 d1                	mov    %edx,%ecx
 104:	fc                   	cld    
 105:	f3 aa                	rep stos %al,%es:(%edi)
 107:	89 ca                	mov    %ecx,%edx
 109:	89 fb                	mov    %edi,%ebx
 10b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 10e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 111:	5b                   	pop    %ebx
 112:	5f                   	pop    %edi
 113:	5d                   	pop    %ebp
 114:	c3                   	ret    

00000115 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 115:	55                   	push   %ebp
 116:	89 e5                	mov    %esp,%ebp
 118:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 11b:	8b 45 08             	mov    0x8(%ebp),%eax
 11e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 121:	90                   	nop
 122:	8b 45 0c             	mov    0xc(%ebp),%eax
 125:	0f b6 10             	movzbl (%eax),%edx
 128:	8b 45 08             	mov    0x8(%ebp),%eax
 12b:	88 10                	mov    %dl,(%eax)
 12d:	8b 45 08             	mov    0x8(%ebp),%eax
 130:	0f b6 00             	movzbl (%eax),%eax
 133:	84 c0                	test   %al,%al
 135:	0f 95 c0             	setne  %al
 138:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 13c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 140:	84 c0                	test   %al,%al
 142:	75 de                	jne    122 <strcpy+0xd>
    ;
  return os;
 144:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 147:	c9                   	leave  
 148:	c3                   	ret    

00000149 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 149:	55                   	push   %ebp
 14a:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 14c:	eb 08                	jmp    156 <strcmp+0xd>
    p++, q++;
 14e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 152:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 156:	8b 45 08             	mov    0x8(%ebp),%eax
 159:	0f b6 00             	movzbl (%eax),%eax
 15c:	84 c0                	test   %al,%al
 15e:	74 10                	je     170 <strcmp+0x27>
 160:	8b 45 08             	mov    0x8(%ebp),%eax
 163:	0f b6 10             	movzbl (%eax),%edx
 166:	8b 45 0c             	mov    0xc(%ebp),%eax
 169:	0f b6 00             	movzbl (%eax),%eax
 16c:	38 c2                	cmp    %al,%dl
 16e:	74 de                	je     14e <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 170:	8b 45 08             	mov    0x8(%ebp),%eax
 173:	0f b6 00             	movzbl (%eax),%eax
 176:	0f b6 d0             	movzbl %al,%edx
 179:	8b 45 0c             	mov    0xc(%ebp),%eax
 17c:	0f b6 00             	movzbl (%eax),%eax
 17f:	0f b6 c0             	movzbl %al,%eax
 182:	89 d1                	mov    %edx,%ecx
 184:	29 c1                	sub    %eax,%ecx
 186:	89 c8                	mov    %ecx,%eax
}
 188:	5d                   	pop    %ebp
 189:	c3                   	ret    

0000018a <strlen>:

uint
strlen(char *s)
{
 18a:	55                   	push   %ebp
 18b:	89 e5                	mov    %esp,%ebp
 18d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 190:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 197:	eb 04                	jmp    19d <strlen+0x13>
 199:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 19d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 1a0:	03 45 08             	add    0x8(%ebp),%eax
 1a3:	0f b6 00             	movzbl (%eax),%eax
 1a6:	84 c0                	test   %al,%al
 1a8:	75 ef                	jne    199 <strlen+0xf>
    ;
  return n;
 1aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1ad:	c9                   	leave  
 1ae:	c3                   	ret    

000001af <memset>:

void*
memset(void *dst, int c, uint n)
{
 1af:	55                   	push   %ebp
 1b0:	89 e5                	mov    %esp,%ebp
 1b2:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1b5:	8b 45 10             	mov    0x10(%ebp),%eax
 1b8:	89 44 24 08          	mov    %eax,0x8(%esp)
 1bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 1bf:	89 44 24 04          	mov    %eax,0x4(%esp)
 1c3:	8b 45 08             	mov    0x8(%ebp),%eax
 1c6:	89 04 24             	mov    %eax,(%esp)
 1c9:	e8 22 ff ff ff       	call   f0 <stosb>
  return dst;
 1ce:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1d1:	c9                   	leave  
 1d2:	c3                   	ret    

000001d3 <strchr>:

char*
strchr(const char *s, char c)
{
 1d3:	55                   	push   %ebp
 1d4:	89 e5                	mov    %esp,%ebp
 1d6:	83 ec 04             	sub    $0x4,%esp
 1d9:	8b 45 0c             	mov    0xc(%ebp),%eax
 1dc:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1df:	eb 14                	jmp    1f5 <strchr+0x22>
    if(*s == c)
 1e1:	8b 45 08             	mov    0x8(%ebp),%eax
 1e4:	0f b6 00             	movzbl (%eax),%eax
 1e7:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1ea:	75 05                	jne    1f1 <strchr+0x1e>
      return (char*)s;
 1ec:	8b 45 08             	mov    0x8(%ebp),%eax
 1ef:	eb 13                	jmp    204 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1f1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1f5:	8b 45 08             	mov    0x8(%ebp),%eax
 1f8:	0f b6 00             	movzbl (%eax),%eax
 1fb:	84 c0                	test   %al,%al
 1fd:	75 e2                	jne    1e1 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
 204:	c9                   	leave  
 205:	c3                   	ret    

00000206 <gets>:

char*
gets(char *buf, int max)
{
 206:	55                   	push   %ebp
 207:	89 e5                	mov    %esp,%ebp
 209:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 213:	eb 44                	jmp    259 <gets+0x53>
    cc = read(0, &c, 1);
 215:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 21c:	00 
 21d:	8d 45 ef             	lea    -0x11(%ebp),%eax
 220:	89 44 24 04          	mov    %eax,0x4(%esp)
 224:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 22b:	e8 3c 01 00 00       	call   36c <read>
 230:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 233:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 237:	7e 2d                	jle    266 <gets+0x60>
      break;
    buf[i++] = c;
 239:	8b 45 f4             	mov    -0xc(%ebp),%eax
 23c:	03 45 08             	add    0x8(%ebp),%eax
 23f:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 243:	88 10                	mov    %dl,(%eax)
 245:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 249:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 24d:	3c 0a                	cmp    $0xa,%al
 24f:	74 16                	je     267 <gets+0x61>
 251:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 255:	3c 0d                	cmp    $0xd,%al
 257:	74 0e                	je     267 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 259:	8b 45 f4             	mov    -0xc(%ebp),%eax
 25c:	83 c0 01             	add    $0x1,%eax
 25f:	3b 45 0c             	cmp    0xc(%ebp),%eax
 262:	7c b1                	jl     215 <gets+0xf>
 264:	eb 01                	jmp    267 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 266:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 267:	8b 45 f4             	mov    -0xc(%ebp),%eax
 26a:	03 45 08             	add    0x8(%ebp),%eax
 26d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 270:	8b 45 08             	mov    0x8(%ebp),%eax
}
 273:	c9                   	leave  
 274:	c3                   	ret    

00000275 <stat>:

int
stat(char *n, struct stat *st)
{
 275:	55                   	push   %ebp
 276:	89 e5                	mov    %esp,%ebp
 278:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 27b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 282:	00 
 283:	8b 45 08             	mov    0x8(%ebp),%eax
 286:	89 04 24             	mov    %eax,(%esp)
 289:	e8 06 01 00 00       	call   394 <open>
 28e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 291:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 295:	79 07                	jns    29e <stat+0x29>
    return -1;
 297:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 29c:	eb 23                	jmp    2c1 <stat+0x4c>
  r = fstat(fd, st);
 29e:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a1:	89 44 24 04          	mov    %eax,0x4(%esp)
 2a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2a8:	89 04 24             	mov    %eax,(%esp)
 2ab:	e8 fc 00 00 00       	call   3ac <fstat>
 2b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2b6:	89 04 24             	mov    %eax,(%esp)
 2b9:	e8 be 00 00 00       	call   37c <close>
  return r;
 2be:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2c1:	c9                   	leave  
 2c2:	c3                   	ret    

000002c3 <atoi>:

int
atoi(const char *s)
{
 2c3:	55                   	push   %ebp
 2c4:	89 e5                	mov    %esp,%ebp
 2c6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2c9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2d0:	eb 23                	jmp    2f5 <atoi+0x32>
    n = n*10 + *s++ - '0';
 2d2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2d5:	89 d0                	mov    %edx,%eax
 2d7:	c1 e0 02             	shl    $0x2,%eax
 2da:	01 d0                	add    %edx,%eax
 2dc:	01 c0                	add    %eax,%eax
 2de:	89 c2                	mov    %eax,%edx
 2e0:	8b 45 08             	mov    0x8(%ebp),%eax
 2e3:	0f b6 00             	movzbl (%eax),%eax
 2e6:	0f be c0             	movsbl %al,%eax
 2e9:	01 d0                	add    %edx,%eax
 2eb:	83 e8 30             	sub    $0x30,%eax
 2ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
 2f1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2f5:	8b 45 08             	mov    0x8(%ebp),%eax
 2f8:	0f b6 00             	movzbl (%eax),%eax
 2fb:	3c 2f                	cmp    $0x2f,%al
 2fd:	7e 0a                	jle    309 <atoi+0x46>
 2ff:	8b 45 08             	mov    0x8(%ebp),%eax
 302:	0f b6 00             	movzbl (%eax),%eax
 305:	3c 39                	cmp    $0x39,%al
 307:	7e c9                	jle    2d2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 309:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 30c:	c9                   	leave  
 30d:	c3                   	ret    

0000030e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 30e:	55                   	push   %ebp
 30f:	89 e5                	mov    %esp,%ebp
 311:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 314:	8b 45 08             	mov    0x8(%ebp),%eax
 317:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 31a:	8b 45 0c             	mov    0xc(%ebp),%eax
 31d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 320:	eb 13                	jmp    335 <memmove+0x27>
    *dst++ = *src++;
 322:	8b 45 f8             	mov    -0x8(%ebp),%eax
 325:	0f b6 10             	movzbl (%eax),%edx
 328:	8b 45 fc             	mov    -0x4(%ebp),%eax
 32b:	88 10                	mov    %dl,(%eax)
 32d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 331:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 335:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 339:	0f 9f c0             	setg   %al
 33c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 340:	84 c0                	test   %al,%al
 342:	75 de                	jne    322 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 344:	8b 45 08             	mov    0x8(%ebp),%eax
}
 347:	c9                   	leave  
 348:	c3                   	ret    
 349:	90                   	nop
 34a:	90                   	nop
 34b:	90                   	nop

0000034c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 34c:	b8 01 00 00 00       	mov    $0x1,%eax
 351:	cd 40                	int    $0x40
 353:	c3                   	ret    

00000354 <exit>:
SYSCALL(exit)
 354:	b8 02 00 00 00       	mov    $0x2,%eax
 359:	cd 40                	int    $0x40
 35b:	c3                   	ret    

0000035c <wait>:
SYSCALL(wait)
 35c:	b8 03 00 00 00       	mov    $0x3,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret    

00000364 <pipe>:
SYSCALL(pipe)
 364:	b8 04 00 00 00       	mov    $0x4,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <read>:
SYSCALL(read)
 36c:	b8 05 00 00 00       	mov    $0x5,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <write>:
SYSCALL(write)
 374:	b8 10 00 00 00       	mov    $0x10,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <close>:
SYSCALL(close)
 37c:	b8 15 00 00 00       	mov    $0x15,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <kill>:
SYSCALL(kill)
 384:	b8 06 00 00 00       	mov    $0x6,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <exec>:
SYSCALL(exec)
 38c:	b8 07 00 00 00       	mov    $0x7,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <open>:
SYSCALL(open)
 394:	b8 0f 00 00 00       	mov    $0xf,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <mknod>:
SYSCALL(mknod)
 39c:	b8 11 00 00 00       	mov    $0x11,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <unlink>:
SYSCALL(unlink)
 3a4:	b8 12 00 00 00       	mov    $0x12,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <fstat>:
SYSCALL(fstat)
 3ac:	b8 08 00 00 00       	mov    $0x8,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <link>:
SYSCALL(link)
 3b4:	b8 13 00 00 00       	mov    $0x13,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <mkdir>:
SYSCALL(mkdir)
 3bc:	b8 14 00 00 00       	mov    $0x14,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <chdir>:
SYSCALL(chdir)
 3c4:	b8 09 00 00 00       	mov    $0x9,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <dup>:
SYSCALL(dup)
 3cc:	b8 0a 00 00 00       	mov    $0xa,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <getpid>:
SYSCALL(getpid)
 3d4:	b8 0b 00 00 00       	mov    $0xb,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <sbrk>:
SYSCALL(sbrk)
 3dc:	b8 0c 00 00 00       	mov    $0xc,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <sleep>:
SYSCALL(sleep)
 3e4:	b8 0d 00 00 00       	mov    $0xd,%eax
 3e9:	cd 40                	int    $0x40
 3eb:	c3                   	ret    

000003ec <uptime>:
SYSCALL(uptime)
 3ec:	b8 0e 00 00 00       	mov    $0xe,%eax
 3f1:	cd 40                	int    $0x40
 3f3:	c3                   	ret    

000003f4 <waitpid>:
SYSCALL(waitpid)
 3f4:	b8 16 00 00 00       	mov    $0x16,%eax
 3f9:	cd 40                	int    $0x40
 3fb:	c3                   	ret    

000003fc <forkjob>:
 3fc:	b8 17 00 00 00       	mov    $0x17,%eax
 401:	cd 40                	int    $0x40
 403:	c3                   	ret    

00000404 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 404:	55                   	push   %ebp
 405:	89 e5                	mov    %esp,%ebp
 407:	83 ec 28             	sub    $0x28,%esp
 40a:	8b 45 0c             	mov    0xc(%ebp),%eax
 40d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 410:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 417:	00 
 418:	8d 45 f4             	lea    -0xc(%ebp),%eax
 41b:	89 44 24 04          	mov    %eax,0x4(%esp)
 41f:	8b 45 08             	mov    0x8(%ebp),%eax
 422:	89 04 24             	mov    %eax,(%esp)
 425:	e8 4a ff ff ff       	call   374 <write>
}
 42a:	c9                   	leave  
 42b:	c3                   	ret    

0000042c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 42c:	55                   	push   %ebp
 42d:	89 e5                	mov    %esp,%ebp
 42f:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 432:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 439:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 43d:	74 17                	je     456 <printint+0x2a>
 43f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 443:	79 11                	jns    456 <printint+0x2a>
    neg = 1;
 445:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 44c:	8b 45 0c             	mov    0xc(%ebp),%eax
 44f:	f7 d8                	neg    %eax
 451:	89 45 ec             	mov    %eax,-0x14(%ebp)
 454:	eb 06                	jmp    45c <printint+0x30>
  } else {
    x = xx;
 456:	8b 45 0c             	mov    0xc(%ebp),%eax
 459:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 45c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 463:	8b 4d 10             	mov    0x10(%ebp),%ecx
 466:	8b 45 ec             	mov    -0x14(%ebp),%eax
 469:	ba 00 00 00 00       	mov    $0x0,%edx
 46e:	f7 f1                	div    %ecx
 470:	89 d0                	mov    %edx,%eax
 472:	0f b6 90 34 0b 00 00 	movzbl 0xb34(%eax),%edx
 479:	8d 45 dc             	lea    -0x24(%ebp),%eax
 47c:	03 45 f4             	add    -0xc(%ebp),%eax
 47f:	88 10                	mov    %dl,(%eax)
 481:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 485:	8b 55 10             	mov    0x10(%ebp),%edx
 488:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 48b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 48e:	ba 00 00 00 00       	mov    $0x0,%edx
 493:	f7 75 d4             	divl   -0x2c(%ebp)
 496:	89 45 ec             	mov    %eax,-0x14(%ebp)
 499:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 49d:	75 c4                	jne    463 <printint+0x37>
  if(neg)
 49f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4a3:	74 2a                	je     4cf <printint+0xa3>
    buf[i++] = '-';
 4a5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 4a8:	03 45 f4             	add    -0xc(%ebp),%eax
 4ab:	c6 00 2d             	movb   $0x2d,(%eax)
 4ae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 4b2:	eb 1b                	jmp    4cf <printint+0xa3>
    putc(fd, buf[i]);
 4b4:	8d 45 dc             	lea    -0x24(%ebp),%eax
 4b7:	03 45 f4             	add    -0xc(%ebp),%eax
 4ba:	0f b6 00             	movzbl (%eax),%eax
 4bd:	0f be c0             	movsbl %al,%eax
 4c0:	89 44 24 04          	mov    %eax,0x4(%esp)
 4c4:	8b 45 08             	mov    0x8(%ebp),%eax
 4c7:	89 04 24             	mov    %eax,(%esp)
 4ca:	e8 35 ff ff ff       	call   404 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4cf:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4d7:	79 db                	jns    4b4 <printint+0x88>
    putc(fd, buf[i]);
}
 4d9:	c9                   	leave  
 4da:	c3                   	ret    

000004db <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4db:	55                   	push   %ebp
 4dc:	89 e5                	mov    %esp,%ebp
 4de:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4e1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4e8:	8d 45 0c             	lea    0xc(%ebp),%eax
 4eb:	83 c0 04             	add    $0x4,%eax
 4ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4f1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4f8:	e9 7d 01 00 00       	jmp    67a <printf+0x19f>
    c = fmt[i] & 0xff;
 4fd:	8b 55 0c             	mov    0xc(%ebp),%edx
 500:	8b 45 f0             	mov    -0x10(%ebp),%eax
 503:	01 d0                	add    %edx,%eax
 505:	0f b6 00             	movzbl (%eax),%eax
 508:	0f be c0             	movsbl %al,%eax
 50b:	25 ff 00 00 00       	and    $0xff,%eax
 510:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 513:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 517:	75 2c                	jne    545 <printf+0x6a>
      if(c == '%'){
 519:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 51d:	75 0c                	jne    52b <printf+0x50>
        state = '%';
 51f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 526:	e9 4b 01 00 00       	jmp    676 <printf+0x19b>
      } else {
        putc(fd, c);
 52b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 52e:	0f be c0             	movsbl %al,%eax
 531:	89 44 24 04          	mov    %eax,0x4(%esp)
 535:	8b 45 08             	mov    0x8(%ebp),%eax
 538:	89 04 24             	mov    %eax,(%esp)
 53b:	e8 c4 fe ff ff       	call   404 <putc>
 540:	e9 31 01 00 00       	jmp    676 <printf+0x19b>
      }
    } else if(state == '%'){
 545:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 549:	0f 85 27 01 00 00    	jne    676 <printf+0x19b>
      if(c == 'd'){
 54f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 553:	75 2d                	jne    582 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 555:	8b 45 e8             	mov    -0x18(%ebp),%eax
 558:	8b 00                	mov    (%eax),%eax
 55a:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 561:	00 
 562:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 569:	00 
 56a:	89 44 24 04          	mov    %eax,0x4(%esp)
 56e:	8b 45 08             	mov    0x8(%ebp),%eax
 571:	89 04 24             	mov    %eax,(%esp)
 574:	e8 b3 fe ff ff       	call   42c <printint>
        ap++;
 579:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 57d:	e9 ed 00 00 00       	jmp    66f <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 582:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 586:	74 06                	je     58e <printf+0xb3>
 588:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 58c:	75 2d                	jne    5bb <printf+0xe0>
        printint(fd, *ap, 16, 0);
 58e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 591:	8b 00                	mov    (%eax),%eax
 593:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 59a:	00 
 59b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5a2:	00 
 5a3:	89 44 24 04          	mov    %eax,0x4(%esp)
 5a7:	8b 45 08             	mov    0x8(%ebp),%eax
 5aa:	89 04 24             	mov    %eax,(%esp)
 5ad:	e8 7a fe ff ff       	call   42c <printint>
        ap++;
 5b2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5b6:	e9 b4 00 00 00       	jmp    66f <printf+0x194>
      } else if(c == 's'){
 5bb:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5bf:	75 46                	jne    607 <printf+0x12c>
        s = (char*)*ap;
 5c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5c4:	8b 00                	mov    (%eax),%eax
 5c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5c9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5d1:	75 27                	jne    5fa <printf+0x11f>
          s = "(null)";
 5d3:	c7 45 f4 ee 08 00 00 	movl   $0x8ee,-0xc(%ebp)
        while(*s != 0){
 5da:	eb 1e                	jmp    5fa <printf+0x11f>
          putc(fd, *s);
 5dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5df:	0f b6 00             	movzbl (%eax),%eax
 5e2:	0f be c0             	movsbl %al,%eax
 5e5:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e9:	8b 45 08             	mov    0x8(%ebp),%eax
 5ec:	89 04 24             	mov    %eax,(%esp)
 5ef:	e8 10 fe ff ff       	call   404 <putc>
          s++;
 5f4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 5f8:	eb 01                	jmp    5fb <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5fa:	90                   	nop
 5fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5fe:	0f b6 00             	movzbl (%eax),%eax
 601:	84 c0                	test   %al,%al
 603:	75 d7                	jne    5dc <printf+0x101>
 605:	eb 68                	jmp    66f <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 607:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 60b:	75 1d                	jne    62a <printf+0x14f>
        putc(fd, *ap);
 60d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 610:	8b 00                	mov    (%eax),%eax
 612:	0f be c0             	movsbl %al,%eax
 615:	89 44 24 04          	mov    %eax,0x4(%esp)
 619:	8b 45 08             	mov    0x8(%ebp),%eax
 61c:	89 04 24             	mov    %eax,(%esp)
 61f:	e8 e0 fd ff ff       	call   404 <putc>
        ap++;
 624:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 628:	eb 45                	jmp    66f <printf+0x194>
      } else if(c == '%'){
 62a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 62e:	75 17                	jne    647 <printf+0x16c>
        putc(fd, c);
 630:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 633:	0f be c0             	movsbl %al,%eax
 636:	89 44 24 04          	mov    %eax,0x4(%esp)
 63a:	8b 45 08             	mov    0x8(%ebp),%eax
 63d:	89 04 24             	mov    %eax,(%esp)
 640:	e8 bf fd ff ff       	call   404 <putc>
 645:	eb 28                	jmp    66f <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 647:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 64e:	00 
 64f:	8b 45 08             	mov    0x8(%ebp),%eax
 652:	89 04 24             	mov    %eax,(%esp)
 655:	e8 aa fd ff ff       	call   404 <putc>
        putc(fd, c);
 65a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 65d:	0f be c0             	movsbl %al,%eax
 660:	89 44 24 04          	mov    %eax,0x4(%esp)
 664:	8b 45 08             	mov    0x8(%ebp),%eax
 667:	89 04 24             	mov    %eax,(%esp)
 66a:	e8 95 fd ff ff       	call   404 <putc>
      }
      state = 0;
 66f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 676:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 67a:	8b 55 0c             	mov    0xc(%ebp),%edx
 67d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 680:	01 d0                	add    %edx,%eax
 682:	0f b6 00             	movzbl (%eax),%eax
 685:	84 c0                	test   %al,%al
 687:	0f 85 70 fe ff ff    	jne    4fd <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 68d:	c9                   	leave  
 68e:	c3                   	ret    
 68f:	90                   	nop

00000690 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 690:	55                   	push   %ebp
 691:	89 e5                	mov    %esp,%ebp
 693:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 696:	8b 45 08             	mov    0x8(%ebp),%eax
 699:	83 e8 08             	sub    $0x8,%eax
 69c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 69f:	a1 50 0b 00 00       	mov    0xb50,%eax
 6a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6a7:	eb 24                	jmp    6cd <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ac:	8b 00                	mov    (%eax),%eax
 6ae:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6b1:	77 12                	ja     6c5 <free+0x35>
 6b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6b9:	77 24                	ja     6df <free+0x4f>
 6bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6be:	8b 00                	mov    (%eax),%eax
 6c0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6c3:	77 1a                	ja     6df <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c8:	8b 00                	mov    (%eax),%eax
 6ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6d0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6d3:	76 d4                	jbe    6a9 <free+0x19>
 6d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d8:	8b 00                	mov    (%eax),%eax
 6da:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6dd:	76 ca                	jbe    6a9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6df:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e2:	8b 40 04             	mov    0x4(%eax),%eax
 6e5:	c1 e0 03             	shl    $0x3,%eax
 6e8:	89 c2                	mov    %eax,%edx
 6ea:	03 55 f8             	add    -0x8(%ebp),%edx
 6ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f0:	8b 00                	mov    (%eax),%eax
 6f2:	39 c2                	cmp    %eax,%edx
 6f4:	75 24                	jne    71a <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 6f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f9:	8b 50 04             	mov    0x4(%eax),%edx
 6fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ff:	8b 00                	mov    (%eax),%eax
 701:	8b 40 04             	mov    0x4(%eax),%eax
 704:	01 c2                	add    %eax,%edx
 706:	8b 45 f8             	mov    -0x8(%ebp),%eax
 709:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 70c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70f:	8b 00                	mov    (%eax),%eax
 711:	8b 10                	mov    (%eax),%edx
 713:	8b 45 f8             	mov    -0x8(%ebp),%eax
 716:	89 10                	mov    %edx,(%eax)
 718:	eb 0a                	jmp    724 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 71a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71d:	8b 10                	mov    (%eax),%edx
 71f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 722:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 724:	8b 45 fc             	mov    -0x4(%ebp),%eax
 727:	8b 40 04             	mov    0x4(%eax),%eax
 72a:	c1 e0 03             	shl    $0x3,%eax
 72d:	03 45 fc             	add    -0x4(%ebp),%eax
 730:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 733:	75 20                	jne    755 <free+0xc5>
    p->s.size += bp->s.size;
 735:	8b 45 fc             	mov    -0x4(%ebp),%eax
 738:	8b 50 04             	mov    0x4(%eax),%edx
 73b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73e:	8b 40 04             	mov    0x4(%eax),%eax
 741:	01 c2                	add    %eax,%edx
 743:	8b 45 fc             	mov    -0x4(%ebp),%eax
 746:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 749:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74c:	8b 10                	mov    (%eax),%edx
 74e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 751:	89 10                	mov    %edx,(%eax)
 753:	eb 08                	jmp    75d <free+0xcd>
  } else
    p->s.ptr = bp;
 755:	8b 45 fc             	mov    -0x4(%ebp),%eax
 758:	8b 55 f8             	mov    -0x8(%ebp),%edx
 75b:	89 10                	mov    %edx,(%eax)
  freep = p;
 75d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 760:	a3 50 0b 00 00       	mov    %eax,0xb50
}
 765:	c9                   	leave  
 766:	c3                   	ret    

00000767 <morecore>:

static Header*
morecore(uint nu)
{
 767:	55                   	push   %ebp
 768:	89 e5                	mov    %esp,%ebp
 76a:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 76d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 774:	77 07                	ja     77d <morecore+0x16>
    nu = 4096;
 776:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 77d:	8b 45 08             	mov    0x8(%ebp),%eax
 780:	c1 e0 03             	shl    $0x3,%eax
 783:	89 04 24             	mov    %eax,(%esp)
 786:	e8 51 fc ff ff       	call   3dc <sbrk>
 78b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 78e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 792:	75 07                	jne    79b <morecore+0x34>
    return 0;
 794:	b8 00 00 00 00       	mov    $0x0,%eax
 799:	eb 22                	jmp    7bd <morecore+0x56>
  hp = (Header*)p;
 79b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a4:	8b 55 08             	mov    0x8(%ebp),%edx
 7a7:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ad:	83 c0 08             	add    $0x8,%eax
 7b0:	89 04 24             	mov    %eax,(%esp)
 7b3:	e8 d8 fe ff ff       	call   690 <free>
  return freep;
 7b8:	a1 50 0b 00 00       	mov    0xb50,%eax
}
 7bd:	c9                   	leave  
 7be:	c3                   	ret    

000007bf <malloc>:

void*
malloc(uint nbytes)
{
 7bf:	55                   	push   %ebp
 7c0:	89 e5                	mov    %esp,%ebp
 7c2:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7c5:	8b 45 08             	mov    0x8(%ebp),%eax
 7c8:	83 c0 07             	add    $0x7,%eax
 7cb:	c1 e8 03             	shr    $0x3,%eax
 7ce:	83 c0 01             	add    $0x1,%eax
 7d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7d4:	a1 50 0b 00 00       	mov    0xb50,%eax
 7d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7e0:	75 23                	jne    805 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7e2:	c7 45 f0 48 0b 00 00 	movl   $0xb48,-0x10(%ebp)
 7e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ec:	a3 50 0b 00 00       	mov    %eax,0xb50
 7f1:	a1 50 0b 00 00       	mov    0xb50,%eax
 7f6:	a3 48 0b 00 00       	mov    %eax,0xb48
    base.s.size = 0;
 7fb:	c7 05 4c 0b 00 00 00 	movl   $0x0,0xb4c
 802:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 805:	8b 45 f0             	mov    -0x10(%ebp),%eax
 808:	8b 00                	mov    (%eax),%eax
 80a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 80d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 810:	8b 40 04             	mov    0x4(%eax),%eax
 813:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 816:	72 4d                	jb     865 <malloc+0xa6>
      if(p->s.size == nunits)
 818:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81b:	8b 40 04             	mov    0x4(%eax),%eax
 81e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 821:	75 0c                	jne    82f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 823:	8b 45 f4             	mov    -0xc(%ebp),%eax
 826:	8b 10                	mov    (%eax),%edx
 828:	8b 45 f0             	mov    -0x10(%ebp),%eax
 82b:	89 10                	mov    %edx,(%eax)
 82d:	eb 26                	jmp    855 <malloc+0x96>
      else {
        p->s.size -= nunits;
 82f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 832:	8b 40 04             	mov    0x4(%eax),%eax
 835:	89 c2                	mov    %eax,%edx
 837:	2b 55 ec             	sub    -0x14(%ebp),%edx
 83a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 840:	8b 45 f4             	mov    -0xc(%ebp),%eax
 843:	8b 40 04             	mov    0x4(%eax),%eax
 846:	c1 e0 03             	shl    $0x3,%eax
 849:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 84c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 852:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 855:	8b 45 f0             	mov    -0x10(%ebp),%eax
 858:	a3 50 0b 00 00       	mov    %eax,0xb50
      return (void*)(p + 1);
 85d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 860:	83 c0 08             	add    $0x8,%eax
 863:	eb 38                	jmp    89d <malloc+0xde>
    }
    if(p == freep)
 865:	a1 50 0b 00 00       	mov    0xb50,%eax
 86a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 86d:	75 1b                	jne    88a <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 86f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 872:	89 04 24             	mov    %eax,(%esp)
 875:	e8 ed fe ff ff       	call   767 <morecore>
 87a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 87d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 881:	75 07                	jne    88a <malloc+0xcb>
        return 0;
 883:	b8 00 00 00 00       	mov    $0x0,%eax
 888:	eb 13                	jmp    89d <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 890:	8b 45 f4             	mov    -0xc(%ebp),%eax
 893:	8b 00                	mov    (%eax),%eax
 895:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 898:	e9 70 ff ff ff       	jmp    80d <malloc+0x4e>
}
 89d:	c9                   	leave  
 89e:	c3                   	ret    
