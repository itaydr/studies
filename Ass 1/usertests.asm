
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

00000304 <waitpid>:
 304:	b8 16 00 00 00       	mov    $0x16,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret    

0000030c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 30c:	55                   	push   %ebp
 30d:	89 e5                	mov    %esp,%ebp
 30f:	83 ec 28             	sub    $0x28,%esp
 312:	8b 45 0c             	mov    0xc(%ebp),%eax
 315:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 318:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 31f:	00 
 320:	8d 45 f4             	lea    -0xc(%ebp),%eax
 323:	89 44 24 04          	mov    %eax,0x4(%esp)
 327:	8b 45 08             	mov    0x8(%ebp),%eax
 32a:	89 04 24             	mov    %eax,(%esp)
 32d:	e8 52 ff ff ff       	call   284 <write>
}
 332:	c9                   	leave  
 333:	c3                   	ret    

00000334 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 334:	55                   	push   %ebp
 335:	89 e5                	mov    %esp,%ebp
 337:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 33a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 341:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 345:	74 17                	je     35e <printint+0x2a>
 347:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 34b:	79 11                	jns    35e <printint+0x2a>
    neg = 1;
 34d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 354:	8b 45 0c             	mov    0xc(%ebp),%eax
 357:	f7 d8                	neg    %eax
 359:	89 45 ec             	mov    %eax,-0x14(%ebp)
 35c:	eb 06                	jmp    364 <printint+0x30>
  } else {
    x = xx;
 35e:	8b 45 0c             	mov    0xc(%ebp),%eax
 361:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 364:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 36b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 36e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 371:	ba 00 00 00 00       	mov    $0x0,%edx
 376:	f7 f1                	div    %ecx
 378:	89 d0                	mov    %edx,%eax
 37a:	0f b6 90 d0 09 00 00 	movzbl 0x9d0(%eax),%edx
 381:	8d 45 dc             	lea    -0x24(%ebp),%eax
 384:	03 45 f4             	add    -0xc(%ebp),%eax
 387:	88 10                	mov    %dl,(%eax)
 389:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 38d:	8b 55 10             	mov    0x10(%ebp),%edx
 390:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 393:	8b 45 ec             	mov    -0x14(%ebp),%eax
 396:	ba 00 00 00 00       	mov    $0x0,%edx
 39b:	f7 75 d4             	divl   -0x2c(%ebp)
 39e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3a1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3a5:	75 c4                	jne    36b <printint+0x37>
  if(neg)
 3a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3ab:	74 2a                	je     3d7 <printint+0xa3>
    buf[i++] = '-';
 3ad:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3b0:	03 45 f4             	add    -0xc(%ebp),%eax
 3b3:	c6 00 2d             	movb   $0x2d,(%eax)
 3b6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 3ba:	eb 1b                	jmp    3d7 <printint+0xa3>
    putc(fd, buf[i]);
 3bc:	8d 45 dc             	lea    -0x24(%ebp),%eax
 3bf:	03 45 f4             	add    -0xc(%ebp),%eax
 3c2:	0f b6 00             	movzbl (%eax),%eax
 3c5:	0f be c0             	movsbl %al,%eax
 3c8:	89 44 24 04          	mov    %eax,0x4(%esp)
 3cc:	8b 45 08             	mov    0x8(%ebp),%eax
 3cf:	89 04 24             	mov    %eax,(%esp)
 3d2:	e8 35 ff ff ff       	call   30c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 3d7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 3db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3df:	79 db                	jns    3bc <printint+0x88>
    putc(fd, buf[i]);
}
 3e1:	c9                   	leave  
 3e2:	c3                   	ret    

000003e3 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 3e3:	55                   	push   %ebp
 3e4:	89 e5                	mov    %esp,%ebp
 3e6:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 3e9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 3f0:	8d 45 0c             	lea    0xc(%ebp),%eax
 3f3:	83 c0 04             	add    $0x4,%eax
 3f6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 3f9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 400:	e9 7d 01 00 00       	jmp    582 <printf+0x19f>
    c = fmt[i] & 0xff;
 405:	8b 55 0c             	mov    0xc(%ebp),%edx
 408:	8b 45 f0             	mov    -0x10(%ebp),%eax
 40b:	01 d0                	add    %edx,%eax
 40d:	0f b6 00             	movzbl (%eax),%eax
 410:	0f be c0             	movsbl %al,%eax
 413:	25 ff 00 00 00       	and    $0xff,%eax
 418:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 41b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 41f:	75 2c                	jne    44d <printf+0x6a>
      if(c == '%'){
 421:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 425:	75 0c                	jne    433 <printf+0x50>
        state = '%';
 427:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 42e:	e9 4b 01 00 00       	jmp    57e <printf+0x19b>
      } else {
        putc(fd, c);
 433:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 436:	0f be c0             	movsbl %al,%eax
 439:	89 44 24 04          	mov    %eax,0x4(%esp)
 43d:	8b 45 08             	mov    0x8(%ebp),%eax
 440:	89 04 24             	mov    %eax,(%esp)
 443:	e8 c4 fe ff ff       	call   30c <putc>
 448:	e9 31 01 00 00       	jmp    57e <printf+0x19b>
      }
    } else if(state == '%'){
 44d:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 451:	0f 85 27 01 00 00    	jne    57e <printf+0x19b>
      if(c == 'd'){
 457:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 45b:	75 2d                	jne    48a <printf+0xa7>
        printint(fd, *ap, 10, 1);
 45d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 460:	8b 00                	mov    (%eax),%eax
 462:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 469:	00 
 46a:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 471:	00 
 472:	89 44 24 04          	mov    %eax,0x4(%esp)
 476:	8b 45 08             	mov    0x8(%ebp),%eax
 479:	89 04 24             	mov    %eax,(%esp)
 47c:	e8 b3 fe ff ff       	call   334 <printint>
        ap++;
 481:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 485:	e9 ed 00 00 00       	jmp    577 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 48a:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 48e:	74 06                	je     496 <printf+0xb3>
 490:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 494:	75 2d                	jne    4c3 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 496:	8b 45 e8             	mov    -0x18(%ebp),%eax
 499:	8b 00                	mov    (%eax),%eax
 49b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 4a2:	00 
 4a3:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 4aa:	00 
 4ab:	89 44 24 04          	mov    %eax,0x4(%esp)
 4af:	8b 45 08             	mov    0x8(%ebp),%eax
 4b2:	89 04 24             	mov    %eax,(%esp)
 4b5:	e8 7a fe ff ff       	call   334 <printint>
        ap++;
 4ba:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4be:	e9 b4 00 00 00       	jmp    577 <printf+0x194>
      } else if(c == 's'){
 4c3:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4c7:	75 46                	jne    50f <printf+0x12c>
        s = (char*)*ap;
 4c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4cc:	8b 00                	mov    (%eax),%eax
 4ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 4d1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 4d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4d9:	75 27                	jne    502 <printf+0x11f>
          s = "(null)";
 4db:	c7 45 f4 a7 07 00 00 	movl   $0x7a7,-0xc(%ebp)
        while(*s != 0){
 4e2:	eb 1e                	jmp    502 <printf+0x11f>
          putc(fd, *s);
 4e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e7:	0f b6 00             	movzbl (%eax),%eax
 4ea:	0f be c0             	movsbl %al,%eax
 4ed:	89 44 24 04          	mov    %eax,0x4(%esp)
 4f1:	8b 45 08             	mov    0x8(%ebp),%eax
 4f4:	89 04 24             	mov    %eax,(%esp)
 4f7:	e8 10 fe ff ff       	call   30c <putc>
          s++;
 4fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 500:	eb 01                	jmp    503 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 502:	90                   	nop
 503:	8b 45 f4             	mov    -0xc(%ebp),%eax
 506:	0f b6 00             	movzbl (%eax),%eax
 509:	84 c0                	test   %al,%al
 50b:	75 d7                	jne    4e4 <printf+0x101>
 50d:	eb 68                	jmp    577 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 50f:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 513:	75 1d                	jne    532 <printf+0x14f>
        putc(fd, *ap);
 515:	8b 45 e8             	mov    -0x18(%ebp),%eax
 518:	8b 00                	mov    (%eax),%eax
 51a:	0f be c0             	movsbl %al,%eax
 51d:	89 44 24 04          	mov    %eax,0x4(%esp)
 521:	8b 45 08             	mov    0x8(%ebp),%eax
 524:	89 04 24             	mov    %eax,(%esp)
 527:	e8 e0 fd ff ff       	call   30c <putc>
        ap++;
 52c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 530:	eb 45                	jmp    577 <printf+0x194>
      } else if(c == '%'){
 532:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 536:	75 17                	jne    54f <printf+0x16c>
        putc(fd, c);
 538:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 53b:	0f be c0             	movsbl %al,%eax
 53e:	89 44 24 04          	mov    %eax,0x4(%esp)
 542:	8b 45 08             	mov    0x8(%ebp),%eax
 545:	89 04 24             	mov    %eax,(%esp)
 548:	e8 bf fd ff ff       	call   30c <putc>
 54d:	eb 28                	jmp    577 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 54f:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 556:	00 
 557:	8b 45 08             	mov    0x8(%ebp),%eax
 55a:	89 04 24             	mov    %eax,(%esp)
 55d:	e8 aa fd ff ff       	call   30c <putc>
        putc(fd, c);
 562:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 565:	0f be c0             	movsbl %al,%eax
 568:	89 44 24 04          	mov    %eax,0x4(%esp)
 56c:	8b 45 08             	mov    0x8(%ebp),%eax
 56f:	89 04 24             	mov    %eax,(%esp)
 572:	e8 95 fd ff ff       	call   30c <putc>
      }
      state = 0;
 577:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 57e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 582:	8b 55 0c             	mov    0xc(%ebp),%edx
 585:	8b 45 f0             	mov    -0x10(%ebp),%eax
 588:	01 d0                	add    %edx,%eax
 58a:	0f b6 00             	movzbl (%eax),%eax
 58d:	84 c0                	test   %al,%al
 58f:	0f 85 70 fe ff ff    	jne    405 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 595:	c9                   	leave  
 596:	c3                   	ret    
 597:	90                   	nop

00000598 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 598:	55                   	push   %ebp
 599:	89 e5                	mov    %esp,%ebp
 59b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 59e:	8b 45 08             	mov    0x8(%ebp),%eax
 5a1:	83 e8 08             	sub    $0x8,%eax
 5a4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5a7:	a1 ec 09 00 00       	mov    0x9ec,%eax
 5ac:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5af:	eb 24                	jmp    5d5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5b4:	8b 00                	mov    (%eax),%eax
 5b6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5b9:	77 12                	ja     5cd <free+0x35>
 5bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5be:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5c1:	77 24                	ja     5e7 <free+0x4f>
 5c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5c6:	8b 00                	mov    (%eax),%eax
 5c8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 5cb:	77 1a                	ja     5e7 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5d0:	8b 00                	mov    (%eax),%eax
 5d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5d8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5db:	76 d4                	jbe    5b1 <free+0x19>
 5dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5e0:	8b 00                	mov    (%eax),%eax
 5e2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 5e5:	76 ca                	jbe    5b1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 5e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5ea:	8b 40 04             	mov    0x4(%eax),%eax
 5ed:	c1 e0 03             	shl    $0x3,%eax
 5f0:	89 c2                	mov    %eax,%edx
 5f2:	03 55 f8             	add    -0x8(%ebp),%edx
 5f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f8:	8b 00                	mov    (%eax),%eax
 5fa:	39 c2                	cmp    %eax,%edx
 5fc:	75 24                	jne    622 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 5fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
 601:	8b 50 04             	mov    0x4(%eax),%edx
 604:	8b 45 fc             	mov    -0x4(%ebp),%eax
 607:	8b 00                	mov    (%eax),%eax
 609:	8b 40 04             	mov    0x4(%eax),%eax
 60c:	01 c2                	add    %eax,%edx
 60e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 611:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 614:	8b 45 fc             	mov    -0x4(%ebp),%eax
 617:	8b 00                	mov    (%eax),%eax
 619:	8b 10                	mov    (%eax),%edx
 61b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 61e:	89 10                	mov    %edx,(%eax)
 620:	eb 0a                	jmp    62c <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 622:	8b 45 fc             	mov    -0x4(%ebp),%eax
 625:	8b 10                	mov    (%eax),%edx
 627:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 62c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62f:	8b 40 04             	mov    0x4(%eax),%eax
 632:	c1 e0 03             	shl    $0x3,%eax
 635:	03 45 fc             	add    -0x4(%ebp),%eax
 638:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 63b:	75 20                	jne    65d <free+0xc5>
    p->s.size += bp->s.size;
 63d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 640:	8b 50 04             	mov    0x4(%eax),%edx
 643:	8b 45 f8             	mov    -0x8(%ebp),%eax
 646:	8b 40 04             	mov    0x4(%eax),%eax
 649:	01 c2                	add    %eax,%edx
 64b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 651:	8b 45 f8             	mov    -0x8(%ebp),%eax
 654:	8b 10                	mov    (%eax),%edx
 656:	8b 45 fc             	mov    -0x4(%ebp),%eax
 659:	89 10                	mov    %edx,(%eax)
 65b:	eb 08                	jmp    665 <free+0xcd>
  } else
    p->s.ptr = bp;
 65d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 660:	8b 55 f8             	mov    -0x8(%ebp),%edx
 663:	89 10                	mov    %edx,(%eax)
  freep = p;
 665:	8b 45 fc             	mov    -0x4(%ebp),%eax
 668:	a3 ec 09 00 00       	mov    %eax,0x9ec
}
 66d:	c9                   	leave  
 66e:	c3                   	ret    

0000066f <morecore>:

static Header*
morecore(uint nu)
{
 66f:	55                   	push   %ebp
 670:	89 e5                	mov    %esp,%ebp
 672:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 675:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 67c:	77 07                	ja     685 <morecore+0x16>
    nu = 4096;
 67e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 685:	8b 45 08             	mov    0x8(%ebp),%eax
 688:	c1 e0 03             	shl    $0x3,%eax
 68b:	89 04 24             	mov    %eax,(%esp)
 68e:	e8 59 fc ff ff       	call   2ec <sbrk>
 693:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 696:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 69a:	75 07                	jne    6a3 <morecore+0x34>
    return 0;
 69c:	b8 00 00 00 00       	mov    $0x0,%eax
 6a1:	eb 22                	jmp    6c5 <morecore+0x56>
  hp = (Header*)p;
 6a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6ac:	8b 55 08             	mov    0x8(%ebp),%edx
 6af:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6b5:	83 c0 08             	add    $0x8,%eax
 6b8:	89 04 24             	mov    %eax,(%esp)
 6bb:	e8 d8 fe ff ff       	call   598 <free>
  return freep;
 6c0:	a1 ec 09 00 00       	mov    0x9ec,%eax
}
 6c5:	c9                   	leave  
 6c6:	c3                   	ret    

000006c7 <malloc>:

void*
malloc(uint nbytes)
{
 6c7:	55                   	push   %ebp
 6c8:	89 e5                	mov    %esp,%ebp
 6ca:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6cd:	8b 45 08             	mov    0x8(%ebp),%eax
 6d0:	83 c0 07             	add    $0x7,%eax
 6d3:	c1 e8 03             	shr    $0x3,%eax
 6d6:	83 c0 01             	add    $0x1,%eax
 6d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 6dc:	a1 ec 09 00 00       	mov    0x9ec,%eax
 6e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 6e4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6e8:	75 23                	jne    70d <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 6ea:	c7 45 f0 e4 09 00 00 	movl   $0x9e4,-0x10(%ebp)
 6f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6f4:	a3 ec 09 00 00       	mov    %eax,0x9ec
 6f9:	a1 ec 09 00 00       	mov    0x9ec,%eax
 6fe:	a3 e4 09 00 00       	mov    %eax,0x9e4
    base.s.size = 0;
 703:	c7 05 e8 09 00 00 00 	movl   $0x0,0x9e8
 70a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 70d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 710:	8b 00                	mov    (%eax),%eax
 712:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 715:	8b 45 f4             	mov    -0xc(%ebp),%eax
 718:	8b 40 04             	mov    0x4(%eax),%eax
 71b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 71e:	72 4d                	jb     76d <malloc+0xa6>
      if(p->s.size == nunits)
 720:	8b 45 f4             	mov    -0xc(%ebp),%eax
 723:	8b 40 04             	mov    0x4(%eax),%eax
 726:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 729:	75 0c                	jne    737 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 72b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72e:	8b 10                	mov    (%eax),%edx
 730:	8b 45 f0             	mov    -0x10(%ebp),%eax
 733:	89 10                	mov    %edx,(%eax)
 735:	eb 26                	jmp    75d <malloc+0x96>
      else {
        p->s.size -= nunits;
 737:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73a:	8b 40 04             	mov    0x4(%eax),%eax
 73d:	89 c2                	mov    %eax,%edx
 73f:	2b 55 ec             	sub    -0x14(%ebp),%edx
 742:	8b 45 f4             	mov    -0xc(%ebp),%eax
 745:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 748:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74b:	8b 40 04             	mov    0x4(%eax),%eax
 74e:	c1 e0 03             	shl    $0x3,%eax
 751:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 754:	8b 45 f4             	mov    -0xc(%ebp),%eax
 757:	8b 55 ec             	mov    -0x14(%ebp),%edx
 75a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 75d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 760:	a3 ec 09 00 00       	mov    %eax,0x9ec
      return (void*)(p + 1);
 765:	8b 45 f4             	mov    -0xc(%ebp),%eax
 768:	83 c0 08             	add    $0x8,%eax
 76b:	eb 38                	jmp    7a5 <malloc+0xde>
    }
    if(p == freep)
 76d:	a1 ec 09 00 00       	mov    0x9ec,%eax
 772:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 775:	75 1b                	jne    792 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 777:	8b 45 ec             	mov    -0x14(%ebp),%eax
 77a:	89 04 24             	mov    %eax,(%esp)
 77d:	e8 ed fe ff ff       	call   66f <morecore>
 782:	89 45 f4             	mov    %eax,-0xc(%ebp)
 785:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 789:	75 07                	jne    792 <malloc+0xcb>
        return 0;
 78b:	b8 00 00 00 00       	mov    $0x0,%eax
 790:	eb 13                	jmp    7a5 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 792:	8b 45 f4             	mov    -0xc(%ebp),%eax
 795:	89 45 f0             	mov    %eax,-0x10(%ebp)
 798:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79b:	8b 00                	mov    (%eax),%eax
 79d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 7a0:	e9 70 ff ff ff       	jmp    715 <malloc+0x4e>
}
 7a5:	c9                   	leave  
 7a6:	c3                   	ret    
