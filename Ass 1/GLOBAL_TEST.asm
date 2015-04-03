
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
  19:	c7 44 24 04 97 08 00 	movl   $0x897,0x4(%esp)
  20:	00 
  21:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  28:	e8 a6 04 00 00       	call   4d3 <printf>
  sleep(500);
  2d:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
  34:	e8 ab 03 00 00       	call   3e4 <sleep>
  printf(2, "getting out from sleep\n");
  39:	c7 44 24 04 ab 08 00 	movl   $0x8ab,0x4(%esp)
  40:	00 
  41:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  48:	e8 86 04 00 00       	call   4d3 <printf>
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
  81:	c7 44 24 04 c3 08 00 	movl   $0x8c3,0x4(%esp)
  88:	00 
  89:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  90:	e8 3e 04 00 00       	call   4d3 <printf>
printf(2, "pid = %d\n", npid);
  95:	8b 44 24 18          	mov    0x18(%esp),%eax
  99:	89 44 24 08          	mov    %eax,0x8(%esp)
  9d:	c7 44 24 04 d0 08 00 	movl   $0x8d0,0x4(%esp)
  a4:	00 
  a5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  ac:	e8 22 04 00 00       	call   4d3 <printf>
  
}
if (status == 123)
  b1:	8b 44 24 14          	mov    0x14(%esp),%eax
  b5:	83 f8 7b             	cmp    $0x7b,%eax
  b8:	75 16                	jne    d0 <main+0xd0>
{
printf(1, "OK\n");
  ba:	c7 44 24 04 da 08 00 	movl   $0x8da,0x4(%esp)
  c1:	00 
  c2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c9:	e8 05 04 00 00       	call   4d3 <printf>
  ce:	eb 14                	jmp    e4 <main+0xe4>
}
else
{
printf(1, "FAILED\n");
  d0:	c7 44 24 04 de 08 00 	movl   $0x8de,0x4(%esp)
  d7:	00 
  d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  df:	e8 ef 03 00 00       	call   4d3 <printf>
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
 3f4:	b8 16 00 00 00       	mov    $0x16,%eax
 3f9:	cd 40                	int    $0x40
 3fb:	c3                   	ret    

000003fc <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3fc:	55                   	push   %ebp
 3fd:	89 e5                	mov    %esp,%ebp
 3ff:	83 ec 28             	sub    $0x28,%esp
 402:	8b 45 0c             	mov    0xc(%ebp),%eax
 405:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 408:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 40f:	00 
 410:	8d 45 f4             	lea    -0xc(%ebp),%eax
 413:	89 44 24 04          	mov    %eax,0x4(%esp)
 417:	8b 45 08             	mov    0x8(%ebp),%eax
 41a:	89 04 24             	mov    %eax,(%esp)
 41d:	e8 52 ff ff ff       	call   374 <write>
}
 422:	c9                   	leave  
 423:	c3                   	ret    

00000424 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 424:	55                   	push   %ebp
 425:	89 e5                	mov    %esp,%ebp
 427:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 42a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 431:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 435:	74 17                	je     44e <printint+0x2a>
 437:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 43b:	79 11                	jns    44e <printint+0x2a>
    neg = 1;
 43d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 444:	8b 45 0c             	mov    0xc(%ebp),%eax
 447:	f7 d8                	neg    %eax
 449:	89 45 ec             	mov    %eax,-0x14(%ebp)
 44c:	eb 06                	jmp    454 <printint+0x30>
  } else {
    x = xx;
 44e:	8b 45 0c             	mov    0xc(%ebp),%eax
 451:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 454:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 45b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 45e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 461:	ba 00 00 00 00       	mov    $0x0,%edx
 466:	f7 f1                	div    %ecx
 468:	89 d0                	mov    %edx,%eax
 46a:	0f b6 90 2c 0b 00 00 	movzbl 0xb2c(%eax),%edx
 471:	8d 45 dc             	lea    -0x24(%ebp),%eax
 474:	03 45 f4             	add    -0xc(%ebp),%eax
 477:	88 10                	mov    %dl,(%eax)
 479:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 47d:	8b 55 10             	mov    0x10(%ebp),%edx
 480:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 483:	8b 45 ec             	mov    -0x14(%ebp),%eax
 486:	ba 00 00 00 00       	mov    $0x0,%edx
 48b:	f7 75 d4             	divl   -0x2c(%ebp)
 48e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 491:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 495:	75 c4                	jne    45b <printint+0x37>
  if(neg)
 497:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 49b:	74 2a                	je     4c7 <printint+0xa3>
    buf[i++] = '-';
 49d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 4a0:	03 45 f4             	add    -0xc(%ebp),%eax
 4a3:	c6 00 2d             	movb   $0x2d,(%eax)
 4a6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 4aa:	eb 1b                	jmp    4c7 <printint+0xa3>
    putc(fd, buf[i]);
 4ac:	8d 45 dc             	lea    -0x24(%ebp),%eax
 4af:	03 45 f4             	add    -0xc(%ebp),%eax
 4b2:	0f b6 00             	movzbl (%eax),%eax
 4b5:	0f be c0             	movsbl %al,%eax
 4b8:	89 44 24 04          	mov    %eax,0x4(%esp)
 4bc:	8b 45 08             	mov    0x8(%ebp),%eax
 4bf:	89 04 24             	mov    %eax,(%esp)
 4c2:	e8 35 ff ff ff       	call   3fc <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4c7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4cf:	79 db                	jns    4ac <printint+0x88>
    putc(fd, buf[i]);
}
 4d1:	c9                   	leave  
 4d2:	c3                   	ret    

000004d3 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4d3:	55                   	push   %ebp
 4d4:	89 e5                	mov    %esp,%ebp
 4d6:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4d9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4e0:	8d 45 0c             	lea    0xc(%ebp),%eax
 4e3:	83 c0 04             	add    $0x4,%eax
 4e6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4e9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4f0:	e9 7d 01 00 00       	jmp    672 <printf+0x19f>
    c = fmt[i] & 0xff;
 4f5:	8b 55 0c             	mov    0xc(%ebp),%edx
 4f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4fb:	01 d0                	add    %edx,%eax
 4fd:	0f b6 00             	movzbl (%eax),%eax
 500:	0f be c0             	movsbl %al,%eax
 503:	25 ff 00 00 00       	and    $0xff,%eax
 508:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 50b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 50f:	75 2c                	jne    53d <printf+0x6a>
      if(c == '%'){
 511:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 515:	75 0c                	jne    523 <printf+0x50>
        state = '%';
 517:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 51e:	e9 4b 01 00 00       	jmp    66e <printf+0x19b>
      } else {
        putc(fd, c);
 523:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 526:	0f be c0             	movsbl %al,%eax
 529:	89 44 24 04          	mov    %eax,0x4(%esp)
 52d:	8b 45 08             	mov    0x8(%ebp),%eax
 530:	89 04 24             	mov    %eax,(%esp)
 533:	e8 c4 fe ff ff       	call   3fc <putc>
 538:	e9 31 01 00 00       	jmp    66e <printf+0x19b>
      }
    } else if(state == '%'){
 53d:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 541:	0f 85 27 01 00 00    	jne    66e <printf+0x19b>
      if(c == 'd'){
 547:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 54b:	75 2d                	jne    57a <printf+0xa7>
        printint(fd, *ap, 10, 1);
 54d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 550:	8b 00                	mov    (%eax),%eax
 552:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 559:	00 
 55a:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 561:	00 
 562:	89 44 24 04          	mov    %eax,0x4(%esp)
 566:	8b 45 08             	mov    0x8(%ebp),%eax
 569:	89 04 24             	mov    %eax,(%esp)
 56c:	e8 b3 fe ff ff       	call   424 <printint>
        ap++;
 571:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 575:	e9 ed 00 00 00       	jmp    667 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 57a:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 57e:	74 06                	je     586 <printf+0xb3>
 580:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 584:	75 2d                	jne    5b3 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 586:	8b 45 e8             	mov    -0x18(%ebp),%eax
 589:	8b 00                	mov    (%eax),%eax
 58b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 592:	00 
 593:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 59a:	00 
 59b:	89 44 24 04          	mov    %eax,0x4(%esp)
 59f:	8b 45 08             	mov    0x8(%ebp),%eax
 5a2:	89 04 24             	mov    %eax,(%esp)
 5a5:	e8 7a fe ff ff       	call   424 <printint>
        ap++;
 5aa:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5ae:	e9 b4 00 00 00       	jmp    667 <printf+0x194>
      } else if(c == 's'){
 5b3:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5b7:	75 46                	jne    5ff <printf+0x12c>
        s = (char*)*ap;
 5b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5bc:	8b 00                	mov    (%eax),%eax
 5be:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5c1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5c9:	75 27                	jne    5f2 <printf+0x11f>
          s = "(null)";
 5cb:	c7 45 f4 e6 08 00 00 	movl   $0x8e6,-0xc(%ebp)
        while(*s != 0){
 5d2:	eb 1e                	jmp    5f2 <printf+0x11f>
          putc(fd, *s);
 5d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5d7:	0f b6 00             	movzbl (%eax),%eax
 5da:	0f be c0             	movsbl %al,%eax
 5dd:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e1:	8b 45 08             	mov    0x8(%ebp),%eax
 5e4:	89 04 24             	mov    %eax,(%esp)
 5e7:	e8 10 fe ff ff       	call   3fc <putc>
          s++;
 5ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 5f0:	eb 01                	jmp    5f3 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5f2:	90                   	nop
 5f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f6:	0f b6 00             	movzbl (%eax),%eax
 5f9:	84 c0                	test   %al,%al
 5fb:	75 d7                	jne    5d4 <printf+0x101>
 5fd:	eb 68                	jmp    667 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5ff:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 603:	75 1d                	jne    622 <printf+0x14f>
        putc(fd, *ap);
 605:	8b 45 e8             	mov    -0x18(%ebp),%eax
 608:	8b 00                	mov    (%eax),%eax
 60a:	0f be c0             	movsbl %al,%eax
 60d:	89 44 24 04          	mov    %eax,0x4(%esp)
 611:	8b 45 08             	mov    0x8(%ebp),%eax
 614:	89 04 24             	mov    %eax,(%esp)
 617:	e8 e0 fd ff ff       	call   3fc <putc>
        ap++;
 61c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 620:	eb 45                	jmp    667 <printf+0x194>
      } else if(c == '%'){
 622:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 626:	75 17                	jne    63f <printf+0x16c>
        putc(fd, c);
 628:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 62b:	0f be c0             	movsbl %al,%eax
 62e:	89 44 24 04          	mov    %eax,0x4(%esp)
 632:	8b 45 08             	mov    0x8(%ebp),%eax
 635:	89 04 24             	mov    %eax,(%esp)
 638:	e8 bf fd ff ff       	call   3fc <putc>
 63d:	eb 28                	jmp    667 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 63f:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 646:	00 
 647:	8b 45 08             	mov    0x8(%ebp),%eax
 64a:	89 04 24             	mov    %eax,(%esp)
 64d:	e8 aa fd ff ff       	call   3fc <putc>
        putc(fd, c);
 652:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 655:	0f be c0             	movsbl %al,%eax
 658:	89 44 24 04          	mov    %eax,0x4(%esp)
 65c:	8b 45 08             	mov    0x8(%ebp),%eax
 65f:	89 04 24             	mov    %eax,(%esp)
 662:	e8 95 fd ff ff       	call   3fc <putc>
      }
      state = 0;
 667:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 66e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 672:	8b 55 0c             	mov    0xc(%ebp),%edx
 675:	8b 45 f0             	mov    -0x10(%ebp),%eax
 678:	01 d0                	add    %edx,%eax
 67a:	0f b6 00             	movzbl (%eax),%eax
 67d:	84 c0                	test   %al,%al
 67f:	0f 85 70 fe ff ff    	jne    4f5 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 685:	c9                   	leave  
 686:	c3                   	ret    
 687:	90                   	nop

00000688 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 688:	55                   	push   %ebp
 689:	89 e5                	mov    %esp,%ebp
 68b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 68e:	8b 45 08             	mov    0x8(%ebp),%eax
 691:	83 e8 08             	sub    $0x8,%eax
 694:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 697:	a1 48 0b 00 00       	mov    0xb48,%eax
 69c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 69f:	eb 24                	jmp    6c5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a4:	8b 00                	mov    (%eax),%eax
 6a6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6a9:	77 12                	ja     6bd <free+0x35>
 6ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ae:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6b1:	77 24                	ja     6d7 <free+0x4f>
 6b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b6:	8b 00                	mov    (%eax),%eax
 6b8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6bb:	77 1a                	ja     6d7 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c0:	8b 00                	mov    (%eax),%eax
 6c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6cb:	76 d4                	jbe    6a1 <free+0x19>
 6cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d0:	8b 00                	mov    (%eax),%eax
 6d2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6d5:	76 ca                	jbe    6a1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6da:	8b 40 04             	mov    0x4(%eax),%eax
 6dd:	c1 e0 03             	shl    $0x3,%eax
 6e0:	89 c2                	mov    %eax,%edx
 6e2:	03 55 f8             	add    -0x8(%ebp),%edx
 6e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e8:	8b 00                	mov    (%eax),%eax
 6ea:	39 c2                	cmp    %eax,%edx
 6ec:	75 24                	jne    712 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 6ee:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f1:	8b 50 04             	mov    0x4(%eax),%edx
 6f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f7:	8b 00                	mov    (%eax),%eax
 6f9:	8b 40 04             	mov    0x4(%eax),%eax
 6fc:	01 c2                	add    %eax,%edx
 6fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
 701:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 704:	8b 45 fc             	mov    -0x4(%ebp),%eax
 707:	8b 00                	mov    (%eax),%eax
 709:	8b 10                	mov    (%eax),%edx
 70b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70e:	89 10                	mov    %edx,(%eax)
 710:	eb 0a                	jmp    71c <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 712:	8b 45 fc             	mov    -0x4(%ebp),%eax
 715:	8b 10                	mov    (%eax),%edx
 717:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 71c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71f:	8b 40 04             	mov    0x4(%eax),%eax
 722:	c1 e0 03             	shl    $0x3,%eax
 725:	03 45 fc             	add    -0x4(%ebp),%eax
 728:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 72b:	75 20                	jne    74d <free+0xc5>
    p->s.size += bp->s.size;
 72d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 730:	8b 50 04             	mov    0x4(%eax),%edx
 733:	8b 45 f8             	mov    -0x8(%ebp),%eax
 736:	8b 40 04             	mov    0x4(%eax),%eax
 739:	01 c2                	add    %eax,%edx
 73b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 741:	8b 45 f8             	mov    -0x8(%ebp),%eax
 744:	8b 10                	mov    (%eax),%edx
 746:	8b 45 fc             	mov    -0x4(%ebp),%eax
 749:	89 10                	mov    %edx,(%eax)
 74b:	eb 08                	jmp    755 <free+0xcd>
  } else
    p->s.ptr = bp;
 74d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 750:	8b 55 f8             	mov    -0x8(%ebp),%edx
 753:	89 10                	mov    %edx,(%eax)
  freep = p;
 755:	8b 45 fc             	mov    -0x4(%ebp),%eax
 758:	a3 48 0b 00 00       	mov    %eax,0xb48
}
 75d:	c9                   	leave  
 75e:	c3                   	ret    

0000075f <morecore>:

static Header*
morecore(uint nu)
{
 75f:	55                   	push   %ebp
 760:	89 e5                	mov    %esp,%ebp
 762:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 765:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 76c:	77 07                	ja     775 <morecore+0x16>
    nu = 4096;
 76e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 775:	8b 45 08             	mov    0x8(%ebp),%eax
 778:	c1 e0 03             	shl    $0x3,%eax
 77b:	89 04 24             	mov    %eax,(%esp)
 77e:	e8 59 fc ff ff       	call   3dc <sbrk>
 783:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 786:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 78a:	75 07                	jne    793 <morecore+0x34>
    return 0;
 78c:	b8 00 00 00 00       	mov    $0x0,%eax
 791:	eb 22                	jmp    7b5 <morecore+0x56>
  hp = (Header*)p;
 793:	8b 45 f4             	mov    -0xc(%ebp),%eax
 796:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 799:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79c:	8b 55 08             	mov    0x8(%ebp),%edx
 79f:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a5:	83 c0 08             	add    $0x8,%eax
 7a8:	89 04 24             	mov    %eax,(%esp)
 7ab:	e8 d8 fe ff ff       	call   688 <free>
  return freep;
 7b0:	a1 48 0b 00 00       	mov    0xb48,%eax
}
 7b5:	c9                   	leave  
 7b6:	c3                   	ret    

000007b7 <malloc>:

void*
malloc(uint nbytes)
{
 7b7:	55                   	push   %ebp
 7b8:	89 e5                	mov    %esp,%ebp
 7ba:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7bd:	8b 45 08             	mov    0x8(%ebp),%eax
 7c0:	83 c0 07             	add    $0x7,%eax
 7c3:	c1 e8 03             	shr    $0x3,%eax
 7c6:	83 c0 01             	add    $0x1,%eax
 7c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7cc:	a1 48 0b 00 00       	mov    0xb48,%eax
 7d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7d8:	75 23                	jne    7fd <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7da:	c7 45 f0 40 0b 00 00 	movl   $0xb40,-0x10(%ebp)
 7e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e4:	a3 48 0b 00 00       	mov    %eax,0xb48
 7e9:	a1 48 0b 00 00       	mov    0xb48,%eax
 7ee:	a3 40 0b 00 00       	mov    %eax,0xb40
    base.s.size = 0;
 7f3:	c7 05 44 0b 00 00 00 	movl   $0x0,0xb44
 7fa:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 800:	8b 00                	mov    (%eax),%eax
 802:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 805:	8b 45 f4             	mov    -0xc(%ebp),%eax
 808:	8b 40 04             	mov    0x4(%eax),%eax
 80b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 80e:	72 4d                	jb     85d <malloc+0xa6>
      if(p->s.size == nunits)
 810:	8b 45 f4             	mov    -0xc(%ebp),%eax
 813:	8b 40 04             	mov    0x4(%eax),%eax
 816:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 819:	75 0c                	jne    827 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 81b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81e:	8b 10                	mov    (%eax),%edx
 820:	8b 45 f0             	mov    -0x10(%ebp),%eax
 823:	89 10                	mov    %edx,(%eax)
 825:	eb 26                	jmp    84d <malloc+0x96>
      else {
        p->s.size -= nunits;
 827:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82a:	8b 40 04             	mov    0x4(%eax),%eax
 82d:	89 c2                	mov    %eax,%edx
 82f:	2b 55 ec             	sub    -0x14(%ebp),%edx
 832:	8b 45 f4             	mov    -0xc(%ebp),%eax
 835:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 838:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83b:	8b 40 04             	mov    0x4(%eax),%eax
 83e:	c1 e0 03             	shl    $0x3,%eax
 841:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 844:	8b 45 f4             	mov    -0xc(%ebp),%eax
 847:	8b 55 ec             	mov    -0x14(%ebp),%edx
 84a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 84d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 850:	a3 48 0b 00 00       	mov    %eax,0xb48
      return (void*)(p + 1);
 855:	8b 45 f4             	mov    -0xc(%ebp),%eax
 858:	83 c0 08             	add    $0x8,%eax
 85b:	eb 38                	jmp    895 <malloc+0xde>
    }
    if(p == freep)
 85d:	a1 48 0b 00 00       	mov    0xb48,%eax
 862:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 865:	75 1b                	jne    882 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 867:	8b 45 ec             	mov    -0x14(%ebp),%eax
 86a:	89 04 24             	mov    %eax,(%esp)
 86d:	e8 ed fe ff ff       	call   75f <morecore>
 872:	89 45 f4             	mov    %eax,-0xc(%ebp)
 875:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 879:	75 07                	jne    882 <malloc+0xcb>
        return 0;
 87b:	b8 00 00 00 00       	mov    $0x0,%eax
 880:	eb 13                	jmp    895 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 882:	8b 45 f4             	mov    -0xc(%ebp),%eax
 885:	89 45 f0             	mov    %eax,-0x10(%ebp)
 888:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88b:	8b 00                	mov    (%eax),%eax
 88d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 890:	e9 70 ff ff ff       	jmp    805 <malloc+0x4e>
}
 895:	c9                   	leave  
 896:	c3                   	ret    
