
_usertests:     file format elf32-i386


Disassembly of section .text:

00000000 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
   5:	8b 4d 08             	mov    0x8(%ebp),%ecx
   8:	8b 55 10             	mov    0x10(%ebp),%edx
   b:	8b 45 0c             	mov    0xc(%ebp),%eax
   e:	89 cb                	mov    %ecx,%ebx
  10:	89 df                	mov    %ebx,%edi
  12:	89 d1                	mov    %edx,%ecx
  14:	fc                   	cld    
  15:	f3 aa                	rep stos %al,%es:(%edi)
  17:	89 ca                	mov    %ecx,%edx
  19:	89 fb                	mov    %edi,%ebx
  1b:	89 5d 08             	mov    %ebx,0x8(%ebp)
  1e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  21:	5b                   	pop    %ebx
  22:	5f                   	pop    %edi
  23:	5d                   	pop    %ebp
  24:	c3                   	ret    

00000025 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  25:	55                   	push   %ebp
  26:	89 e5                	mov    %esp,%ebp
  28:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  2b:	8b 45 08             	mov    0x8(%ebp),%eax
  2e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  31:	90                   	nop
  32:	8b 45 0c             	mov    0xc(%ebp),%eax
  35:	0f b6 10             	movzbl (%eax),%edx
  38:	8b 45 08             	mov    0x8(%ebp),%eax
  3b:	88 10                	mov    %dl,(%eax)
  3d:	8b 45 08             	mov    0x8(%ebp),%eax
  40:	0f b6 00             	movzbl (%eax),%eax
  43:	84 c0                	test   %al,%al
  45:	0f 95 c0             	setne  %al
  48:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  4c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  50:	84 c0                	test   %al,%al
  52:	75 de                	jne    32 <strcpy+0xd>
    ;
  return os;
  54:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  57:	c9                   	leave  
  58:	c3                   	ret    

00000059 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  59:	55                   	push   %ebp
  5a:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  5c:	eb 08                	jmp    66 <strcmp+0xd>
    p++, q++;
  5e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  62:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  66:	8b 45 08             	mov    0x8(%ebp),%eax
  69:	0f b6 00             	movzbl (%eax),%eax
  6c:	84 c0                	test   %al,%al
  6e:	74 10                	je     80 <strcmp+0x27>
  70:	8b 45 08             	mov    0x8(%ebp),%eax
  73:	0f b6 10             	movzbl (%eax),%edx
  76:	8b 45 0c             	mov    0xc(%ebp),%eax
  79:	0f b6 00             	movzbl (%eax),%eax
  7c:	38 c2                	cmp    %al,%dl
  7e:	74 de                	je     5e <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  80:	8b 45 08             	mov    0x8(%ebp),%eax
  83:	0f b6 00             	movzbl (%eax),%eax
  86:	0f b6 d0             	movzbl %al,%edx
  89:	8b 45 0c             	mov    0xc(%ebp),%eax
  8c:	0f b6 00             	movzbl (%eax),%eax
  8f:	0f b6 c0             	movzbl %al,%eax
  92:	89 d1                	mov    %edx,%ecx
  94:	29 c1                	sub    %eax,%ecx
  96:	89 c8                	mov    %ecx,%eax
}
  98:	5d                   	pop    %ebp
  99:	c3                   	ret    

0000009a <strlen>:

uint
strlen(char *s)
{
  9a:	55                   	push   %ebp
  9b:	89 e5                	mov    %esp,%ebp
  9d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  a0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  a7:	eb 04                	jmp    ad <strlen+0x13>
  a9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
  b0:	03 45 08             	add    0x8(%ebp),%eax
  b3:	0f b6 00             	movzbl (%eax),%eax
  b6:	84 c0                	test   %al,%al
  b8:	75 ef                	jne    a9 <strlen+0xf>
    ;
  return n;
  ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  bd:	c9                   	leave  
  be:	c3                   	ret    

000000bf <memset>:

void*
memset(void *dst, int c, uint n)
{
  bf:	55                   	push   %ebp
  c0:	89 e5                	mov    %esp,%ebp
  c2:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
  c5:	8b 45 10             	mov    0x10(%ebp),%eax
  c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  d3:	8b 45 08             	mov    0x8(%ebp),%eax
  d6:	89 04 24             	mov    %eax,(%esp)
  d9:	e8 22 ff ff ff       	call   0 <stosb>
  return dst;
  de:	8b 45 08             	mov    0x8(%ebp),%eax
}
  e1:	c9                   	leave  
  e2:	c3                   	ret    

000000e3 <strchr>:

char*
strchr(const char *s, char c)
{
  e3:	55                   	push   %ebp
  e4:	89 e5                	mov    %esp,%ebp
  e6:	83 ec 04             	sub    $0x4,%esp
  e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  ec:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
  ef:	eb 14                	jmp    105 <strchr+0x22>
    if(*s == c)
  f1:	8b 45 08             	mov    0x8(%ebp),%eax
  f4:	0f b6 00             	movzbl (%eax),%eax
  f7:	3a 45 fc             	cmp    -0x4(%ebp),%al
  fa:	75 05                	jne    101 <strchr+0x1e>
      return (char*)s;
  fc:	8b 45 08             	mov    0x8(%ebp),%eax
  ff:	eb 13                	jmp    114 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 101:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 105:	8b 45 08             	mov    0x8(%ebp),%eax
 108:	0f b6 00             	movzbl (%eax),%eax
 10b:	84 c0                	test   %al,%al
 10d:	75 e2                	jne    f1 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 10f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 114:	c9                   	leave  
 115:	c3                   	ret    

00000116 <gets>:

char*
gets(char *buf, int max)
{
 116:	55                   	push   %ebp
 117:	89 e5                	mov    %esp,%ebp
 119:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 11c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 123:	eb 44                	jmp    169 <gets+0x53>
    cc = read(0, &c, 1);
 125:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 12c:	00 
 12d:	8d 45 ef             	lea    -0x11(%ebp),%eax
 130:	89 44 24 04          	mov    %eax,0x4(%esp)
 134:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 13b:	e8 3c 01 00 00       	call   27c <read>
 140:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 143:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 147:	7e 2d                	jle    176 <gets+0x60>
      break;
    buf[i++] = c;
 149:	8b 45 f4             	mov    -0xc(%ebp),%eax
 14c:	03 45 08             	add    0x8(%ebp),%eax
 14f:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 153:	88 10                	mov    %dl,(%eax)
 155:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 159:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 15d:	3c 0a                	cmp    $0xa,%al
 15f:	74 16                	je     177 <gets+0x61>
 161:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 165:	3c 0d                	cmp    $0xd,%al
 167:	74 0e                	je     177 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 169:	8b 45 f4             	mov    -0xc(%ebp),%eax
 16c:	83 c0 01             	add    $0x1,%eax
 16f:	3b 45 0c             	cmp    0xc(%ebp),%eax
 172:	7c b1                	jl     125 <gets+0xf>
 174:	eb 01                	jmp    177 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 176:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 177:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17a:	03 45 08             	add    0x8(%ebp),%eax
 17d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 180:	8b 45 08             	mov    0x8(%ebp),%eax
}
 183:	c9                   	leave  
 184:	c3                   	ret    

00000185 <stat>:

int
stat(char *n, struct stat *st)
{
 185:	55                   	push   %ebp
 186:	89 e5                	mov    %esp,%ebp
 188:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 18b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 192:	00 
 193:	8b 45 08             	mov    0x8(%ebp),%eax
 196:	89 04 24             	mov    %eax,(%esp)
 199:	e8 06 01 00 00       	call   2a4 <open>
 19e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1a5:	79 07                	jns    1ae <stat+0x29>
    return -1;
 1a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1ac:	eb 23                	jmp    1d1 <stat+0x4c>
  r = fstat(fd, st);
 1ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b1:	89 44 24 04          	mov    %eax,0x4(%esp)
 1b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b8:	89 04 24             	mov    %eax,(%esp)
 1bb:	e8 fc 00 00 00       	call   2bc <fstat>
 1c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c6:	89 04 24             	mov    %eax,(%esp)
 1c9:	e8 be 00 00 00       	call   28c <close>
  return r;
 1ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1d1:	c9                   	leave  
 1d2:	c3                   	ret    

000001d3 <atoi>:

int
atoi(const char *s)
{
 1d3:	55                   	push   %ebp
 1d4:	89 e5                	mov    %esp,%ebp
 1d6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1d9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 1e0:	eb 23                	jmp    205 <atoi+0x32>
    n = n*10 + *s++ - '0';
 1e2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1e5:	89 d0                	mov    %edx,%eax
 1e7:	c1 e0 02             	shl    $0x2,%eax
 1ea:	01 d0                	add    %edx,%eax
 1ec:	01 c0                	add    %eax,%eax
 1ee:	89 c2                	mov    %eax,%edx
 1f0:	8b 45 08             	mov    0x8(%ebp),%eax
 1f3:	0f b6 00             	movzbl (%eax),%eax
 1f6:	0f be c0             	movsbl %al,%eax
 1f9:	01 d0                	add    %edx,%eax
 1fb:	83 e8 30             	sub    $0x30,%eax
 1fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
 201:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 205:	8b 45 08             	mov    0x8(%ebp),%eax
 208:	0f b6 00             	movzbl (%eax),%eax
 20b:	3c 2f                	cmp    $0x2f,%al
 20d:	7e 0a                	jle    219 <atoi+0x46>
 20f:	8b 45 08             	mov    0x8(%ebp),%eax
 212:	0f b6 00             	movzbl (%eax),%eax
 215:	3c 39                	cmp    $0x39,%al
 217:	7e c9                	jle    1e2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 219:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 21c:	c9                   	leave  
 21d:	c3                   	ret    

0000021e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 21e:	55                   	push   %ebp
 21f:	89 e5                	mov    %esp,%ebp
 221:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 224:	8b 45 08             	mov    0x8(%ebp),%eax
 227:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 22a:	8b 45 0c             	mov    0xc(%ebp),%eax
 22d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 230:	eb 13                	jmp    245 <memmove+0x27>
    *dst++ = *src++;
 232:	8b 45 f8             	mov    -0x8(%ebp),%eax
 235:	0f b6 10             	movzbl (%eax),%edx
 238:	8b 45 fc             	mov    -0x4(%ebp),%eax
 23b:	88 10                	mov    %dl,(%eax)
 23d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 241:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 245:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 249:	0f 9f c0             	setg   %al
 24c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 250:	84 c0                	test   %al,%al
 252:	75 de                	jne    232 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 254:	8b 45 08             	mov    0x8(%ebp),%eax
}
 257:	c9                   	leave  
 258:	c3                   	ret    
 259:	90                   	nop
 25a:	90                   	nop
 25b:	90                   	nop

0000025c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 25c:	b8 01 00 00 00       	mov    $0x1,%eax
 261:	cd 40                	int    $0x40
 263:	c3                   	ret    

00000264 <exit>:
SYSCALL(exit)
 264:	b8 02 00 00 00       	mov    $0x2,%eax
 269:	cd 40                	int    $0x40
 26b:	c3                   	ret    

0000026c <wait>:
SYSCALL(wait)
 26c:	b8 03 00 00 00       	mov    $0x3,%eax
 271:	cd 40                	int    $0x40
 273:	c3                   	ret    

00000274 <pipe>:
SYSCALL(pipe)
 274:	b8 04 00 00 00       	mov    $0x4,%eax
 279:	cd 40                	int    $0x40
 27b:	c3                   	ret    

0000027c <read>:
SYSCALL(read)
 27c:	b8 05 00 00 00       	mov    $0x5,%eax
 281:	cd 40                	int    $0x40
 283:	c3                   	ret    

00000284 <write>:
SYSCALL(write)
 284:	b8 10 00 00 00       	mov    $0x10,%eax
 289:	cd 40                	int    $0x40
 28b:	c3                   	ret    

0000028c <close>:
SYSCALL(close)
 28c:	b8 15 00 00 00       	mov    $0x15,%eax
 291:	cd 40                	int    $0x40
 293:	c3                   	ret    

00000294 <kill>:
SYSCALL(kill)
 294:	b8 06 00 00 00       	mov    $0x6,%eax
 299:	cd 40                	int    $0x40
 29b:	c3                   	ret    

0000029c <exec>:
SYSCALL(exec)
 29c:	b8 07 00 00 00       	mov    $0x7,%eax
 2a1:	cd 40                	int    $0x40
 2a3:	c3                   	ret    

000002a4 <open>:
SYSCALL(open)
 2a4:	b8 0f 00 00 00       	mov    $0xf,%eax
 2a9:	cd 40                	int    $0x40
 2ab:	c3                   	ret    

000002ac <mknod>:
SYSCALL(mknod)
 2ac:	b8 11 00 00 00       	mov    $0x11,%eax
 2b1:	cd 40                	int    $0x40
 2b3:	c3                   	ret    

000002b4 <unlink>:
SYSCALL(unlink)
 2b4:	b8 12 00 00 00       	mov    $0x12,%eax
 2b9:	cd 40                	int    $0x40
 2bb:	c3                   	ret    

000002bc <fstat>:
SYSCALL(fstat)
 2bc:	b8 08 00 00 00       	mov    $0x8,%eax
 2c1:	cd 40                	int    $0x40
 2c3:	c3                   	ret    

000002c4 <link>:
SYSCALL(link)
 2c4:	b8 13 00 00 00       	mov    $0x13,%eax
 2c9:	cd 40                	int    $0x40
 2cb:	c3                   	ret    

000002cc <mkdir>:
SYSCALL(mkdir)
 2cc:	b8 14 00 00 00       	mov    $0x14,%eax
 2d1:	cd 40                	int    $0x40
 2d3:	c3                   	ret    

000002d4 <chdir>:
SYSCALL(chdir)
 2d4:	b8 09 00 00 00       	mov    $0x9,%eax
 2d9:	cd 40                	int    $0x40
 2db:	c3                   	ret    

000002dc <dup>:
SYSCALL(dup)
 2dc:	b8 0a 00 00 00       	mov    $0xa,%eax
 2e1:	cd 40                	int    $0x40
 2e3:	c3                   	ret    

000002e4 <getpid>:
SYSCALL(getpid)
 2e4:	b8 0b 00 00 00       	mov    $0xb,%eax
 2e9:	cd 40                	int    $0x40
 2eb:	c3                   	ret    

000002ec <sbrk>:
SYSCALL(sbrk)
 2ec:	b8 0c 00 00 00       	mov    $0xc,%eax
 2f1:	cd 40                	int    $0x40
 2f3:	c3                   	ret    

000002f4 <sleep>:
SYSCALL(sleep)
 2f4:	b8 0d 00 00 00       	mov    $0xd,%eax
 2f9:	cd 40                	int    $0x40
 2fb:	c3                   	ret    

000002fc <uptime>:
SYSCALL(uptime)
 2fc:	b8 0e 00 00 00       	mov    $0xe,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret    

00000304 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 304:	55                   	push   %ebp
 305:	89 e5                	mov    %esp,%ebp
 307:	83 ec 28             	sub    $0x28,%esp
 30a:	8b 45 0c             	mov    0xc(%ebp),%eax
 30d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 310:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 317:	00 
 318:	8d 45 f4             	lea    -0xc(%ebp),%eax
 31b:	89 44 24 04          	mov    %eax,0x4(%esp)
 31f:	8b 45 08             	mov    0x8(%ebp),%eax
 322:	89 04 24             	mov    %eax,(%esp)
 325:	e8 5a ff ff ff       	call   284 <write>
}
 32a:	c9                   	leave  
 32b:	c3                   	ret    

0000032c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 32c:	55                   	push   %ebp
 32d:	89 e5                	mov    %esp,%ebp
 32f:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 332:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 339:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 33d:	74 17                	je     356 <printint+0x2a>
 33f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 343:	79 11                	jns    356 <printint+0x2a>
    neg = 1;
 345:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 34c:	8b 45 0c             	mov    0xc(%ebp),%eax
 34f:	f7 d8                	neg    %eax
 351:	89 45 ec             	mov    %eax,-0x14(%ebp)
 354:	eb 06                	jmp    35c <printint+0x30>
  } else {
    x = xx;
 356:	8b 45 0c             	mov    0xc(%ebp),%eax
 359:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 35c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 363:	8b 4d 10             	mov    0x10(%ebp),%ecx
 366:	8b 45 ec             	mov    -0x14(%ebp),%eax
 369:	ba 00 00 00 00       	mov    $0x0,%edx
 36e:	f7 f1                	div    %ecx
 370:	89 d0                	mov    %edx,%eax
 372:	0f b6 90 c8 09 00 00 	movzbl 0x9c8(%eax),%edx
 379:	8d 45 dc             	lea    -0x24(%ebp),%eax
 37c:	03 45 f4             	add    -0xc(%ebp),%eax
 37f:	88 10                	mov    %dl,(%eax)
 381:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 385:	8b 55 10             	mov    0x10(%ebp),%edx
 388:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 38b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 38e:	ba 00 00 00 00       	mov    $0x0,%edx
 393:	f7 75 d4             	divl   -0x2c(%ebp)
 396:	89 45 ec             	mov    %eax,-0x14(%ebp)
 399:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 39d:	75 c4                	jne    363 <printint+0x37>
  if(neg)
 39f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3a3:	74 2a                	je     3cf <printint+0xa3>
    buf[i++] = '-';
 3a5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3a8:	03 45 f4             	add    -0xc(%ebp),%eax
 3ab:	c6 00 2d             	movb   $0x2d,(%eax)
 3ae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 3b2:	eb 1b                	jmp    3cf <printint+0xa3>
    putc(fd, buf[i]);
 3b4:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3b7:	03 45 f4             	add    -0xc(%ebp),%eax
 3ba:	0f b6 00             	movzbl (%eax),%eax
 3bd:	0f be c0             	movsbl %al,%eax
 3c0:	89 44 24 04          	mov    %eax,0x4(%esp)
 3c4:	8b 45 08             	mov    0x8(%ebp),%eax
 3c7:	89 04 24             	mov    %eax,(%esp)
 3ca:	e8 35 ff ff ff       	call   304 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 3cf:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 3d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3d7:	79 db                	jns    3b4 <printint+0x88>
    putc(fd, buf[i]);
}
 3d9:	c9                   	leave  
 3da:	c3                   	ret    

000003db <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 3db:	55                   	push   %ebp
 3dc:	89 e5                	mov    %esp,%ebp
 3de:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 3e1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 3e8:	8d 45 0c             	lea    0xc(%ebp),%eax
 3eb:	83 c0 04             	add    $0x4,%eax
 3ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 3f1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 3f8:	e9 7d 01 00 00       	jmp    57a <printf+0x19f>
    c = fmt[i] & 0xff;
 3fd:	8b 55 0c             	mov    0xc(%ebp),%edx
 400:	8b 45 f0             	mov    -0x10(%ebp),%eax
 403:	01 d0                	add    %edx,%eax
 405:	0f b6 00             	movzbl (%eax),%eax
 408:	0f be c0             	movsbl %al,%eax
 40b:	25 ff 00 00 00       	and    $0xff,%eax
 410:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 413:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 417:	75 2c                	jne    445 <printf+0x6a>
      if(c == '%'){
 419:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 41d:	75 0c                	jne    42b <printf+0x50>
        state = '%';
 41f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 426:	e9 4b 01 00 00       	jmp    576 <printf+0x19b>
      } else {
        putc(fd, c);
 42b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 42e:	0f be c0             	movsbl %al,%eax
 431:	89 44 24 04          	mov    %eax,0x4(%esp)
 435:	8b 45 08             	mov    0x8(%ebp),%eax
 438:	89 04 24             	mov    %eax,(%esp)
 43b:	e8 c4 fe ff ff       	call   304 <putc>
 440:	e9 31 01 00 00       	jmp    576 <printf+0x19b>
      }
    } else if(state == '%'){
 445:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 449:	0f 85 27 01 00 00    	jne    576 <printf+0x19b>
      if(c == 'd'){
 44f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 453:	75 2d                	jne    482 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 455:	8b 45 e8             	mov    -0x18(%ebp),%eax
 458:	8b 00                	mov    (%eax),%eax
 45a:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 461:	00 
 462:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 469:	00 
 46a:	89 44 24 04          	mov    %eax,0x4(%esp)
 46e:	8b 45 08             	mov    0x8(%ebp),%eax
 471:	89 04 24             	mov    %eax,(%esp)
 474:	e8 b3 fe ff ff       	call   32c <printint>
        ap++;
 479:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 47d:	e9 ed 00 00 00       	jmp    56f <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 482:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 486:	74 06                	je     48e <printf+0xb3>
 488:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 48c:	75 2d                	jne    4bb <printf+0xe0>
        printint(fd, *ap, 16, 0);
 48e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 491:	8b 00                	mov    (%eax),%eax
 493:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 49a:	00 
 49b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 4a2:	00 
 4a3:	89 44 24 04          	mov    %eax,0x4(%esp)
 4a7:	8b 45 08             	mov    0x8(%ebp),%eax
 4aa:	89 04 24             	mov    %eax,(%esp)
 4ad:	e8 7a fe ff ff       	call   32c <printint>
        ap++;
 4b2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4b6:	e9 b4 00 00 00       	jmp    56f <printf+0x194>
      } else if(c == 's'){
 4bb:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4bf:	75 46                	jne    507 <printf+0x12c>
        s = (char*)*ap;
 4c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4c4:	8b 00                	mov    (%eax),%eax
 4c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 4c9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 4cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4d1:	75 27                	jne    4fa <printf+0x11f>
          s = "(null)";
 4d3:	c7 45 f4 9f 07 00 00 	movl   $0x79f,-0xc(%ebp)
        while(*s != 0){
 4da:	eb 1e                	jmp    4fa <printf+0x11f>
          putc(fd, *s);
 4dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4df:	0f b6 00             	movzbl (%eax),%eax
 4e2:	0f be c0             	movsbl %al,%eax
 4e5:	89 44 24 04          	mov    %eax,0x4(%esp)
 4e9:	8b 45 08             	mov    0x8(%ebp),%eax
 4ec:	89 04 24             	mov    %eax,(%esp)
 4ef:	e8 10 fe ff ff       	call   304 <putc>
          s++;
 4f4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 4f8:	eb 01                	jmp    4fb <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 4fa:	90                   	nop
 4fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4fe:	0f b6 00             	movzbl (%eax),%eax
 501:	84 c0                	test   %al,%al
 503:	75 d7                	jne    4dc <printf+0x101>
 505:	eb 68                	jmp    56f <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 507:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 50b:	75 1d                	jne    52a <printf+0x14f>
        putc(fd, *ap);
 50d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 510:	8b 00                	mov    (%eax),%eax
 512:	0f be c0             	movsbl %al,%eax
 515:	89 44 24 04          	mov    %eax,0x4(%esp)
 519:	8b 45 08             	mov    0x8(%ebp),%eax
 51c:	89 04 24             	mov    %eax,(%esp)
 51f:	e8 e0 fd ff ff       	call   304 <putc>
        ap++;
 524:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 528:	eb 45                	jmp    56f <printf+0x194>
      } else if(c == '%'){
 52a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 52e:	75 17                	jne    547 <printf+0x16c>
        putc(fd, c);
 530:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 533:	0f be c0             	movsbl %al,%eax
 536:	89 44 24 04          	mov    %eax,0x4(%esp)
 53a:	8b 45 08             	mov    0x8(%ebp),%eax
 53d:	89 04 24             	mov    %eax,(%esp)
 540:	e8 bf fd ff ff       	call   304 <putc>
 545:	eb 28                	jmp    56f <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 547:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 54e:	00 
 54f:	8b 45 08             	mov    0x8(%ebp),%eax
 552:	89 04 24             	mov    %eax,(%esp)
 555:	e8 aa fd ff ff       	call   304 <putc>
        putc(fd, c);
 55a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 55d:	0f be c0             	movsbl %al,%eax
 560:	89 44 24 04          	mov    %eax,0x4(%esp)
 564:	8b 45 08             	mov    0x8(%ebp),%eax
 567:	89 04 24             	mov    %eax,(%esp)
 56a:	e8 95 fd ff ff       	call   304 <putc>
      }
      state = 0;
 56f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 576:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 57a:	8b 55 0c             	mov    0xc(%ebp),%edx
 57d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 580:	01 d0                	add    %edx,%eax
 582:	0f b6 00             	movzbl (%eax),%eax
 585:	84 c0                	test   %al,%al
 587:	0f 85 70 fe ff ff    	jne    3fd <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 58d:	c9                   	leave  
 58e:	c3                   	ret    
 58f:	90                   	nop

00000590 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 590:	55                   	push   %ebp
 591:	89 e5                	mov    %esp,%ebp
 593:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 596:	8b 45 08             	mov    0x8(%ebp),%eax
 599:	83 e8 08             	sub    $0x8,%eax
 59c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 59f:	a1 e4 09 00 00       	mov    0x9e4,%eax
 5a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5a7:	eb 24                	jmp    5cd <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5ac:	8b 00                	mov    (%eax),%eax
 5ae:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5b1:	77 12                	ja     5c5 <free+0x35>
 5b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5b6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5b9:	77 24                	ja     5df <free+0x4f>
 5bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5be:	8b 00                	mov    (%eax),%eax
 5c0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 5c3:	77 1a                	ja     5df <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5c8:	8b 00                	mov    (%eax),%eax
 5ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5d0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5d3:	76 d4                	jbe    5a9 <free+0x19>
 5d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5d8:	8b 00                	mov    (%eax),%eax
 5da:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 5dd:	76 ca                	jbe    5a9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 5df:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5e2:	8b 40 04             	mov    0x4(%eax),%eax
 5e5:	c1 e0 03             	shl    $0x3,%eax
 5e8:	89 c2                	mov    %eax,%edx
 5ea:	03 55 f8             	add    -0x8(%ebp),%edx
 5ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f0:	8b 00                	mov    (%eax),%eax
 5f2:	39 c2                	cmp    %eax,%edx
 5f4:	75 24                	jne    61a <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 5f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5f9:	8b 50 04             	mov    0x4(%eax),%edx
 5fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5ff:	8b 00                	mov    (%eax),%eax
 601:	8b 40 04             	mov    0x4(%eax),%eax
 604:	01 c2                	add    %eax,%edx
 606:	8b 45 f8             	mov    -0x8(%ebp),%eax
 609:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 60c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 60f:	8b 00                	mov    (%eax),%eax
 611:	8b 10                	mov    (%eax),%edx
 613:	8b 45 f8             	mov    -0x8(%ebp),%eax
 616:	89 10                	mov    %edx,(%eax)
 618:	eb 0a                	jmp    624 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 61a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61d:	8b 10                	mov    (%eax),%edx
 61f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 622:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 624:	8b 45 fc             	mov    -0x4(%ebp),%eax
 627:	8b 40 04             	mov    0x4(%eax),%eax
 62a:	c1 e0 03             	shl    $0x3,%eax
 62d:	03 45 fc             	add    -0x4(%ebp),%eax
 630:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 633:	75 20                	jne    655 <free+0xc5>
    p->s.size += bp->s.size;
 635:	8b 45 fc             	mov    -0x4(%ebp),%eax
 638:	8b 50 04             	mov    0x4(%eax),%edx
 63b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 63e:	8b 40 04             	mov    0x4(%eax),%eax
 641:	01 c2                	add    %eax,%edx
 643:	8b 45 fc             	mov    -0x4(%ebp),%eax
 646:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 649:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64c:	8b 10                	mov    (%eax),%edx
 64e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 651:	89 10                	mov    %edx,(%eax)
 653:	eb 08                	jmp    65d <free+0xcd>
  } else
    p->s.ptr = bp;
 655:	8b 45 fc             	mov    -0x4(%ebp),%eax
 658:	8b 55 f8             	mov    -0x8(%ebp),%edx
 65b:	89 10                	mov    %edx,(%eax)
  freep = p;
 65d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 660:	a3 e4 09 00 00       	mov    %eax,0x9e4
}
 665:	c9                   	leave  
 666:	c3                   	ret    

00000667 <morecore>:

static Header*
morecore(uint nu)
{
 667:	55                   	push   %ebp
 668:	89 e5                	mov    %esp,%ebp
 66a:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 66d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 674:	77 07                	ja     67d <morecore+0x16>
    nu = 4096;
 676:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 67d:	8b 45 08             	mov    0x8(%ebp),%eax
 680:	c1 e0 03             	shl    $0x3,%eax
 683:	89 04 24             	mov    %eax,(%esp)
 686:	e8 61 fc ff ff       	call   2ec <sbrk>
 68b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 68e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 692:	75 07                	jne    69b <morecore+0x34>
    return 0;
 694:	b8 00 00 00 00       	mov    $0x0,%eax
 699:	eb 22                	jmp    6bd <morecore+0x56>
  hp = (Header*)p;
 69b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 69e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6a4:	8b 55 08             	mov    0x8(%ebp),%edx
 6a7:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6ad:	83 c0 08             	add    $0x8,%eax
 6b0:	89 04 24             	mov    %eax,(%esp)
 6b3:	e8 d8 fe ff ff       	call   590 <free>
  return freep;
 6b8:	a1 e4 09 00 00       	mov    0x9e4,%eax
}
 6bd:	c9                   	leave  
 6be:	c3                   	ret    

000006bf <malloc>:

void*
malloc(uint nbytes)
{
 6bf:	55                   	push   %ebp
 6c0:	89 e5                	mov    %esp,%ebp
 6c2:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6c5:	8b 45 08             	mov    0x8(%ebp),%eax
 6c8:	83 c0 07             	add    $0x7,%eax
 6cb:	c1 e8 03             	shr    $0x3,%eax
 6ce:	83 c0 01             	add    $0x1,%eax
 6d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 6d4:	a1 e4 09 00 00       	mov    0x9e4,%eax
 6d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 6dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6e0:	75 23                	jne    705 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 6e2:	c7 45 f0 dc 09 00 00 	movl   $0x9dc,-0x10(%ebp)
 6e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6ec:	a3 e4 09 00 00       	mov    %eax,0x9e4
 6f1:	a1 e4 09 00 00       	mov    0x9e4,%eax
 6f6:	a3 dc 09 00 00       	mov    %eax,0x9dc
    base.s.size = 0;
 6fb:	c7 05 e0 09 00 00 00 	movl   $0x0,0x9e0
 702:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 705:	8b 45 f0             	mov    -0x10(%ebp),%eax
 708:	8b 00                	mov    (%eax),%eax
 70a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 70d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 710:	8b 40 04             	mov    0x4(%eax),%eax
 713:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 716:	72 4d                	jb     765 <malloc+0xa6>
      if(p->s.size == nunits)
 718:	8b 45 f4             	mov    -0xc(%ebp),%eax
 71b:	8b 40 04             	mov    0x4(%eax),%eax
 71e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 721:	75 0c                	jne    72f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 723:	8b 45 f4             	mov    -0xc(%ebp),%eax
 726:	8b 10                	mov    (%eax),%edx
 728:	8b 45 f0             	mov    -0x10(%ebp),%eax
 72b:	89 10                	mov    %edx,(%eax)
 72d:	eb 26                	jmp    755 <malloc+0x96>
      else {
        p->s.size -= nunits;
 72f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 732:	8b 40 04             	mov    0x4(%eax),%eax
 735:	89 c2                	mov    %eax,%edx
 737:	2b 55 ec             	sub    -0x14(%ebp),%edx
 73a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 740:	8b 45 f4             	mov    -0xc(%ebp),%eax
 743:	8b 40 04             	mov    0x4(%eax),%eax
 746:	c1 e0 03             	shl    $0x3,%eax
 749:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 74c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 752:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 755:	8b 45 f0             	mov    -0x10(%ebp),%eax
 758:	a3 e4 09 00 00       	mov    %eax,0x9e4
      return (void*)(p + 1);
 75d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 760:	83 c0 08             	add    $0x8,%eax
 763:	eb 38                	jmp    79d <malloc+0xde>
    }
    if(p == freep)
 765:	a1 e4 09 00 00       	mov    0x9e4,%eax
 76a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 76d:	75 1b                	jne    78a <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 76f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 772:	89 04 24             	mov    %eax,(%esp)
 775:	e8 ed fe ff ff       	call   667 <morecore>
 77a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 77d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 781:	75 07                	jne    78a <malloc+0xcb>
        return 0;
 783:	b8 00 00 00 00       	mov    $0x0,%eax
 788:	eb 13                	jmp    79d <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 78a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 790:	8b 45 f4             	mov    -0xc(%ebp),%eax
 793:	8b 00                	mov    (%eax),%eax
 795:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 798:	e9 70 ff ff ff       	jmp    70d <malloc+0x4e>
}
 79d:	c9                   	leave  
 79e:	c3                   	ret    
