
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 d6 10 80       	mov    $0x8010d650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 ab 37 10 80       	mov    $0x801037ab,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 d8 89 10 	movl   $0x801089d8,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
80100049:	e8 68 52 00 00       	call   801052b6 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 70 15 11 80 64 	movl   $0x80111564,0x80111570
80100055:	15 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 74 15 11 80 64 	movl   $0x80111564,0x80111574
8010005f:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 94 d6 10 80 	movl   $0x8010d694,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 74 15 11 80    	mov    0x80111574,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 64 15 11 80 	movl   $0x80111564,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 74 15 11 80       	mov    0x80111574,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 74 15 11 80       	mov    %eax,0x80111574

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 64 15 11 80 	cmpl   $0x80111564,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
801000bd:	e8 15 52 00 00       	call   801052d7 <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 74 15 11 80       	mov    0x80111574,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->sector == sector){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	89 c2                	mov    %eax,%edx
801000f5:	83 ca 01             	or     $0x1,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
80100104:	e8 30 52 00 00       	call   80105339 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 d6 10 	movl   $0x8010d660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 cd 4e 00 00       	call   80104ff1 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 64 15 11 80 	cmpl   $0x80111564,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 70 15 11 80       	mov    0x80111570,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
8010017c:	e8 b8 51 00 00       	call   80105339 <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 64 15 11 80 	cmpl   $0x80111564,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 df 89 10 80 	movl   $0x801089df,(%esp)
8010019f:	e8 99 03 00 00       	call   8010053d <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, sector);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 24 26 00 00       	call   801027fc <iderw>
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 f0 89 10 80 	movl   $0x801089f0,(%esp)
801001f6:	e8 42 03 00 00       	call   8010053d <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	89 c2                	mov    %eax,%edx
80100202:	83 ca 04             	or     $0x4,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 e7 25 00 00       	call   801027fc <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 f7 89 10 80 	movl   $0x801089f7,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
8010023c:	e8 96 50 00 00       	call   801052d7 <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 74 15 11 80    	mov    0x80111574,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 64 15 11 80 	movl   $0x80111564,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 74 15 11 80       	mov    0x80111574,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 74 15 11 80       	mov    %eax,0x80111574

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	89 c2                	mov    %eax,%edx
8010028f:	83 e2 fe             	and    $0xfffffffe,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 2b 4e 00 00       	call   801050cd <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
801002a9:	e8 8b 50 00 00       	call   80105339 <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	53                   	push   %ebx
801002b4:	83 ec 14             	sub    $0x14,%esp
801002b7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ba:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002be:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801002c2:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801002c6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801002ca:	ec                   	in     (%dx),%al
801002cb:	89 c3                	mov    %eax,%ebx
801002cd:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801002d0:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801002d4:	83 c4 14             	add    $0x14,%esp
801002d7:	5b                   	pop    %ebx
801002d8:	5d                   	pop    %ebp
801002d9:	c3                   	ret    

801002da <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002da:	55                   	push   %ebp
801002db:	89 e5                	mov    %esp,%ebp
801002dd:	83 ec 08             	sub    $0x8,%esp
801002e0:	8b 55 08             	mov    0x8(%ebp),%edx
801002e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801002e6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002ea:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002ed:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002f1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002f5:	ee                   	out    %al,(%dx)
}
801002f6:	c9                   	leave  
801002f7:	c3                   	ret    

801002f8 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002f8:	55                   	push   %ebp
801002f9:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002fb:	fa                   	cli    
}
801002fc:	5d                   	pop    %ebp
801002fd:	c3                   	ret    

801002fe <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002fe:	55                   	push   %ebp
801002ff:	89 e5                	mov    %esp,%ebp
80100301:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100304:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100308:	74 19                	je     80100323 <printint+0x25>
8010030a:	8b 45 08             	mov    0x8(%ebp),%eax
8010030d:	c1 e8 1f             	shr    $0x1f,%eax
80100310:	89 45 10             	mov    %eax,0x10(%ebp)
80100313:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100317:	74 0a                	je     80100323 <printint+0x25>
    x = -xx;
80100319:	8b 45 08             	mov    0x8(%ebp),%eax
8010031c:	f7 d8                	neg    %eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100321:	eb 06                	jmp    80100329 <printint+0x2b>
  else
    x = xx;
80100323:	8b 45 08             	mov    0x8(%ebp),%eax
80100326:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100329:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100333:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100336:	ba 00 00 00 00       	mov    $0x0,%edx
8010033b:	f7 f1                	div    %ecx
8010033d:	89 d0                	mov    %edx,%eax
8010033f:	0f b6 90 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%edx
80100346:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100349:	03 45 f4             	add    -0xc(%ebp),%eax
8010034c:	88 10                	mov    %dl,(%eax)
8010034e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
80100352:	8b 55 0c             	mov    0xc(%ebp),%edx
80100355:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80100358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035b:	ba 00 00 00 00       	mov    $0x0,%edx
80100360:	f7 75 d4             	divl   -0x2c(%ebp)
80100363:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100366:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010036a:	75 c4                	jne    80100330 <printint+0x32>

  if(sign)
8010036c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100370:	74 23                	je     80100395 <printint+0x97>
    buf[i++] = '-';
80100372:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100375:	03 45 f4             	add    -0xc(%ebp),%eax
80100378:	c6 00 2d             	movb   $0x2d,(%eax)
8010037b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
8010037f:	eb 14                	jmp    80100395 <printint+0x97>
    consputc(buf[i]);
80100381:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100384:	03 45 f4             	add    -0xc(%ebp),%eax
80100387:	0f b6 00             	movzbl (%eax),%eax
8010038a:	0f be c0             	movsbl %al,%eax
8010038d:	89 04 24             	mov    %eax,(%esp)
80100390:	e8 bb 03 00 00       	call   80100750 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
80100395:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100399:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010039d:	79 e2                	jns    80100381 <printint+0x83>
    consputc(buf[i]);
}
8010039f:	c9                   	leave  
801003a0:	c3                   	ret    

801003a1 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a1:	55                   	push   %ebp
801003a2:	89 e5                	mov    %esp,%ebp
801003a4:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a7:	a1 f4 c5 10 80       	mov    0x8010c5f4,%eax
801003ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003af:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b3:	74 0c                	je     801003c1 <cprintf+0x20>
    acquire(&cons.lock);
801003b5:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
801003bc:	e8 16 4f 00 00       	call   801052d7 <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 fe 89 10 80 	movl   $0x801089fe,(%esp)
801003cf:	e8 69 01 00 00       	call   8010053d <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d4:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e1:	e9 20 01 00 00       	jmp    80100506 <cprintf+0x165>
    if(c != '%'){
801003e6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003ea:	74 10                	je     801003fc <cprintf+0x5b>
      consputc(c);
801003ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ef:	89 04 24             	mov    %eax,(%esp)
801003f2:	e8 59 03 00 00       	call   80100750 <consputc>
      continue;
801003f7:	e9 06 01 00 00       	jmp    80100502 <cprintf+0x161>
    }
    c = fmt[++i] & 0xff;
801003fc:	8b 55 08             	mov    0x8(%ebp),%edx
801003ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100406:	01 d0                	add    %edx,%eax
80100408:	0f b6 00             	movzbl (%eax),%eax
8010040b:	0f be c0             	movsbl %al,%eax
8010040e:	25 ff 00 00 00       	and    $0xff,%eax
80100413:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100416:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010041a:	0f 84 08 01 00 00    	je     80100528 <cprintf+0x187>
      break;
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4d                	je     80100475 <cprintf+0xd4>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0x9f>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13b>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xae>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x149>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 53                	je     80100498 <cprintf+0xf7>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2b                	je     80100475 <cprintf+0xd4>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x149>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8b 00                	mov    (%eax),%eax
80100454:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
80100458:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010045f:	00 
80100460:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100467:	00 
80100468:	89 04 24             	mov    %eax,(%esp)
8010046b:	e8 8e fe ff ff       	call   801002fe <printint>
      break;
80100470:	e9 8d 00 00 00       	jmp    80100502 <cprintf+0x161>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100478:	8b 00                	mov    (%eax),%eax
8010047a:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
8010047e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100485:	00 
80100486:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
8010048d:	00 
8010048e:	89 04 24             	mov    %eax,(%esp)
80100491:	e8 68 fe ff ff       	call   801002fe <printint>
      break;
80100496:	eb 6a                	jmp    80100502 <cprintf+0x161>
    case 's':
      if((s = (char*)*argp++) == 0)
80100498:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049b:	8b 00                	mov    (%eax),%eax
8010049d:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004a0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004a4:	0f 94 c0             	sete   %al
801004a7:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
801004ab:	84 c0                	test   %al,%al
801004ad:	74 20                	je     801004cf <cprintf+0x12e>
        s = "(null)";
801004af:	c7 45 ec 07 8a 10 80 	movl   $0x80108a07,-0x14(%ebp)
      for(; *s; s++)
801004b6:	eb 17                	jmp    801004cf <cprintf+0x12e>
        consputc(*s);
801004b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004bb:	0f b6 00             	movzbl (%eax),%eax
801004be:	0f be c0             	movsbl %al,%eax
801004c1:	89 04 24             	mov    %eax,(%esp)
801004c4:	e8 87 02 00 00       	call   80100750 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004c9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004cd:	eb 01                	jmp    801004d0 <cprintf+0x12f>
801004cf:	90                   	nop
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 de                	jne    801004b8 <cprintf+0x117>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x161>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 68 02 00 00       	call   80100750 <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x161>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 5a 02 00 00       	call   80100750 <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 4f 02 00 00       	call   80100750 <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 c0 fe ff ff    	jne    801003e6 <cprintf+0x45>
80100526:	eb 01                	jmp    80100529 <cprintf+0x188>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
80100528:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
80100529:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052d:	74 0c                	je     8010053b <cprintf+0x19a>
    release(&cons.lock);
8010052f:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100536:	e8 fe 4d 00 00       	call   80105339 <release>
}
8010053b:	c9                   	leave  
8010053c:	c3                   	ret    

8010053d <panic>:

void
panic(char *s)
{
8010053d:	55                   	push   %ebp
8010053e:	89 e5                	mov    %esp,%ebp
80100540:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100543:	e8 b0 fd ff ff       	call   801002f8 <cli>
  cons.locking = 0;
80100548:	c7 05 f4 c5 10 80 00 	movl   $0x0,0x8010c5f4
8010054f:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
80100552:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f b6 c0             	movzbl %al,%eax
8010055e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100562:	c7 04 24 0e 8a 10 80 	movl   $0x80108a0e,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 1d 8a 10 80 	movl   $0x80108a1d,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 f1 4d 00 00       	call   80105388 <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 1f 8a 10 80 	movl   $0x80108a1f,(%esp)
801005b2:	e8 ea fd ff ff       	call   801003a1 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005bb:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bf:	7e df                	jle    801005a0 <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005c1:	c7 05 a0 c5 10 80 01 	movl   $0x1,0x8010c5a0
801005c8:	00 00 00 
  for(;;)
    ;
801005cb:	eb fe                	jmp    801005cb <panic+0x8e>

801005cd <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005cd:	55                   	push   %ebp
801005ce:	89 e5                	mov    %esp,%ebp
801005d0:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d3:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005da:	00 
801005db:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005e2:	e8 f3 fc ff ff       	call   801002da <outb>
  pos = inb(CRTPORT+1) << 8;
801005e7:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005ee:	e8 bd fc ff ff       	call   801002b0 <inb>
801005f3:	0f b6 c0             	movzbl %al,%eax
801005f6:	c1 e0 08             	shl    $0x8,%eax
801005f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005fc:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100603:	00 
80100604:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010060b:	e8 ca fc ff ff       	call   801002da <outb>
  pos |= inb(CRTPORT+1);
80100610:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100617:	e8 94 fc ff ff       	call   801002b0 <inb>
8010061c:	0f b6 c0             	movzbl %al,%eax
8010061f:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100622:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100626:	75 30                	jne    80100658 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100628:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010062b:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100630:	89 c8                	mov    %ecx,%eax
80100632:	f7 ea                	imul   %edx
80100634:	c1 fa 05             	sar    $0x5,%edx
80100637:	89 c8                	mov    %ecx,%eax
80100639:	c1 f8 1f             	sar    $0x1f,%eax
8010063c:	29 c2                	sub    %eax,%edx
8010063e:	89 d0                	mov    %edx,%eax
80100640:	c1 e0 02             	shl    $0x2,%eax
80100643:	01 d0                	add    %edx,%eax
80100645:	c1 e0 04             	shl    $0x4,%eax
80100648:	89 ca                	mov    %ecx,%edx
8010064a:	29 c2                	sub    %eax,%edx
8010064c:	b8 50 00 00 00       	mov    $0x50,%eax
80100651:	29 d0                	sub    %edx,%eax
80100653:	01 45 f4             	add    %eax,-0xc(%ebp)
80100656:	eb 32                	jmp    8010068a <cgaputc+0xbd>
  else if(c == BACKSPACE){
80100658:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065f:	75 0c                	jne    8010066d <cgaputc+0xa0>
    if(pos > 0) --pos;
80100661:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100665:	7e 23                	jle    8010068a <cgaputc+0xbd>
80100667:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010066b:	eb 1d                	jmp    8010068a <cgaputc+0xbd>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010066d:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100672:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100675:	01 d2                	add    %edx,%edx
80100677:	01 c2                	add    %eax,%edx
80100679:	8b 45 08             	mov    0x8(%ebp),%eax
8010067c:	66 25 ff 00          	and    $0xff,%ax
80100680:	80 cc 07             	or     $0x7,%ah
80100683:	66 89 02             	mov    %ax,(%edx)
80100686:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  if((pos/80) >= 24){  // Scroll up.
8010068a:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100691:	7e 53                	jle    801006e6 <cgaputc+0x119>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100693:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100698:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
8010069e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006a3:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006aa:	00 
801006ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801006af:	89 04 24             	mov    %eax,(%esp)
801006b2:	e8 42 4f 00 00       	call   801055f9 <memmove>
    pos -= 80;
801006b7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006bb:	b8 80 07 00 00       	mov    $0x780,%eax
801006c0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006c3:	01 c0                	add    %eax,%eax
801006c5:	8b 15 00 a0 10 80    	mov    0x8010a000,%edx
801006cb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006ce:	01 c9                	add    %ecx,%ecx
801006d0:	01 ca                	add    %ecx,%edx
801006d2:	89 44 24 08          	mov    %eax,0x8(%esp)
801006d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006dd:	00 
801006de:	89 14 24             	mov    %edx,(%esp)
801006e1:	e8 40 4e 00 00       	call   80105526 <memset>
  }
  
  outb(CRTPORT, 14);
801006e6:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801006ed:	00 
801006ee:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801006f5:	e8 e0 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos>>8);
801006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006fd:	c1 f8 08             	sar    $0x8,%eax
80100700:	0f b6 c0             	movzbl %al,%eax
80100703:	89 44 24 04          	mov    %eax,0x4(%esp)
80100707:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010070e:	e8 c7 fb ff ff       	call   801002da <outb>
  outb(CRTPORT, 15);
80100713:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010071a:	00 
8010071b:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100722:	e8 b3 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos);
80100727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010072a:	0f b6 c0             	movzbl %al,%eax
8010072d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100731:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100738:	e8 9d fb ff ff       	call   801002da <outb>
  crt[pos] = ' ' | 0x0700;
8010073d:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100742:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100745:	01 d2                	add    %edx,%edx
80100747:	01 d0                	add    %edx,%eax
80100749:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010074e:	c9                   	leave  
8010074f:	c3                   	ret    

80100750 <consputc>:

void
consputc(int c)
{
80100750:	55                   	push   %ebp
80100751:	89 e5                	mov    %esp,%ebp
80100753:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100756:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
8010075b:	85 c0                	test   %eax,%eax
8010075d:	74 07                	je     80100766 <consputc+0x16>
    cli();
8010075f:	e8 94 fb ff ff       	call   801002f8 <cli>
    for(;;)
      ;
80100764:	eb fe                	jmp    80100764 <consputc+0x14>
  }

  if(c == BACKSPACE){
80100766:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010076d:	75 26                	jne    80100795 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010076f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100776:	e8 a2 68 00 00       	call   8010701d <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 96 68 00 00       	call   8010701d <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 8a 68 00 00       	call   8010701d <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 7d 68 00 00       	call   8010701d <uartputc>
  cgaputc(c);
801007a0:	8b 45 08             	mov    0x8(%ebp),%eax
801007a3:	89 04 24             	mov    %eax,(%esp)
801007a6:	e8 22 fe ff ff       	call   801005cd <cgaputc>
}
801007ab:	c9                   	leave  
801007ac:	c3                   	ret    

801007ad <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007ad:	55                   	push   %ebp
801007ae:	89 e5                	mov    %esp,%ebp
801007b0:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
801007b3:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
801007ba:	e8 18 4b 00 00       	call   801052d7 <acquire>
  while((c = getc()) >= 0){
801007bf:	e9 41 01 00 00       	jmp    80100905 <consoleintr+0x158>
    switch(c){
801007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007c7:	83 f8 10             	cmp    $0x10,%eax
801007ca:	74 1e                	je     801007ea <consoleintr+0x3d>
801007cc:	83 f8 10             	cmp    $0x10,%eax
801007cf:	7f 0a                	jg     801007db <consoleintr+0x2e>
801007d1:	83 f8 08             	cmp    $0x8,%eax
801007d4:	74 68                	je     8010083e <consoleintr+0x91>
801007d6:	e9 94 00 00 00       	jmp    8010086f <consoleintr+0xc2>
801007db:	83 f8 15             	cmp    $0x15,%eax
801007de:	74 2f                	je     8010080f <consoleintr+0x62>
801007e0:	83 f8 7f             	cmp    $0x7f,%eax
801007e3:	74 59                	je     8010083e <consoleintr+0x91>
801007e5:	e9 85 00 00 00       	jmp    8010086f <consoleintr+0xc2>
    case C('P'):  // Process listing.
      procdump();
801007ea:	e8 84 49 00 00       	call   80105173 <procdump>
      break;
801007ef:	e9 11 01 00 00       	jmp    80100905 <consoleintr+0x158>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801007f4:	a1 3c 18 11 80       	mov    0x8011183c,%eax
801007f9:	83 e8 01             	sub    $0x1,%eax
801007fc:	a3 3c 18 11 80       	mov    %eax,0x8011183c
        consputc(BACKSPACE);
80100801:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100808:	e8 43 ff ff ff       	call   80100750 <consputc>
8010080d:	eb 01                	jmp    80100810 <consoleintr+0x63>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010080f:	90                   	nop
80100810:	8b 15 3c 18 11 80    	mov    0x8011183c,%edx
80100816:	a1 38 18 11 80       	mov    0x80111838,%eax
8010081b:	39 c2                	cmp    %eax,%edx
8010081d:	0f 84 db 00 00 00    	je     801008fe <consoleintr+0x151>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100823:	a1 3c 18 11 80       	mov    0x8011183c,%eax
80100828:	83 e8 01             	sub    $0x1,%eax
8010082b:	83 e0 7f             	and    $0x7f,%eax
8010082e:	0f b6 80 b4 17 11 80 	movzbl -0x7feee84c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100835:	3c 0a                	cmp    $0xa,%al
80100837:	75 bb                	jne    801007f4 <consoleintr+0x47>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100839:	e9 c0 00 00 00       	jmp    801008fe <consoleintr+0x151>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010083e:	8b 15 3c 18 11 80    	mov    0x8011183c,%edx
80100844:	a1 38 18 11 80       	mov    0x80111838,%eax
80100849:	39 c2                	cmp    %eax,%edx
8010084b:	0f 84 b0 00 00 00    	je     80100901 <consoleintr+0x154>
        input.e--;
80100851:	a1 3c 18 11 80       	mov    0x8011183c,%eax
80100856:	83 e8 01             	sub    $0x1,%eax
80100859:	a3 3c 18 11 80       	mov    %eax,0x8011183c
        consputc(BACKSPACE);
8010085e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100865:	e8 e6 fe ff ff       	call   80100750 <consputc>
      }
      break;
8010086a:	e9 92 00 00 00       	jmp    80100901 <consoleintr+0x154>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010086f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100873:	0f 84 8b 00 00 00    	je     80100904 <consoleintr+0x157>
80100879:	8b 15 3c 18 11 80    	mov    0x8011183c,%edx
8010087f:	a1 34 18 11 80       	mov    0x80111834,%eax
80100884:	89 d1                	mov    %edx,%ecx
80100886:	29 c1                	sub    %eax,%ecx
80100888:	89 c8                	mov    %ecx,%eax
8010088a:	83 f8 7f             	cmp    $0x7f,%eax
8010088d:	77 75                	ja     80100904 <consoleintr+0x157>
        c = (c == '\r') ? '\n' : c;
8010088f:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
80100893:	74 05                	je     8010089a <consoleintr+0xed>
80100895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100898:	eb 05                	jmp    8010089f <consoleintr+0xf2>
8010089a:	b8 0a 00 00 00       	mov    $0xa,%eax
8010089f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008a2:	a1 3c 18 11 80       	mov    0x8011183c,%eax
801008a7:	89 c1                	mov    %eax,%ecx
801008a9:	83 e1 7f             	and    $0x7f,%ecx
801008ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008af:	88 91 b4 17 11 80    	mov    %dl,-0x7feee84c(%ecx)
801008b5:	83 c0 01             	add    $0x1,%eax
801008b8:	a3 3c 18 11 80       	mov    %eax,0x8011183c
        consputc(c);
801008bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008c0:	89 04 24             	mov    %eax,(%esp)
801008c3:	e8 88 fe ff ff       	call   80100750 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008c8:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008cc:	74 18                	je     801008e6 <consoleintr+0x139>
801008ce:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008d2:	74 12                	je     801008e6 <consoleintr+0x139>
801008d4:	a1 3c 18 11 80       	mov    0x8011183c,%eax
801008d9:	8b 15 34 18 11 80    	mov    0x80111834,%edx
801008df:	83 ea 80             	sub    $0xffffff80,%edx
801008e2:	39 d0                	cmp    %edx,%eax
801008e4:	75 1e                	jne    80100904 <consoleintr+0x157>
          input.w = input.e;
801008e6:	a1 3c 18 11 80       	mov    0x8011183c,%eax
801008eb:	a3 38 18 11 80       	mov    %eax,0x80111838
          wakeup(&input.r);
801008f0:	c7 04 24 34 18 11 80 	movl   $0x80111834,(%esp)
801008f7:	e8 d1 47 00 00       	call   801050cd <wakeup>
        }
      }
      break;
801008fc:	eb 06                	jmp    80100904 <consoleintr+0x157>
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801008fe:	90                   	nop
801008ff:	eb 04                	jmp    80100905 <consoleintr+0x158>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100901:	90                   	nop
80100902:	eb 01                	jmp    80100905 <consoleintr+0x158>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
          input.w = input.e;
          wakeup(&input.r);
        }
      }
      break;
80100904:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80100905:	8b 45 08             	mov    0x8(%ebp),%eax
80100908:	ff d0                	call   *%eax
8010090a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010090d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100911:	0f 89 ad fe ff ff    	jns    801007c4 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100917:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
8010091e:	e8 16 4a 00 00       	call   80105339 <release>
}
80100923:	c9                   	leave  
80100924:	c3                   	ret    

80100925 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100925:	55                   	push   %ebp
80100926:	89 e5                	mov    %esp,%ebp
80100928:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
8010092b:	8b 45 08             	mov    0x8(%ebp),%eax
8010092e:	89 04 24             	mov    %eax,(%esp)
80100931:	e8 c8 10 00 00       	call   801019fe <iunlock>
  target = n;
80100936:	8b 45 10             	mov    0x10(%ebp),%eax
80100939:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
8010093c:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
80100943:	e8 8f 49 00 00       	call   801052d7 <acquire>
  while(n > 0){
80100948:	e9 a8 00 00 00       	jmp    801009f5 <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
8010094d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100953:	8b 40 24             	mov    0x24(%eax),%eax
80100956:	85 c0                	test   %eax,%eax
80100958:	74 21                	je     8010097b <consoleread+0x56>
        release(&input.lock);
8010095a:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
80100961:	e8 d3 49 00 00       	call   80105339 <release>
        ilock(ip);
80100966:	8b 45 08             	mov    0x8(%ebp),%eax
80100969:	89 04 24             	mov    %eax,(%esp)
8010096c:	e8 3f 0f 00 00       	call   801018b0 <ilock>
        return -1;
80100971:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100976:	e9 a9 00 00 00       	jmp    80100a24 <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
8010097b:	c7 44 24 04 80 17 11 	movl   $0x80111780,0x4(%esp)
80100982:	80 
80100983:	c7 04 24 34 18 11 80 	movl   $0x80111834,(%esp)
8010098a:	e8 62 46 00 00       	call   80104ff1 <sleep>
8010098f:	eb 01                	jmp    80100992 <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100991:	90                   	nop
80100992:	8b 15 34 18 11 80    	mov    0x80111834,%edx
80100998:	a1 38 18 11 80       	mov    0x80111838,%eax
8010099d:	39 c2                	cmp    %eax,%edx
8010099f:	74 ac                	je     8010094d <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009a1:	a1 34 18 11 80       	mov    0x80111834,%eax
801009a6:	89 c2                	mov    %eax,%edx
801009a8:	83 e2 7f             	and    $0x7f,%edx
801009ab:	0f b6 92 b4 17 11 80 	movzbl -0x7feee84c(%edx),%edx
801009b2:	0f be d2             	movsbl %dl,%edx
801009b5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801009b8:	83 c0 01             	add    $0x1,%eax
801009bb:	a3 34 18 11 80       	mov    %eax,0x80111834
    if(c == C('D')){  // EOF
801009c0:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009c4:	75 17                	jne    801009dd <consoleread+0xb8>
      if(n < target){
801009c6:	8b 45 10             	mov    0x10(%ebp),%eax
801009c9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009cc:	73 2f                	jae    801009fd <consoleread+0xd8>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009ce:	a1 34 18 11 80       	mov    0x80111834,%eax
801009d3:	83 e8 01             	sub    $0x1,%eax
801009d6:	a3 34 18 11 80       	mov    %eax,0x80111834
      }
      break;
801009db:	eb 20                	jmp    801009fd <consoleread+0xd8>
    }
    *dst++ = c;
801009dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801009e0:	89 c2                	mov    %eax,%edx
801009e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801009e5:	88 10                	mov    %dl,(%eax)
801009e7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    --n;
801009eb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
801009ef:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009f3:	74 0b                	je     80100a00 <consoleread+0xdb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
801009f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801009f9:	7f 96                	jg     80100991 <consoleread+0x6c>
801009fb:	eb 04                	jmp    80100a01 <consoleread+0xdc>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
801009fd:	90                   	nop
801009fe:	eb 01                	jmp    80100a01 <consoleread+0xdc>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a00:	90                   	nop
  }
  release(&input.lock);
80100a01:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
80100a08:	e8 2c 49 00 00       	call   80105339 <release>
  ilock(ip);
80100a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80100a10:	89 04 24             	mov    %eax,(%esp)
80100a13:	e8 98 0e 00 00       	call   801018b0 <ilock>

  return target - n;
80100a18:	8b 45 10             	mov    0x10(%ebp),%eax
80100a1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a1e:	89 d1                	mov    %edx,%ecx
80100a20:	29 c1                	sub    %eax,%ecx
80100a22:	89 c8                	mov    %ecx,%eax
}
80100a24:	c9                   	leave  
80100a25:	c3                   	ret    

80100a26 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a26:	55                   	push   %ebp
80100a27:	89 e5                	mov    %esp,%ebp
80100a29:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a2c:	8b 45 08             	mov    0x8(%ebp),%eax
80100a2f:	89 04 24             	mov    %eax,(%esp)
80100a32:	e8 c7 0f 00 00       	call   801019fe <iunlock>
  acquire(&cons.lock);
80100a37:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100a3e:	e8 94 48 00 00       	call   801052d7 <acquire>
  for(i = 0; i < n; i++)
80100a43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a4a:	eb 1d                	jmp    80100a69 <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a4f:	03 45 0c             	add    0xc(%ebp),%eax
80100a52:	0f b6 00             	movzbl (%eax),%eax
80100a55:	0f be c0             	movsbl %al,%eax
80100a58:	25 ff 00 00 00       	and    $0xff,%eax
80100a5d:	89 04 24             	mov    %eax,(%esp)
80100a60:	e8 eb fc ff ff       	call   80100750 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a65:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a6c:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a6f:	7c db                	jl     80100a4c <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a71:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100a78:	e8 bc 48 00 00       	call   80105339 <release>
  ilock(ip);
80100a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80100a80:	89 04 24             	mov    %eax,(%esp)
80100a83:	e8 28 0e 00 00       	call   801018b0 <ilock>

  return n;
80100a88:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100a8b:	c9                   	leave  
80100a8c:	c3                   	ret    

80100a8d <consoleinit>:

void
consoleinit(void)
{
80100a8d:	55                   	push   %ebp
80100a8e:	89 e5                	mov    %esp,%ebp
80100a90:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100a93:	c7 44 24 04 23 8a 10 	movl   $0x80108a23,0x4(%esp)
80100a9a:	80 
80100a9b:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100aa2:	e8 0f 48 00 00       	call   801052b6 <initlock>
  initlock(&input.lock, "input");
80100aa7:	c7 44 24 04 2b 8a 10 	movl   $0x80108a2b,0x4(%esp)
80100aae:	80 
80100aaf:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
80100ab6:	e8 fb 47 00 00       	call   801052b6 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100abb:	c7 05 ec 21 11 80 26 	movl   $0x80100a26,0x801121ec
80100ac2:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ac5:	c7 05 e8 21 11 80 25 	movl   $0x80100925,0x801121e8
80100acc:	09 10 80 
  cons.locking = 1;
80100acf:	c7 05 f4 c5 10 80 01 	movl   $0x1,0x8010c5f4
80100ad6:	00 00 00 

  picenable(IRQ_KBD);
80100ad9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ae0:	e8 70 33 00 00       	call   80103e55 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100ae5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100aec:	00 
80100aed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100af4:	e8 c5 1e 00 00       	call   801029be <ioapicenable>
}
80100af9:	c9                   	leave  
80100afa:	c3                   	ret    
	...

80100afc <exec>:
extern int EXEC_COPY_EXIT(void);
extern int EXEC_COPY_EXIT_END(void);

int
exec(char *path, char **argv)
{
80100afc:	55                   	push   %ebp
80100afd:	89 e5                	mov    %esp,%ebp
80100aff:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b05:	e8 93 29 00 00       	call   8010349d <begin_op>
  if((ip = namei(path)) == 0){
80100b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80100b0d:	89 04 24             	mov    %eax,(%esp)
80100b10:	e8 3d 19 00 00       	call   80102452 <namei>
80100b15:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b18:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b1c:	75 0f                	jne    80100b2d <exec+0x31>
    end_op();
80100b1e:	e8 fb 29 00 00       	call   8010351e <end_op>
    return -1;
80100b23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b28:	e9 16 04 00 00       	jmp    80100f43 <exec+0x447>
  }
  ilock(ip);
80100b2d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b30:	89 04 24             	mov    %eax,(%esp)
80100b33:	e8 78 0d 00 00       	call   801018b0 <ilock>
  pgdir = 0;
80100b38:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b3f:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b46:	00 
80100b47:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b4e:	00 
80100b4f:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100b55:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b59:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b5c:	89 04 24             	mov    %eax,(%esp)
80100b5f:	e8 42 12 00 00       	call   80101da6 <readi>
80100b64:	83 f8 33             	cmp    $0x33,%eax
80100b67:	0f 86 8b 03 00 00    	jbe    80100ef8 <exec+0x3fc>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100b6d:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100b73:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b78:	0f 85 7d 03 00 00    	jne    80100efb <exec+0x3ff>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100b7e:	e8 de 75 00 00       	call   80108161 <setupkvm>
80100b83:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b86:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b8a:	0f 84 6e 03 00 00    	je     80100efe <exec+0x402>
    goto bad;

  // Load program into memory.
  sz = 0;
80100b90:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b97:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100b9e:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100ba4:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ba7:	e9 c5 00 00 00       	jmp    80100c71 <exec+0x175>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bac:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100baf:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bb6:	00 
80100bb7:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bbb:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bc5:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bc8:	89 04 24             	mov    %eax,(%esp)
80100bcb:	e8 d6 11 00 00       	call   80101da6 <readi>
80100bd0:	83 f8 20             	cmp    $0x20,%eax
80100bd3:	0f 85 28 03 00 00    	jne    80100f01 <exec+0x405>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100bd9:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100bdf:	83 f8 01             	cmp    $0x1,%eax
80100be2:	75 7f                	jne    80100c63 <exec+0x167>
      continue;
    if(ph.memsz < ph.filesz)
80100be4:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100bea:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100bf0:	39 c2                	cmp    %eax,%edx
80100bf2:	0f 82 0c 03 00 00    	jb     80100f04 <exec+0x408>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100bf8:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100bfe:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c04:	01 d0                	add    %edx,%eax
80100c06:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c0d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c11:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c14:	89 04 24             	mov    %eax,(%esp)
80100c17:	e8 17 79 00 00       	call   80108533 <allocuvm>
80100c1c:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c1f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c23:	0f 84 de 02 00 00    	je     80100f07 <exec+0x40b>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c29:	8b 8d f8 fe ff ff    	mov    -0x108(%ebp),%ecx
80100c2f:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100c35:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c3b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c3f:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c43:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c46:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c4a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c4e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c51:	89 04 24             	mov    %eax,(%esp)
80100c54:	e8 eb 77 00 00       	call   80108444 <loaduvm>
80100c59:	85 c0                	test   %eax,%eax
80100c5b:	0f 88 a9 02 00 00    	js     80100f0a <exec+0x40e>
80100c61:	eb 01                	jmp    80100c64 <exec+0x168>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100c63:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c64:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c68:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c6b:	83 c0 20             	add    $0x20,%eax
80100c6e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c71:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100c78:	0f b7 c0             	movzwl %ax,%eax
80100c7b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c7e:	0f 8f 28 ff ff ff    	jg     80100bac <exec+0xb0>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100c84:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c87:	89 04 24             	mov    %eax,(%esp)
80100c8a:	e8 a5 0e 00 00       	call   80101b34 <iunlockput>
  end_op();
80100c8f:	e8 8a 28 00 00       	call   8010351e <end_op>
  ip = 0;
80100c94:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100c9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c9e:	05 ff 0f 00 00       	add    $0xfff,%eax
80100ca3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ca8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100cab:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cae:	05 00 20 00 00       	add    $0x2000,%eax
80100cb3:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cb7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cba:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cbe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cc1:	89 04 24             	mov    %eax,(%esp)
80100cc4:	e8 6a 78 00 00       	call   80108533 <allocuvm>
80100cc9:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ccc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cd0:	0f 84 37 02 00 00    	je     80100f0d <exec+0x411>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cd6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd9:	2d 00 20 00 00       	sub    $0x2000,%eax
80100cde:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ce2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ce5:	89 04 24             	mov    %eax,(%esp)
80100ce8:	e8 6a 7a 00 00       	call   80108757 <clearpteu>
  sp = sz;
80100ced:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cf0:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100cf3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100cfa:	e9 81 00 00 00       	jmp    80100d80 <exec+0x284>
    if(argc >= MAXARG)
80100cff:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d03:	0f 87 07 02 00 00    	ja     80100f10 <exec+0x414>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d0c:	c1 e0 02             	shl    $0x2,%eax
80100d0f:	03 45 0c             	add    0xc(%ebp),%eax
80100d12:	8b 00                	mov    (%eax),%eax
80100d14:	89 04 24             	mov    %eax,(%esp)
80100d17:	e8 88 4a 00 00       	call   801057a4 <strlen>
80100d1c:	f7 d0                	not    %eax
80100d1e:	03 45 dc             	add    -0x24(%ebp),%eax
80100d21:	83 e0 fc             	and    $0xfffffffc,%eax
80100d24:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d2a:	c1 e0 02             	shl    $0x2,%eax
80100d2d:	03 45 0c             	add    0xc(%ebp),%eax
80100d30:	8b 00                	mov    (%eax),%eax
80100d32:	89 04 24             	mov    %eax,(%esp)
80100d35:	e8 6a 4a 00 00       	call   801057a4 <strlen>
80100d3a:	83 c0 01             	add    $0x1,%eax
80100d3d:	89 c2                	mov    %eax,%edx
80100d3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d42:	c1 e0 02             	shl    $0x2,%eax
80100d45:	03 45 0c             	add    0xc(%ebp),%eax
80100d48:	8b 00                	mov    (%eax),%eax
80100d4a:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d4e:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d52:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d55:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d59:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d5c:	89 04 24             	mov    %eax,(%esp)
80100d5f:	e8 b8 7b 00 00       	call   8010891c <copyout>
80100d64:	85 c0                	test   %eax,%eax
80100d66:	0f 88 a7 01 00 00    	js     80100f13 <exec+0x417>
      goto bad;
    ustack[3+argc] = sp;
80100d6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d6f:	8d 50 03             	lea    0x3(%eax),%edx
80100d72:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d75:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d7c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100d80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d83:	c1 e0 02             	shl    $0x2,%eax
80100d86:	03 45 0c             	add    0xc(%ebp),%eax
80100d89:	8b 00                	mov    (%eax),%eax
80100d8b:	85 c0                	test   %eax,%eax
80100d8d:	0f 85 6c ff ff ff    	jne    80100cff <exec+0x203>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100d93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d96:	83 c0 03             	add    $0x3,%eax
80100d99:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100da0:	00 00 00 00 
  
  
  // @itay - calculate the size to copy, copy and save the address at sz.
  exec_copy_exit_diff	= EXEC_COPY_EXIT_END - EXEC_COPY_EXIT;
80100da4:	ba d6 89 10 80       	mov    $0x801089d6,%edx
80100da9:	b8 cc 89 10 80       	mov    $0x801089cc,%eax
80100dae:	89 d1                	mov    %edx,%ecx
80100db0:	29 c1                	sub    %eax,%ecx
80100db2:	89 c8                	mov    %ecx,%eax
80100db4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  sp = ( sp - exec_copy_exit_diff );// & ~3;
80100db7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100dba:	29 45 dc             	sub    %eax,-0x24(%ebp)
  copyout(pgdir,sp,EXEC_COPY_EXIT,exec_copy_exit_diff);
80100dbd:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100dc0:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100dc4:	c7 44 24 08 cc 89 10 	movl   $0x801089cc,0x8(%esp)
80100dcb:	80 
80100dcc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dcf:	89 44 24 04          	mov    %eax,0x4(%esp)
80100dd3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100dd6:	89 04 24             	mov    %eax,(%esp)
80100dd9:	e8 3e 7b 00 00       	call   8010891c <copyout>
  ustack[0] = sp;//0xffffffff;  // fake return PC (sp will make EXIT call)
80100dde:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100de1:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%ebp)
//  cprintf(2, "we wanna junp to: %d ", sp);
//  for ( i = 0 ; i < 8 ; ++i) {
//    cprintf(2, " i:    %d  \n", i, ustack[i]);
//  }
   
  ustack[1] = argc;
80100de7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dea:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100df0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df3:	83 c0 01             	add    $0x1,%eax
80100df6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dfd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e00:	29 d0                	sub    %edx,%eax
80100e02:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e0b:	83 c0 04             	add    $0x4,%eax
80100e0e:	c1 e0 02             	shl    $0x2,%eax
80100e11:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e17:	83 c0 04             	add    $0x4,%eax
80100e1a:	c1 e0 02             	shl    $0x2,%eax
80100e1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100e21:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100e27:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e2b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e32:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e35:	89 04 24             	mov    %eax,(%esp)
80100e38:	e8 df 7a 00 00       	call   8010891c <copyout>
80100e3d:	85 c0                	test   %eax,%eax
80100e3f:	0f 88 d1 00 00 00    	js     80100f16 <exec+0x41a>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e45:	8b 45 08             	mov    0x8(%ebp),%eax
80100e48:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e51:	eb 17                	jmp    80100e6a <exec+0x36e>
    if(*s == '/')
80100e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e56:	0f b6 00             	movzbl (%eax),%eax
80100e59:	3c 2f                	cmp    $0x2f,%al
80100e5b:	75 09                	jne    80100e66 <exec+0x36a>
      last = s+1;
80100e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e60:	83 c0 01             	add    $0x1,%eax
80100e63:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e66:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e6d:	0f b6 00             	movzbl (%eax),%eax
80100e70:	84 c0                	test   %al,%al
80100e72:	75 df                	jne    80100e53 <exec+0x357>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e74:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e7a:	8d 50 6c             	lea    0x6c(%eax),%edx
80100e7d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e84:	00 
80100e85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e88:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e8c:	89 14 24             	mov    %edx,(%esp)
80100e8f:	e8 c2 48 00 00       	call   80105756 <safestrcpy>
 
  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e94:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e9a:	8b 40 04             	mov    0x4(%eax),%eax
80100e9d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  proc->pgdir = pgdir;
80100ea0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ea9:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100eac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb2:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100eb5:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100eb7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ebd:	8b 40 18             	mov    0x18(%eax),%eax
80100ec0:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100ec6:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ec9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ecf:	8b 40 18             	mov    0x18(%eax),%eax
80100ed2:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ed5:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ed8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ede:	89 04 24             	mov    %eax,(%esp)
80100ee1:	e8 6c 73 00 00       	call   80108252 <switchuvm>
  freevm(oldpgdir);
80100ee6:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100ee9:	89 04 24             	mov    %eax,(%esp)
80100eec:	e8 d8 77 00 00       	call   801086c9 <freevm>
  return 0;
80100ef1:	b8 00 00 00 00       	mov    $0x0,%eax
80100ef6:	eb 4b                	jmp    80100f43 <exec+0x447>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100ef8:	90                   	nop
80100ef9:	eb 1c                	jmp    80100f17 <exec+0x41b>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100efb:	90                   	nop
80100efc:	eb 19                	jmp    80100f17 <exec+0x41b>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100efe:	90                   	nop
80100eff:	eb 16                	jmp    80100f17 <exec+0x41b>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100f01:	90                   	nop
80100f02:	eb 13                	jmp    80100f17 <exec+0x41b>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100f04:	90                   	nop
80100f05:	eb 10                	jmp    80100f17 <exec+0x41b>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100f07:	90                   	nop
80100f08:	eb 0d                	jmp    80100f17 <exec+0x41b>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100f0a:	90                   	nop
80100f0b:	eb 0a                	jmp    80100f17 <exec+0x41b>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100f0d:	90                   	nop
80100f0e:	eb 07                	jmp    80100f17 <exec+0x41b>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100f10:	90                   	nop
80100f11:	eb 04                	jmp    80100f17 <exec+0x41b>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100f13:	90                   	nop
80100f14:	eb 01                	jmp    80100f17 <exec+0x41b>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100f16:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100f17:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f1b:	74 0b                	je     80100f28 <exec+0x42c>
    freevm(pgdir);
80100f1d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f20:	89 04 24             	mov    %eax,(%esp)
80100f23:	e8 a1 77 00 00       	call   801086c9 <freevm>
  if(ip){
80100f28:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f2c:	74 10                	je     80100f3e <exec+0x442>
    iunlockput(ip);
80100f2e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f31:	89 04 24             	mov    %eax,(%esp)
80100f34:	e8 fb 0b 00 00       	call   80101b34 <iunlockput>
    end_op();
80100f39:	e8 e0 25 00 00       	call   8010351e <end_op>
  }
  return -1;
80100f3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f43:	c9                   	leave  
80100f44:	c3                   	ret    
80100f45:	00 00                	add    %al,(%eax)
	...

80100f48 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f48:	55                   	push   %ebp
80100f49:	89 e5                	mov    %esp,%ebp
80100f4b:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f4e:	c7 44 24 04 31 8a 10 	movl   $0x80108a31,0x4(%esp)
80100f55:	80 
80100f56:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80100f5d:	e8 54 43 00 00       	call   801052b6 <initlock>
}
80100f62:	c9                   	leave  
80100f63:	c3                   	ret    

80100f64 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f64:	55                   	push   %ebp
80100f65:	89 e5                	mov    %esp,%ebp
80100f67:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f6a:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80100f71:	e8 61 43 00 00       	call   801052d7 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f76:	c7 45 f4 74 18 11 80 	movl   $0x80111874,-0xc(%ebp)
80100f7d:	eb 29                	jmp    80100fa8 <filealloc+0x44>
    if(f->ref == 0){
80100f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f82:	8b 40 04             	mov    0x4(%eax),%eax
80100f85:	85 c0                	test   %eax,%eax
80100f87:	75 1b                	jne    80100fa4 <filealloc+0x40>
      f->ref = 1;
80100f89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f8c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f93:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80100f9a:	e8 9a 43 00 00       	call   80105339 <release>
      return f;
80100f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fa2:	eb 1e                	jmp    80100fc2 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fa4:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fa8:	81 7d f4 d4 21 11 80 	cmpl   $0x801121d4,-0xc(%ebp)
80100faf:	72 ce                	jb     80100f7f <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fb1:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80100fb8:	e8 7c 43 00 00       	call   80105339 <release>
  return 0;
80100fbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100fc2:	c9                   	leave  
80100fc3:	c3                   	ret    

80100fc4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fc4:	55                   	push   %ebp
80100fc5:	89 e5                	mov    %esp,%ebp
80100fc7:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100fca:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80100fd1:	e8 01 43 00 00       	call   801052d7 <acquire>
  if(f->ref < 1)
80100fd6:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd9:	8b 40 04             	mov    0x4(%eax),%eax
80100fdc:	85 c0                	test   %eax,%eax
80100fde:	7f 0c                	jg     80100fec <filedup+0x28>
    panic("filedup");
80100fe0:	c7 04 24 38 8a 10 80 	movl   $0x80108a38,(%esp)
80100fe7:	e8 51 f5 ff ff       	call   8010053d <panic>
  f->ref++;
80100fec:	8b 45 08             	mov    0x8(%ebp),%eax
80100fef:	8b 40 04             	mov    0x4(%eax),%eax
80100ff2:	8d 50 01             	lea    0x1(%eax),%edx
80100ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff8:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100ffb:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80101002:	e8 32 43 00 00       	call   80105339 <release>
  return f;
80101007:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010100a:	c9                   	leave  
8010100b:	c3                   	ret    

8010100c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010100c:	55                   	push   %ebp
8010100d:	89 e5                	mov    %esp,%ebp
8010100f:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80101012:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80101019:	e8 b9 42 00 00       	call   801052d7 <acquire>
  if(f->ref < 1)
8010101e:	8b 45 08             	mov    0x8(%ebp),%eax
80101021:	8b 40 04             	mov    0x4(%eax),%eax
80101024:	85 c0                	test   %eax,%eax
80101026:	7f 0c                	jg     80101034 <fileclose+0x28>
    panic("fileclose");
80101028:	c7 04 24 40 8a 10 80 	movl   $0x80108a40,(%esp)
8010102f:	e8 09 f5 ff ff       	call   8010053d <panic>
  if(--f->ref > 0){
80101034:	8b 45 08             	mov    0x8(%ebp),%eax
80101037:	8b 40 04             	mov    0x4(%eax),%eax
8010103a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010103d:	8b 45 08             	mov    0x8(%ebp),%eax
80101040:	89 50 04             	mov    %edx,0x4(%eax)
80101043:	8b 45 08             	mov    0x8(%ebp),%eax
80101046:	8b 40 04             	mov    0x4(%eax),%eax
80101049:	85 c0                	test   %eax,%eax
8010104b:	7e 11                	jle    8010105e <fileclose+0x52>
    release(&ftable.lock);
8010104d:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80101054:	e8 e0 42 00 00       	call   80105339 <release>
    return;
80101059:	e9 82 00 00 00       	jmp    801010e0 <fileclose+0xd4>
  }
  ff = *f;
8010105e:	8b 45 08             	mov    0x8(%ebp),%eax
80101061:	8b 10                	mov    (%eax),%edx
80101063:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101066:	8b 50 04             	mov    0x4(%eax),%edx
80101069:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010106c:	8b 50 08             	mov    0x8(%eax),%edx
8010106f:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101072:	8b 50 0c             	mov    0xc(%eax),%edx
80101075:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101078:	8b 50 10             	mov    0x10(%eax),%edx
8010107b:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010107e:	8b 40 14             	mov    0x14(%eax),%eax
80101081:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101084:	8b 45 08             	mov    0x8(%ebp),%eax
80101087:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010108e:	8b 45 08             	mov    0x8(%ebp),%eax
80101091:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101097:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
8010109e:	e8 96 42 00 00       	call   80105339 <release>
  
  if(ff.type == FD_PIPE)
801010a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010a6:	83 f8 01             	cmp    $0x1,%eax
801010a9:	75 18                	jne    801010c3 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
801010ab:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801010af:	0f be d0             	movsbl %al,%edx
801010b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801010b5:	89 54 24 04          	mov    %edx,0x4(%esp)
801010b9:	89 04 24             	mov    %eax,(%esp)
801010bc:	e8 4e 30 00 00       	call   8010410f <pipeclose>
801010c1:	eb 1d                	jmp    801010e0 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
801010c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010c6:	83 f8 02             	cmp    $0x2,%eax
801010c9:	75 15                	jne    801010e0 <fileclose+0xd4>
    begin_op();
801010cb:	e8 cd 23 00 00       	call   8010349d <begin_op>
    iput(ff.ip);
801010d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801010d3:	89 04 24             	mov    %eax,(%esp)
801010d6:	e8 88 09 00 00       	call   80101a63 <iput>
    end_op();
801010db:	e8 3e 24 00 00       	call   8010351e <end_op>
  }
}
801010e0:	c9                   	leave  
801010e1:	c3                   	ret    

801010e2 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010e2:	55                   	push   %ebp
801010e3:	89 e5                	mov    %esp,%ebp
801010e5:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010e8:	8b 45 08             	mov    0x8(%ebp),%eax
801010eb:	8b 00                	mov    (%eax),%eax
801010ed:	83 f8 02             	cmp    $0x2,%eax
801010f0:	75 38                	jne    8010112a <filestat+0x48>
    ilock(f->ip);
801010f2:	8b 45 08             	mov    0x8(%ebp),%eax
801010f5:	8b 40 10             	mov    0x10(%eax),%eax
801010f8:	89 04 24             	mov    %eax,(%esp)
801010fb:	e8 b0 07 00 00       	call   801018b0 <ilock>
    stati(f->ip, st);
80101100:	8b 45 08             	mov    0x8(%ebp),%eax
80101103:	8b 40 10             	mov    0x10(%eax),%eax
80101106:	8b 55 0c             	mov    0xc(%ebp),%edx
80101109:	89 54 24 04          	mov    %edx,0x4(%esp)
8010110d:	89 04 24             	mov    %eax,(%esp)
80101110:	e8 4c 0c 00 00       	call   80101d61 <stati>
    iunlock(f->ip);
80101115:	8b 45 08             	mov    0x8(%ebp),%eax
80101118:	8b 40 10             	mov    0x10(%eax),%eax
8010111b:	89 04 24             	mov    %eax,(%esp)
8010111e:	e8 db 08 00 00       	call   801019fe <iunlock>
    return 0;
80101123:	b8 00 00 00 00       	mov    $0x0,%eax
80101128:	eb 05                	jmp    8010112f <filestat+0x4d>
  }
  return -1;
8010112a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010112f:	c9                   	leave  
80101130:	c3                   	ret    

80101131 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101131:	55                   	push   %ebp
80101132:	89 e5                	mov    %esp,%ebp
80101134:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101137:	8b 45 08             	mov    0x8(%ebp),%eax
8010113a:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010113e:	84 c0                	test   %al,%al
80101140:	75 0a                	jne    8010114c <fileread+0x1b>
    return -1;
80101142:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101147:	e9 9f 00 00 00       	jmp    801011eb <fileread+0xba>
  if(f->type == FD_PIPE)
8010114c:	8b 45 08             	mov    0x8(%ebp),%eax
8010114f:	8b 00                	mov    (%eax),%eax
80101151:	83 f8 01             	cmp    $0x1,%eax
80101154:	75 1e                	jne    80101174 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101156:	8b 45 08             	mov    0x8(%ebp),%eax
80101159:	8b 40 0c             	mov    0xc(%eax),%eax
8010115c:	8b 55 10             	mov    0x10(%ebp),%edx
8010115f:	89 54 24 08          	mov    %edx,0x8(%esp)
80101163:	8b 55 0c             	mov    0xc(%ebp),%edx
80101166:	89 54 24 04          	mov    %edx,0x4(%esp)
8010116a:	89 04 24             	mov    %eax,(%esp)
8010116d:	e8 1f 31 00 00       	call   80104291 <piperead>
80101172:	eb 77                	jmp    801011eb <fileread+0xba>
  if(f->type == FD_INODE){
80101174:	8b 45 08             	mov    0x8(%ebp),%eax
80101177:	8b 00                	mov    (%eax),%eax
80101179:	83 f8 02             	cmp    $0x2,%eax
8010117c:	75 61                	jne    801011df <fileread+0xae>
    ilock(f->ip);
8010117e:	8b 45 08             	mov    0x8(%ebp),%eax
80101181:	8b 40 10             	mov    0x10(%eax),%eax
80101184:	89 04 24             	mov    %eax,(%esp)
80101187:	e8 24 07 00 00       	call   801018b0 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010118c:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010118f:	8b 45 08             	mov    0x8(%ebp),%eax
80101192:	8b 50 14             	mov    0x14(%eax),%edx
80101195:	8b 45 08             	mov    0x8(%ebp),%eax
80101198:	8b 40 10             	mov    0x10(%eax),%eax
8010119b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010119f:	89 54 24 08          	mov    %edx,0x8(%esp)
801011a3:	8b 55 0c             	mov    0xc(%ebp),%edx
801011a6:	89 54 24 04          	mov    %edx,0x4(%esp)
801011aa:	89 04 24             	mov    %eax,(%esp)
801011ad:	e8 f4 0b 00 00       	call   80101da6 <readi>
801011b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801011b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801011b9:	7e 11                	jle    801011cc <fileread+0x9b>
      f->off += r;
801011bb:	8b 45 08             	mov    0x8(%ebp),%eax
801011be:	8b 50 14             	mov    0x14(%eax),%edx
801011c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011c4:	01 c2                	add    %eax,%edx
801011c6:	8b 45 08             	mov    0x8(%ebp),%eax
801011c9:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801011cc:	8b 45 08             	mov    0x8(%ebp),%eax
801011cf:	8b 40 10             	mov    0x10(%eax),%eax
801011d2:	89 04 24             	mov    %eax,(%esp)
801011d5:	e8 24 08 00 00       	call   801019fe <iunlock>
    return r;
801011da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011dd:	eb 0c                	jmp    801011eb <fileread+0xba>
  }
  panic("fileread");
801011df:	c7 04 24 4a 8a 10 80 	movl   $0x80108a4a,(%esp)
801011e6:	e8 52 f3 ff ff       	call   8010053d <panic>
}
801011eb:	c9                   	leave  
801011ec:	c3                   	ret    

801011ed <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011ed:	55                   	push   %ebp
801011ee:	89 e5                	mov    %esp,%ebp
801011f0:	53                   	push   %ebx
801011f1:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011f4:	8b 45 08             	mov    0x8(%ebp),%eax
801011f7:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011fb:	84 c0                	test   %al,%al
801011fd:	75 0a                	jne    80101209 <filewrite+0x1c>
    return -1;
801011ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101204:	e9 23 01 00 00       	jmp    8010132c <filewrite+0x13f>
  if(f->type == FD_PIPE)
80101209:	8b 45 08             	mov    0x8(%ebp),%eax
8010120c:	8b 00                	mov    (%eax),%eax
8010120e:	83 f8 01             	cmp    $0x1,%eax
80101211:	75 21                	jne    80101234 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101213:	8b 45 08             	mov    0x8(%ebp),%eax
80101216:	8b 40 0c             	mov    0xc(%eax),%eax
80101219:	8b 55 10             	mov    0x10(%ebp),%edx
8010121c:	89 54 24 08          	mov    %edx,0x8(%esp)
80101220:	8b 55 0c             	mov    0xc(%ebp),%edx
80101223:	89 54 24 04          	mov    %edx,0x4(%esp)
80101227:	89 04 24             	mov    %eax,(%esp)
8010122a:	e8 72 2f 00 00       	call   801041a1 <pipewrite>
8010122f:	e9 f8 00 00 00       	jmp    8010132c <filewrite+0x13f>
  if(f->type == FD_INODE){
80101234:	8b 45 08             	mov    0x8(%ebp),%eax
80101237:	8b 00                	mov    (%eax),%eax
80101239:	83 f8 02             	cmp    $0x2,%eax
8010123c:	0f 85 de 00 00 00    	jne    80101320 <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101242:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101249:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101250:	e9 a8 00 00 00       	jmp    801012fd <filewrite+0x110>
      int n1 = n - i;
80101255:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101258:	8b 55 10             	mov    0x10(%ebp),%edx
8010125b:	89 d1                	mov    %edx,%ecx
8010125d:	29 c1                	sub    %eax,%ecx
8010125f:	89 c8                	mov    %ecx,%eax
80101261:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101264:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101267:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010126a:	7e 06                	jle    80101272 <filewrite+0x85>
        n1 = max;
8010126c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010126f:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101272:	e8 26 22 00 00       	call   8010349d <begin_op>
      ilock(f->ip);
80101277:	8b 45 08             	mov    0x8(%ebp),%eax
8010127a:	8b 40 10             	mov    0x10(%eax),%eax
8010127d:	89 04 24             	mov    %eax,(%esp)
80101280:	e8 2b 06 00 00       	call   801018b0 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101285:	8b 5d f0             	mov    -0x10(%ebp),%ebx
80101288:	8b 45 08             	mov    0x8(%ebp),%eax
8010128b:	8b 48 14             	mov    0x14(%eax),%ecx
8010128e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101291:	89 c2                	mov    %eax,%edx
80101293:	03 55 0c             	add    0xc(%ebp),%edx
80101296:	8b 45 08             	mov    0x8(%ebp),%eax
80101299:	8b 40 10             	mov    0x10(%eax),%eax
8010129c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
801012a0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801012a4:	89 54 24 04          	mov    %edx,0x4(%esp)
801012a8:	89 04 24             	mov    %eax,(%esp)
801012ab:	e8 61 0c 00 00       	call   80101f11 <writei>
801012b0:	89 45 e8             	mov    %eax,-0x18(%ebp)
801012b3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012b7:	7e 11                	jle    801012ca <filewrite+0xdd>
        f->off += r;
801012b9:	8b 45 08             	mov    0x8(%ebp),%eax
801012bc:	8b 50 14             	mov    0x14(%eax),%edx
801012bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012c2:	01 c2                	add    %eax,%edx
801012c4:	8b 45 08             	mov    0x8(%ebp),%eax
801012c7:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012ca:	8b 45 08             	mov    0x8(%ebp),%eax
801012cd:	8b 40 10             	mov    0x10(%eax),%eax
801012d0:	89 04 24             	mov    %eax,(%esp)
801012d3:	e8 26 07 00 00       	call   801019fe <iunlock>
      end_op();
801012d8:	e8 41 22 00 00       	call   8010351e <end_op>

      if(r < 0)
801012dd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012e1:	78 28                	js     8010130b <filewrite+0x11e>
        break;
      if(r != n1)
801012e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012e6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012e9:	74 0c                	je     801012f7 <filewrite+0x10a>
        panic("short filewrite");
801012eb:	c7 04 24 53 8a 10 80 	movl   $0x80108a53,(%esp)
801012f2:	e8 46 f2 ff ff       	call   8010053d <panic>
      i += r;
801012f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012fa:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101300:	3b 45 10             	cmp    0x10(%ebp),%eax
80101303:	0f 8c 4c ff ff ff    	jl     80101255 <filewrite+0x68>
80101309:	eb 01                	jmp    8010130c <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
8010130b:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
8010130c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010130f:	3b 45 10             	cmp    0x10(%ebp),%eax
80101312:	75 05                	jne    80101319 <filewrite+0x12c>
80101314:	8b 45 10             	mov    0x10(%ebp),%eax
80101317:	eb 05                	jmp    8010131e <filewrite+0x131>
80101319:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010131e:	eb 0c                	jmp    8010132c <filewrite+0x13f>
  }
  panic("filewrite");
80101320:	c7 04 24 63 8a 10 80 	movl   $0x80108a63,(%esp)
80101327:	e8 11 f2 ff ff       	call   8010053d <panic>
}
8010132c:	83 c4 24             	add    $0x24,%esp
8010132f:	5b                   	pop    %ebx
80101330:	5d                   	pop    %ebp
80101331:	c3                   	ret    
	...

80101334 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101334:	55                   	push   %ebp
80101335:	89 e5                	mov    %esp,%ebp
80101337:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
8010133a:	8b 45 08             	mov    0x8(%ebp),%eax
8010133d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101344:	00 
80101345:	89 04 24             	mov    %eax,(%esp)
80101348:	e8 59 ee ff ff       	call   801001a6 <bread>
8010134d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101350:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101353:	83 c0 18             	add    $0x18,%eax
80101356:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010135d:	00 
8010135e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101362:	8b 45 0c             	mov    0xc(%ebp),%eax
80101365:	89 04 24             	mov    %eax,(%esp)
80101368:	e8 8c 42 00 00       	call   801055f9 <memmove>
  brelse(bp);
8010136d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101370:	89 04 24             	mov    %eax,(%esp)
80101373:	e8 9f ee ff ff       	call   80100217 <brelse>
}
80101378:	c9                   	leave  
80101379:	c3                   	ret    

8010137a <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010137a:	55                   	push   %ebp
8010137b:	89 e5                	mov    %esp,%ebp
8010137d:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101380:	8b 55 0c             	mov    0xc(%ebp),%edx
80101383:	8b 45 08             	mov    0x8(%ebp),%eax
80101386:	89 54 24 04          	mov    %edx,0x4(%esp)
8010138a:	89 04 24             	mov    %eax,(%esp)
8010138d:	e8 14 ee ff ff       	call   801001a6 <bread>
80101392:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101395:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101398:	83 c0 18             	add    $0x18,%eax
8010139b:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801013a2:	00 
801013a3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801013aa:	00 
801013ab:	89 04 24             	mov    %eax,(%esp)
801013ae:	e8 73 41 00 00       	call   80105526 <memset>
  log_write(bp);
801013b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b6:	89 04 24             	mov    %eax,(%esp)
801013b9:	e8 e4 22 00 00       	call   801036a2 <log_write>
  brelse(bp);
801013be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013c1:	89 04 24             	mov    %eax,(%esp)
801013c4:	e8 4e ee ff ff       	call   80100217 <brelse>
}
801013c9:	c9                   	leave  
801013ca:	c3                   	ret    

801013cb <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801013cb:	55                   	push   %ebp
801013cc:	89 e5                	mov    %esp,%ebp
801013ce:	53                   	push   %ebx
801013cf:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
801013d2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
801013d9:	8b 45 08             	mov    0x8(%ebp),%eax
801013dc:	8d 55 d8             	lea    -0x28(%ebp),%edx
801013df:	89 54 24 04          	mov    %edx,0x4(%esp)
801013e3:	89 04 24             	mov    %eax,(%esp)
801013e6:	e8 49 ff ff ff       	call   80101334 <readsb>
  for(b = 0; b < sb.size; b += BPB){
801013eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013f2:	e9 11 01 00 00       	jmp    80101508 <balloc+0x13d>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
801013f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013fa:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101400:	85 c0                	test   %eax,%eax
80101402:	0f 48 c2             	cmovs  %edx,%eax
80101405:	c1 f8 0c             	sar    $0xc,%eax
80101408:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010140b:	c1 ea 03             	shr    $0x3,%edx
8010140e:	01 d0                	add    %edx,%eax
80101410:	83 c0 03             	add    $0x3,%eax
80101413:	89 44 24 04          	mov    %eax,0x4(%esp)
80101417:	8b 45 08             	mov    0x8(%ebp),%eax
8010141a:	89 04 24             	mov    %eax,(%esp)
8010141d:	e8 84 ed ff ff       	call   801001a6 <bread>
80101422:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101425:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010142c:	e9 a7 00 00 00       	jmp    801014d8 <balloc+0x10d>
      m = 1 << (bi % 8);
80101431:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101434:	89 c2                	mov    %eax,%edx
80101436:	c1 fa 1f             	sar    $0x1f,%edx
80101439:	c1 ea 1d             	shr    $0x1d,%edx
8010143c:	01 d0                	add    %edx,%eax
8010143e:	83 e0 07             	and    $0x7,%eax
80101441:	29 d0                	sub    %edx,%eax
80101443:	ba 01 00 00 00       	mov    $0x1,%edx
80101448:	89 d3                	mov    %edx,%ebx
8010144a:	89 c1                	mov    %eax,%ecx
8010144c:	d3 e3                	shl    %cl,%ebx
8010144e:	89 d8                	mov    %ebx,%eax
80101450:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101453:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101456:	8d 50 07             	lea    0x7(%eax),%edx
80101459:	85 c0                	test   %eax,%eax
8010145b:	0f 48 c2             	cmovs  %edx,%eax
8010145e:	c1 f8 03             	sar    $0x3,%eax
80101461:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101464:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101469:	0f b6 c0             	movzbl %al,%eax
8010146c:	23 45 e8             	and    -0x18(%ebp),%eax
8010146f:	85 c0                	test   %eax,%eax
80101471:	75 61                	jne    801014d4 <balloc+0x109>
        bp->data[bi/8] |= m;  // Mark block in use.
80101473:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101476:	8d 50 07             	lea    0x7(%eax),%edx
80101479:	85 c0                	test   %eax,%eax
8010147b:	0f 48 c2             	cmovs  %edx,%eax
8010147e:	c1 f8 03             	sar    $0x3,%eax
80101481:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101484:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101489:	89 d1                	mov    %edx,%ecx
8010148b:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010148e:	09 ca                	or     %ecx,%edx
80101490:	89 d1                	mov    %edx,%ecx
80101492:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101495:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101499:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010149c:	89 04 24             	mov    %eax,(%esp)
8010149f:	e8 fe 21 00 00       	call   801036a2 <log_write>
        brelse(bp);
801014a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014a7:	89 04 24             	mov    %eax,(%esp)
801014aa:	e8 68 ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
801014af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014b5:	01 c2                	add    %eax,%edx
801014b7:	8b 45 08             	mov    0x8(%ebp),%eax
801014ba:	89 54 24 04          	mov    %edx,0x4(%esp)
801014be:	89 04 24             	mov    %eax,(%esp)
801014c1:	e8 b4 fe ff ff       	call   8010137a <bzero>
        return b + bi;
801014c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014cc:	01 d0                	add    %edx,%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
801014ce:	83 c4 34             	add    $0x34,%esp
801014d1:	5b                   	pop    %ebx
801014d2:	5d                   	pop    %ebp
801014d3:	c3                   	ret    

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014d4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801014d8:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801014df:	7f 15                	jg     801014f6 <balloc+0x12b>
801014e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014e7:	01 d0                	add    %edx,%eax
801014e9:	89 c2                	mov    %eax,%edx
801014eb:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014ee:	39 c2                	cmp    %eax,%edx
801014f0:	0f 82 3b ff ff ff    	jb     80101431 <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014f9:	89 04 24             	mov    %eax,(%esp)
801014fc:	e8 16 ed ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
80101501:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101508:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010150b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010150e:	39 c2                	cmp    %eax,%edx
80101510:	0f 82 e1 fe ff ff    	jb     801013f7 <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101516:	c7 04 24 6d 8a 10 80 	movl   $0x80108a6d,(%esp)
8010151d:	e8 1b f0 ff ff       	call   8010053d <panic>

80101522 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101522:	55                   	push   %ebp
80101523:	89 e5                	mov    %esp,%ebp
80101525:	53                   	push   %ebx
80101526:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
80101529:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010152c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101530:	8b 45 08             	mov    0x8(%ebp),%eax
80101533:	89 04 24             	mov    %eax,(%esp)
80101536:	e8 f9 fd ff ff       	call   80101334 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
8010153b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010153e:	89 c2                	mov    %eax,%edx
80101540:	c1 ea 0c             	shr    $0xc,%edx
80101543:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101546:	c1 e8 03             	shr    $0x3,%eax
80101549:	01 d0                	add    %edx,%eax
8010154b:	8d 50 03             	lea    0x3(%eax),%edx
8010154e:	8b 45 08             	mov    0x8(%ebp),%eax
80101551:	89 54 24 04          	mov    %edx,0x4(%esp)
80101555:	89 04 24             	mov    %eax,(%esp)
80101558:	e8 49 ec ff ff       	call   801001a6 <bread>
8010155d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101560:	8b 45 0c             	mov    0xc(%ebp),%eax
80101563:	25 ff 0f 00 00       	and    $0xfff,%eax
80101568:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010156b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010156e:	89 c2                	mov    %eax,%edx
80101570:	c1 fa 1f             	sar    $0x1f,%edx
80101573:	c1 ea 1d             	shr    $0x1d,%edx
80101576:	01 d0                	add    %edx,%eax
80101578:	83 e0 07             	and    $0x7,%eax
8010157b:	29 d0                	sub    %edx,%eax
8010157d:	ba 01 00 00 00       	mov    $0x1,%edx
80101582:	89 d3                	mov    %edx,%ebx
80101584:	89 c1                	mov    %eax,%ecx
80101586:	d3 e3                	shl    %cl,%ebx
80101588:	89 d8                	mov    %ebx,%eax
8010158a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010158d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101590:	8d 50 07             	lea    0x7(%eax),%edx
80101593:	85 c0                	test   %eax,%eax
80101595:	0f 48 c2             	cmovs  %edx,%eax
80101598:	c1 f8 03             	sar    $0x3,%eax
8010159b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010159e:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
801015a3:	0f b6 c0             	movzbl %al,%eax
801015a6:	23 45 ec             	and    -0x14(%ebp),%eax
801015a9:	85 c0                	test   %eax,%eax
801015ab:	75 0c                	jne    801015b9 <bfree+0x97>
    panic("freeing free block");
801015ad:	c7 04 24 83 8a 10 80 	movl   $0x80108a83,(%esp)
801015b4:	e8 84 ef ff ff       	call   8010053d <panic>
  bp->data[bi/8] &= ~m;
801015b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015bc:	8d 50 07             	lea    0x7(%eax),%edx
801015bf:	85 c0                	test   %eax,%eax
801015c1:	0f 48 c2             	cmovs  %edx,%eax
801015c4:	c1 f8 03             	sar    $0x3,%eax
801015c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015ca:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801015cf:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801015d2:	f7 d1                	not    %ecx
801015d4:	21 ca                	and    %ecx,%edx
801015d6:	89 d1                	mov    %edx,%ecx
801015d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015db:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801015df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015e2:	89 04 24             	mov    %eax,(%esp)
801015e5:	e8 b8 20 00 00       	call   801036a2 <log_write>
  brelse(bp);
801015ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015ed:	89 04 24             	mov    %eax,(%esp)
801015f0:	e8 22 ec ff ff       	call   80100217 <brelse>
}
801015f5:	83 c4 34             	add    $0x34,%esp
801015f8:	5b                   	pop    %ebx
801015f9:	5d                   	pop    %ebp
801015fa:	c3                   	ret    

801015fb <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
801015fb:	55                   	push   %ebp
801015fc:	89 e5                	mov    %esp,%ebp
801015fe:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
80101601:	c7 44 24 04 96 8a 10 	movl   $0x80108a96,0x4(%esp)
80101608:	80 
80101609:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101610:	e8 a1 3c 00 00       	call   801052b6 <initlock>
}
80101615:	c9                   	leave  
80101616:	c3                   	ret    

80101617 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101617:	55                   	push   %ebp
80101618:	89 e5                	mov    %esp,%ebp
8010161a:	83 ec 48             	sub    $0x48,%esp
8010161d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101620:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
80101624:	8b 45 08             	mov    0x8(%ebp),%eax
80101627:	8d 55 dc             	lea    -0x24(%ebp),%edx
8010162a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010162e:	89 04 24             	mov    %eax,(%esp)
80101631:	e8 fe fc ff ff       	call   80101334 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
80101636:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010163d:	e9 98 00 00 00       	jmp    801016da <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
80101642:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101645:	c1 e8 03             	shr    $0x3,%eax
80101648:	83 c0 02             	add    $0x2,%eax
8010164b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010164f:	8b 45 08             	mov    0x8(%ebp),%eax
80101652:	89 04 24             	mov    %eax,(%esp)
80101655:	e8 4c eb ff ff       	call   801001a6 <bread>
8010165a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010165d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101660:	8d 50 18             	lea    0x18(%eax),%edx
80101663:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101666:	83 e0 07             	and    $0x7,%eax
80101669:	c1 e0 06             	shl    $0x6,%eax
8010166c:	01 d0                	add    %edx,%eax
8010166e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101671:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101674:	0f b7 00             	movzwl (%eax),%eax
80101677:	66 85 c0             	test   %ax,%ax
8010167a:	75 4f                	jne    801016cb <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
8010167c:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101683:	00 
80101684:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010168b:	00 
8010168c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010168f:	89 04 24             	mov    %eax,(%esp)
80101692:	e8 8f 3e 00 00       	call   80105526 <memset>
      dip->type = type;
80101697:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010169a:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
8010169e:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801016a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016a4:	89 04 24             	mov    %eax,(%esp)
801016a7:	e8 f6 1f 00 00       	call   801036a2 <log_write>
      brelse(bp);
801016ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016af:	89 04 24             	mov    %eax,(%esp)
801016b2:	e8 60 eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
801016b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801016be:	8b 45 08             	mov    0x8(%ebp),%eax
801016c1:	89 04 24             	mov    %eax,(%esp)
801016c4:	e8 e3 00 00 00       	call   801017ac <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
801016c9:	c9                   	leave  
801016ca:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
801016cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016ce:	89 04 24             	mov    %eax,(%esp)
801016d1:	e8 41 eb ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
801016d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801016da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801016e0:	39 c2                	cmp    %eax,%edx
801016e2:	0f 82 5a ff ff ff    	jb     80101642 <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801016e8:	c7 04 24 9d 8a 10 80 	movl   $0x80108a9d,(%esp)
801016ef:	e8 49 ee ff ff       	call   8010053d <panic>

801016f4 <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801016f4:	55                   	push   %ebp
801016f5:	89 e5                	mov    %esp,%ebp
801016f7:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
801016fa:	8b 45 08             	mov    0x8(%ebp),%eax
801016fd:	8b 40 04             	mov    0x4(%eax),%eax
80101700:	c1 e8 03             	shr    $0x3,%eax
80101703:	8d 50 02             	lea    0x2(%eax),%edx
80101706:	8b 45 08             	mov    0x8(%ebp),%eax
80101709:	8b 00                	mov    (%eax),%eax
8010170b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010170f:	89 04 24             	mov    %eax,(%esp)
80101712:	e8 8f ea ff ff       	call   801001a6 <bread>
80101717:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010171a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010171d:	8d 50 18             	lea    0x18(%eax),%edx
80101720:	8b 45 08             	mov    0x8(%ebp),%eax
80101723:	8b 40 04             	mov    0x4(%eax),%eax
80101726:	83 e0 07             	and    $0x7,%eax
80101729:	c1 e0 06             	shl    $0x6,%eax
8010172c:	01 d0                	add    %edx,%eax
8010172e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101731:	8b 45 08             	mov    0x8(%ebp),%eax
80101734:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101738:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010173b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010173e:	8b 45 08             	mov    0x8(%ebp),%eax
80101741:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101745:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101748:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010174c:	8b 45 08             	mov    0x8(%ebp),%eax
8010174f:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101753:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101756:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010175a:	8b 45 08             	mov    0x8(%ebp),%eax
8010175d:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101761:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101764:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101768:	8b 45 08             	mov    0x8(%ebp),%eax
8010176b:	8b 50 18             	mov    0x18(%eax),%edx
8010176e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101771:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101774:	8b 45 08             	mov    0x8(%ebp),%eax
80101777:	8d 50 1c             	lea    0x1c(%eax),%edx
8010177a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010177d:	83 c0 0c             	add    $0xc,%eax
80101780:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101787:	00 
80101788:	89 54 24 04          	mov    %edx,0x4(%esp)
8010178c:	89 04 24             	mov    %eax,(%esp)
8010178f:	e8 65 3e 00 00       	call   801055f9 <memmove>
  log_write(bp);
80101794:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101797:	89 04 24             	mov    %eax,(%esp)
8010179a:	e8 03 1f 00 00       	call   801036a2 <log_write>
  brelse(bp);
8010179f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a2:	89 04 24             	mov    %eax,(%esp)
801017a5:	e8 6d ea ff ff       	call   80100217 <brelse>
}
801017aa:	c9                   	leave  
801017ab:	c3                   	ret    

801017ac <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801017ac:	55                   	push   %ebp
801017ad:	89 e5                	mov    %esp,%ebp
801017af:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801017b2:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
801017b9:	e8 19 3b 00 00       	call   801052d7 <acquire>

  // Is the inode already cached?
  empty = 0;
801017be:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017c5:	c7 45 f4 74 22 11 80 	movl   $0x80112274,-0xc(%ebp)
801017cc:	eb 59                	jmp    80101827 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801017ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d1:	8b 40 08             	mov    0x8(%eax),%eax
801017d4:	85 c0                	test   %eax,%eax
801017d6:	7e 35                	jle    8010180d <iget+0x61>
801017d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017db:	8b 00                	mov    (%eax),%eax
801017dd:	3b 45 08             	cmp    0x8(%ebp),%eax
801017e0:	75 2b                	jne    8010180d <iget+0x61>
801017e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e5:	8b 40 04             	mov    0x4(%eax),%eax
801017e8:	3b 45 0c             	cmp    0xc(%ebp),%eax
801017eb:	75 20                	jne    8010180d <iget+0x61>
      ip->ref++;
801017ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f0:	8b 40 08             	mov    0x8(%eax),%eax
801017f3:	8d 50 01             	lea    0x1(%eax),%edx
801017f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f9:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801017fc:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101803:	e8 31 3b 00 00       	call   80105339 <release>
      return ip;
80101808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010180b:	eb 6f                	jmp    8010187c <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010180d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101811:	75 10                	jne    80101823 <iget+0x77>
80101813:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101816:	8b 40 08             	mov    0x8(%eax),%eax
80101819:	85 c0                	test   %eax,%eax
8010181b:	75 06                	jne    80101823 <iget+0x77>
      empty = ip;
8010181d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101820:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101823:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101827:	81 7d f4 14 32 11 80 	cmpl   $0x80113214,-0xc(%ebp)
8010182e:	72 9e                	jb     801017ce <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101830:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101834:	75 0c                	jne    80101842 <iget+0x96>
    panic("iget: no inodes");
80101836:	c7 04 24 af 8a 10 80 	movl   $0x80108aaf,(%esp)
8010183d:	e8 fb ec ff ff       	call   8010053d <panic>

  ip = empty;
80101842:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101845:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101848:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010184b:	8b 55 08             	mov    0x8(%ebp),%edx
8010184e:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101850:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101853:	8b 55 0c             	mov    0xc(%ebp),%edx
80101856:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101859:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010185c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101863:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101866:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
8010186d:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101874:	e8 c0 3a 00 00       	call   80105339 <release>

  return ip;
80101879:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010187c:	c9                   	leave  
8010187d:	c3                   	ret    

8010187e <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
8010187e:	55                   	push   %ebp
8010187f:	89 e5                	mov    %esp,%ebp
80101881:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101884:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
8010188b:	e8 47 3a 00 00       	call   801052d7 <acquire>
  ip->ref++;
80101890:	8b 45 08             	mov    0x8(%ebp),%eax
80101893:	8b 40 08             	mov    0x8(%eax),%eax
80101896:	8d 50 01             	lea    0x1(%eax),%edx
80101899:	8b 45 08             	mov    0x8(%ebp),%eax
8010189c:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
8010189f:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
801018a6:	e8 8e 3a 00 00       	call   80105339 <release>
  return ip;
801018ab:	8b 45 08             	mov    0x8(%ebp),%eax
}
801018ae:	c9                   	leave  
801018af:	c3                   	ret    

801018b0 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801018b0:	55                   	push   %ebp
801018b1:	89 e5                	mov    %esp,%ebp
801018b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801018b6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801018ba:	74 0a                	je     801018c6 <ilock+0x16>
801018bc:	8b 45 08             	mov    0x8(%ebp),%eax
801018bf:	8b 40 08             	mov    0x8(%eax),%eax
801018c2:	85 c0                	test   %eax,%eax
801018c4:	7f 0c                	jg     801018d2 <ilock+0x22>
    panic("ilock");
801018c6:	c7 04 24 bf 8a 10 80 	movl   $0x80108abf,(%esp)
801018cd:	e8 6b ec ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
801018d2:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
801018d9:	e8 f9 39 00 00       	call   801052d7 <acquire>
  while(ip->flags & I_BUSY)
801018de:	eb 13                	jmp    801018f3 <ilock+0x43>
    sleep(ip, &icache.lock);
801018e0:	c7 44 24 04 40 22 11 	movl   $0x80112240,0x4(%esp)
801018e7:	80 
801018e8:	8b 45 08             	mov    0x8(%ebp),%eax
801018eb:	89 04 24             	mov    %eax,(%esp)
801018ee:	e8 fe 36 00 00       	call   80104ff1 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
801018f3:	8b 45 08             	mov    0x8(%ebp),%eax
801018f6:	8b 40 0c             	mov    0xc(%eax),%eax
801018f9:	83 e0 01             	and    $0x1,%eax
801018fc:	84 c0                	test   %al,%al
801018fe:	75 e0                	jne    801018e0 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101900:	8b 45 08             	mov    0x8(%ebp),%eax
80101903:	8b 40 0c             	mov    0xc(%eax),%eax
80101906:	89 c2                	mov    %eax,%edx
80101908:	83 ca 01             	or     $0x1,%edx
8010190b:	8b 45 08             	mov    0x8(%ebp),%eax
8010190e:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101911:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101918:	e8 1c 3a 00 00       	call   80105339 <release>

  if(!(ip->flags & I_VALID)){
8010191d:	8b 45 08             	mov    0x8(%ebp),%eax
80101920:	8b 40 0c             	mov    0xc(%eax),%eax
80101923:	83 e0 02             	and    $0x2,%eax
80101926:	85 c0                	test   %eax,%eax
80101928:	0f 85 ce 00 00 00    	jne    801019fc <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
8010192e:	8b 45 08             	mov    0x8(%ebp),%eax
80101931:	8b 40 04             	mov    0x4(%eax),%eax
80101934:	c1 e8 03             	shr    $0x3,%eax
80101937:	8d 50 02             	lea    0x2(%eax),%edx
8010193a:	8b 45 08             	mov    0x8(%ebp),%eax
8010193d:	8b 00                	mov    (%eax),%eax
8010193f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101943:	89 04 24             	mov    %eax,(%esp)
80101946:	e8 5b e8 ff ff       	call   801001a6 <bread>
8010194b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
8010194e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101951:	8d 50 18             	lea    0x18(%eax),%edx
80101954:	8b 45 08             	mov    0x8(%ebp),%eax
80101957:	8b 40 04             	mov    0x4(%eax),%eax
8010195a:	83 e0 07             	and    $0x7,%eax
8010195d:	c1 e0 06             	shl    $0x6,%eax
80101960:	01 d0                	add    %edx,%eax
80101962:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101965:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101968:	0f b7 10             	movzwl (%eax),%edx
8010196b:	8b 45 08             	mov    0x8(%ebp),%eax
8010196e:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101972:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101975:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101979:	8b 45 08             	mov    0x8(%ebp),%eax
8010197c:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101980:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101983:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101987:	8b 45 08             	mov    0x8(%ebp),%eax
8010198a:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
8010198e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101991:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101995:	8b 45 08             	mov    0x8(%ebp),%eax
80101998:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
8010199c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010199f:	8b 50 08             	mov    0x8(%eax),%edx
801019a2:	8b 45 08             	mov    0x8(%ebp),%eax
801019a5:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801019a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019ab:	8d 50 0c             	lea    0xc(%eax),%edx
801019ae:	8b 45 08             	mov    0x8(%ebp),%eax
801019b1:	83 c0 1c             	add    $0x1c,%eax
801019b4:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801019bb:	00 
801019bc:	89 54 24 04          	mov    %edx,0x4(%esp)
801019c0:	89 04 24             	mov    %eax,(%esp)
801019c3:	e8 31 3c 00 00       	call   801055f9 <memmove>
    brelse(bp);
801019c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019cb:	89 04 24             	mov    %eax,(%esp)
801019ce:	e8 44 e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
801019d3:	8b 45 08             	mov    0x8(%ebp),%eax
801019d6:	8b 40 0c             	mov    0xc(%eax),%eax
801019d9:	89 c2                	mov    %eax,%edx
801019db:	83 ca 02             	or     $0x2,%edx
801019de:	8b 45 08             	mov    0x8(%ebp),%eax
801019e1:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
801019e4:	8b 45 08             	mov    0x8(%ebp),%eax
801019e7:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801019eb:	66 85 c0             	test   %ax,%ax
801019ee:	75 0c                	jne    801019fc <ilock+0x14c>
      panic("ilock: no type");
801019f0:	c7 04 24 c5 8a 10 80 	movl   $0x80108ac5,(%esp)
801019f7:	e8 41 eb ff ff       	call   8010053d <panic>
  }
}
801019fc:	c9                   	leave  
801019fd:	c3                   	ret    

801019fe <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
801019fe:	55                   	push   %ebp
801019ff:	89 e5                	mov    %esp,%ebp
80101a01:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101a04:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a08:	74 17                	je     80101a21 <iunlock+0x23>
80101a0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0d:	8b 40 0c             	mov    0xc(%eax),%eax
80101a10:	83 e0 01             	and    $0x1,%eax
80101a13:	85 c0                	test   %eax,%eax
80101a15:	74 0a                	je     80101a21 <iunlock+0x23>
80101a17:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1a:	8b 40 08             	mov    0x8(%eax),%eax
80101a1d:	85 c0                	test   %eax,%eax
80101a1f:	7f 0c                	jg     80101a2d <iunlock+0x2f>
    panic("iunlock");
80101a21:	c7 04 24 d4 8a 10 80 	movl   $0x80108ad4,(%esp)
80101a28:	e8 10 eb ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101a2d:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101a34:	e8 9e 38 00 00       	call   801052d7 <acquire>
  ip->flags &= ~I_BUSY;
80101a39:	8b 45 08             	mov    0x8(%ebp),%eax
80101a3c:	8b 40 0c             	mov    0xc(%eax),%eax
80101a3f:	89 c2                	mov    %eax,%edx
80101a41:	83 e2 fe             	and    $0xfffffffe,%edx
80101a44:	8b 45 08             	mov    0x8(%ebp),%eax
80101a47:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101a4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4d:	89 04 24             	mov    %eax,(%esp)
80101a50:	e8 78 36 00 00       	call   801050cd <wakeup>
  release(&icache.lock);
80101a55:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101a5c:	e8 d8 38 00 00       	call   80105339 <release>
}
80101a61:	c9                   	leave  
80101a62:	c3                   	ret    

80101a63 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101a63:	55                   	push   %ebp
80101a64:	89 e5                	mov    %esp,%ebp
80101a66:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a69:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101a70:	e8 62 38 00 00       	call   801052d7 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a75:	8b 45 08             	mov    0x8(%ebp),%eax
80101a78:	8b 40 08             	mov    0x8(%eax),%eax
80101a7b:	83 f8 01             	cmp    $0x1,%eax
80101a7e:	0f 85 93 00 00 00    	jne    80101b17 <iput+0xb4>
80101a84:	8b 45 08             	mov    0x8(%ebp),%eax
80101a87:	8b 40 0c             	mov    0xc(%eax),%eax
80101a8a:	83 e0 02             	and    $0x2,%eax
80101a8d:	85 c0                	test   %eax,%eax
80101a8f:	0f 84 82 00 00 00    	je     80101b17 <iput+0xb4>
80101a95:	8b 45 08             	mov    0x8(%ebp),%eax
80101a98:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101a9c:	66 85 c0             	test   %ax,%ax
80101a9f:	75 76                	jne    80101b17 <iput+0xb4>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101aa1:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa4:	8b 40 0c             	mov    0xc(%eax),%eax
80101aa7:	83 e0 01             	and    $0x1,%eax
80101aaa:	84 c0                	test   %al,%al
80101aac:	74 0c                	je     80101aba <iput+0x57>
      panic("iput busy");
80101aae:	c7 04 24 dc 8a 10 80 	movl   $0x80108adc,(%esp)
80101ab5:	e8 83 ea ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80101aba:	8b 45 08             	mov    0x8(%ebp),%eax
80101abd:	8b 40 0c             	mov    0xc(%eax),%eax
80101ac0:	89 c2                	mov    %eax,%edx
80101ac2:	83 ca 01             	or     $0x1,%edx
80101ac5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac8:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101acb:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101ad2:	e8 62 38 00 00       	call   80105339 <release>
    itrunc(ip);
80101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ada:	89 04 24             	mov    %eax,(%esp)
80101add:	e8 72 01 00 00       	call   80101c54 <itrunc>
    ip->type = 0;
80101ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae5:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101aeb:	8b 45 08             	mov    0x8(%ebp),%eax
80101aee:	89 04 24             	mov    %eax,(%esp)
80101af1:	e8 fe fb ff ff       	call   801016f4 <iupdate>
    acquire(&icache.lock);
80101af6:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101afd:	e8 d5 37 00 00       	call   801052d7 <acquire>
    ip->flags = 0;
80101b02:	8b 45 08             	mov    0x8(%ebp),%eax
80101b05:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101b0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0f:	89 04 24             	mov    %eax,(%esp)
80101b12:	e8 b6 35 00 00       	call   801050cd <wakeup>
  }
  ip->ref--;
80101b17:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1a:	8b 40 08             	mov    0x8(%eax),%eax
80101b1d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101b20:	8b 45 08             	mov    0x8(%ebp),%eax
80101b23:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b26:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101b2d:	e8 07 38 00 00       	call   80105339 <release>
}
80101b32:	c9                   	leave  
80101b33:	c3                   	ret    

80101b34 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101b34:	55                   	push   %ebp
80101b35:	89 e5                	mov    %esp,%ebp
80101b37:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101b3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3d:	89 04 24             	mov    %eax,(%esp)
80101b40:	e8 b9 fe ff ff       	call   801019fe <iunlock>
  iput(ip);
80101b45:	8b 45 08             	mov    0x8(%ebp),%eax
80101b48:	89 04 24             	mov    %eax,(%esp)
80101b4b:	e8 13 ff ff ff       	call   80101a63 <iput>
}
80101b50:	c9                   	leave  
80101b51:	c3                   	ret    

80101b52 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101b52:	55                   	push   %ebp
80101b53:	89 e5                	mov    %esp,%ebp
80101b55:	53                   	push   %ebx
80101b56:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b59:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b5d:	77 3e                	ja     80101b9d <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b62:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b65:	83 c2 04             	add    $0x4,%edx
80101b68:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b6f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b73:	75 20                	jne    80101b95 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b75:	8b 45 08             	mov    0x8(%ebp),%eax
80101b78:	8b 00                	mov    (%eax),%eax
80101b7a:	89 04 24             	mov    %eax,(%esp)
80101b7d:	e8 49 f8 ff ff       	call   801013cb <balloc>
80101b82:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b85:	8b 45 08             	mov    0x8(%ebp),%eax
80101b88:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b8b:	8d 4a 04             	lea    0x4(%edx),%ecx
80101b8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b91:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b98:	e9 b1 00 00 00       	jmp    80101c4e <bmap+0xfc>
  }
  bn -= NDIRECT;
80101b9d:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101ba1:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101ba5:	0f 87 97 00 00 00    	ja     80101c42 <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101bab:	8b 45 08             	mov    0x8(%ebp),%eax
80101bae:	8b 40 4c             	mov    0x4c(%eax),%eax
80101bb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bb4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bb8:	75 19                	jne    80101bd3 <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101bba:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbd:	8b 00                	mov    (%eax),%eax
80101bbf:	89 04 24             	mov    %eax,(%esp)
80101bc2:	e8 04 f8 ff ff       	call   801013cb <balloc>
80101bc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bca:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bd0:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101bd3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd6:	8b 00                	mov    (%eax),%eax
80101bd8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bdb:	89 54 24 04          	mov    %edx,0x4(%esp)
80101bdf:	89 04 24             	mov    %eax,(%esp)
80101be2:	e8 bf e5 ff ff       	call   801001a6 <bread>
80101be7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bed:	83 c0 18             	add    $0x18,%eax
80101bf0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101bf3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bf6:	c1 e0 02             	shl    $0x2,%eax
80101bf9:	03 45 ec             	add    -0x14(%ebp),%eax
80101bfc:	8b 00                	mov    (%eax),%eax
80101bfe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c01:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c05:	75 2b                	jne    80101c32 <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
80101c07:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c0a:	c1 e0 02             	shl    $0x2,%eax
80101c0d:	89 c3                	mov    %eax,%ebx
80101c0f:	03 5d ec             	add    -0x14(%ebp),%ebx
80101c12:	8b 45 08             	mov    0x8(%ebp),%eax
80101c15:	8b 00                	mov    (%eax),%eax
80101c17:	89 04 24             	mov    %eax,(%esp)
80101c1a:	e8 ac f7 ff ff       	call   801013cb <balloc>
80101c1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c25:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101c27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c2a:	89 04 24             	mov    %eax,(%esp)
80101c2d:	e8 70 1a 00 00       	call   801036a2 <log_write>
    }
    brelse(bp);
80101c32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c35:	89 04 24             	mov    %eax,(%esp)
80101c38:	e8 da e5 ff ff       	call   80100217 <brelse>
    return addr;
80101c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c40:	eb 0c                	jmp    80101c4e <bmap+0xfc>
  }

  panic("bmap: out of range");
80101c42:	c7 04 24 e6 8a 10 80 	movl   $0x80108ae6,(%esp)
80101c49:	e8 ef e8 ff ff       	call   8010053d <panic>
}
80101c4e:	83 c4 24             	add    $0x24,%esp
80101c51:	5b                   	pop    %ebx
80101c52:	5d                   	pop    %ebp
80101c53:	c3                   	ret    

80101c54 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c54:	55                   	push   %ebp
80101c55:	89 e5                	mov    %esp,%ebp
80101c57:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c61:	eb 44                	jmp    80101ca7 <itrunc+0x53>
    if(ip->addrs[i]){
80101c63:	8b 45 08             	mov    0x8(%ebp),%eax
80101c66:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c69:	83 c2 04             	add    $0x4,%edx
80101c6c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c70:	85 c0                	test   %eax,%eax
80101c72:	74 2f                	je     80101ca3 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101c74:	8b 45 08             	mov    0x8(%ebp),%eax
80101c77:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c7a:	83 c2 04             	add    $0x4,%edx
80101c7d:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101c81:	8b 45 08             	mov    0x8(%ebp),%eax
80101c84:	8b 00                	mov    (%eax),%eax
80101c86:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c8a:	89 04 24             	mov    %eax,(%esp)
80101c8d:	e8 90 f8 ff ff       	call   80101522 <bfree>
      ip->addrs[i] = 0;
80101c92:	8b 45 08             	mov    0x8(%ebp),%eax
80101c95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c98:	83 c2 04             	add    $0x4,%edx
80101c9b:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101ca2:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101ca3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101ca7:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101cab:	7e b6                	jle    80101c63 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101cad:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb0:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cb3:	85 c0                	test   %eax,%eax
80101cb5:	0f 84 8f 00 00 00    	je     80101d4a <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101cbb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbe:	8b 50 4c             	mov    0x4c(%eax),%edx
80101cc1:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc4:	8b 00                	mov    (%eax),%eax
80101cc6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cca:	89 04 24             	mov    %eax,(%esp)
80101ccd:	e8 d4 e4 ff ff       	call   801001a6 <bread>
80101cd2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101cd5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cd8:	83 c0 18             	add    $0x18,%eax
80101cdb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101cde:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101ce5:	eb 2f                	jmp    80101d16 <itrunc+0xc2>
      if(a[j])
80101ce7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cea:	c1 e0 02             	shl    $0x2,%eax
80101ced:	03 45 e8             	add    -0x18(%ebp),%eax
80101cf0:	8b 00                	mov    (%eax),%eax
80101cf2:	85 c0                	test   %eax,%eax
80101cf4:	74 1c                	je     80101d12 <itrunc+0xbe>
        bfree(ip->dev, a[j]);
80101cf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cf9:	c1 e0 02             	shl    $0x2,%eax
80101cfc:	03 45 e8             	add    -0x18(%ebp),%eax
80101cff:	8b 10                	mov    (%eax),%edx
80101d01:	8b 45 08             	mov    0x8(%ebp),%eax
80101d04:	8b 00                	mov    (%eax),%eax
80101d06:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d0a:	89 04 24             	mov    %eax,(%esp)
80101d0d:	e8 10 f8 ff ff       	call   80101522 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101d12:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101d16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d19:	83 f8 7f             	cmp    $0x7f,%eax
80101d1c:	76 c9                	jbe    80101ce7 <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101d1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d21:	89 04 24             	mov    %eax,(%esp)
80101d24:	e8 ee e4 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101d29:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2c:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d32:	8b 00                	mov    (%eax),%eax
80101d34:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d38:	89 04 24             	mov    %eax,(%esp)
80101d3b:	e8 e2 f7 ff ff       	call   80101522 <bfree>
    ip->addrs[NDIRECT] = 0;
80101d40:	8b 45 08             	mov    0x8(%ebp),%eax
80101d43:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101d4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4d:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101d54:	8b 45 08             	mov    0x8(%ebp),%eax
80101d57:	89 04 24             	mov    %eax,(%esp)
80101d5a:	e8 95 f9 ff ff       	call   801016f4 <iupdate>
}
80101d5f:	c9                   	leave  
80101d60:	c3                   	ret    

80101d61 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101d61:	55                   	push   %ebp
80101d62:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101d64:	8b 45 08             	mov    0x8(%ebp),%eax
80101d67:	8b 00                	mov    (%eax),%eax
80101d69:	89 c2                	mov    %eax,%edx
80101d6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d6e:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101d71:	8b 45 08             	mov    0x8(%ebp),%eax
80101d74:	8b 50 04             	mov    0x4(%eax),%edx
80101d77:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d7a:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101d7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d80:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101d84:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d87:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101d8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8d:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101d91:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d94:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101d98:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9b:	8b 50 18             	mov    0x18(%eax),%edx
80101d9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101da1:	89 50 10             	mov    %edx,0x10(%eax)
}
80101da4:	5d                   	pop    %ebp
80101da5:	c3                   	ret    

80101da6 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101da6:	55                   	push   %ebp
80101da7:	89 e5                	mov    %esp,%ebp
80101da9:	53                   	push   %ebx
80101daa:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101dad:	8b 45 08             	mov    0x8(%ebp),%eax
80101db0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101db4:	66 83 f8 03          	cmp    $0x3,%ax
80101db8:	75 60                	jne    80101e1a <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101dba:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbd:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101dc1:	66 85 c0             	test   %ax,%ax
80101dc4:	78 20                	js     80101de6 <readi+0x40>
80101dc6:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101dcd:	66 83 f8 09          	cmp    $0x9,%ax
80101dd1:	7f 13                	jg     80101de6 <readi+0x40>
80101dd3:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd6:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101dda:	98                   	cwtl   
80101ddb:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
80101de2:	85 c0                	test   %eax,%eax
80101de4:	75 0a                	jne    80101df0 <readi+0x4a>
      return -1;
80101de6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101deb:	e9 1b 01 00 00       	jmp    80101f0b <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
80101df0:	8b 45 08             	mov    0x8(%ebp),%eax
80101df3:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101df7:	98                   	cwtl   
80101df8:	8b 14 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%edx
80101dff:	8b 45 14             	mov    0x14(%ebp),%eax
80101e02:	89 44 24 08          	mov    %eax,0x8(%esp)
80101e06:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e09:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e10:	89 04 24             	mov    %eax,(%esp)
80101e13:	ff d2                	call   *%edx
80101e15:	e9 f1 00 00 00       	jmp    80101f0b <readi+0x165>
  }

  if(off > ip->size || off + n < off)
80101e1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1d:	8b 40 18             	mov    0x18(%eax),%eax
80101e20:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e23:	72 0d                	jb     80101e32 <readi+0x8c>
80101e25:	8b 45 14             	mov    0x14(%ebp),%eax
80101e28:	8b 55 10             	mov    0x10(%ebp),%edx
80101e2b:	01 d0                	add    %edx,%eax
80101e2d:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e30:	73 0a                	jae    80101e3c <readi+0x96>
    return -1;
80101e32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e37:	e9 cf 00 00 00       	jmp    80101f0b <readi+0x165>
  if(off + n > ip->size)
80101e3c:	8b 45 14             	mov    0x14(%ebp),%eax
80101e3f:	8b 55 10             	mov    0x10(%ebp),%edx
80101e42:	01 c2                	add    %eax,%edx
80101e44:	8b 45 08             	mov    0x8(%ebp),%eax
80101e47:	8b 40 18             	mov    0x18(%eax),%eax
80101e4a:	39 c2                	cmp    %eax,%edx
80101e4c:	76 0c                	jbe    80101e5a <readi+0xb4>
    n = ip->size - off;
80101e4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e51:	8b 40 18             	mov    0x18(%eax),%eax
80101e54:	2b 45 10             	sub    0x10(%ebp),%eax
80101e57:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e61:	e9 96 00 00 00       	jmp    80101efc <readi+0x156>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e66:	8b 45 10             	mov    0x10(%ebp),%eax
80101e69:	c1 e8 09             	shr    $0x9,%eax
80101e6c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e70:	8b 45 08             	mov    0x8(%ebp),%eax
80101e73:	89 04 24             	mov    %eax,(%esp)
80101e76:	e8 d7 fc ff ff       	call   80101b52 <bmap>
80101e7b:	8b 55 08             	mov    0x8(%ebp),%edx
80101e7e:	8b 12                	mov    (%edx),%edx
80101e80:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e84:	89 14 24             	mov    %edx,(%esp)
80101e87:	e8 1a e3 ff ff       	call   801001a6 <bread>
80101e8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101e8f:	8b 45 10             	mov    0x10(%ebp),%eax
80101e92:	89 c2                	mov    %eax,%edx
80101e94:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80101e9a:	b8 00 02 00 00       	mov    $0x200,%eax
80101e9f:	89 c1                	mov    %eax,%ecx
80101ea1:	29 d1                	sub    %edx,%ecx
80101ea3:	89 ca                	mov    %ecx,%edx
80101ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ea8:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101eab:	89 cb                	mov    %ecx,%ebx
80101ead:	29 c3                	sub    %eax,%ebx
80101eaf:	89 d8                	mov    %ebx,%eax
80101eb1:	39 c2                	cmp    %eax,%edx
80101eb3:	0f 46 c2             	cmovbe %edx,%eax
80101eb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101eb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ebc:	8d 50 18             	lea    0x18(%eax),%edx
80101ebf:	8b 45 10             	mov    0x10(%ebp),%eax
80101ec2:	25 ff 01 00 00       	and    $0x1ff,%eax
80101ec7:	01 c2                	add    %eax,%edx
80101ec9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ecc:	89 44 24 08          	mov    %eax,0x8(%esp)
80101ed0:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ed4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed7:	89 04 24             	mov    %eax,(%esp)
80101eda:	e8 1a 37 00 00       	call   801055f9 <memmove>
    brelse(bp);
80101edf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ee2:	89 04 24             	mov    %eax,(%esp)
80101ee5:	e8 2d e3 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101eea:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eed:	01 45 f4             	add    %eax,-0xc(%ebp)
80101ef0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ef3:	01 45 10             	add    %eax,0x10(%ebp)
80101ef6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ef9:	01 45 0c             	add    %eax,0xc(%ebp)
80101efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101eff:	3b 45 14             	cmp    0x14(%ebp),%eax
80101f02:	0f 82 5e ff ff ff    	jb     80101e66 <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101f08:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101f0b:	83 c4 24             	add    $0x24,%esp
80101f0e:	5b                   	pop    %ebx
80101f0f:	5d                   	pop    %ebp
80101f10:	c3                   	ret    

80101f11 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101f11:	55                   	push   %ebp
80101f12:	89 e5                	mov    %esp,%ebp
80101f14:	53                   	push   %ebx
80101f15:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f18:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101f1f:	66 83 f8 03          	cmp    $0x3,%ax
80101f23:	75 60                	jne    80101f85 <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101f25:	8b 45 08             	mov    0x8(%ebp),%eax
80101f28:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f2c:	66 85 c0             	test   %ax,%ax
80101f2f:	78 20                	js     80101f51 <writei+0x40>
80101f31:	8b 45 08             	mov    0x8(%ebp),%eax
80101f34:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f38:	66 83 f8 09          	cmp    $0x9,%ax
80101f3c:	7f 13                	jg     80101f51 <writei+0x40>
80101f3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f41:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f45:	98                   	cwtl   
80101f46:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
80101f4d:	85 c0                	test   %eax,%eax
80101f4f:	75 0a                	jne    80101f5b <writei+0x4a>
      return -1;
80101f51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f56:	e9 46 01 00 00       	jmp    801020a1 <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
80101f5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f62:	98                   	cwtl   
80101f63:	8b 14 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%edx
80101f6a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6d:	89 44 24 08          	mov    %eax,0x8(%esp)
80101f71:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f74:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f78:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7b:	89 04 24             	mov    %eax,(%esp)
80101f7e:	ff d2                	call   *%edx
80101f80:	e9 1c 01 00 00       	jmp    801020a1 <writei+0x190>
  }

  if(off > ip->size || off + n < off)
80101f85:	8b 45 08             	mov    0x8(%ebp),%eax
80101f88:	8b 40 18             	mov    0x18(%eax),%eax
80101f8b:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f8e:	72 0d                	jb     80101f9d <writei+0x8c>
80101f90:	8b 45 14             	mov    0x14(%ebp),%eax
80101f93:	8b 55 10             	mov    0x10(%ebp),%edx
80101f96:	01 d0                	add    %edx,%eax
80101f98:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f9b:	73 0a                	jae    80101fa7 <writei+0x96>
    return -1;
80101f9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fa2:	e9 fa 00 00 00       	jmp    801020a1 <writei+0x190>
  if(off + n > MAXFILE*BSIZE)
80101fa7:	8b 45 14             	mov    0x14(%ebp),%eax
80101faa:	8b 55 10             	mov    0x10(%ebp),%edx
80101fad:	01 d0                	add    %edx,%eax
80101faf:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101fb4:	76 0a                	jbe    80101fc0 <writei+0xaf>
    return -1;
80101fb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fbb:	e9 e1 00 00 00       	jmp    801020a1 <writei+0x190>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101fc0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101fc7:	e9 a1 00 00 00       	jmp    8010206d <writei+0x15c>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101fcc:	8b 45 10             	mov    0x10(%ebp),%eax
80101fcf:	c1 e8 09             	shr    $0x9,%eax
80101fd2:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd9:	89 04 24             	mov    %eax,(%esp)
80101fdc:	e8 71 fb ff ff       	call   80101b52 <bmap>
80101fe1:	8b 55 08             	mov    0x8(%ebp),%edx
80101fe4:	8b 12                	mov    (%edx),%edx
80101fe6:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fea:	89 14 24             	mov    %edx,(%esp)
80101fed:	e8 b4 e1 ff ff       	call   801001a6 <bread>
80101ff2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101ff5:	8b 45 10             	mov    0x10(%ebp),%eax
80101ff8:	89 c2                	mov    %eax,%edx
80101ffa:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102000:	b8 00 02 00 00       	mov    $0x200,%eax
80102005:	89 c1                	mov    %eax,%ecx
80102007:	29 d1                	sub    %edx,%ecx
80102009:	89 ca                	mov    %ecx,%edx
8010200b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010200e:	8b 4d 14             	mov    0x14(%ebp),%ecx
80102011:	89 cb                	mov    %ecx,%ebx
80102013:	29 c3                	sub    %eax,%ebx
80102015:	89 d8                	mov    %ebx,%eax
80102017:	39 c2                	cmp    %eax,%edx
80102019:	0f 46 c2             	cmovbe %edx,%eax
8010201c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010201f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102022:	8d 50 18             	lea    0x18(%eax),%edx
80102025:	8b 45 10             	mov    0x10(%ebp),%eax
80102028:	25 ff 01 00 00       	and    $0x1ff,%eax
8010202d:	01 c2                	add    %eax,%edx
8010202f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102032:	89 44 24 08          	mov    %eax,0x8(%esp)
80102036:	8b 45 0c             	mov    0xc(%ebp),%eax
80102039:	89 44 24 04          	mov    %eax,0x4(%esp)
8010203d:	89 14 24             	mov    %edx,(%esp)
80102040:	e8 b4 35 00 00       	call   801055f9 <memmove>
    log_write(bp);
80102045:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102048:	89 04 24             	mov    %eax,(%esp)
8010204b:	e8 52 16 00 00       	call   801036a2 <log_write>
    brelse(bp);
80102050:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102053:	89 04 24             	mov    %eax,(%esp)
80102056:	e8 bc e1 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010205b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010205e:	01 45 f4             	add    %eax,-0xc(%ebp)
80102061:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102064:	01 45 10             	add    %eax,0x10(%ebp)
80102067:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010206a:	01 45 0c             	add    %eax,0xc(%ebp)
8010206d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102070:	3b 45 14             	cmp    0x14(%ebp),%eax
80102073:	0f 82 53 ff ff ff    	jb     80101fcc <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102079:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010207d:	74 1f                	je     8010209e <writei+0x18d>
8010207f:	8b 45 08             	mov    0x8(%ebp),%eax
80102082:	8b 40 18             	mov    0x18(%eax),%eax
80102085:	3b 45 10             	cmp    0x10(%ebp),%eax
80102088:	73 14                	jae    8010209e <writei+0x18d>
    ip->size = off;
8010208a:	8b 45 08             	mov    0x8(%ebp),%eax
8010208d:	8b 55 10             	mov    0x10(%ebp),%edx
80102090:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102093:	8b 45 08             	mov    0x8(%ebp),%eax
80102096:	89 04 24             	mov    %eax,(%esp)
80102099:	e8 56 f6 ff ff       	call   801016f4 <iupdate>
  }
  return n;
8010209e:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020a1:	83 c4 24             	add    $0x24,%esp
801020a4:	5b                   	pop    %ebx
801020a5:	5d                   	pop    %ebp
801020a6:	c3                   	ret    

801020a7 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801020a7:	55                   	push   %ebp
801020a8:	89 e5                	mov    %esp,%ebp
801020aa:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801020ad:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801020b4:	00 
801020b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801020b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801020bc:	8b 45 08             	mov    0x8(%ebp),%eax
801020bf:	89 04 24             	mov    %eax,(%esp)
801020c2:	e8 d6 35 00 00       	call   8010569d <strncmp>
}
801020c7:	c9                   	leave  
801020c8:	c3                   	ret    

801020c9 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801020c9:	55                   	push   %ebp
801020ca:	89 e5                	mov    %esp,%ebp
801020cc:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801020cf:	8b 45 08             	mov    0x8(%ebp),%eax
801020d2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020d6:	66 83 f8 01          	cmp    $0x1,%ax
801020da:	74 0c                	je     801020e8 <dirlookup+0x1f>
    panic("dirlookup not DIR");
801020dc:	c7 04 24 f9 8a 10 80 	movl   $0x80108af9,(%esp)
801020e3:	e8 55 e4 ff ff       	call   8010053d <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801020e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020ef:	e9 87 00 00 00       	jmp    8010217b <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801020f4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801020fb:	00 
801020fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020ff:	89 44 24 08          	mov    %eax,0x8(%esp)
80102103:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102106:	89 44 24 04          	mov    %eax,0x4(%esp)
8010210a:	8b 45 08             	mov    0x8(%ebp),%eax
8010210d:	89 04 24             	mov    %eax,(%esp)
80102110:	e8 91 fc ff ff       	call   80101da6 <readi>
80102115:	83 f8 10             	cmp    $0x10,%eax
80102118:	74 0c                	je     80102126 <dirlookup+0x5d>
      panic("dirlink read");
8010211a:	c7 04 24 0b 8b 10 80 	movl   $0x80108b0b,(%esp)
80102121:	e8 17 e4 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
80102126:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010212a:	66 85 c0             	test   %ax,%ax
8010212d:	74 47                	je     80102176 <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
8010212f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102132:	83 c0 02             	add    $0x2,%eax
80102135:	89 44 24 04          	mov    %eax,0x4(%esp)
80102139:	8b 45 0c             	mov    0xc(%ebp),%eax
8010213c:	89 04 24             	mov    %eax,(%esp)
8010213f:	e8 63 ff ff ff       	call   801020a7 <namecmp>
80102144:	85 c0                	test   %eax,%eax
80102146:	75 2f                	jne    80102177 <dirlookup+0xae>
      // entry matches path element
      if(poff)
80102148:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010214c:	74 08                	je     80102156 <dirlookup+0x8d>
        *poff = off;
8010214e:	8b 45 10             	mov    0x10(%ebp),%eax
80102151:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102154:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102156:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010215a:	0f b7 c0             	movzwl %ax,%eax
8010215d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102160:	8b 45 08             	mov    0x8(%ebp),%eax
80102163:	8b 00                	mov    (%eax),%eax
80102165:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102168:	89 54 24 04          	mov    %edx,0x4(%esp)
8010216c:	89 04 24             	mov    %eax,(%esp)
8010216f:	e8 38 f6 ff ff       	call   801017ac <iget>
80102174:	eb 19                	jmp    8010218f <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102176:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102177:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010217b:	8b 45 08             	mov    0x8(%ebp),%eax
8010217e:	8b 40 18             	mov    0x18(%eax),%eax
80102181:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102184:	0f 87 6a ff ff ff    	ja     801020f4 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010218a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010218f:	c9                   	leave  
80102190:	c3                   	ret    

80102191 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102191:	55                   	push   %ebp
80102192:	89 e5                	mov    %esp,%ebp
80102194:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102197:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010219e:	00 
8010219f:	8b 45 0c             	mov    0xc(%ebp),%eax
801021a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801021a6:	8b 45 08             	mov    0x8(%ebp),%eax
801021a9:	89 04 24             	mov    %eax,(%esp)
801021ac:	e8 18 ff ff ff       	call   801020c9 <dirlookup>
801021b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801021b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801021b8:	74 15                	je     801021cf <dirlink+0x3e>
    iput(ip);
801021ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021bd:	89 04 24             	mov    %eax,(%esp)
801021c0:	e8 9e f8 ff ff       	call   80101a63 <iput>
    return -1;
801021c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021ca:	e9 b8 00 00 00       	jmp    80102287 <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021d6:	eb 44                	jmp    8010221c <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021db:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801021e2:	00 
801021e3:	89 44 24 08          	mov    %eax,0x8(%esp)
801021e7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801021ee:	8b 45 08             	mov    0x8(%ebp),%eax
801021f1:	89 04 24             	mov    %eax,(%esp)
801021f4:	e8 ad fb ff ff       	call   80101da6 <readi>
801021f9:	83 f8 10             	cmp    $0x10,%eax
801021fc:	74 0c                	je     8010220a <dirlink+0x79>
      panic("dirlink read");
801021fe:	c7 04 24 0b 8b 10 80 	movl   $0x80108b0b,(%esp)
80102205:	e8 33 e3 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
8010220a:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010220e:	66 85 c0             	test   %ax,%ax
80102211:	74 18                	je     8010222b <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102213:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102216:	83 c0 10             	add    $0x10,%eax
80102219:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010221c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010221f:	8b 45 08             	mov    0x8(%ebp),%eax
80102222:	8b 40 18             	mov    0x18(%eax),%eax
80102225:	39 c2                	cmp    %eax,%edx
80102227:	72 af                	jb     801021d8 <dirlink+0x47>
80102229:	eb 01                	jmp    8010222c <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
8010222b:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010222c:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102233:	00 
80102234:	8b 45 0c             	mov    0xc(%ebp),%eax
80102237:	89 44 24 04          	mov    %eax,0x4(%esp)
8010223b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010223e:	83 c0 02             	add    $0x2,%eax
80102241:	89 04 24             	mov    %eax,(%esp)
80102244:	e8 ac 34 00 00       	call   801056f5 <strncpy>
  de.inum = inum;
80102249:	8b 45 10             	mov    0x10(%ebp),%eax
8010224c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102250:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102253:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010225a:	00 
8010225b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010225f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102262:	89 44 24 04          	mov    %eax,0x4(%esp)
80102266:	8b 45 08             	mov    0x8(%ebp),%eax
80102269:	89 04 24             	mov    %eax,(%esp)
8010226c:	e8 a0 fc ff ff       	call   80101f11 <writei>
80102271:	83 f8 10             	cmp    $0x10,%eax
80102274:	74 0c                	je     80102282 <dirlink+0xf1>
    panic("dirlink");
80102276:	c7 04 24 18 8b 10 80 	movl   $0x80108b18,(%esp)
8010227d:	e8 bb e2 ff ff       	call   8010053d <panic>
  
  return 0;
80102282:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102287:	c9                   	leave  
80102288:	c3                   	ret    

80102289 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102289:	55                   	push   %ebp
8010228a:	89 e5                	mov    %esp,%ebp
8010228c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
8010228f:	eb 04                	jmp    80102295 <skipelem+0xc>
    path++;
80102291:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102295:	8b 45 08             	mov    0x8(%ebp),%eax
80102298:	0f b6 00             	movzbl (%eax),%eax
8010229b:	3c 2f                	cmp    $0x2f,%al
8010229d:	74 f2                	je     80102291 <skipelem+0x8>
    path++;
  if(*path == 0)
8010229f:	8b 45 08             	mov    0x8(%ebp),%eax
801022a2:	0f b6 00             	movzbl (%eax),%eax
801022a5:	84 c0                	test   %al,%al
801022a7:	75 0a                	jne    801022b3 <skipelem+0x2a>
    return 0;
801022a9:	b8 00 00 00 00       	mov    $0x0,%eax
801022ae:	e9 86 00 00 00       	jmp    80102339 <skipelem+0xb0>
  s = path;
801022b3:	8b 45 08             	mov    0x8(%ebp),%eax
801022b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801022b9:	eb 04                	jmp    801022bf <skipelem+0x36>
    path++;
801022bb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801022bf:	8b 45 08             	mov    0x8(%ebp),%eax
801022c2:	0f b6 00             	movzbl (%eax),%eax
801022c5:	3c 2f                	cmp    $0x2f,%al
801022c7:	74 0a                	je     801022d3 <skipelem+0x4a>
801022c9:	8b 45 08             	mov    0x8(%ebp),%eax
801022cc:	0f b6 00             	movzbl (%eax),%eax
801022cf:	84 c0                	test   %al,%al
801022d1:	75 e8                	jne    801022bb <skipelem+0x32>
    path++;
  len = path - s;
801022d3:	8b 55 08             	mov    0x8(%ebp),%edx
801022d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d9:	89 d1                	mov    %edx,%ecx
801022db:	29 c1                	sub    %eax,%ecx
801022dd:	89 c8                	mov    %ecx,%eax
801022df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801022e2:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801022e6:	7e 1c                	jle    80102304 <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
801022e8:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801022ef:	00 
801022f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801022f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801022fa:	89 04 24             	mov    %eax,(%esp)
801022fd:	e8 f7 32 00 00       	call   801055f9 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102302:	eb 28                	jmp    8010232c <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102304:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102307:	89 44 24 08          	mov    %eax,0x8(%esp)
8010230b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010230e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102312:	8b 45 0c             	mov    0xc(%ebp),%eax
80102315:	89 04 24             	mov    %eax,(%esp)
80102318:	e8 dc 32 00 00       	call   801055f9 <memmove>
    name[len] = 0;
8010231d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102320:	03 45 0c             	add    0xc(%ebp),%eax
80102323:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102326:	eb 04                	jmp    8010232c <skipelem+0xa3>
    path++;
80102328:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010232c:	8b 45 08             	mov    0x8(%ebp),%eax
8010232f:	0f b6 00             	movzbl (%eax),%eax
80102332:	3c 2f                	cmp    $0x2f,%al
80102334:	74 f2                	je     80102328 <skipelem+0x9f>
    path++;
  return path;
80102336:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102339:	c9                   	leave  
8010233a:	c3                   	ret    

8010233b <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010233b:	55                   	push   %ebp
8010233c:	89 e5                	mov    %esp,%ebp
8010233e:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102341:	8b 45 08             	mov    0x8(%ebp),%eax
80102344:	0f b6 00             	movzbl (%eax),%eax
80102347:	3c 2f                	cmp    $0x2f,%al
80102349:	75 1c                	jne    80102367 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
8010234b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102352:	00 
80102353:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010235a:	e8 4d f4 ff ff       	call   801017ac <iget>
8010235f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102362:	e9 af 00 00 00       	jmp    80102416 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102367:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010236d:	8b 40 68             	mov    0x68(%eax),%eax
80102370:	89 04 24             	mov    %eax,(%esp)
80102373:	e8 06 f5 ff ff       	call   8010187e <idup>
80102378:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010237b:	e9 96 00 00 00       	jmp    80102416 <namex+0xdb>
    ilock(ip);
80102380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102383:	89 04 24             	mov    %eax,(%esp)
80102386:	e8 25 f5 ff ff       	call   801018b0 <ilock>
    if(ip->type != T_DIR){
8010238b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010238e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102392:	66 83 f8 01          	cmp    $0x1,%ax
80102396:	74 15                	je     801023ad <namex+0x72>
      iunlockput(ip);
80102398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010239b:	89 04 24             	mov    %eax,(%esp)
8010239e:	e8 91 f7 ff ff       	call   80101b34 <iunlockput>
      return 0;
801023a3:	b8 00 00 00 00       	mov    $0x0,%eax
801023a8:	e9 a3 00 00 00       	jmp    80102450 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
801023ad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023b1:	74 1d                	je     801023d0 <namex+0x95>
801023b3:	8b 45 08             	mov    0x8(%ebp),%eax
801023b6:	0f b6 00             	movzbl (%eax),%eax
801023b9:	84 c0                	test   %al,%al
801023bb:	75 13                	jne    801023d0 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
801023bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c0:	89 04 24             	mov    %eax,(%esp)
801023c3:	e8 36 f6 ff ff       	call   801019fe <iunlock>
      return ip;
801023c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023cb:	e9 80 00 00 00       	jmp    80102450 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801023d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801023d7:	00 
801023d8:	8b 45 10             	mov    0x10(%ebp),%eax
801023db:	89 44 24 04          	mov    %eax,0x4(%esp)
801023df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023e2:	89 04 24             	mov    %eax,(%esp)
801023e5:	e8 df fc ff ff       	call   801020c9 <dirlookup>
801023ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023f1:	75 12                	jne    80102405 <namex+0xca>
      iunlockput(ip);
801023f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f6:	89 04 24             	mov    %eax,(%esp)
801023f9:	e8 36 f7 ff ff       	call   80101b34 <iunlockput>
      return 0;
801023fe:	b8 00 00 00 00       	mov    $0x0,%eax
80102403:	eb 4b                	jmp    80102450 <namex+0x115>
    }
    iunlockput(ip);
80102405:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102408:	89 04 24             	mov    %eax,(%esp)
8010240b:	e8 24 f7 ff ff       	call   80101b34 <iunlockput>
    ip = next;
80102410:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102413:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102416:	8b 45 10             	mov    0x10(%ebp),%eax
80102419:	89 44 24 04          	mov    %eax,0x4(%esp)
8010241d:	8b 45 08             	mov    0x8(%ebp),%eax
80102420:	89 04 24             	mov    %eax,(%esp)
80102423:	e8 61 fe ff ff       	call   80102289 <skipelem>
80102428:	89 45 08             	mov    %eax,0x8(%ebp)
8010242b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010242f:	0f 85 4b ff ff ff    	jne    80102380 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102435:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102439:	74 12                	je     8010244d <namex+0x112>
    iput(ip);
8010243b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010243e:	89 04 24             	mov    %eax,(%esp)
80102441:	e8 1d f6 ff ff       	call   80101a63 <iput>
    return 0;
80102446:	b8 00 00 00 00       	mov    $0x0,%eax
8010244b:	eb 03                	jmp    80102450 <namex+0x115>
  }
  return ip;
8010244d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102450:	c9                   	leave  
80102451:	c3                   	ret    

80102452 <namei>:

struct inode*
namei(char *path)
{
80102452:	55                   	push   %ebp
80102453:	89 e5                	mov    %esp,%ebp
80102455:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102458:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010245b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010245f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102466:	00 
80102467:	8b 45 08             	mov    0x8(%ebp),%eax
8010246a:	89 04 24             	mov    %eax,(%esp)
8010246d:	e8 c9 fe ff ff       	call   8010233b <namex>
}
80102472:	c9                   	leave  
80102473:	c3                   	ret    

80102474 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102474:	55                   	push   %ebp
80102475:	89 e5                	mov    %esp,%ebp
80102477:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010247a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010247d:	89 44 24 08          	mov    %eax,0x8(%esp)
80102481:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102488:	00 
80102489:	8b 45 08             	mov    0x8(%ebp),%eax
8010248c:	89 04 24             	mov    %eax,(%esp)
8010248f:	e8 a7 fe ff ff       	call   8010233b <namex>
}
80102494:	c9                   	leave  
80102495:	c3                   	ret    
	...

80102498 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102498:	55                   	push   %ebp
80102499:	89 e5                	mov    %esp,%ebp
8010249b:	53                   	push   %ebx
8010249c:	83 ec 14             	sub    $0x14,%esp
8010249f:	8b 45 08             	mov    0x8(%ebp),%eax
801024a2:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801024a6:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801024aa:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801024ae:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801024b2:	ec                   	in     (%dx),%al
801024b3:	89 c3                	mov    %eax,%ebx
801024b5:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801024b8:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801024bc:	83 c4 14             	add    $0x14,%esp
801024bf:	5b                   	pop    %ebx
801024c0:	5d                   	pop    %ebp
801024c1:	c3                   	ret    

801024c2 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801024c2:	55                   	push   %ebp
801024c3:	89 e5                	mov    %esp,%ebp
801024c5:	57                   	push   %edi
801024c6:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801024c7:	8b 55 08             	mov    0x8(%ebp),%edx
801024ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024cd:	8b 45 10             	mov    0x10(%ebp),%eax
801024d0:	89 cb                	mov    %ecx,%ebx
801024d2:	89 df                	mov    %ebx,%edi
801024d4:	89 c1                	mov    %eax,%ecx
801024d6:	fc                   	cld    
801024d7:	f3 6d                	rep insl (%dx),%es:(%edi)
801024d9:	89 c8                	mov    %ecx,%eax
801024db:	89 fb                	mov    %edi,%ebx
801024dd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024e0:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801024e3:	5b                   	pop    %ebx
801024e4:	5f                   	pop    %edi
801024e5:	5d                   	pop    %ebp
801024e6:	c3                   	ret    

801024e7 <outb>:

static inline void
outb(ushort port, uchar data)
{
801024e7:	55                   	push   %ebp
801024e8:	89 e5                	mov    %esp,%ebp
801024ea:	83 ec 08             	sub    $0x8,%esp
801024ed:	8b 55 08             	mov    0x8(%ebp),%edx
801024f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801024f3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801024f7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801024fa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801024fe:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102502:	ee                   	out    %al,(%dx)
}
80102503:	c9                   	leave  
80102504:	c3                   	ret    

80102505 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102505:	55                   	push   %ebp
80102506:	89 e5                	mov    %esp,%ebp
80102508:	56                   	push   %esi
80102509:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010250a:	8b 55 08             	mov    0x8(%ebp),%edx
8010250d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102510:	8b 45 10             	mov    0x10(%ebp),%eax
80102513:	89 cb                	mov    %ecx,%ebx
80102515:	89 de                	mov    %ebx,%esi
80102517:	89 c1                	mov    %eax,%ecx
80102519:	fc                   	cld    
8010251a:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010251c:	89 c8                	mov    %ecx,%eax
8010251e:	89 f3                	mov    %esi,%ebx
80102520:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102523:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102526:	5b                   	pop    %ebx
80102527:	5e                   	pop    %esi
80102528:	5d                   	pop    %ebp
80102529:	c3                   	ret    

8010252a <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010252a:	55                   	push   %ebp
8010252b:	89 e5                	mov    %esp,%ebp
8010252d:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102530:	90                   	nop
80102531:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102538:	e8 5b ff ff ff       	call   80102498 <inb>
8010253d:	0f b6 c0             	movzbl %al,%eax
80102540:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102543:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102546:	25 c0 00 00 00       	and    $0xc0,%eax
8010254b:	83 f8 40             	cmp    $0x40,%eax
8010254e:	75 e1                	jne    80102531 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102550:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102554:	74 11                	je     80102567 <idewait+0x3d>
80102556:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102559:	83 e0 21             	and    $0x21,%eax
8010255c:	85 c0                	test   %eax,%eax
8010255e:	74 07                	je     80102567 <idewait+0x3d>
    return -1;
80102560:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102565:	eb 05                	jmp    8010256c <idewait+0x42>
  return 0;
80102567:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010256c:	c9                   	leave  
8010256d:	c3                   	ret    

8010256e <ideinit>:

void
ideinit(void)
{
8010256e:	55                   	push   %ebp
8010256f:	89 e5                	mov    %esp,%ebp
80102571:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102574:	c7 44 24 04 20 8b 10 	movl   $0x80108b20,0x4(%esp)
8010257b:	80 
8010257c:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102583:	e8 2e 2d 00 00       	call   801052b6 <initlock>
  picenable(IRQ_IDE);
80102588:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010258f:	e8 c1 18 00 00       	call   80103e55 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102594:	a1 40 39 11 80       	mov    0x80113940,%eax
80102599:	83 e8 01             	sub    $0x1,%eax
8010259c:	89 44 24 04          	mov    %eax,0x4(%esp)
801025a0:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801025a7:	e8 12 04 00 00       	call   801029be <ioapicenable>
  idewait(0);
801025ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025b3:	e8 72 ff ff ff       	call   8010252a <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801025b8:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801025bf:	00 
801025c0:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025c7:	e8 1b ff ff ff       	call   801024e7 <outb>
  for(i=0; i<1000; i++){
801025cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025d3:	eb 20                	jmp    801025f5 <ideinit+0x87>
    if(inb(0x1f7) != 0){
801025d5:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801025dc:	e8 b7 fe ff ff       	call   80102498 <inb>
801025e1:	84 c0                	test   %al,%al
801025e3:	74 0c                	je     801025f1 <ideinit+0x83>
      havedisk1 = 1;
801025e5:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
801025ec:	00 00 00 
      break;
801025ef:	eb 0d                	jmp    801025fe <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801025f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801025f5:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801025fc:	7e d7                	jle    801025d5 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801025fe:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102605:	00 
80102606:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010260d:	e8 d5 fe ff ff       	call   801024e7 <outb>
}
80102612:	c9                   	leave  
80102613:	c3                   	ret    

80102614 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102614:	55                   	push   %ebp
80102615:	89 e5                	mov    %esp,%ebp
80102617:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
8010261a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010261e:	75 0c                	jne    8010262c <idestart+0x18>
    panic("idestart");
80102620:	c7 04 24 24 8b 10 80 	movl   $0x80108b24,(%esp)
80102627:	e8 11 df ff ff       	call   8010053d <panic>

  idewait(0);
8010262c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102633:	e8 f2 fe ff ff       	call   8010252a <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102638:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010263f:	00 
80102640:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102647:	e8 9b fe ff ff       	call   801024e7 <outb>
  outb(0x1f2, 1);  // number of sectors
8010264c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102653:	00 
80102654:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
8010265b:	e8 87 fe ff ff       	call   801024e7 <outb>
  outb(0x1f3, b->sector & 0xff);
80102660:	8b 45 08             	mov    0x8(%ebp),%eax
80102663:	8b 40 08             	mov    0x8(%eax),%eax
80102666:	0f b6 c0             	movzbl %al,%eax
80102669:	89 44 24 04          	mov    %eax,0x4(%esp)
8010266d:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102674:	e8 6e fe ff ff       	call   801024e7 <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
80102679:	8b 45 08             	mov    0x8(%ebp),%eax
8010267c:	8b 40 08             	mov    0x8(%eax),%eax
8010267f:	c1 e8 08             	shr    $0x8,%eax
80102682:	0f b6 c0             	movzbl %al,%eax
80102685:	89 44 24 04          	mov    %eax,0x4(%esp)
80102689:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102690:	e8 52 fe ff ff       	call   801024e7 <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102695:	8b 45 08             	mov    0x8(%ebp),%eax
80102698:	8b 40 08             	mov    0x8(%eax),%eax
8010269b:	c1 e8 10             	shr    $0x10,%eax
8010269e:	0f b6 c0             	movzbl %al,%eax
801026a1:	89 44 24 04          	mov    %eax,0x4(%esp)
801026a5:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801026ac:	e8 36 fe ff ff       	call   801024e7 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
801026b1:	8b 45 08             	mov    0x8(%ebp),%eax
801026b4:	8b 40 04             	mov    0x4(%eax),%eax
801026b7:	83 e0 01             	and    $0x1,%eax
801026ba:	89 c2                	mov    %eax,%edx
801026bc:	c1 e2 04             	shl    $0x4,%edx
801026bf:	8b 45 08             	mov    0x8(%ebp),%eax
801026c2:	8b 40 08             	mov    0x8(%eax),%eax
801026c5:	c1 e8 18             	shr    $0x18,%eax
801026c8:	83 e0 0f             	and    $0xf,%eax
801026cb:	09 d0                	or     %edx,%eax
801026cd:	83 c8 e0             	or     $0xffffffe0,%eax
801026d0:	0f b6 c0             	movzbl %al,%eax
801026d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801026d7:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801026de:	e8 04 fe ff ff       	call   801024e7 <outb>
  if(b->flags & B_DIRTY){
801026e3:	8b 45 08             	mov    0x8(%ebp),%eax
801026e6:	8b 00                	mov    (%eax),%eax
801026e8:	83 e0 04             	and    $0x4,%eax
801026eb:	85 c0                	test   %eax,%eax
801026ed:	74 34                	je     80102723 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
801026ef:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801026f6:	00 
801026f7:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026fe:	e8 e4 fd ff ff       	call   801024e7 <outb>
    outsl(0x1f0, b->data, 512/4);
80102703:	8b 45 08             	mov    0x8(%ebp),%eax
80102706:	83 c0 18             	add    $0x18,%eax
80102709:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102710:	00 
80102711:	89 44 24 04          	mov    %eax,0x4(%esp)
80102715:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010271c:	e8 e4 fd ff ff       	call   80102505 <outsl>
80102721:	eb 14                	jmp    80102737 <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102723:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
8010272a:	00 
8010272b:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102732:	e8 b0 fd ff ff       	call   801024e7 <outb>
  }
}
80102737:	c9                   	leave  
80102738:	c3                   	ret    

80102739 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102739:	55                   	push   %ebp
8010273a:	89 e5                	mov    %esp,%ebp
8010273c:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010273f:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102746:	e8 8c 2b 00 00       	call   801052d7 <acquire>
  if((b = idequeue) == 0){
8010274b:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102750:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102753:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102757:	75 11                	jne    8010276a <ideintr+0x31>
    release(&idelock);
80102759:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102760:	e8 d4 2b 00 00       	call   80105339 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102765:	e9 90 00 00 00       	jmp    801027fa <ideintr+0xc1>
  }
  idequeue = b->qnext;
8010276a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010276d:	8b 40 14             	mov    0x14(%eax),%eax
80102770:	a3 34 c6 10 80       	mov    %eax,0x8010c634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102775:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102778:	8b 00                	mov    (%eax),%eax
8010277a:	83 e0 04             	and    $0x4,%eax
8010277d:	85 c0                	test   %eax,%eax
8010277f:	75 2e                	jne    801027af <ideintr+0x76>
80102781:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102788:	e8 9d fd ff ff       	call   8010252a <idewait>
8010278d:	85 c0                	test   %eax,%eax
8010278f:	78 1e                	js     801027af <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102794:	83 c0 18             	add    $0x18,%eax
80102797:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010279e:	00 
8010279f:	89 44 24 04          	mov    %eax,0x4(%esp)
801027a3:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801027aa:	e8 13 fd ff ff       	call   801024c2 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801027af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027b2:	8b 00                	mov    (%eax),%eax
801027b4:	89 c2                	mov    %eax,%edx
801027b6:	83 ca 02             	or     $0x2,%edx
801027b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027bc:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801027be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027c1:	8b 00                	mov    (%eax),%eax
801027c3:	89 c2                	mov    %eax,%edx
801027c5:	83 e2 fb             	and    $0xfffffffb,%edx
801027c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027cb:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801027cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d0:	89 04 24             	mov    %eax,(%esp)
801027d3:	e8 f5 28 00 00       	call   801050cd <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
801027d8:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801027dd:	85 c0                	test   %eax,%eax
801027df:	74 0d                	je     801027ee <ideintr+0xb5>
    idestart(idequeue);
801027e1:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801027e6:	89 04 24             	mov    %eax,(%esp)
801027e9:	e8 26 fe ff ff       	call   80102614 <idestart>

  release(&idelock);
801027ee:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
801027f5:	e8 3f 2b 00 00       	call   80105339 <release>
}
801027fa:	c9                   	leave  
801027fb:	c3                   	ret    

801027fc <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801027fc:	55                   	push   %ebp
801027fd:	89 e5                	mov    %esp,%ebp
801027ff:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102802:	8b 45 08             	mov    0x8(%ebp),%eax
80102805:	8b 00                	mov    (%eax),%eax
80102807:	83 e0 01             	and    $0x1,%eax
8010280a:	85 c0                	test   %eax,%eax
8010280c:	75 0c                	jne    8010281a <iderw+0x1e>
    panic("iderw: buf not busy");
8010280e:	c7 04 24 2d 8b 10 80 	movl   $0x80108b2d,(%esp)
80102815:	e8 23 dd ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010281a:	8b 45 08             	mov    0x8(%ebp),%eax
8010281d:	8b 00                	mov    (%eax),%eax
8010281f:	83 e0 06             	and    $0x6,%eax
80102822:	83 f8 02             	cmp    $0x2,%eax
80102825:	75 0c                	jne    80102833 <iderw+0x37>
    panic("iderw: nothing to do");
80102827:	c7 04 24 41 8b 10 80 	movl   $0x80108b41,(%esp)
8010282e:	e8 0a dd ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
80102833:	8b 45 08             	mov    0x8(%ebp),%eax
80102836:	8b 40 04             	mov    0x4(%eax),%eax
80102839:	85 c0                	test   %eax,%eax
8010283b:	74 15                	je     80102852 <iderw+0x56>
8010283d:	a1 38 c6 10 80       	mov    0x8010c638,%eax
80102842:	85 c0                	test   %eax,%eax
80102844:	75 0c                	jne    80102852 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80102846:	c7 04 24 56 8b 10 80 	movl   $0x80108b56,(%esp)
8010284d:	e8 eb dc ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102852:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102859:	e8 79 2a 00 00       	call   801052d7 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
8010285e:	8b 45 08             	mov    0x8(%ebp),%eax
80102861:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102868:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
8010286f:	eb 0b                	jmp    8010287c <iderw+0x80>
80102871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102874:	8b 00                	mov    (%eax),%eax
80102876:	83 c0 14             	add    $0x14,%eax
80102879:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010287c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010287f:	8b 00                	mov    (%eax),%eax
80102881:	85 c0                	test   %eax,%eax
80102883:	75 ec                	jne    80102871 <iderw+0x75>
    ;
  *pp = b;
80102885:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102888:	8b 55 08             	mov    0x8(%ebp),%edx
8010288b:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
8010288d:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102892:	3b 45 08             	cmp    0x8(%ebp),%eax
80102895:	75 22                	jne    801028b9 <iderw+0xbd>
    idestart(b);
80102897:	8b 45 08             	mov    0x8(%ebp),%eax
8010289a:	89 04 24             	mov    %eax,(%esp)
8010289d:	e8 72 fd ff ff       	call   80102614 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801028a2:	eb 15                	jmp    801028b9 <iderw+0xbd>
    sleep(b, &idelock);
801028a4:	c7 44 24 04 00 c6 10 	movl   $0x8010c600,0x4(%esp)
801028ab:	80 
801028ac:	8b 45 08             	mov    0x8(%ebp),%eax
801028af:	89 04 24             	mov    %eax,(%esp)
801028b2:	e8 3a 27 00 00       	call   80104ff1 <sleep>
801028b7:	eb 01                	jmp    801028ba <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801028b9:	90                   	nop
801028ba:	8b 45 08             	mov    0x8(%ebp),%eax
801028bd:	8b 00                	mov    (%eax),%eax
801028bf:	83 e0 06             	and    $0x6,%eax
801028c2:	83 f8 02             	cmp    $0x2,%eax
801028c5:	75 dd                	jne    801028a4 <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
801028c7:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
801028ce:	e8 66 2a 00 00       	call   80105339 <release>
}
801028d3:	c9                   	leave  
801028d4:	c3                   	ret    
801028d5:	00 00                	add    %al,(%eax)
	...

801028d8 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801028d8:	55                   	push   %ebp
801028d9:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801028db:	a1 14 32 11 80       	mov    0x80113214,%eax
801028e0:	8b 55 08             	mov    0x8(%ebp),%edx
801028e3:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801028e5:	a1 14 32 11 80       	mov    0x80113214,%eax
801028ea:	8b 40 10             	mov    0x10(%eax),%eax
}
801028ed:	5d                   	pop    %ebp
801028ee:	c3                   	ret    

801028ef <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
801028ef:	55                   	push   %ebp
801028f0:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801028f2:	a1 14 32 11 80       	mov    0x80113214,%eax
801028f7:	8b 55 08             	mov    0x8(%ebp),%edx
801028fa:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801028fc:	a1 14 32 11 80       	mov    0x80113214,%eax
80102901:	8b 55 0c             	mov    0xc(%ebp),%edx
80102904:	89 50 10             	mov    %edx,0x10(%eax)
}
80102907:	5d                   	pop    %ebp
80102908:	c3                   	ret    

80102909 <ioapicinit>:

void
ioapicinit(void)
{
80102909:	55                   	push   %ebp
8010290a:	89 e5                	mov    %esp,%ebp
8010290c:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
8010290f:	a1 44 33 11 80       	mov    0x80113344,%eax
80102914:	85 c0                	test   %eax,%eax
80102916:	0f 84 9f 00 00 00    	je     801029bb <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010291c:	c7 05 14 32 11 80 00 	movl   $0xfec00000,0x80113214
80102923:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102926:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010292d:	e8 a6 ff ff ff       	call   801028d8 <ioapicread>
80102932:	c1 e8 10             	shr    $0x10,%eax
80102935:	25 ff 00 00 00       	and    $0xff,%eax
8010293a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
8010293d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102944:	e8 8f ff ff ff       	call   801028d8 <ioapicread>
80102949:	c1 e8 18             	shr    $0x18,%eax
8010294c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
8010294f:	0f b6 05 40 33 11 80 	movzbl 0x80113340,%eax
80102956:	0f b6 c0             	movzbl %al,%eax
80102959:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010295c:	74 0c                	je     8010296a <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
8010295e:	c7 04 24 74 8b 10 80 	movl   $0x80108b74,(%esp)
80102965:	e8 37 da ff ff       	call   801003a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010296a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102971:	eb 3e                	jmp    801029b1 <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102973:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102976:	83 c0 20             	add    $0x20,%eax
80102979:	0d 00 00 01 00       	or     $0x10000,%eax
8010297e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102981:	83 c2 08             	add    $0x8,%edx
80102984:	01 d2                	add    %edx,%edx
80102986:	89 44 24 04          	mov    %eax,0x4(%esp)
8010298a:	89 14 24             	mov    %edx,(%esp)
8010298d:	e8 5d ff ff ff       	call   801028ef <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102995:	83 c0 08             	add    $0x8,%eax
80102998:	01 c0                	add    %eax,%eax
8010299a:	83 c0 01             	add    $0x1,%eax
8010299d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801029a4:	00 
801029a5:	89 04 24             	mov    %eax,(%esp)
801029a8:	e8 42 ff ff ff       	call   801028ef <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801029ad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801029b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801029b7:	7e ba                	jle    80102973 <ioapicinit+0x6a>
801029b9:	eb 01                	jmp    801029bc <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
801029bb:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
801029bc:	c9                   	leave  
801029bd:	c3                   	ret    

801029be <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801029be:	55                   	push   %ebp
801029bf:	89 e5                	mov    %esp,%ebp
801029c1:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
801029c4:	a1 44 33 11 80       	mov    0x80113344,%eax
801029c9:	85 c0                	test   %eax,%eax
801029cb:	74 39                	je     80102a06 <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801029cd:	8b 45 08             	mov    0x8(%ebp),%eax
801029d0:	83 c0 20             	add    $0x20,%eax
801029d3:	8b 55 08             	mov    0x8(%ebp),%edx
801029d6:	83 c2 08             	add    $0x8,%edx
801029d9:	01 d2                	add    %edx,%edx
801029db:	89 44 24 04          	mov    %eax,0x4(%esp)
801029df:	89 14 24             	mov    %edx,(%esp)
801029e2:	e8 08 ff ff ff       	call   801028ef <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801029e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801029ea:	c1 e0 18             	shl    $0x18,%eax
801029ed:	8b 55 08             	mov    0x8(%ebp),%edx
801029f0:	83 c2 08             	add    $0x8,%edx
801029f3:	01 d2                	add    %edx,%edx
801029f5:	83 c2 01             	add    $0x1,%edx
801029f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801029fc:	89 14 24             	mov    %edx,(%esp)
801029ff:	e8 eb fe ff ff       	call   801028ef <ioapicwrite>
80102a04:	eb 01                	jmp    80102a07 <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102a06:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102a07:	c9                   	leave  
80102a08:	c3                   	ret    
80102a09:	00 00                	add    %al,(%eax)
	...

80102a0c <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102a0c:	55                   	push   %ebp
80102a0d:	89 e5                	mov    %esp,%ebp
80102a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80102a12:	05 00 00 00 80       	add    $0x80000000,%eax
80102a17:	5d                   	pop    %ebp
80102a18:	c3                   	ret    

80102a19 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102a19:	55                   	push   %ebp
80102a1a:	89 e5                	mov    %esp,%ebp
80102a1c:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102a1f:	c7 44 24 04 a6 8b 10 	movl   $0x80108ba6,0x4(%esp)
80102a26:	80 
80102a27:	c7 04 24 20 32 11 80 	movl   $0x80113220,(%esp)
80102a2e:	e8 83 28 00 00       	call   801052b6 <initlock>
  kmem.use_lock = 0;
80102a33:	c7 05 54 32 11 80 00 	movl   $0x0,0x80113254
80102a3a:	00 00 00 
  freerange(vstart, vend);
80102a3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a40:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a44:	8b 45 08             	mov    0x8(%ebp),%eax
80102a47:	89 04 24             	mov    %eax,(%esp)
80102a4a:	e8 26 00 00 00       	call   80102a75 <freerange>
}
80102a4f:	c9                   	leave  
80102a50:	c3                   	ret    

80102a51 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102a51:	55                   	push   %ebp
80102a52:	89 e5                	mov    %esp,%ebp
80102a54:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102a57:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a5a:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a5e:	8b 45 08             	mov    0x8(%ebp),%eax
80102a61:	89 04 24             	mov    %eax,(%esp)
80102a64:	e8 0c 00 00 00       	call   80102a75 <freerange>
  kmem.use_lock = 1;
80102a69:	c7 05 54 32 11 80 01 	movl   $0x1,0x80113254
80102a70:	00 00 00 
}
80102a73:	c9                   	leave  
80102a74:	c3                   	ret    

80102a75 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102a75:	55                   	push   %ebp
80102a76:	89 e5                	mov    %esp,%ebp
80102a78:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102a7b:	8b 45 08             	mov    0x8(%ebp),%eax
80102a7e:	05 ff 0f 00 00       	add    $0xfff,%eax
80102a83:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102a88:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a8b:	eb 12                	jmp    80102a9f <freerange+0x2a>
    kfree(p);
80102a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a90:	89 04 24             	mov    %eax,(%esp)
80102a93:	e8 16 00 00 00       	call   80102aae <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a98:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa2:	05 00 10 00 00       	add    $0x1000,%eax
80102aa7:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102aaa:	76 e1                	jbe    80102a8d <freerange+0x18>
    kfree(p);
}
80102aac:	c9                   	leave  
80102aad:	c3                   	ret    

80102aae <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102aae:	55                   	push   %ebp
80102aaf:	89 e5                	mov    %esp,%ebp
80102ab1:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab7:	25 ff 0f 00 00       	and    $0xfff,%eax
80102abc:	85 c0                	test   %eax,%eax
80102abe:	75 1b                	jne    80102adb <kfree+0x2d>
80102ac0:	81 7d 08 7c 66 11 80 	cmpl   $0x8011667c,0x8(%ebp)
80102ac7:	72 12                	jb     80102adb <kfree+0x2d>
80102ac9:	8b 45 08             	mov    0x8(%ebp),%eax
80102acc:	89 04 24             	mov    %eax,(%esp)
80102acf:	e8 38 ff ff ff       	call   80102a0c <v2p>
80102ad4:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102ad9:	76 0c                	jbe    80102ae7 <kfree+0x39>
    panic("kfree");
80102adb:	c7 04 24 ab 8b 10 80 	movl   $0x80108bab,(%esp)
80102ae2:	e8 56 da ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102ae7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102aee:	00 
80102aef:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102af6:	00 
80102af7:	8b 45 08             	mov    0x8(%ebp),%eax
80102afa:	89 04 24             	mov    %eax,(%esp)
80102afd:	e8 24 2a 00 00       	call   80105526 <memset>

  if(kmem.use_lock)
80102b02:	a1 54 32 11 80       	mov    0x80113254,%eax
80102b07:	85 c0                	test   %eax,%eax
80102b09:	74 0c                	je     80102b17 <kfree+0x69>
    acquire(&kmem.lock);
80102b0b:	c7 04 24 20 32 11 80 	movl   $0x80113220,(%esp)
80102b12:	e8 c0 27 00 00       	call   801052d7 <acquire>
  r = (struct run*)v;
80102b17:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102b1d:	8b 15 58 32 11 80    	mov    0x80113258,%edx
80102b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b26:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b2b:	a3 58 32 11 80       	mov    %eax,0x80113258
  if(kmem.use_lock)
80102b30:	a1 54 32 11 80       	mov    0x80113254,%eax
80102b35:	85 c0                	test   %eax,%eax
80102b37:	74 0c                	je     80102b45 <kfree+0x97>
    release(&kmem.lock);
80102b39:	c7 04 24 20 32 11 80 	movl   $0x80113220,(%esp)
80102b40:	e8 f4 27 00 00       	call   80105339 <release>
}
80102b45:	c9                   	leave  
80102b46:	c3                   	ret    

80102b47 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102b47:	55                   	push   %ebp
80102b48:	89 e5                	mov    %esp,%ebp
80102b4a:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102b4d:	a1 54 32 11 80       	mov    0x80113254,%eax
80102b52:	85 c0                	test   %eax,%eax
80102b54:	74 0c                	je     80102b62 <kalloc+0x1b>
    acquire(&kmem.lock);
80102b56:	c7 04 24 20 32 11 80 	movl   $0x80113220,(%esp)
80102b5d:	e8 75 27 00 00       	call   801052d7 <acquire>
  r = kmem.freelist;
80102b62:	a1 58 32 11 80       	mov    0x80113258,%eax
80102b67:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b6a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b6e:	74 0a                	je     80102b7a <kalloc+0x33>
    kmem.freelist = r->next;
80102b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b73:	8b 00                	mov    (%eax),%eax
80102b75:	a3 58 32 11 80       	mov    %eax,0x80113258
  if(kmem.use_lock)
80102b7a:	a1 54 32 11 80       	mov    0x80113254,%eax
80102b7f:	85 c0                	test   %eax,%eax
80102b81:	74 0c                	je     80102b8f <kalloc+0x48>
    release(&kmem.lock);
80102b83:	c7 04 24 20 32 11 80 	movl   $0x80113220,(%esp)
80102b8a:	e8 aa 27 00 00       	call   80105339 <release>
  return (char*)r;
80102b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102b92:	c9                   	leave  
80102b93:	c3                   	ret    

80102b94 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102b94:	55                   	push   %ebp
80102b95:	89 e5                	mov    %esp,%ebp
80102b97:	53                   	push   %ebx
80102b98:	83 ec 14             	sub    $0x14,%esp
80102b9b:	8b 45 08             	mov    0x8(%ebp),%eax
80102b9e:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ba2:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102ba6:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102baa:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102bae:	ec                   	in     (%dx),%al
80102baf:	89 c3                	mov    %eax,%ebx
80102bb1:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102bb4:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102bb8:	83 c4 14             	add    $0x14,%esp
80102bbb:	5b                   	pop    %ebx
80102bbc:	5d                   	pop    %ebp
80102bbd:	c3                   	ret    

80102bbe <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102bbe:	55                   	push   %ebp
80102bbf:	89 e5                	mov    %esp,%ebp
80102bc1:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102bc4:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102bcb:	e8 c4 ff ff ff       	call   80102b94 <inb>
80102bd0:	0f b6 c0             	movzbl %al,%eax
80102bd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bd9:	83 e0 01             	and    $0x1,%eax
80102bdc:	85 c0                	test   %eax,%eax
80102bde:	75 0a                	jne    80102bea <kbdgetc+0x2c>
    return -1;
80102be0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102be5:	e9 23 01 00 00       	jmp    80102d0d <kbdgetc+0x14f>
  data = inb(KBDATAP);
80102bea:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102bf1:	e8 9e ff ff ff       	call   80102b94 <inb>
80102bf6:	0f b6 c0             	movzbl %al,%eax
80102bf9:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102bfc:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102c03:	75 17                	jne    80102c1c <kbdgetc+0x5e>
    shift |= E0ESC;
80102c05:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c0a:	83 c8 40             	or     $0x40,%eax
80102c0d:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102c12:	b8 00 00 00 00       	mov    $0x0,%eax
80102c17:	e9 f1 00 00 00       	jmp    80102d0d <kbdgetc+0x14f>
  } else if(data & 0x80){
80102c1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c1f:	25 80 00 00 00       	and    $0x80,%eax
80102c24:	85 c0                	test   %eax,%eax
80102c26:	74 45                	je     80102c6d <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102c28:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c2d:	83 e0 40             	and    $0x40,%eax
80102c30:	85 c0                	test   %eax,%eax
80102c32:	75 08                	jne    80102c3c <kbdgetc+0x7e>
80102c34:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c37:	83 e0 7f             	and    $0x7f,%eax
80102c3a:	eb 03                	jmp    80102c3f <kbdgetc+0x81>
80102c3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c3f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102c42:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c45:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102c4a:	0f b6 00             	movzbl (%eax),%eax
80102c4d:	83 c8 40             	or     $0x40,%eax
80102c50:	0f b6 c0             	movzbl %al,%eax
80102c53:	f7 d0                	not    %eax
80102c55:	89 c2                	mov    %eax,%edx
80102c57:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c5c:	21 d0                	and    %edx,%eax
80102c5e:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102c63:	b8 00 00 00 00       	mov    $0x0,%eax
80102c68:	e9 a0 00 00 00       	jmp    80102d0d <kbdgetc+0x14f>
  } else if(shift & E0ESC){
80102c6d:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c72:	83 e0 40             	and    $0x40,%eax
80102c75:	85 c0                	test   %eax,%eax
80102c77:	74 14                	je     80102c8d <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102c79:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102c80:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c85:	83 e0 bf             	and    $0xffffffbf,%eax
80102c88:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
80102c8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c90:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102c95:	0f b6 00             	movzbl (%eax),%eax
80102c98:	0f b6 d0             	movzbl %al,%edx
80102c9b:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102ca0:	09 d0                	or     %edx,%eax
80102ca2:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
80102ca7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102caa:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102caf:	0f b6 00             	movzbl (%eax),%eax
80102cb2:	0f b6 d0             	movzbl %al,%edx
80102cb5:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102cba:	31 d0                	xor    %edx,%eax
80102cbc:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102cc1:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102cc6:	83 e0 03             	and    $0x3,%eax
80102cc9:	8b 04 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%eax
80102cd0:	03 45 fc             	add    -0x4(%ebp),%eax
80102cd3:	0f b6 00             	movzbl (%eax),%eax
80102cd6:	0f b6 c0             	movzbl %al,%eax
80102cd9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102cdc:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102ce1:	83 e0 08             	and    $0x8,%eax
80102ce4:	85 c0                	test   %eax,%eax
80102ce6:	74 22                	je     80102d0a <kbdgetc+0x14c>
    if('a' <= c && c <= 'z')
80102ce8:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102cec:	76 0c                	jbe    80102cfa <kbdgetc+0x13c>
80102cee:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102cf2:	77 06                	ja     80102cfa <kbdgetc+0x13c>
      c += 'A' - 'a';
80102cf4:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102cf8:	eb 10                	jmp    80102d0a <kbdgetc+0x14c>
    else if('A' <= c && c <= 'Z')
80102cfa:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102cfe:	76 0a                	jbe    80102d0a <kbdgetc+0x14c>
80102d00:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102d04:	77 04                	ja     80102d0a <kbdgetc+0x14c>
      c += 'a' - 'A';
80102d06:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102d0a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d0d:	c9                   	leave  
80102d0e:	c3                   	ret    

80102d0f <kbdintr>:

void
kbdintr(void)
{
80102d0f:	55                   	push   %ebp
80102d10:	89 e5                	mov    %esp,%ebp
80102d12:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102d15:	c7 04 24 be 2b 10 80 	movl   $0x80102bbe,(%esp)
80102d1c:	e8 8c da ff ff       	call   801007ad <consoleintr>
}
80102d21:	c9                   	leave  
80102d22:	c3                   	ret    
	...

80102d24 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d24:	55                   	push   %ebp
80102d25:	89 e5                	mov    %esp,%ebp
80102d27:	53                   	push   %ebx
80102d28:	83 ec 14             	sub    $0x14,%esp
80102d2b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d2e:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d32:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102d36:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102d3a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102d3e:	ec                   	in     (%dx),%al
80102d3f:	89 c3                	mov    %eax,%ebx
80102d41:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102d44:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102d48:	83 c4 14             	add    $0x14,%esp
80102d4b:	5b                   	pop    %ebx
80102d4c:	5d                   	pop    %ebp
80102d4d:	c3                   	ret    

80102d4e <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102d4e:	55                   	push   %ebp
80102d4f:	89 e5                	mov    %esp,%ebp
80102d51:	83 ec 08             	sub    $0x8,%esp
80102d54:	8b 55 08             	mov    0x8(%ebp),%edx
80102d57:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d5a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102d5e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d61:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102d65:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102d69:	ee                   	out    %al,(%dx)
}
80102d6a:	c9                   	leave  
80102d6b:	c3                   	ret    

80102d6c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102d6c:	55                   	push   %ebp
80102d6d:	89 e5                	mov    %esp,%ebp
80102d6f:	53                   	push   %ebx
80102d70:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102d73:	9c                   	pushf  
80102d74:	5b                   	pop    %ebx
80102d75:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80102d78:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d7b:	83 c4 10             	add    $0x10,%esp
80102d7e:	5b                   	pop    %ebx
80102d7f:	5d                   	pop    %ebp
80102d80:	c3                   	ret    

80102d81 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102d81:	55                   	push   %ebp
80102d82:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102d84:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102d89:	8b 55 08             	mov    0x8(%ebp),%edx
80102d8c:	c1 e2 02             	shl    $0x2,%edx
80102d8f:	01 c2                	add    %eax,%edx
80102d91:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d94:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102d96:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102d9b:	83 c0 20             	add    $0x20,%eax
80102d9e:	8b 00                	mov    (%eax),%eax
}
80102da0:	5d                   	pop    %ebp
80102da1:	c3                   	ret    

80102da2 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102da2:	55                   	push   %ebp
80102da3:	89 e5                	mov    %esp,%ebp
80102da5:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102da8:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102dad:	85 c0                	test   %eax,%eax
80102daf:	0f 84 47 01 00 00    	je     80102efc <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102db5:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102dbc:	00 
80102dbd:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102dc4:	e8 b8 ff ff ff       	call   80102d81 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102dc9:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102dd0:	00 
80102dd1:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102dd8:	e8 a4 ff ff ff       	call   80102d81 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102ddd:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102de4:	00 
80102de5:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102dec:	e8 90 ff ff ff       	call   80102d81 <lapicw>
  lapicw(TICR, 10000000); 
80102df1:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102df8:	00 
80102df9:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102e00:	e8 7c ff ff ff       	call   80102d81 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102e05:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e0c:	00 
80102e0d:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102e14:	e8 68 ff ff ff       	call   80102d81 <lapicw>
  lapicw(LINT1, MASKED);
80102e19:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e20:	00 
80102e21:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102e28:	e8 54 ff ff ff       	call   80102d81 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102e2d:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102e32:	83 c0 30             	add    $0x30,%eax
80102e35:	8b 00                	mov    (%eax),%eax
80102e37:	c1 e8 10             	shr    $0x10,%eax
80102e3a:	25 ff 00 00 00       	and    $0xff,%eax
80102e3f:	83 f8 03             	cmp    $0x3,%eax
80102e42:	76 14                	jbe    80102e58 <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
80102e44:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e4b:	00 
80102e4c:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102e53:	e8 29 ff ff ff       	call   80102d81 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102e58:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102e5f:	00 
80102e60:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102e67:	e8 15 ff ff ff       	call   80102d81 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102e6c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e73:	00 
80102e74:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e7b:	e8 01 ff ff ff       	call   80102d81 <lapicw>
  lapicw(ESR, 0);
80102e80:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e87:	00 
80102e88:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e8f:	e8 ed fe ff ff       	call   80102d81 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102e94:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e9b:	00 
80102e9c:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102ea3:	e8 d9 fe ff ff       	call   80102d81 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ea8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102eaf:	00 
80102eb0:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102eb7:	e8 c5 fe ff ff       	call   80102d81 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ebc:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102ec3:	00 
80102ec4:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102ecb:	e8 b1 fe ff ff       	call   80102d81 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102ed0:	90                   	nop
80102ed1:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102ed6:	05 00 03 00 00       	add    $0x300,%eax
80102edb:	8b 00                	mov    (%eax),%eax
80102edd:	25 00 10 00 00       	and    $0x1000,%eax
80102ee2:	85 c0                	test   %eax,%eax
80102ee4:	75 eb                	jne    80102ed1 <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102ee6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102eed:	00 
80102eee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102ef5:	e8 87 fe ff ff       	call   80102d81 <lapicw>
80102efa:	eb 01                	jmp    80102efd <lapicinit+0x15b>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80102efc:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102efd:	c9                   	leave  
80102efe:	c3                   	ret    

80102eff <cpunum>:

int
cpunum(void)
{
80102eff:	55                   	push   %ebp
80102f00:	89 e5                	mov    %esp,%ebp
80102f02:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102f05:	e8 62 fe ff ff       	call   80102d6c <readeflags>
80102f0a:	25 00 02 00 00       	and    $0x200,%eax
80102f0f:	85 c0                	test   %eax,%eax
80102f11:	74 29                	je     80102f3c <cpunum+0x3d>
    static int n;
    if(n++ == 0)
80102f13:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80102f18:	85 c0                	test   %eax,%eax
80102f1a:	0f 94 c2             	sete   %dl
80102f1d:	83 c0 01             	add    $0x1,%eax
80102f20:	a3 40 c6 10 80       	mov    %eax,0x8010c640
80102f25:	84 d2                	test   %dl,%dl
80102f27:	74 13                	je     80102f3c <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
80102f29:	8b 45 04             	mov    0x4(%ebp),%eax
80102f2c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f30:	c7 04 24 b4 8b 10 80 	movl   $0x80108bb4,(%esp)
80102f37:	e8 65 d4 ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102f3c:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102f41:	85 c0                	test   %eax,%eax
80102f43:	74 0f                	je     80102f54 <cpunum+0x55>
    return lapic[ID]>>24;
80102f45:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102f4a:	83 c0 20             	add    $0x20,%eax
80102f4d:	8b 00                	mov    (%eax),%eax
80102f4f:	c1 e8 18             	shr    $0x18,%eax
80102f52:	eb 05                	jmp    80102f59 <cpunum+0x5a>
  return 0;
80102f54:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102f59:	c9                   	leave  
80102f5a:	c3                   	ret    

80102f5b <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f5b:	55                   	push   %ebp
80102f5c:	89 e5                	mov    %esp,%ebp
80102f5e:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102f61:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102f66:	85 c0                	test   %eax,%eax
80102f68:	74 14                	je     80102f7e <lapiceoi+0x23>
    lapicw(EOI, 0);
80102f6a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f71:	00 
80102f72:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102f79:	e8 03 fe ff ff       	call   80102d81 <lapicw>
}
80102f7e:	c9                   	leave  
80102f7f:	c3                   	ret    

80102f80 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102f80:	55                   	push   %ebp
80102f81:	89 e5                	mov    %esp,%ebp
}
80102f83:	5d                   	pop    %ebp
80102f84:	c3                   	ret    

80102f85 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102f85:	55                   	push   %ebp
80102f86:	89 e5                	mov    %esp,%ebp
80102f88:	83 ec 1c             	sub    $0x1c,%esp
80102f8b:	8b 45 08             	mov    0x8(%ebp),%eax
80102f8e:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102f91:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102f98:	00 
80102f99:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102fa0:	e8 a9 fd ff ff       	call   80102d4e <outb>
  outb(CMOS_PORT+1, 0x0A);
80102fa5:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102fac:	00 
80102fad:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102fb4:	e8 95 fd ff ff       	call   80102d4e <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102fb9:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102fc0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102fc3:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102fc8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102fcb:	8d 50 02             	lea    0x2(%eax),%edx
80102fce:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fd1:	c1 e8 04             	shr    $0x4,%eax
80102fd4:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102fd7:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102fdb:	c1 e0 18             	shl    $0x18,%eax
80102fde:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fe2:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102fe9:	e8 93 fd ff ff       	call   80102d81 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102fee:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80102ff5:	00 
80102ff6:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102ffd:	e8 7f fd ff ff       	call   80102d81 <lapicw>
  microdelay(200);
80103002:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103009:	e8 72 ff ff ff       	call   80102f80 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
8010300e:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80103015:	00 
80103016:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010301d:	e8 5f fd ff ff       	call   80102d81 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103022:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103029:	e8 52 ff ff ff       	call   80102f80 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010302e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103035:	eb 40                	jmp    80103077 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80103037:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010303b:	c1 e0 18             	shl    $0x18,%eax
8010303e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103042:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103049:	e8 33 fd ff ff       	call   80102d81 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
8010304e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103051:	c1 e8 0c             	shr    $0xc,%eax
80103054:	80 cc 06             	or     $0x6,%ah
80103057:	89 44 24 04          	mov    %eax,0x4(%esp)
8010305b:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103062:	e8 1a fd ff ff       	call   80102d81 <lapicw>
    microdelay(200);
80103067:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010306e:	e8 0d ff ff ff       	call   80102f80 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103073:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103077:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010307b:	7e ba                	jle    80103037 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010307d:	c9                   	leave  
8010307e:	c3                   	ret    

8010307f <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010307f:	55                   	push   %ebp
80103080:	89 e5                	mov    %esp,%ebp
80103082:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80103085:	8b 45 08             	mov    0x8(%ebp),%eax
80103088:	0f b6 c0             	movzbl %al,%eax
8010308b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010308f:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103096:	e8 b3 fc ff ff       	call   80102d4e <outb>
  microdelay(200);
8010309b:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030a2:	e8 d9 fe ff ff       	call   80102f80 <microdelay>

  return inb(CMOS_RETURN);
801030a7:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801030ae:	e8 71 fc ff ff       	call   80102d24 <inb>
801030b3:	0f b6 c0             	movzbl %al,%eax
}
801030b6:	c9                   	leave  
801030b7:	c3                   	ret    

801030b8 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801030b8:	55                   	push   %ebp
801030b9:	89 e5                	mov    %esp,%ebp
801030bb:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
801030be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801030c5:	e8 b5 ff ff ff       	call   8010307f <cmos_read>
801030ca:	8b 55 08             	mov    0x8(%ebp),%edx
801030cd:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
801030cf:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801030d6:	e8 a4 ff ff ff       	call   8010307f <cmos_read>
801030db:	8b 55 08             	mov    0x8(%ebp),%edx
801030de:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
801030e1:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801030e8:	e8 92 ff ff ff       	call   8010307f <cmos_read>
801030ed:	8b 55 08             	mov    0x8(%ebp),%edx
801030f0:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801030f3:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
801030fa:	e8 80 ff ff ff       	call   8010307f <cmos_read>
801030ff:	8b 55 08             	mov    0x8(%ebp),%edx
80103102:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103105:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010310c:	e8 6e ff ff ff       	call   8010307f <cmos_read>
80103111:	8b 55 08             	mov    0x8(%ebp),%edx
80103114:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103117:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
8010311e:	e8 5c ff ff ff       	call   8010307f <cmos_read>
80103123:	8b 55 08             	mov    0x8(%ebp),%edx
80103126:	89 42 14             	mov    %eax,0x14(%edx)
}
80103129:	c9                   	leave  
8010312a:	c3                   	ret    

8010312b <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010312b:	55                   	push   %ebp
8010312c:	89 e5                	mov    %esp,%ebp
8010312e:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103131:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
80103138:	e8 42 ff ff ff       	call   8010307f <cmos_read>
8010313d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103140:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103143:	83 e0 04             	and    $0x4,%eax
80103146:	85 c0                	test   %eax,%eax
80103148:	0f 94 c0             	sete   %al
8010314b:	0f b6 c0             	movzbl %al,%eax
8010314e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103151:	eb 01                	jmp    80103154 <cmostime+0x29>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103153:	90                   	nop

  bcd = (sb & (1 << 2)) == 0;

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103154:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103157:	89 04 24             	mov    %eax,(%esp)
8010315a:	e8 59 ff ff ff       	call   801030b8 <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
8010315f:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80103166:	e8 14 ff ff ff       	call   8010307f <cmos_read>
8010316b:	25 80 00 00 00       	and    $0x80,%eax
80103170:	85 c0                	test   %eax,%eax
80103172:	75 2b                	jne    8010319f <cmostime+0x74>
        continue;
    fill_rtcdate(&t2);
80103174:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103177:	89 04 24             	mov    %eax,(%esp)
8010317a:	e8 39 ff ff ff       	call   801030b8 <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
8010317f:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80103186:	00 
80103187:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010318a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010318e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103191:	89 04 24             	mov    %eax,(%esp)
80103194:	e8 04 24 00 00       	call   8010559d <memcmp>
80103199:	85 c0                	test   %eax,%eax
8010319b:	75 b6                	jne    80103153 <cmostime+0x28>
      break;
8010319d:	eb 03                	jmp    801031a2 <cmostime+0x77>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
8010319f:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801031a0:	eb b1                	jmp    80103153 <cmostime+0x28>

  // convert
  if (bcd) {
801031a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801031a6:	0f 84 a8 00 00 00    	je     80103254 <cmostime+0x129>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801031ac:	8b 45 d8             	mov    -0x28(%ebp),%eax
801031af:	89 c2                	mov    %eax,%edx
801031b1:	c1 ea 04             	shr    $0x4,%edx
801031b4:	89 d0                	mov    %edx,%eax
801031b6:	c1 e0 02             	shl    $0x2,%eax
801031b9:	01 d0                	add    %edx,%eax
801031bb:	01 c0                	add    %eax,%eax
801031bd:	8b 55 d8             	mov    -0x28(%ebp),%edx
801031c0:	83 e2 0f             	and    $0xf,%edx
801031c3:	01 d0                	add    %edx,%eax
801031c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801031c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801031cb:	89 c2                	mov    %eax,%edx
801031cd:	c1 ea 04             	shr    $0x4,%edx
801031d0:	89 d0                	mov    %edx,%eax
801031d2:	c1 e0 02             	shl    $0x2,%eax
801031d5:	01 d0                	add    %edx,%eax
801031d7:	01 c0                	add    %eax,%eax
801031d9:	8b 55 dc             	mov    -0x24(%ebp),%edx
801031dc:	83 e2 0f             	and    $0xf,%edx
801031df:	01 d0                	add    %edx,%eax
801031e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801031e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801031e7:	89 c2                	mov    %eax,%edx
801031e9:	c1 ea 04             	shr    $0x4,%edx
801031ec:	89 d0                	mov    %edx,%eax
801031ee:	c1 e0 02             	shl    $0x2,%eax
801031f1:	01 d0                	add    %edx,%eax
801031f3:	01 c0                	add    %eax,%eax
801031f5:	8b 55 e0             	mov    -0x20(%ebp),%edx
801031f8:	83 e2 0f             	and    $0xf,%edx
801031fb:	01 d0                	add    %edx,%eax
801031fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103200:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103203:	89 c2                	mov    %eax,%edx
80103205:	c1 ea 04             	shr    $0x4,%edx
80103208:	89 d0                	mov    %edx,%eax
8010320a:	c1 e0 02             	shl    $0x2,%eax
8010320d:	01 d0                	add    %edx,%eax
8010320f:	01 c0                	add    %eax,%eax
80103211:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103214:	83 e2 0f             	and    $0xf,%edx
80103217:	01 d0                	add    %edx,%eax
80103219:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010321c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010321f:	89 c2                	mov    %eax,%edx
80103221:	c1 ea 04             	shr    $0x4,%edx
80103224:	89 d0                	mov    %edx,%eax
80103226:	c1 e0 02             	shl    $0x2,%eax
80103229:	01 d0                	add    %edx,%eax
8010322b:	01 c0                	add    %eax,%eax
8010322d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103230:	83 e2 0f             	and    $0xf,%edx
80103233:	01 d0                	add    %edx,%eax
80103235:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103238:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010323b:	89 c2                	mov    %eax,%edx
8010323d:	c1 ea 04             	shr    $0x4,%edx
80103240:	89 d0                	mov    %edx,%eax
80103242:	c1 e0 02             	shl    $0x2,%eax
80103245:	01 d0                	add    %edx,%eax
80103247:	01 c0                	add    %eax,%eax
80103249:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010324c:	83 e2 0f             	and    $0xf,%edx
8010324f:	01 d0                	add    %edx,%eax
80103251:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103254:	8b 45 08             	mov    0x8(%ebp),%eax
80103257:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010325a:	89 10                	mov    %edx,(%eax)
8010325c:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010325f:	89 50 04             	mov    %edx,0x4(%eax)
80103262:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103265:	89 50 08             	mov    %edx,0x8(%eax)
80103268:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010326b:	89 50 0c             	mov    %edx,0xc(%eax)
8010326e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103271:	89 50 10             	mov    %edx,0x10(%eax)
80103274:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103277:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
8010327a:	8b 45 08             	mov    0x8(%ebp),%eax
8010327d:	8b 40 14             	mov    0x14(%eax),%eax
80103280:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103286:	8b 45 08             	mov    0x8(%ebp),%eax
80103289:	89 50 14             	mov    %edx,0x14(%eax)
}
8010328c:	c9                   	leave  
8010328d:	c3                   	ret    
	...

80103290 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(void)
{
80103290:	55                   	push   %ebp
80103291:	89 e5                	mov    %esp,%ebp
80103293:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103296:	c7 44 24 04 e0 8b 10 	movl   $0x80108be0,0x4(%esp)
8010329d:	80 
8010329e:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
801032a5:	e8 0c 20 00 00       	call   801052b6 <initlock>
  readsb(ROOTDEV, &sb);
801032aa:	8d 45 e8             	lea    -0x18(%ebp),%eax
801032ad:	89 44 24 04          	mov    %eax,0x4(%esp)
801032b1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801032b8:	e8 77 e0 ff ff       	call   80101334 <readsb>
  log.start = sb.size - sb.nlog;
801032bd:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032c3:	89 d1                	mov    %edx,%ecx
801032c5:	29 c1                	sub    %eax,%ecx
801032c7:	89 c8                	mov    %ecx,%eax
801032c9:	a3 94 32 11 80       	mov    %eax,0x80113294
  log.size = sb.nlog;
801032ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d1:	a3 98 32 11 80       	mov    %eax,0x80113298
  log.dev = ROOTDEV;
801032d6:	c7 05 a4 32 11 80 01 	movl   $0x1,0x801132a4
801032dd:	00 00 00 
  recover_from_log();
801032e0:	e8 97 01 00 00       	call   8010347c <recover_from_log>
}
801032e5:	c9                   	leave  
801032e6:	c3                   	ret    

801032e7 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801032e7:	55                   	push   %ebp
801032e8:	89 e5                	mov    %esp,%ebp
801032ea:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032f4:	e9 89 00 00 00       	jmp    80103382 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801032f9:	a1 94 32 11 80       	mov    0x80113294,%eax
801032fe:	03 45 f4             	add    -0xc(%ebp),%eax
80103301:	83 c0 01             	add    $0x1,%eax
80103304:	89 c2                	mov    %eax,%edx
80103306:	a1 a4 32 11 80       	mov    0x801132a4,%eax
8010330b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010330f:	89 04 24             	mov    %eax,(%esp)
80103312:	e8 8f ce ff ff       	call   801001a6 <bread>
80103317:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
8010331a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010331d:	83 c0 10             	add    $0x10,%eax
80103320:	8b 04 85 6c 32 11 80 	mov    -0x7feecd94(,%eax,4),%eax
80103327:	89 c2                	mov    %eax,%edx
80103329:	a1 a4 32 11 80       	mov    0x801132a4,%eax
8010332e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103332:	89 04 24             	mov    %eax,(%esp)
80103335:	e8 6c ce ff ff       	call   801001a6 <bread>
8010333a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010333d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103340:	8d 50 18             	lea    0x18(%eax),%edx
80103343:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103346:	83 c0 18             	add    $0x18,%eax
80103349:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103350:	00 
80103351:	89 54 24 04          	mov    %edx,0x4(%esp)
80103355:	89 04 24             	mov    %eax,(%esp)
80103358:	e8 9c 22 00 00       	call   801055f9 <memmove>
    bwrite(dbuf);  // write dst to disk
8010335d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103360:	89 04 24             	mov    %eax,(%esp)
80103363:	e8 75 ce ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
80103368:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010336b:	89 04 24             	mov    %eax,(%esp)
8010336e:	e8 a4 ce ff ff       	call   80100217 <brelse>
    brelse(dbuf);
80103373:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103376:	89 04 24             	mov    %eax,(%esp)
80103379:	e8 99 ce ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010337e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103382:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103387:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010338a:	0f 8f 69 ff ff ff    	jg     801032f9 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103390:	c9                   	leave  
80103391:	c3                   	ret    

80103392 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103392:	55                   	push   %ebp
80103393:	89 e5                	mov    %esp,%ebp
80103395:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103398:	a1 94 32 11 80       	mov    0x80113294,%eax
8010339d:	89 c2                	mov    %eax,%edx
8010339f:	a1 a4 32 11 80       	mov    0x801132a4,%eax
801033a4:	89 54 24 04          	mov    %edx,0x4(%esp)
801033a8:	89 04 24             	mov    %eax,(%esp)
801033ab:	e8 f6 cd ff ff       	call   801001a6 <bread>
801033b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801033b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033b6:	83 c0 18             	add    $0x18,%eax
801033b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801033bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033bf:	8b 00                	mov    (%eax),%eax
801033c1:	a3 a8 32 11 80       	mov    %eax,0x801132a8
  for (i = 0; i < log.lh.n; i++) {
801033c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033cd:	eb 1b                	jmp    801033ea <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
801033cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033d5:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801033d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033dc:	83 c2 10             	add    $0x10,%edx
801033df:	89 04 95 6c 32 11 80 	mov    %eax,-0x7feecd94(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801033e6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033ea:	a1 a8 32 11 80       	mov    0x801132a8,%eax
801033ef:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033f2:	7f db                	jg     801033cf <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
801033f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033f7:	89 04 24             	mov    %eax,(%esp)
801033fa:	e8 18 ce ff ff       	call   80100217 <brelse>
}
801033ff:	c9                   	leave  
80103400:	c3                   	ret    

80103401 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103401:	55                   	push   %ebp
80103402:	89 e5                	mov    %esp,%ebp
80103404:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103407:	a1 94 32 11 80       	mov    0x80113294,%eax
8010340c:	89 c2                	mov    %eax,%edx
8010340e:	a1 a4 32 11 80       	mov    0x801132a4,%eax
80103413:	89 54 24 04          	mov    %edx,0x4(%esp)
80103417:	89 04 24             	mov    %eax,(%esp)
8010341a:	e8 87 cd ff ff       	call   801001a6 <bread>
8010341f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103422:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103425:	83 c0 18             	add    $0x18,%eax
80103428:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010342b:	8b 15 a8 32 11 80    	mov    0x801132a8,%edx
80103431:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103434:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103436:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010343d:	eb 1b                	jmp    8010345a <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
8010343f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103442:	83 c0 10             	add    $0x10,%eax
80103445:	8b 0c 85 6c 32 11 80 	mov    -0x7feecd94(,%eax,4),%ecx
8010344c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010344f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103452:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103456:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010345a:	a1 a8 32 11 80       	mov    0x801132a8,%eax
8010345f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103462:	7f db                	jg     8010343f <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
80103464:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103467:	89 04 24             	mov    %eax,(%esp)
8010346a:	e8 6e cd ff ff       	call   801001dd <bwrite>
  brelse(buf);
8010346f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103472:	89 04 24             	mov    %eax,(%esp)
80103475:	e8 9d cd ff ff       	call   80100217 <brelse>
}
8010347a:	c9                   	leave  
8010347b:	c3                   	ret    

8010347c <recover_from_log>:

static void
recover_from_log(void)
{
8010347c:	55                   	push   %ebp
8010347d:	89 e5                	mov    %esp,%ebp
8010347f:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103482:	e8 0b ff ff ff       	call   80103392 <read_head>
  install_trans(); // if committed, copy from log to disk
80103487:	e8 5b fe ff ff       	call   801032e7 <install_trans>
  log.lh.n = 0;
8010348c:	c7 05 a8 32 11 80 00 	movl   $0x0,0x801132a8
80103493:	00 00 00 
  write_head(); // clear the log
80103496:	e8 66 ff ff ff       	call   80103401 <write_head>
}
8010349b:	c9                   	leave  
8010349c:	c3                   	ret    

8010349d <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010349d:	55                   	push   %ebp
8010349e:	89 e5                	mov    %esp,%ebp
801034a0:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801034a3:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
801034aa:	e8 28 1e 00 00       	call   801052d7 <acquire>
  while(1){
    if(log.committing){
801034af:	a1 a0 32 11 80       	mov    0x801132a0,%eax
801034b4:	85 c0                	test   %eax,%eax
801034b6:	74 16                	je     801034ce <begin_op+0x31>
      sleep(&log, &log.lock);
801034b8:	c7 44 24 04 60 32 11 	movl   $0x80113260,0x4(%esp)
801034bf:	80 
801034c0:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
801034c7:	e8 25 1b 00 00       	call   80104ff1 <sleep>
    } else {
      log.outstanding += 1;
      release(&log.lock);
      break;
    }
  }
801034cc:	eb e1                	jmp    801034af <begin_op+0x12>
{
  acquire(&log.lock);
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801034ce:	8b 0d a8 32 11 80    	mov    0x801132a8,%ecx
801034d4:	a1 9c 32 11 80       	mov    0x8011329c,%eax
801034d9:	8d 50 01             	lea    0x1(%eax),%edx
801034dc:	89 d0                	mov    %edx,%eax
801034de:	c1 e0 02             	shl    $0x2,%eax
801034e1:	01 d0                	add    %edx,%eax
801034e3:	01 c0                	add    %eax,%eax
801034e5:	01 c8                	add    %ecx,%eax
801034e7:	83 f8 1e             	cmp    $0x1e,%eax
801034ea:	7e 16                	jle    80103502 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801034ec:	c7 44 24 04 60 32 11 	movl   $0x80113260,0x4(%esp)
801034f3:	80 
801034f4:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
801034fb:	e8 f1 1a 00 00       	call   80104ff1 <sleep>
    } else {
      log.outstanding += 1;
      release(&log.lock);
      break;
    }
  }
80103500:	eb ad                	jmp    801034af <begin_op+0x12>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
80103502:	a1 9c 32 11 80       	mov    0x8011329c,%eax
80103507:	83 c0 01             	add    $0x1,%eax
8010350a:	a3 9c 32 11 80       	mov    %eax,0x8011329c
      release(&log.lock);
8010350f:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
80103516:	e8 1e 1e 00 00       	call   80105339 <release>
      break;
8010351b:	90                   	nop
    }
  }
}
8010351c:	c9                   	leave  
8010351d:	c3                   	ret    

8010351e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010351e:	55                   	push   %ebp
8010351f:	89 e5                	mov    %esp,%ebp
80103521:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
80103524:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010352b:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
80103532:	e8 a0 1d 00 00       	call   801052d7 <acquire>
  log.outstanding -= 1;
80103537:	a1 9c 32 11 80       	mov    0x8011329c,%eax
8010353c:	83 e8 01             	sub    $0x1,%eax
8010353f:	a3 9c 32 11 80       	mov    %eax,0x8011329c
  if(log.committing)
80103544:	a1 a0 32 11 80       	mov    0x801132a0,%eax
80103549:	85 c0                	test   %eax,%eax
8010354b:	74 0c                	je     80103559 <end_op+0x3b>
    panic("log.committing");
8010354d:	c7 04 24 e4 8b 10 80 	movl   $0x80108be4,(%esp)
80103554:	e8 e4 cf ff ff       	call   8010053d <panic>
  if(log.outstanding == 0){
80103559:	a1 9c 32 11 80       	mov    0x8011329c,%eax
8010355e:	85 c0                	test   %eax,%eax
80103560:	75 13                	jne    80103575 <end_op+0x57>
    do_commit = 1;
80103562:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103569:	c7 05 a0 32 11 80 01 	movl   $0x1,0x801132a0
80103570:	00 00 00 
80103573:	eb 0c                	jmp    80103581 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103575:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
8010357c:	e8 4c 1b 00 00       	call   801050cd <wakeup>
  }
  release(&log.lock);
80103581:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
80103588:	e8 ac 1d 00 00       	call   80105339 <release>

  if(do_commit){
8010358d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103591:	74 33                	je     801035c6 <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103593:	e8 db 00 00 00       	call   80103673 <commit>
    acquire(&log.lock);
80103598:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
8010359f:	e8 33 1d 00 00       	call   801052d7 <acquire>
    log.committing = 0;
801035a4:	c7 05 a0 32 11 80 00 	movl   $0x0,0x801132a0
801035ab:	00 00 00 
    wakeup(&log);
801035ae:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
801035b5:	e8 13 1b 00 00       	call   801050cd <wakeup>
    release(&log.lock);
801035ba:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
801035c1:	e8 73 1d 00 00       	call   80105339 <release>
  }
}
801035c6:	c9                   	leave  
801035c7:	c3                   	ret    

801035c8 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
801035c8:	55                   	push   %ebp
801035c9:	89 e5                	mov    %esp,%ebp
801035cb:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801035ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035d5:	e9 89 00 00 00       	jmp    80103663 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801035da:	a1 94 32 11 80       	mov    0x80113294,%eax
801035df:	03 45 f4             	add    -0xc(%ebp),%eax
801035e2:	83 c0 01             	add    $0x1,%eax
801035e5:	89 c2                	mov    %eax,%edx
801035e7:	a1 a4 32 11 80       	mov    0x801132a4,%eax
801035ec:	89 54 24 04          	mov    %edx,0x4(%esp)
801035f0:	89 04 24             	mov    %eax,(%esp)
801035f3:	e8 ae cb ff ff       	call   801001a6 <bread>
801035f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
801035fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035fe:	83 c0 10             	add    $0x10,%eax
80103601:	8b 04 85 6c 32 11 80 	mov    -0x7feecd94(,%eax,4),%eax
80103608:	89 c2                	mov    %eax,%edx
8010360a:	a1 a4 32 11 80       	mov    0x801132a4,%eax
8010360f:	89 54 24 04          	mov    %edx,0x4(%esp)
80103613:	89 04 24             	mov    %eax,(%esp)
80103616:	e8 8b cb ff ff       	call   801001a6 <bread>
8010361b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010361e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103621:	8d 50 18             	lea    0x18(%eax),%edx
80103624:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103627:	83 c0 18             	add    $0x18,%eax
8010362a:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103631:	00 
80103632:	89 54 24 04          	mov    %edx,0x4(%esp)
80103636:	89 04 24             	mov    %eax,(%esp)
80103639:	e8 bb 1f 00 00       	call   801055f9 <memmove>
    bwrite(to);  // write the log
8010363e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103641:	89 04 24             	mov    %eax,(%esp)
80103644:	e8 94 cb ff ff       	call   801001dd <bwrite>
    brelse(from); 
80103649:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010364c:	89 04 24             	mov    %eax,(%esp)
8010364f:	e8 c3 cb ff ff       	call   80100217 <brelse>
    brelse(to);
80103654:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103657:	89 04 24             	mov    %eax,(%esp)
8010365a:	e8 b8 cb ff ff       	call   80100217 <brelse>
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010365f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103663:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103668:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010366b:	0f 8f 69 ff ff ff    	jg     801035da <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103671:	c9                   	leave  
80103672:	c3                   	ret    

80103673 <commit>:

static void
commit()
{
80103673:	55                   	push   %ebp
80103674:	89 e5                	mov    %esp,%ebp
80103676:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103679:	a1 a8 32 11 80       	mov    0x801132a8,%eax
8010367e:	85 c0                	test   %eax,%eax
80103680:	7e 1e                	jle    801036a0 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103682:	e8 41 ff ff ff       	call   801035c8 <write_log>
    write_head();    // Write header to disk -- the real commit
80103687:	e8 75 fd ff ff       	call   80103401 <write_head>
    install_trans(); // Now install writes to home locations
8010368c:	e8 56 fc ff ff       	call   801032e7 <install_trans>
    log.lh.n = 0; 
80103691:	c7 05 a8 32 11 80 00 	movl   $0x0,0x801132a8
80103698:	00 00 00 
    write_head();    // Erase the transaction from the log
8010369b:	e8 61 fd ff ff       	call   80103401 <write_head>
  }
}
801036a0:	c9                   	leave  
801036a1:	c3                   	ret    

801036a2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801036a2:	55                   	push   %ebp
801036a3:	89 e5                	mov    %esp,%ebp
801036a5:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801036a8:	a1 a8 32 11 80       	mov    0x801132a8,%eax
801036ad:	83 f8 1d             	cmp    $0x1d,%eax
801036b0:	7f 12                	jg     801036c4 <log_write+0x22>
801036b2:	a1 a8 32 11 80       	mov    0x801132a8,%eax
801036b7:	8b 15 98 32 11 80    	mov    0x80113298,%edx
801036bd:	83 ea 01             	sub    $0x1,%edx
801036c0:	39 d0                	cmp    %edx,%eax
801036c2:	7c 0c                	jl     801036d0 <log_write+0x2e>
    panic("too big a transaction");
801036c4:	c7 04 24 f3 8b 10 80 	movl   $0x80108bf3,(%esp)
801036cb:	e8 6d ce ff ff       	call   8010053d <panic>
  if (log.outstanding < 1)
801036d0:	a1 9c 32 11 80       	mov    0x8011329c,%eax
801036d5:	85 c0                	test   %eax,%eax
801036d7:	7f 0c                	jg     801036e5 <log_write+0x43>
    panic("log_write outside of trans");
801036d9:	c7 04 24 09 8c 10 80 	movl   $0x80108c09,(%esp)
801036e0:	e8 58 ce ff ff       	call   8010053d <panic>

  acquire(&log.lock);
801036e5:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
801036ec:	e8 e6 1b 00 00       	call   801052d7 <acquire>
  for (i = 0; i < log.lh.n; i++) {
801036f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036f8:	eb 1d                	jmp    80103717 <log_write+0x75>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
801036fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036fd:	83 c0 10             	add    $0x10,%eax
80103700:	8b 04 85 6c 32 11 80 	mov    -0x7feecd94(,%eax,4),%eax
80103707:	89 c2                	mov    %eax,%edx
80103709:	8b 45 08             	mov    0x8(%ebp),%eax
8010370c:	8b 40 08             	mov    0x8(%eax),%eax
8010370f:	39 c2                	cmp    %eax,%edx
80103711:	74 10                	je     80103723 <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103713:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103717:	a1 a8 32 11 80       	mov    0x801132a8,%eax
8010371c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010371f:	7f d9                	jg     801036fa <log_write+0x58>
80103721:	eb 01                	jmp    80103724 <log_write+0x82>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
      break;
80103723:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
80103724:	8b 45 08             	mov    0x8(%ebp),%eax
80103727:	8b 40 08             	mov    0x8(%eax),%eax
8010372a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010372d:	83 c2 10             	add    $0x10,%edx
80103730:	89 04 95 6c 32 11 80 	mov    %eax,-0x7feecd94(,%edx,4)
  if (i == log.lh.n)
80103737:	a1 a8 32 11 80       	mov    0x801132a8,%eax
8010373c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010373f:	75 0d                	jne    8010374e <log_write+0xac>
    log.lh.n++;
80103741:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103746:	83 c0 01             	add    $0x1,%eax
80103749:	a3 a8 32 11 80       	mov    %eax,0x801132a8
  b->flags |= B_DIRTY; // prevent eviction
8010374e:	8b 45 08             	mov    0x8(%ebp),%eax
80103751:	8b 00                	mov    (%eax),%eax
80103753:	89 c2                	mov    %eax,%edx
80103755:	83 ca 04             	or     $0x4,%edx
80103758:	8b 45 08             	mov    0x8(%ebp),%eax
8010375b:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010375d:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
80103764:	e8 d0 1b 00 00       	call   80105339 <release>
}
80103769:	c9                   	leave  
8010376a:	c3                   	ret    
	...

8010376c <v2p>:
8010376c:	55                   	push   %ebp
8010376d:	89 e5                	mov    %esp,%ebp
8010376f:	8b 45 08             	mov    0x8(%ebp),%eax
80103772:	05 00 00 00 80       	add    $0x80000000,%eax
80103777:	5d                   	pop    %ebp
80103778:	c3                   	ret    

80103779 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103779:	55                   	push   %ebp
8010377a:	89 e5                	mov    %esp,%ebp
8010377c:	8b 45 08             	mov    0x8(%ebp),%eax
8010377f:	05 00 00 00 80       	add    $0x80000000,%eax
80103784:	5d                   	pop    %ebp
80103785:	c3                   	ret    

80103786 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103786:	55                   	push   %ebp
80103787:	89 e5                	mov    %esp,%ebp
80103789:	53                   	push   %ebx
8010378a:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
8010378d:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103790:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80103793:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103796:	89 c3                	mov    %eax,%ebx
80103798:	89 d8                	mov    %ebx,%eax
8010379a:	f0 87 02             	lock xchg %eax,(%edx)
8010379d:	89 c3                	mov    %eax,%ebx
8010379f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801037a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801037a5:	83 c4 10             	add    $0x10,%esp
801037a8:	5b                   	pop    %ebx
801037a9:	5d                   	pop    %ebp
801037aa:	c3                   	ret    

801037ab <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801037ab:	55                   	push   %ebp
801037ac:	89 e5                	mov    %esp,%ebp
801037ae:	83 e4 f0             	and    $0xfffffff0,%esp
801037b1:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801037b4:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
801037bb:	80 
801037bc:	c7 04 24 7c 66 11 80 	movl   $0x8011667c,(%esp)
801037c3:	e8 51 f2 ff ff       	call   80102a19 <kinit1>
  kvmalloc();      // kernel page table
801037c8:	e8 51 4a 00 00       	call   8010821e <kvmalloc>
  mpinit();        // collect info about this machine
801037cd:	e8 53 04 00 00       	call   80103c25 <mpinit>
  lapicinit();
801037d2:	e8 cb f5 ff ff       	call   80102da2 <lapicinit>
  seginit();       // set up segments
801037d7:	e8 e5 43 00 00       	call   80107bc1 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801037dc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037e2:	0f b6 00             	movzbl (%eax),%eax
801037e5:	0f b6 c0             	movzbl %al,%eax
801037e8:	89 44 24 04          	mov    %eax,0x4(%esp)
801037ec:	c7 04 24 24 8c 10 80 	movl   $0x80108c24,(%esp)
801037f3:	e8 a9 cb ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
801037f8:	e8 8d 06 00 00       	call   80103e8a <picinit>
  ioapicinit();    // another interrupt controller
801037fd:	e8 07 f1 ff ff       	call   80102909 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103802:	e8 86 d2 ff ff       	call   80100a8d <consoleinit>
  uartinit();      // serial port
80103807:	e8 00 37 00 00       	call   80106f0c <uartinit>
  pinit();         // process table
8010380c:	e8 8e 0b 00 00       	call   8010439f <pinit>
  tvinit();        // trap vectors
80103811:	e8 7d 32 00 00       	call   80106a93 <tvinit>
  binit();         // buffer cache
80103816:	e8 19 c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010381b:	e8 28 d7 ff ff       	call   80100f48 <fileinit>
  iinit();         // inode cache
80103820:	e8 d6 dd ff ff       	call   801015fb <iinit>
  ideinit();       // disk
80103825:	e8 44 ed ff ff       	call   8010256e <ideinit>
  if(!ismp)
8010382a:	a1 44 33 11 80       	mov    0x80113344,%eax
8010382f:	85 c0                	test   %eax,%eax
80103831:	75 05                	jne    80103838 <main+0x8d>
    timerinit();   // uniprocessor timer
80103833:	e8 9e 31 00 00       	call   801069d6 <timerinit>
  startothers();   // start other processors
80103838:	e8 7f 00 00 00       	call   801038bc <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
8010383d:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103844:	8e 
80103845:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
8010384c:	e8 00 f2 ff ff       	call   80102a51 <kinit2>
  userinit();      // first user process
80103851:	e8 ef 0c 00 00       	call   80104545 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103856:	e8 1a 00 00 00       	call   80103875 <mpmain>

8010385b <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010385b:	55                   	push   %ebp
8010385c:	89 e5                	mov    %esp,%ebp
8010385e:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103861:	e8 cf 49 00 00       	call   80108235 <switchkvm>
  seginit();
80103866:	e8 56 43 00 00       	call   80107bc1 <seginit>
  lapicinit();
8010386b:	e8 32 f5 ff ff       	call   80102da2 <lapicinit>
  mpmain();
80103870:	e8 00 00 00 00       	call   80103875 <mpmain>

80103875 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103875:	55                   	push   %ebp
80103876:	89 e5                	mov    %esp,%ebp
80103878:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010387b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103881:	0f b6 00             	movzbl (%eax),%eax
80103884:	0f b6 c0             	movzbl %al,%eax
80103887:	89 44 24 04          	mov    %eax,0x4(%esp)
8010388b:	c7 04 24 3b 8c 10 80 	movl   $0x80108c3b,(%esp)
80103892:	e8 0a cb ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
80103897:	e8 6b 33 00 00       	call   80106c07 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
8010389c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038a2:	05 a8 00 00 00       	add    $0xa8,%eax
801038a7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801038ae:	00 
801038af:	89 04 24             	mov    %eax,(%esp)
801038b2:	e8 cf fe ff ff       	call   80103786 <xchg>
  scheduler();     // start running processes
801038b7:	e8 89 15 00 00       	call   80104e45 <scheduler>

801038bc <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801038bc:	55                   	push   %ebp
801038bd:	89 e5                	mov    %esp,%ebp
801038bf:	53                   	push   %ebx
801038c0:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801038c3:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
801038ca:	e8 aa fe ff ff       	call   80103779 <p2v>
801038cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801038d2:	b8 8a 00 00 00       	mov    $0x8a,%eax
801038d7:	89 44 24 08          	mov    %eax,0x8(%esp)
801038db:	c7 44 24 04 0c c5 10 	movl   $0x8010c50c,0x4(%esp)
801038e2:	80 
801038e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038e6:	89 04 24             	mov    %eax,(%esp)
801038e9:	e8 0b 1d 00 00       	call   801055f9 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801038ee:	c7 45 f4 60 33 11 80 	movl   $0x80113360,-0xc(%ebp)
801038f5:	e9 86 00 00 00       	jmp    80103980 <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
801038fa:	e8 00 f6 ff ff       	call   80102eff <cpunum>
801038ff:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103905:	05 60 33 11 80       	add    $0x80113360,%eax
8010390a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010390d:	74 69                	je     80103978 <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010390f:	e8 33 f2 ff ff       	call   80102b47 <kalloc>
80103914:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103917:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010391a:	83 e8 04             	sub    $0x4,%eax
8010391d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103920:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103926:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103928:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010392b:	83 e8 08             	sub    $0x8,%eax
8010392e:	c7 00 5b 38 10 80    	movl   $0x8010385b,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103934:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103937:	8d 58 f4             	lea    -0xc(%eax),%ebx
8010393a:	c7 04 24 00 b0 10 80 	movl   $0x8010b000,(%esp)
80103941:	e8 26 fe ff ff       	call   8010376c <v2p>
80103946:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103948:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010394b:	89 04 24             	mov    %eax,(%esp)
8010394e:	e8 19 fe ff ff       	call   8010376c <v2p>
80103953:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103956:	0f b6 12             	movzbl (%edx),%edx
80103959:	0f b6 d2             	movzbl %dl,%edx
8010395c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103960:	89 14 24             	mov    %edx,(%esp)
80103963:	e8 1d f6 ff ff       	call   80102f85 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103968:	90                   	nop
80103969:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010396c:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103972:	85 c0                	test   %eax,%eax
80103974:	74 f3                	je     80103969 <startothers+0xad>
80103976:	eb 01                	jmp    80103979 <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103978:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103979:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103980:	a1 40 39 11 80       	mov    0x80113940,%eax
80103985:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010398b:	05 60 33 11 80       	add    $0x80113360,%eax
80103990:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103993:	0f 87 61 ff ff ff    	ja     801038fa <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103999:	83 c4 24             	add    $0x24,%esp
8010399c:	5b                   	pop    %ebx
8010399d:	5d                   	pop    %ebp
8010399e:	c3                   	ret    
	...

801039a0 <p2v>:
801039a0:	55                   	push   %ebp
801039a1:	89 e5                	mov    %esp,%ebp
801039a3:	8b 45 08             	mov    0x8(%ebp),%eax
801039a6:	05 00 00 00 80       	add    $0x80000000,%eax
801039ab:	5d                   	pop    %ebp
801039ac:	c3                   	ret    

801039ad <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801039ad:	55                   	push   %ebp
801039ae:	89 e5                	mov    %esp,%ebp
801039b0:	53                   	push   %ebx
801039b1:	83 ec 14             	sub    $0x14,%esp
801039b4:	8b 45 08             	mov    0x8(%ebp),%eax
801039b7:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801039bb:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801039bf:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801039c3:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801039c7:	ec                   	in     (%dx),%al
801039c8:	89 c3                	mov    %eax,%ebx
801039ca:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801039cd:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801039d1:	83 c4 14             	add    $0x14,%esp
801039d4:	5b                   	pop    %ebx
801039d5:	5d                   	pop    %ebp
801039d6:	c3                   	ret    

801039d7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801039d7:	55                   	push   %ebp
801039d8:	89 e5                	mov    %esp,%ebp
801039da:	83 ec 08             	sub    $0x8,%esp
801039dd:	8b 55 08             	mov    0x8(%ebp),%edx
801039e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801039e3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801039e7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801039ea:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801039ee:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801039f2:	ee                   	out    %al,(%dx)
}
801039f3:	c9                   	leave  
801039f4:	c3                   	ret    

801039f5 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801039f5:	55                   	push   %ebp
801039f6:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801039f8:	a1 44 c6 10 80       	mov    0x8010c644,%eax
801039fd:	89 c2                	mov    %eax,%edx
801039ff:	b8 60 33 11 80       	mov    $0x80113360,%eax
80103a04:	89 d1                	mov    %edx,%ecx
80103a06:	29 c1                	sub    %eax,%ecx
80103a08:	89 c8                	mov    %ecx,%eax
80103a0a:	c1 f8 02             	sar    $0x2,%eax
80103a0d:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103a13:	5d                   	pop    %ebp
80103a14:	c3                   	ret    

80103a15 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103a15:	55                   	push   %ebp
80103a16:	89 e5                	mov    %esp,%ebp
80103a18:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103a1b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a22:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a29:	eb 13                	jmp    80103a3e <sum+0x29>
    sum += addr[i];
80103a2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a2e:	03 45 08             	add    0x8(%ebp),%eax
80103a31:	0f b6 00             	movzbl (%eax),%eax
80103a34:	0f b6 c0             	movzbl %al,%eax
80103a37:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103a3a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103a3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a41:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a44:	7c e5                	jl     80103a2b <sum+0x16>
    sum += addr[i];
  return sum;
80103a46:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a49:	c9                   	leave  
80103a4a:	c3                   	ret    

80103a4b <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a4b:	55                   	push   %ebp
80103a4c:	89 e5                	mov    %esp,%ebp
80103a4e:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103a51:	8b 45 08             	mov    0x8(%ebp),%eax
80103a54:	89 04 24             	mov    %eax,(%esp)
80103a57:	e8 44 ff ff ff       	call   801039a0 <p2v>
80103a5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a62:	03 45 f0             	add    -0x10(%ebp),%eax
80103a65:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a6e:	eb 3f                	jmp    80103aaf <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a70:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a77:	00 
80103a78:	c7 44 24 04 4c 8c 10 	movl   $0x80108c4c,0x4(%esp)
80103a7f:	80 
80103a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a83:	89 04 24             	mov    %eax,(%esp)
80103a86:	e8 12 1b 00 00       	call   8010559d <memcmp>
80103a8b:	85 c0                	test   %eax,%eax
80103a8d:	75 1c                	jne    80103aab <mpsearch1+0x60>
80103a8f:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a96:	00 
80103a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a9a:	89 04 24             	mov    %eax,(%esp)
80103a9d:	e8 73 ff ff ff       	call   80103a15 <sum>
80103aa2:	84 c0                	test   %al,%al
80103aa4:	75 05                	jne    80103aab <mpsearch1+0x60>
      return (struct mp*)p;
80103aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa9:	eb 11                	jmp    80103abc <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103aab:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103ab5:	72 b9                	jb     80103a70 <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103ab7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103abc:	c9                   	leave  
80103abd:	c3                   	ret    

80103abe <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103abe:	55                   	push   %ebp
80103abf:	89 e5                	mov    %esp,%ebp
80103ac1:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103ac4:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ace:	83 c0 0f             	add    $0xf,%eax
80103ad1:	0f b6 00             	movzbl (%eax),%eax
80103ad4:	0f b6 c0             	movzbl %al,%eax
80103ad7:	89 c2                	mov    %eax,%edx
80103ad9:	c1 e2 08             	shl    $0x8,%edx
80103adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103adf:	83 c0 0e             	add    $0xe,%eax
80103ae2:	0f b6 00             	movzbl (%eax),%eax
80103ae5:	0f b6 c0             	movzbl %al,%eax
80103ae8:	09 d0                	or     %edx,%eax
80103aea:	c1 e0 04             	shl    $0x4,%eax
80103aed:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103af0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103af4:	74 21                	je     80103b17 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103af6:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103afd:	00 
80103afe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b01:	89 04 24             	mov    %eax,(%esp)
80103b04:	e8 42 ff ff ff       	call   80103a4b <mpsearch1>
80103b09:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b0c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b10:	74 50                	je     80103b62 <mpsearch+0xa4>
      return mp;
80103b12:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b15:	eb 5f                	jmp    80103b76 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b1a:	83 c0 14             	add    $0x14,%eax
80103b1d:	0f b6 00             	movzbl (%eax),%eax
80103b20:	0f b6 c0             	movzbl %al,%eax
80103b23:	89 c2                	mov    %eax,%edx
80103b25:	c1 e2 08             	shl    $0x8,%edx
80103b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b2b:	83 c0 13             	add    $0x13,%eax
80103b2e:	0f b6 00             	movzbl (%eax),%eax
80103b31:	0f b6 c0             	movzbl %al,%eax
80103b34:	09 d0                	or     %edx,%eax
80103b36:	c1 e0 0a             	shl    $0xa,%eax
80103b39:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b3f:	2d 00 04 00 00       	sub    $0x400,%eax
80103b44:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b4b:	00 
80103b4c:	89 04 24             	mov    %eax,(%esp)
80103b4f:	e8 f7 fe ff ff       	call   80103a4b <mpsearch1>
80103b54:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b57:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b5b:	74 05                	je     80103b62 <mpsearch+0xa4>
      return mp;
80103b5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b60:	eb 14                	jmp    80103b76 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b62:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b69:	00 
80103b6a:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b71:	e8 d5 fe ff ff       	call   80103a4b <mpsearch1>
}
80103b76:	c9                   	leave  
80103b77:	c3                   	ret    

80103b78 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b78:	55                   	push   %ebp
80103b79:	89 e5                	mov    %esp,%ebp
80103b7b:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b7e:	e8 3b ff ff ff       	call   80103abe <mpsearch>
80103b83:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b86:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b8a:	74 0a                	je     80103b96 <mpconfig+0x1e>
80103b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8f:	8b 40 04             	mov    0x4(%eax),%eax
80103b92:	85 c0                	test   %eax,%eax
80103b94:	75 0a                	jne    80103ba0 <mpconfig+0x28>
    return 0;
80103b96:	b8 00 00 00 00       	mov    $0x0,%eax
80103b9b:	e9 83 00 00 00       	jmp    80103c23 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba3:	8b 40 04             	mov    0x4(%eax),%eax
80103ba6:	89 04 24             	mov    %eax,(%esp)
80103ba9:	e8 f2 fd ff ff       	call   801039a0 <p2v>
80103bae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103bb1:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103bb8:	00 
80103bb9:	c7 44 24 04 51 8c 10 	movl   $0x80108c51,0x4(%esp)
80103bc0:	80 
80103bc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc4:	89 04 24             	mov    %eax,(%esp)
80103bc7:	e8 d1 19 00 00       	call   8010559d <memcmp>
80103bcc:	85 c0                	test   %eax,%eax
80103bce:	74 07                	je     80103bd7 <mpconfig+0x5f>
    return 0;
80103bd0:	b8 00 00 00 00       	mov    $0x0,%eax
80103bd5:	eb 4c                	jmp    80103c23 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bda:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bde:	3c 01                	cmp    $0x1,%al
80103be0:	74 12                	je     80103bf4 <mpconfig+0x7c>
80103be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103be5:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103be9:	3c 04                	cmp    $0x4,%al
80103beb:	74 07                	je     80103bf4 <mpconfig+0x7c>
    return 0;
80103bed:	b8 00 00 00 00       	mov    $0x0,%eax
80103bf2:	eb 2f                	jmp    80103c23 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103bf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bf7:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103bfb:	0f b7 c0             	movzwl %ax,%eax
80103bfe:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c05:	89 04 24             	mov    %eax,(%esp)
80103c08:	e8 08 fe ff ff       	call   80103a15 <sum>
80103c0d:	84 c0                	test   %al,%al
80103c0f:	74 07                	je     80103c18 <mpconfig+0xa0>
    return 0;
80103c11:	b8 00 00 00 00       	mov    $0x0,%eax
80103c16:	eb 0b                	jmp    80103c23 <mpconfig+0xab>
  *pmp = mp;
80103c18:	8b 45 08             	mov    0x8(%ebp),%eax
80103c1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c1e:	89 10                	mov    %edx,(%eax)
  return conf;
80103c20:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c23:	c9                   	leave  
80103c24:	c3                   	ret    

80103c25 <mpinit>:

void
mpinit(void)
{
80103c25:	55                   	push   %ebp
80103c26:	89 e5                	mov    %esp,%ebp
80103c28:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103c2b:	c7 05 44 c6 10 80 60 	movl   $0x80113360,0x8010c644
80103c32:	33 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103c35:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103c38:	89 04 24             	mov    %eax,(%esp)
80103c3b:	e8 38 ff ff ff       	call   80103b78 <mpconfig>
80103c40:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c43:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c47:	0f 84 9c 01 00 00    	je     80103de9 <mpinit+0x1c4>
    return;
  ismp = 1;
80103c4d:	c7 05 44 33 11 80 01 	movl   $0x1,0x80113344
80103c54:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103c57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c5a:	8b 40 24             	mov    0x24(%eax),%eax
80103c5d:	a3 5c 32 11 80       	mov    %eax,0x8011325c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c65:	83 c0 2c             	add    $0x2c,%eax
80103c68:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c6e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c72:	0f b7 c0             	movzwl %ax,%eax
80103c75:	03 45 f0             	add    -0x10(%ebp),%eax
80103c78:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c7b:	e9 f4 00 00 00       	jmp    80103d74 <mpinit+0x14f>
    switch(*p){
80103c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c83:	0f b6 00             	movzbl (%eax),%eax
80103c86:	0f b6 c0             	movzbl %al,%eax
80103c89:	83 f8 04             	cmp    $0x4,%eax
80103c8c:	0f 87 bf 00 00 00    	ja     80103d51 <mpinit+0x12c>
80103c92:	8b 04 85 94 8c 10 80 	mov    -0x7fef736c(,%eax,4),%eax
80103c99:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103ca1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ca4:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103ca8:	0f b6 d0             	movzbl %al,%edx
80103cab:	a1 40 39 11 80       	mov    0x80113940,%eax
80103cb0:	39 c2                	cmp    %eax,%edx
80103cb2:	74 2d                	je     80103ce1 <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103cb4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103cb7:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cbb:	0f b6 d0             	movzbl %al,%edx
80103cbe:	a1 40 39 11 80       	mov    0x80113940,%eax
80103cc3:	89 54 24 08          	mov    %edx,0x8(%esp)
80103cc7:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ccb:	c7 04 24 56 8c 10 80 	movl   $0x80108c56,(%esp)
80103cd2:	e8 ca c6 ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80103cd7:	c7 05 44 33 11 80 00 	movl   $0x0,0x80113344
80103cde:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103ce1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ce4:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103ce8:	0f b6 c0             	movzbl %al,%eax
80103ceb:	83 e0 02             	and    $0x2,%eax
80103cee:	85 c0                	test   %eax,%eax
80103cf0:	74 15                	je     80103d07 <mpinit+0xe2>
        bcpu = &cpus[ncpu];
80103cf2:	a1 40 39 11 80       	mov    0x80113940,%eax
80103cf7:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103cfd:	05 60 33 11 80       	add    $0x80113360,%eax
80103d02:	a3 44 c6 10 80       	mov    %eax,0x8010c644
      cpus[ncpu].id = ncpu;
80103d07:	8b 15 40 39 11 80    	mov    0x80113940,%edx
80103d0d:	a1 40 39 11 80       	mov    0x80113940,%eax
80103d12:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103d18:	81 c2 60 33 11 80    	add    $0x80113360,%edx
80103d1e:	88 02                	mov    %al,(%edx)
      ncpu++;
80103d20:	a1 40 39 11 80       	mov    0x80113940,%eax
80103d25:	83 c0 01             	add    $0x1,%eax
80103d28:	a3 40 39 11 80       	mov    %eax,0x80113940
      p += sizeof(struct mpproc);
80103d2d:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d31:	eb 41                	jmp    80103d74 <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103d39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d3c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d40:	a2 40 33 11 80       	mov    %al,0x80113340
      p += sizeof(struct mpioapic);
80103d45:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d49:	eb 29                	jmp    80103d74 <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d4b:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d4f:	eb 23                	jmp    80103d74 <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d54:	0f b6 00             	movzbl (%eax),%eax
80103d57:	0f b6 c0             	movzbl %al,%eax
80103d5a:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d5e:	c7 04 24 74 8c 10 80 	movl   $0x80108c74,(%esp)
80103d65:	e8 37 c6 ff ff       	call   801003a1 <cprintf>
      ismp = 0;
80103d6a:	c7 05 44 33 11 80 00 	movl   $0x0,0x80113344
80103d71:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d77:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d7a:	0f 82 00 ff ff ff    	jb     80103c80 <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103d80:	a1 44 33 11 80       	mov    0x80113344,%eax
80103d85:	85 c0                	test   %eax,%eax
80103d87:	75 1d                	jne    80103da6 <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103d89:	c7 05 40 39 11 80 01 	movl   $0x1,0x80113940
80103d90:	00 00 00 
    lapic = 0;
80103d93:	c7 05 5c 32 11 80 00 	movl   $0x0,0x8011325c
80103d9a:	00 00 00 
    ioapicid = 0;
80103d9d:	c6 05 40 33 11 80 00 	movb   $0x0,0x80113340
    return;
80103da4:	eb 44                	jmp    80103dea <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103da6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103da9:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103dad:	84 c0                	test   %al,%al
80103daf:	74 39                	je     80103dea <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103db1:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103db8:	00 
80103db9:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103dc0:	e8 12 fc ff ff       	call   801039d7 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103dc5:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103dcc:	e8 dc fb ff ff       	call   801039ad <inb>
80103dd1:	83 c8 01             	or     $0x1,%eax
80103dd4:	0f b6 c0             	movzbl %al,%eax
80103dd7:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ddb:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103de2:	e8 f0 fb ff ff       	call   801039d7 <outb>
80103de7:	eb 01                	jmp    80103dea <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103de9:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103dea:	c9                   	leave  
80103deb:	c3                   	ret    

80103dec <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103dec:	55                   	push   %ebp
80103ded:	89 e5                	mov    %esp,%ebp
80103def:	83 ec 08             	sub    $0x8,%esp
80103df2:	8b 55 08             	mov    0x8(%ebp),%edx
80103df5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103df8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103dfc:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103dff:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103e03:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103e07:	ee                   	out    %al,(%dx)
}
80103e08:	c9                   	leave  
80103e09:	c3                   	ret    

80103e0a <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103e0a:	55                   	push   %ebp
80103e0b:	89 e5                	mov    %esp,%ebp
80103e0d:	83 ec 0c             	sub    $0xc,%esp
80103e10:	8b 45 08             	mov    0x8(%ebp),%eax
80103e13:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103e17:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e1b:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80103e21:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e25:	0f b6 c0             	movzbl %al,%eax
80103e28:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e2c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e33:	e8 b4 ff ff ff       	call   80103dec <outb>
  outb(IO_PIC2+1, mask >> 8);
80103e38:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e3c:	66 c1 e8 08          	shr    $0x8,%ax
80103e40:	0f b6 c0             	movzbl %al,%eax
80103e43:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e47:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e4e:	e8 99 ff ff ff       	call   80103dec <outb>
}
80103e53:	c9                   	leave  
80103e54:	c3                   	ret    

80103e55 <picenable>:

void
picenable(int irq)
{
80103e55:	55                   	push   %ebp
80103e56:	89 e5                	mov    %esp,%ebp
80103e58:	53                   	push   %ebx
80103e59:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e5f:	ba 01 00 00 00       	mov    $0x1,%edx
80103e64:	89 d3                	mov    %edx,%ebx
80103e66:	89 c1                	mov    %eax,%ecx
80103e68:	d3 e3                	shl    %cl,%ebx
80103e6a:	89 d8                	mov    %ebx,%eax
80103e6c:	89 c2                	mov    %eax,%edx
80103e6e:	f7 d2                	not    %edx
80103e70:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103e77:	21 d0                	and    %edx,%eax
80103e79:	0f b7 c0             	movzwl %ax,%eax
80103e7c:	89 04 24             	mov    %eax,(%esp)
80103e7f:	e8 86 ff ff ff       	call   80103e0a <picsetmask>
}
80103e84:	83 c4 04             	add    $0x4,%esp
80103e87:	5b                   	pop    %ebx
80103e88:	5d                   	pop    %ebp
80103e89:	c3                   	ret    

80103e8a <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103e8a:	55                   	push   %ebp
80103e8b:	89 e5                	mov    %esp,%ebp
80103e8d:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e90:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e97:	00 
80103e98:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e9f:	e8 48 ff ff ff       	call   80103dec <outb>
  outb(IO_PIC2+1, 0xFF);
80103ea4:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103eab:	00 
80103eac:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103eb3:	e8 34 ff ff ff       	call   80103dec <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103eb8:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103ebf:	00 
80103ec0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ec7:	e8 20 ff ff ff       	call   80103dec <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103ecc:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103ed3:	00 
80103ed4:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103edb:	e8 0c ff ff ff       	call   80103dec <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103ee0:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103ee7:	00 
80103ee8:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103eef:	e8 f8 fe ff ff       	call   80103dec <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103ef4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103efb:	00 
80103efc:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103f03:	e8 e4 fe ff ff       	call   80103dec <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103f08:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103f0f:	00 
80103f10:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f17:	e8 d0 fe ff ff       	call   80103dec <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103f1c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103f23:	00 
80103f24:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f2b:	e8 bc fe ff ff       	call   80103dec <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103f30:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103f37:	00 
80103f38:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f3f:	e8 a8 fe ff ff       	call   80103dec <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103f44:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103f4b:	00 
80103f4c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f53:	e8 94 fe ff ff       	call   80103dec <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103f58:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f5f:	00 
80103f60:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f67:	e8 80 fe ff ff       	call   80103dec <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f6c:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f73:	00 
80103f74:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f7b:	e8 6c fe ff ff       	call   80103dec <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103f80:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f87:	00 
80103f88:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f8f:	e8 58 fe ff ff       	call   80103dec <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103f94:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f9b:	00 
80103f9c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103fa3:	e8 44 fe ff ff       	call   80103dec <outb>

  if(irqmask != 0xFFFF)
80103fa8:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103faf:	66 83 f8 ff          	cmp    $0xffff,%ax
80103fb3:	74 12                	je     80103fc7 <picinit+0x13d>
    picsetmask(irqmask);
80103fb5:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103fbc:	0f b7 c0             	movzwl %ax,%eax
80103fbf:	89 04 24             	mov    %eax,(%esp)
80103fc2:	e8 43 fe ff ff       	call   80103e0a <picsetmask>
}
80103fc7:	c9                   	leave  
80103fc8:	c3                   	ret    
80103fc9:	00 00                	add    %al,(%eax)
	...

80103fcc <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103fcc:	55                   	push   %ebp
80103fcd:	89 e5                	mov    %esp,%ebp
80103fcf:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103fd2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103fd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fdc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103fe2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fe5:	8b 10                	mov    (%eax),%edx
80103fe7:	8b 45 08             	mov    0x8(%ebp),%eax
80103fea:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103fec:	e8 73 cf ff ff       	call   80100f64 <filealloc>
80103ff1:	8b 55 08             	mov    0x8(%ebp),%edx
80103ff4:	89 02                	mov    %eax,(%edx)
80103ff6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff9:	8b 00                	mov    (%eax),%eax
80103ffb:	85 c0                	test   %eax,%eax
80103ffd:	0f 84 c8 00 00 00    	je     801040cb <pipealloc+0xff>
80104003:	e8 5c cf ff ff       	call   80100f64 <filealloc>
80104008:	8b 55 0c             	mov    0xc(%ebp),%edx
8010400b:	89 02                	mov    %eax,(%edx)
8010400d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104010:	8b 00                	mov    (%eax),%eax
80104012:	85 c0                	test   %eax,%eax
80104014:	0f 84 b1 00 00 00    	je     801040cb <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010401a:	e8 28 eb ff ff       	call   80102b47 <kalloc>
8010401f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104022:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104026:	0f 84 9e 00 00 00    	je     801040ca <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
8010402c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402f:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104036:	00 00 00 
  p->writeopen = 1;
80104039:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010403c:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104043:	00 00 00 
  p->nwrite = 0;
80104046:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104049:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104050:	00 00 00 
  p->nread = 0;
80104053:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104056:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010405d:	00 00 00 
  initlock(&p->lock, "pipe");
80104060:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104063:	c7 44 24 04 a8 8c 10 	movl   $0x80108ca8,0x4(%esp)
8010406a:	80 
8010406b:	89 04 24             	mov    %eax,(%esp)
8010406e:	e8 43 12 00 00       	call   801052b6 <initlock>
  (*f0)->type = FD_PIPE;
80104073:	8b 45 08             	mov    0x8(%ebp),%eax
80104076:	8b 00                	mov    (%eax),%eax
80104078:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010407e:	8b 45 08             	mov    0x8(%ebp),%eax
80104081:	8b 00                	mov    (%eax),%eax
80104083:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104087:	8b 45 08             	mov    0x8(%ebp),%eax
8010408a:	8b 00                	mov    (%eax),%eax
8010408c:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104090:	8b 45 08             	mov    0x8(%ebp),%eax
80104093:	8b 00                	mov    (%eax),%eax
80104095:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104098:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010409b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010409e:	8b 00                	mov    (%eax),%eax
801040a0:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801040a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801040a9:	8b 00                	mov    (%eax),%eax
801040ab:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801040af:	8b 45 0c             	mov    0xc(%ebp),%eax
801040b2:	8b 00                	mov    (%eax),%eax
801040b4:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801040b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801040bb:	8b 00                	mov    (%eax),%eax
801040bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040c0:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801040c3:	b8 00 00 00 00       	mov    $0x0,%eax
801040c8:	eb 43                	jmp    8010410d <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
801040ca:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
801040cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040cf:	74 0b                	je     801040dc <pipealloc+0x110>
    kfree((char*)p);
801040d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d4:	89 04 24             	mov    %eax,(%esp)
801040d7:	e8 d2 e9 ff ff       	call   80102aae <kfree>
  if(*f0)
801040dc:	8b 45 08             	mov    0x8(%ebp),%eax
801040df:	8b 00                	mov    (%eax),%eax
801040e1:	85 c0                	test   %eax,%eax
801040e3:	74 0d                	je     801040f2 <pipealloc+0x126>
    fileclose(*f0);
801040e5:	8b 45 08             	mov    0x8(%ebp),%eax
801040e8:	8b 00                	mov    (%eax),%eax
801040ea:	89 04 24             	mov    %eax,(%esp)
801040ed:	e8 1a cf ff ff       	call   8010100c <fileclose>
  if(*f1)
801040f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801040f5:	8b 00                	mov    (%eax),%eax
801040f7:	85 c0                	test   %eax,%eax
801040f9:	74 0d                	je     80104108 <pipealloc+0x13c>
    fileclose(*f1);
801040fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801040fe:	8b 00                	mov    (%eax),%eax
80104100:	89 04 24             	mov    %eax,(%esp)
80104103:	e8 04 cf ff ff       	call   8010100c <fileclose>
  return -1;
80104108:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010410d:	c9                   	leave  
8010410e:	c3                   	ret    

8010410f <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010410f:	55                   	push   %ebp
80104110:	89 e5                	mov    %esp,%ebp
80104112:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104115:	8b 45 08             	mov    0x8(%ebp),%eax
80104118:	89 04 24             	mov    %eax,(%esp)
8010411b:	e8 b7 11 00 00       	call   801052d7 <acquire>
  if(writable){
80104120:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104124:	74 1f                	je     80104145 <pipeclose+0x36>
    p->writeopen = 0;
80104126:	8b 45 08             	mov    0x8(%ebp),%eax
80104129:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104130:	00 00 00 
    wakeup(&p->nread);
80104133:	8b 45 08             	mov    0x8(%ebp),%eax
80104136:	05 34 02 00 00       	add    $0x234,%eax
8010413b:	89 04 24             	mov    %eax,(%esp)
8010413e:	e8 8a 0f 00 00       	call   801050cd <wakeup>
80104143:	eb 1d                	jmp    80104162 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104145:	8b 45 08             	mov    0x8(%ebp),%eax
80104148:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010414f:	00 00 00 
    wakeup(&p->nwrite);
80104152:	8b 45 08             	mov    0x8(%ebp),%eax
80104155:	05 38 02 00 00       	add    $0x238,%eax
8010415a:	89 04 24             	mov    %eax,(%esp)
8010415d:	e8 6b 0f 00 00       	call   801050cd <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104162:	8b 45 08             	mov    0x8(%ebp),%eax
80104165:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010416b:	85 c0                	test   %eax,%eax
8010416d:	75 25                	jne    80104194 <pipeclose+0x85>
8010416f:	8b 45 08             	mov    0x8(%ebp),%eax
80104172:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104178:	85 c0                	test   %eax,%eax
8010417a:	75 18                	jne    80104194 <pipeclose+0x85>
    release(&p->lock);
8010417c:	8b 45 08             	mov    0x8(%ebp),%eax
8010417f:	89 04 24             	mov    %eax,(%esp)
80104182:	e8 b2 11 00 00       	call   80105339 <release>
    kfree((char*)p);
80104187:	8b 45 08             	mov    0x8(%ebp),%eax
8010418a:	89 04 24             	mov    %eax,(%esp)
8010418d:	e8 1c e9 ff ff       	call   80102aae <kfree>
80104192:	eb 0b                	jmp    8010419f <pipeclose+0x90>
  } else
    release(&p->lock);
80104194:	8b 45 08             	mov    0x8(%ebp),%eax
80104197:	89 04 24             	mov    %eax,(%esp)
8010419a:	e8 9a 11 00 00       	call   80105339 <release>
}
8010419f:	c9                   	leave  
801041a0:	c3                   	ret    

801041a1 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801041a1:	55                   	push   %ebp
801041a2:	89 e5                	mov    %esp,%ebp
801041a4:	53                   	push   %ebx
801041a5:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801041a8:	8b 45 08             	mov    0x8(%ebp),%eax
801041ab:	89 04 24             	mov    %eax,(%esp)
801041ae:	e8 24 11 00 00       	call   801052d7 <acquire>
  for(i = 0; i < n; i++){
801041b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041ba:	e9 a6 00 00 00       	jmp    80104265 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
801041bf:	8b 45 08             	mov    0x8(%ebp),%eax
801041c2:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041c8:	85 c0                	test   %eax,%eax
801041ca:	74 0d                	je     801041d9 <pipewrite+0x38>
801041cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041d2:	8b 40 24             	mov    0x24(%eax),%eax
801041d5:	85 c0                	test   %eax,%eax
801041d7:	74 15                	je     801041ee <pipewrite+0x4d>
        release(&p->lock);
801041d9:	8b 45 08             	mov    0x8(%ebp),%eax
801041dc:	89 04 24             	mov    %eax,(%esp)
801041df:	e8 55 11 00 00       	call   80105339 <release>
        return -1;
801041e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041e9:	e9 9d 00 00 00       	jmp    8010428b <pipewrite+0xea>
      }
      wakeup(&p->nread);
801041ee:	8b 45 08             	mov    0x8(%ebp),%eax
801041f1:	05 34 02 00 00       	add    $0x234,%eax
801041f6:	89 04 24             	mov    %eax,(%esp)
801041f9:	e8 cf 0e 00 00       	call   801050cd <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801041fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104201:	8b 55 08             	mov    0x8(%ebp),%edx
80104204:	81 c2 38 02 00 00    	add    $0x238,%edx
8010420a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010420e:	89 14 24             	mov    %edx,(%esp)
80104211:	e8 db 0d 00 00       	call   80104ff1 <sleep>
80104216:	eb 01                	jmp    80104219 <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104218:	90                   	nop
80104219:	8b 45 08             	mov    0x8(%ebp),%eax
8010421c:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104222:	8b 45 08             	mov    0x8(%ebp),%eax
80104225:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010422b:	05 00 02 00 00       	add    $0x200,%eax
80104230:	39 c2                	cmp    %eax,%edx
80104232:	74 8b                	je     801041bf <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104234:	8b 45 08             	mov    0x8(%ebp),%eax
80104237:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010423d:	89 c3                	mov    %eax,%ebx
8010423f:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80104245:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104248:	03 55 0c             	add    0xc(%ebp),%edx
8010424b:	0f b6 0a             	movzbl (%edx),%ecx
8010424e:	8b 55 08             	mov    0x8(%ebp),%edx
80104251:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
80104255:	8d 50 01             	lea    0x1(%eax),%edx
80104258:	8b 45 08             	mov    0x8(%ebp),%eax
8010425b:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104261:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104265:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104268:	3b 45 10             	cmp    0x10(%ebp),%eax
8010426b:	7c ab                	jl     80104218 <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010426d:	8b 45 08             	mov    0x8(%ebp),%eax
80104270:	05 34 02 00 00       	add    $0x234,%eax
80104275:	89 04 24             	mov    %eax,(%esp)
80104278:	e8 50 0e 00 00       	call   801050cd <wakeup>
  release(&p->lock);
8010427d:	8b 45 08             	mov    0x8(%ebp),%eax
80104280:	89 04 24             	mov    %eax,(%esp)
80104283:	e8 b1 10 00 00       	call   80105339 <release>
  return n;
80104288:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010428b:	83 c4 24             	add    $0x24,%esp
8010428e:	5b                   	pop    %ebx
8010428f:	5d                   	pop    %ebp
80104290:	c3                   	ret    

80104291 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104291:	55                   	push   %ebp
80104292:	89 e5                	mov    %esp,%ebp
80104294:	53                   	push   %ebx
80104295:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104298:	8b 45 08             	mov    0x8(%ebp),%eax
8010429b:	89 04 24             	mov    %eax,(%esp)
8010429e:	e8 34 10 00 00       	call   801052d7 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042a3:	eb 3a                	jmp    801042df <piperead+0x4e>
    if(proc->killed){
801042a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042ab:	8b 40 24             	mov    0x24(%eax),%eax
801042ae:	85 c0                	test   %eax,%eax
801042b0:	74 15                	je     801042c7 <piperead+0x36>
      release(&p->lock);
801042b2:	8b 45 08             	mov    0x8(%ebp),%eax
801042b5:	89 04 24             	mov    %eax,(%esp)
801042b8:	e8 7c 10 00 00       	call   80105339 <release>
      return -1;
801042bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042c2:	e9 b6 00 00 00       	jmp    8010437d <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801042c7:	8b 45 08             	mov    0x8(%ebp),%eax
801042ca:	8b 55 08             	mov    0x8(%ebp),%edx
801042cd:	81 c2 34 02 00 00    	add    $0x234,%edx
801042d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801042d7:	89 14 24             	mov    %edx,(%esp)
801042da:	e8 12 0d 00 00       	call   80104ff1 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042df:	8b 45 08             	mov    0x8(%ebp),%eax
801042e2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042e8:	8b 45 08             	mov    0x8(%ebp),%eax
801042eb:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042f1:	39 c2                	cmp    %eax,%edx
801042f3:	75 0d                	jne    80104302 <piperead+0x71>
801042f5:	8b 45 08             	mov    0x8(%ebp),%eax
801042f8:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042fe:	85 c0                	test   %eax,%eax
80104300:	75 a3                	jne    801042a5 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104302:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104309:	eb 49                	jmp    80104354 <piperead+0xc3>
    if(p->nread == p->nwrite)
8010430b:	8b 45 08             	mov    0x8(%ebp),%eax
8010430e:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104314:	8b 45 08             	mov    0x8(%ebp),%eax
80104317:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010431d:	39 c2                	cmp    %eax,%edx
8010431f:	74 3d                	je     8010435e <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104321:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104324:	89 c2                	mov    %eax,%edx
80104326:	03 55 0c             	add    0xc(%ebp),%edx
80104329:	8b 45 08             	mov    0x8(%ebp),%eax
8010432c:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104332:	89 c3                	mov    %eax,%ebx
80104334:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
8010433a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010433d:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
80104342:	88 0a                	mov    %cl,(%edx)
80104344:	8d 50 01             	lea    0x1(%eax),%edx
80104347:	8b 45 08             	mov    0x8(%ebp),%eax
8010434a:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104350:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104354:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104357:	3b 45 10             	cmp    0x10(%ebp),%eax
8010435a:	7c af                	jl     8010430b <piperead+0x7a>
8010435c:	eb 01                	jmp    8010435f <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
8010435e:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010435f:	8b 45 08             	mov    0x8(%ebp),%eax
80104362:	05 38 02 00 00       	add    $0x238,%eax
80104367:	89 04 24             	mov    %eax,(%esp)
8010436a:	e8 5e 0d 00 00       	call   801050cd <wakeup>
  release(&p->lock);
8010436f:	8b 45 08             	mov    0x8(%ebp),%eax
80104372:	89 04 24             	mov    %eax,(%esp)
80104375:	e8 bf 0f 00 00       	call   80105339 <release>
  return i;
8010437a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010437d:	83 c4 24             	add    $0x24,%esp
80104380:	5b                   	pop    %ebx
80104381:	5d                   	pop    %ebp
80104382:	c3                   	ret    
	...

80104384 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104384:	55                   	push   %ebp
80104385:	89 e5                	mov    %esp,%ebp
80104387:	53                   	push   %ebx
80104388:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010438b:	9c                   	pushf  
8010438c:	5b                   	pop    %ebx
8010438d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104390:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104393:	83 c4 10             	add    $0x10,%esp
80104396:	5b                   	pop    %ebx
80104397:	5d                   	pop    %ebp
80104398:	c3                   	ret    

80104399 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104399:	55                   	push   %ebp
8010439a:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010439c:	fb                   	sti    
}
8010439d:	5d                   	pop    %ebp
8010439e:	c3                   	ret    

8010439f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010439f:	55                   	push   %ebp
801043a0:	89 e5                	mov    %esp,%ebp
801043a2:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
801043a5:	c7 44 24 04 b0 8c 10 	movl   $0x80108cb0,0x4(%esp)
801043ac:	80 
801043ad:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
801043b4:	e8 fd 0e 00 00       	call   801052b6 <initlock>
  initlock(&jtable.lock, "jtable");
801043b9:	c7 44 24 04 b7 8c 10 	movl   $0x80108cb7,0x4(%esp)
801043c0:	80 
801043c1:	c7 04 24 60 39 11 80 	movl   $0x80113960,(%esp)
801043c8:	e8 e9 0e 00 00       	call   801052b6 <initlock>
}
801043cd:	c9                   	leave  
801043ce:	c3                   	ret    

801043cf <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801043cf:	55                   	push   %ebp
801043d0:	89 e5                	mov    %esp,%ebp
801043d2:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801043d5:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
801043dc:	e8 f6 0e 00 00       	call   801052d7 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043e1:	c7 45 f4 d4 3c 11 80 	movl   $0x80113cd4,-0xc(%ebp)
801043e8:	eb 11                	jmp    801043fb <allocproc+0x2c>
    if(p->state == UNUSED)
801043ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ed:	8b 40 0c             	mov    0xc(%eax),%eax
801043f0:	85 c0                	test   %eax,%eax
801043f2:	74 26                	je     8010441a <allocproc+0x4b>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043f4:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801043fb:	81 7d f4 d4 5d 11 80 	cmpl   $0x80115dd4,-0xc(%ebp)
80104402:	72 e6                	jb     801043ea <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104404:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
8010440b:	e8 29 0f 00 00       	call   80105339 <release>
  return 0;
80104410:	b8 00 00 00 00       	mov    $0x0,%eax
80104415:	e9 b5 00 00 00       	jmp    801044cf <allocproc+0x100>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
8010441a:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010441b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441e:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104425:	a1 04 c0 10 80       	mov    0x8010c004,%eax
8010442a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010442d:	89 42 10             	mov    %eax,0x10(%edx)
80104430:	83 c0 01             	add    $0x1,%eax
80104433:	a3 04 c0 10 80       	mov    %eax,0x8010c004
  release(&ptable.lock);
80104438:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
8010443f:	e8 f5 0e 00 00       	call   80105339 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104444:	e8 fe e6 ff ff       	call   80102b47 <kalloc>
80104449:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010444c:	89 42 08             	mov    %eax,0x8(%edx)
8010444f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104452:	8b 40 08             	mov    0x8(%eax),%eax
80104455:	85 c0                	test   %eax,%eax
80104457:	75 11                	jne    8010446a <allocproc+0x9b>
    p->state = UNUSED;
80104459:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104463:	b8 00 00 00 00       	mov    $0x0,%eax
80104468:	eb 65                	jmp    801044cf <allocproc+0x100>
  }
  sp = p->kstack + KSTACKSIZE;
8010446a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446d:	8b 40 08             	mov    0x8(%eax),%eax
80104470:	05 00 10 00 00       	add    $0x1000,%eax
80104475:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104478:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010447c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104482:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104485:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104489:	ba 48 6a 10 80       	mov    $0x80106a48,%edx
8010448e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104491:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104493:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104497:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010449a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010449d:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801044a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a3:	8b 40 1c             	mov    0x1c(%eax),%eax
801044a6:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801044ad:	00 
801044ae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801044b5:	00 
801044b6:	89 04 24             	mov    %eax,(%esp)
801044b9:	e8 68 10 00 00       	call   80105526 <memset>
  p->context->eip = (uint)forkret;
801044be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c1:	8b 40 1c             	mov    0x1c(%eax),%eax
801044c4:	ba c5 4f 10 80       	mov    $0x80104fc5,%edx
801044c9:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801044cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801044cf:	c9                   	leave  
801044d0:	c3                   	ret    

801044d1 <allocjob>:

static struct job*
allocjob(void)
{
801044d1:	55                   	push   %ebp
801044d2:	89 e5                	mov    %esp,%ebp
801044d4:	83 ec 28             	sub    $0x28,%esp
  struct job *j;
  
  acquire(&jtable.lock);
801044d7:	c7 04 24 60 39 11 80 	movl   $0x80113960,(%esp)
801044de:	e8 f4 0d 00 00       	call   801052d7 <acquire>
  for(j = jtable.jobs; j < &jtable.jobs[NPROC]; j++)
801044e3:	c7 45 f4 94 39 11 80 	movl   $0x80113994,-0xc(%ebp)
801044ea:	eb 0e                	jmp    801044fa <allocjob+0x29>
    if(j->state == JOB_S_UNUSED)
801044ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ef:	8b 40 08             	mov    0x8(%eax),%eax
801044f2:	85 c0                	test   %eax,%eax
801044f4:	74 20                	je     80104516 <allocjob+0x45>
allocjob(void)
{
  struct job *j;
  
  acquire(&jtable.lock);
  for(j = jtable.jobs; j < &jtable.jobs[NPROC]; j++)
801044f6:	83 45 f4 0c          	addl   $0xc,-0xc(%ebp)
801044fa:	81 7d f4 94 3c 11 80 	cmpl   $0x80113c94,-0xc(%ebp)
80104501:	72 e9                	jb     801044ec <allocjob+0x1b>
    if(j->state == JOB_S_UNUSED)
      goto found;
  release(&jtable.lock);
80104503:	c7 04 24 60 39 11 80 	movl   $0x80113960,(%esp)
8010450a:	e8 2a 0e 00 00       	call   80105339 <release>
  return 0;
8010450f:	b8 00 00 00 00       	mov    $0x0,%eax
80104514:	eb 2d                	jmp    80104543 <allocjob+0x72>
  struct job *j;
  
  acquire(&jtable.lock);
  for(j = jtable.jobs; j < &jtable.jobs[NPROC]; j++)
    if(j->state == JOB_S_UNUSED)
      goto found;
80104516:	90                   	nop
  release(&jtable.lock);
  return 0;

found:
  j->state = JOB_S_EMBRYO;
80104517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  j->jid = nextjid++;
80104521:	a1 08 c0 10 80       	mov    0x8010c008,%eax
80104526:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104529:	89 42 04             	mov    %eax,0x4(%edx)
8010452c:	83 c0 01             	add    $0x1,%eax
8010452f:	a3 08 c0 10 80       	mov    %eax,0x8010c008
  release(&jtable.lock);
80104534:	c7 04 24 60 39 11 80 	movl   $0x80113960,(%esp)
8010453b:	e8 f9 0d 00 00       	call   80105339 <release>
  
  return j;
80104540:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104543:	c9                   	leave  
80104544:	c3                   	ret    

80104545 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104545:	55                   	push   %ebp
80104546:	89 e5                	mov    %esp,%ebp
80104548:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
8010454b:	e8 7f fe ff ff       	call   801043cf <allocproc>
80104550:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104556:	a3 48 c6 10 80       	mov    %eax,0x8010c648
  if((p->pgdir = setupkvm()) == 0)
8010455b:	e8 01 3c 00 00       	call   80108161 <setupkvm>
80104560:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104563:	89 42 04             	mov    %eax,0x4(%edx)
80104566:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104569:	8b 40 04             	mov    0x4(%eax),%eax
8010456c:	85 c0                	test   %eax,%eax
8010456e:	75 0c                	jne    8010457c <userinit+0x37>
    panic("userinit: out of memory?");
80104570:	c7 04 24 be 8c 10 80 	movl   $0x80108cbe,(%esp)
80104577:	e8 c1 bf ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010457c:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104581:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104584:	8b 40 04             	mov    0x4(%eax),%eax
80104587:	89 54 24 08          	mov    %edx,0x8(%esp)
8010458b:	c7 44 24 04 e0 c4 10 	movl   $0x8010c4e0,0x4(%esp)
80104592:	80 
80104593:	89 04 24             	mov    %eax,(%esp)
80104596:	e8 1e 3e 00 00       	call   801083b9 <inituvm>
  p->sz = PGSIZE;
8010459b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459e:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801045a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a7:	8b 40 18             	mov    0x18(%eax),%eax
801045aa:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801045b1:	00 
801045b2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801045b9:	00 
801045ba:	89 04 24             	mov    %eax,(%esp)
801045bd:	e8 64 0f 00 00       	call   80105526 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801045c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c5:	8b 40 18             	mov    0x18(%eax),%eax
801045c8:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801045ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d1:	8b 40 18             	mov    0x18(%eax),%eax
801045d4:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
801045da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045dd:	8b 40 18             	mov    0x18(%eax),%eax
801045e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045e3:	8b 52 18             	mov    0x18(%edx),%edx
801045e6:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801045ea:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801045ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f1:	8b 40 18             	mov    0x18(%eax),%eax
801045f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045f7:	8b 52 18             	mov    0x18(%edx),%edx
801045fa:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801045fe:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104605:	8b 40 18             	mov    0x18(%eax),%eax
80104608:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010460f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104612:	8b 40 18             	mov    0x18(%eax),%eax
80104615:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010461c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461f:	8b 40 18             	mov    0x18(%eax),%eax
80104622:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104629:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462c:	83 c0 6c             	add    $0x6c,%eax
8010462f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104636:	00 
80104637:	c7 44 24 04 d7 8c 10 	movl   $0x80108cd7,0x4(%esp)
8010463e:	80 
8010463f:	89 04 24             	mov    %eax,(%esp)
80104642:	e8 0f 11 00 00       	call   80105756 <safestrcpy>
  p->cwd = namei("/");
80104647:	c7 04 24 e0 8c 10 80 	movl   $0x80108ce0,(%esp)
8010464e:	e8 ff dd ff ff       	call   80102452 <namei>
80104653:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104656:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
80104659:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104663:	c9                   	leave  
80104664:	c3                   	ret    

80104665 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104665:	55                   	push   %ebp
80104666:	89 e5                	mov    %esp,%ebp
80104668:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
8010466b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104671:	8b 00                	mov    (%eax),%eax
80104673:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104676:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010467a:	7e 34                	jle    801046b0 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
8010467c:	8b 45 08             	mov    0x8(%ebp),%eax
8010467f:	89 c2                	mov    %eax,%edx
80104681:	03 55 f4             	add    -0xc(%ebp),%edx
80104684:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010468a:	8b 40 04             	mov    0x4(%eax),%eax
8010468d:	89 54 24 08          	mov    %edx,0x8(%esp)
80104691:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104694:	89 54 24 04          	mov    %edx,0x4(%esp)
80104698:	89 04 24             	mov    %eax,(%esp)
8010469b:	e8 93 3e 00 00       	call   80108533 <allocuvm>
801046a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801046a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801046a7:	75 41                	jne    801046ea <growproc+0x85>
      return -1;
801046a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046ae:	eb 58                	jmp    80104708 <growproc+0xa3>
  } else if(n < 0){
801046b0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046b4:	79 34                	jns    801046ea <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801046b6:	8b 45 08             	mov    0x8(%ebp),%eax
801046b9:	89 c2                	mov    %eax,%edx
801046bb:	03 55 f4             	add    -0xc(%ebp),%edx
801046be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046c4:	8b 40 04             	mov    0x4(%eax),%eax
801046c7:	89 54 24 08          	mov    %edx,0x8(%esp)
801046cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046ce:	89 54 24 04          	mov    %edx,0x4(%esp)
801046d2:	89 04 24             	mov    %eax,(%esp)
801046d5:	e8 33 3f 00 00       	call   8010860d <deallocuvm>
801046da:	89 45 f4             	mov    %eax,-0xc(%ebp)
801046dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801046e1:	75 07                	jne    801046ea <growproc+0x85>
      return -1;
801046e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046e8:	eb 1e                	jmp    80104708 <growproc+0xa3>
  }
  proc->sz = sz;
801046ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046f3:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
801046f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046fb:	89 04 24             	mov    %eax,(%esp)
801046fe:	e8 4f 3b 00 00       	call   80108252 <switchuvm>
  return 0;
80104703:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104708:	c9                   	leave  
80104709:	c3                   	ret    

8010470a <createJob>:

int
createJob(char *command) {
8010470a:	55                   	push   %ebp
8010470b:	89 e5                	mov    %esp,%ebp
8010470d:	83 ec 18             	sub    $0x18,%esp
  struct job *nj;
    
  // Allocate job.
  if((nj = allocjob()) == 0)
80104710:	e8 bc fd ff ff       	call   801044d1 <allocjob>
80104715:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104718:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010471c:	75 07                	jne    80104725 <createJob+0x1b>
    return -1;
8010471e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104723:	eb 26                	jmp    8010474b <createJob+0x41>
  
  proc->job = nj;
80104725:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010472b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010472e:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  proc->job->commandName = command;
80104734:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010473a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104740:	8b 55 08             	mov    0x8(%ebp),%edx
80104743:	89 10                	mov    %edx,(%eax)
  
  return nj->jid;
80104745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104748:	8b 40 04             	mov    0x4(%eax),%eax
}
8010474b:	c9                   	leave  
8010474c:	c3                   	ret    

8010474d <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010474d:	55                   	push   %ebp
8010474e:	89 e5                	mov    %esp,%ebp
80104750:	57                   	push   %edi
80104751:	56                   	push   %esi
80104752:	53                   	push   %ebx
80104753:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104756:	e8 74 fc ff ff       	call   801043cf <allocproc>
8010475b:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010475e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104762:	75 0a                	jne    8010476e <fork+0x21>
    return -1;
80104764:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104769:	e9 91 01 00 00       	jmp    801048ff <fork+0x1b2>
  
  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010476e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104774:	8b 10                	mov    (%eax),%edx
80104776:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010477c:	8b 40 04             	mov    0x4(%eax),%eax
8010477f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104783:	89 04 24             	mov    %eax,(%esp)
80104786:	e8 12 40 00 00       	call   8010879d <copyuvm>
8010478b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010478e:	89 42 04             	mov    %eax,0x4(%edx)
80104791:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104794:	8b 40 04             	mov    0x4(%eax),%eax
80104797:	85 c0                	test   %eax,%eax
80104799:	75 2c                	jne    801047c7 <fork+0x7a>
    kfree(np->kstack);
8010479b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010479e:	8b 40 08             	mov    0x8(%eax),%eax
801047a1:	89 04 24             	mov    %eax,(%esp)
801047a4:	e8 05 e3 ff ff       	call   80102aae <kfree>
    np->kstack = 0;
801047a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ac:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801047b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047b6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801047bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047c2:	e9 38 01 00 00       	jmp    801048ff <fork+0x1b2>
  }
  
  if (proc->job == NULL && proc->pid >= SHELL_ID) {
801047c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047cd:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801047d3:	85 c0                	test   %eax,%eax
801047d5:	75 1a                	jne    801047f1 <fork+0xa4>
801047d7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047dd:	8b 40 10             	mov    0x10(%eax),%eax
801047e0:	83 f8 01             	cmp    $0x1,%eax
801047e3:	7e 0c                	jle    801047f1 <fork+0xa4>
      cprintf("Error - Forking new process from a process which don't have a job!.\n");
801047e5:	c7 04 24 e4 8c 10 80 	movl   $0x80108ce4,(%esp)
801047ec:	e8 b0 bb ff ff       	call   801003a1 <cprintf>
  }
  
  np->job = proc->job;
801047f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047f7:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801047fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104800:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
    
  np->sz = proc->sz;
80104806:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010480c:	8b 10                	mov    (%eax),%edx
8010480e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104811:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104813:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010481a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010481d:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104820:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104823:	8b 50 18             	mov    0x18(%eax),%edx
80104826:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010482c:	8b 40 18             	mov    0x18(%eax),%eax
8010482f:	89 c3                	mov    %eax,%ebx
80104831:	b8 13 00 00 00       	mov    $0x13,%eax
80104836:	89 d7                	mov    %edx,%edi
80104838:	89 de                	mov    %ebx,%esi
8010483a:	89 c1                	mov    %eax,%ecx
8010483c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  
  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010483e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104841:	8b 40 18             	mov    0x18(%eax),%eax
80104844:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010484b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104852:	eb 3d                	jmp    80104891 <fork+0x144>
    if(proc->ofile[i])
80104854:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010485a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010485d:	83 c2 08             	add    $0x8,%edx
80104860:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104864:	85 c0                	test   %eax,%eax
80104866:	74 25                	je     8010488d <fork+0x140>
      np->ofile[i] = filedup(proc->ofile[i]);
80104868:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010486e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104871:	83 c2 08             	add    $0x8,%edx
80104874:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104878:	89 04 24             	mov    %eax,(%esp)
8010487b:	e8 44 c7 ff ff       	call   80100fc4 <filedup>
80104880:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104883:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104886:	83 c1 08             	add    $0x8,%ecx
80104889:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;
  
  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010488d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104891:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104895:	7e bd                	jle    80104854 <fork+0x107>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104897:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010489d:	8b 40 68             	mov    0x68(%eax),%eax
801048a0:	89 04 24             	mov    %eax,(%esp)
801048a3:	e8 d6 cf ff ff       	call   8010187e <idup>
801048a8:	8b 55 e0             	mov    -0x20(%ebp),%edx
801048ab:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801048ae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048b4:	8d 50 6c             	lea    0x6c(%eax),%edx
801048b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048ba:	83 c0 6c             	add    $0x6c,%eax
801048bd:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801048c4:	00 
801048c5:	89 54 24 04          	mov    %edx,0x4(%esp)
801048c9:	89 04 24             	mov    %eax,(%esp)
801048cc:	e8 85 0e 00 00       	call   80105756 <safestrcpy>

  pid = np->pid;
801048d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048d4:	8b 40 10             	mov    0x10(%eax),%eax
801048d7:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801048da:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
801048e1:	e8 f1 09 00 00       	call   801052d7 <acquire>
  np->state = RUNNABLE;
801048e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048e9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801048f0:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
801048f7:	e8 3d 0a 00 00       	call   80105339 <release>
  
  return pid;
801048fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801048ff:	83 c4 2c             	add    $0x2c,%esp
80104902:	5b                   	pop    %ebx
80104903:	5e                   	pop    %esi
80104904:	5f                   	pop    %edi
80104905:	5d                   	pop    %ebp
80104906:	c3                   	ret    

80104907 <forkjob>:

// Same as fork, but creates a new job.
int
forkjob(char *command)
{
80104907:	55                   	push   %ebp
80104908:	89 e5                	mov    %esp,%ebp
8010490a:	57                   	push   %edi
8010490b:	56                   	push   %esi
8010490c:	53                   	push   %ebx
8010490d:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104910:	e8 ba fa ff ff       	call   801043cf <allocproc>
80104915:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104918:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010491c:	75 0a                	jne    80104928 <forkjob+0x21>
    return -1;
8010491e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104923:	e9 6d 01 00 00       	jmp    80104a95 <forkjob+0x18e>
  
  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104928:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010492e:	8b 10                	mov    (%eax),%edx
80104930:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104936:	8b 40 04             	mov    0x4(%eax),%eax
80104939:	89 54 24 04          	mov    %edx,0x4(%esp)
8010493d:	89 04 24             	mov    %eax,(%esp)
80104940:	e8 58 3e 00 00       	call   8010879d <copyuvm>
80104945:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104948:	89 42 04             	mov    %eax,0x4(%edx)
8010494b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010494e:	8b 40 04             	mov    0x4(%eax),%eax
80104951:	85 c0                	test   %eax,%eax
80104953:	75 2c                	jne    80104981 <forkjob+0x7a>
    kfree(np->kstack);
80104955:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104958:	8b 40 08             	mov    0x8(%eax),%eax
8010495b:	89 04 24             	mov    %eax,(%esp)
8010495e:	e8 4b e1 ff ff       	call   80102aae <kfree>
    np->kstack = 0;
80104963:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104966:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
8010496d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104970:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104977:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010497c:	e9 14 01 00 00       	jmp    80104a95 <forkjob+0x18e>
  }
  
  // Create a new job.
  if (createJob(command) < 0) {
80104981:	8b 45 08             	mov    0x8(%ebp),%eax
80104984:	89 04 24             	mov    %eax,(%esp)
80104987:	e8 7e fd ff ff       	call   8010470a <createJob>
8010498c:	85 c0                	test   %eax,%eax
8010498e:	79 0c                	jns    8010499c <forkjob+0x95>
    panic("Failed creating a job");
80104990:	c7 04 24 29 8d 10 80 	movl   $0x80108d29,(%esp)
80104997:	e8 a1 bb ff ff       	call   8010053d <panic>
  }

  
  np->sz = proc->sz;
8010499c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049a2:	8b 10                	mov    (%eax),%edx
801049a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049a7:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801049a9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801049b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049b3:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801049b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049b9:	8b 50 18             	mov    0x18(%eax),%edx
801049bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049c2:	8b 40 18             	mov    0x18(%eax),%eax
801049c5:	89 c3                	mov    %eax,%ebx
801049c7:	b8 13 00 00 00       	mov    $0x13,%eax
801049cc:	89 d7                	mov    %edx,%edi
801049ce:	89 de                	mov    %ebx,%esi
801049d0:	89 c1                	mov    %eax,%ecx
801049d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  
  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801049d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049d7:	8b 40 18             	mov    0x18(%eax),%eax
801049da:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801049e1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801049e8:	eb 3d                	jmp    80104a27 <forkjob+0x120>
    if(proc->ofile[i])
801049ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801049f3:	83 c2 08             	add    $0x8,%edx
801049f6:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049fa:	85 c0                	test   %eax,%eax
801049fc:	74 25                	je     80104a23 <forkjob+0x11c>
      np->ofile[i] = filedup(proc->ofile[i]);
801049fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a04:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104a07:	83 c2 08             	add    $0x8,%edx
80104a0a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a0e:	89 04 24             	mov    %eax,(%esp)
80104a11:	e8 ae c5 ff ff       	call   80100fc4 <filedup>
80104a16:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104a19:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104a1c:	83 c1 08             	add    $0x8,%ecx
80104a1f:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;
  
  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104a23:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104a27:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104a2b:	7e bd                	jle    801049ea <forkjob+0xe3>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104a2d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a33:	8b 40 68             	mov    0x68(%eax),%eax
80104a36:	89 04 24             	mov    %eax,(%esp)
80104a39:	e8 40 ce ff ff       	call   8010187e <idup>
80104a3e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104a41:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104a44:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a4a:	8d 50 6c             	lea    0x6c(%eax),%edx
80104a4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a50:	83 c0 6c             	add    $0x6c,%eax
80104a53:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104a5a:	00 
80104a5b:	89 54 24 04          	mov    %edx,0x4(%esp)
80104a5f:	89 04 24             	mov    %eax,(%esp)
80104a62:	e8 ef 0c 00 00       	call   80105756 <safestrcpy>

  pid = np->pid;
80104a67:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a6a:	8b 40 10             	mov    0x10(%eax),%eax
80104a6d:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104a70:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
80104a77:	e8 5b 08 00 00       	call   801052d7 <acquire>
  np->state = RUNNABLE;
80104a7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a7f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80104a86:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
80104a8d:	e8 a7 08 00 00       	call   80105339 <release>
  
  return pid;
80104a92:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104a95:	83 c4 2c             	add    $0x2c,%esp
80104a98:	5b                   	pop    %ebx
80104a99:	5e                   	pop    %esi
80104a9a:	5f                   	pop    %edi
80104a9b:	5d                   	pop    %ebp
80104a9c:	c3                   	ret    

80104a9d <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(int status)
{
80104a9d:	55                   	push   %ebp
80104a9e:	89 e5                	mov    %esp,%ebp
80104aa0:	83 ec 28             	sub    $0x28,%esp
  //cprintf("enterted: exit, %d\n", status);
  struct proc *p;
  int fd;
  
  if(proc == initproc)
80104aa3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104aaa:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80104aaf:	39 c2                	cmp    %eax,%edx
80104ab1:	75 0c                	jne    80104abf <exit+0x22>
    panic("init exiting");
80104ab3:	c7 04 24 3f 8d 10 80 	movl   $0x80108d3f,(%esp)
80104aba:	e8 7e ba ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104abf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104ac6:	eb 44                	jmp    80104b0c <exit+0x6f>
    if(proc->ofile[fd]){
80104ac8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ace:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ad1:	83 c2 08             	add    $0x8,%edx
80104ad4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104ad8:	85 c0                	test   %eax,%eax
80104ada:	74 2c                	je     80104b08 <exit+0x6b>
      fileclose(proc->ofile[fd]);
80104adc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ae2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ae5:	83 c2 08             	add    $0x8,%edx
80104ae8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104aec:	89 04 24             	mov    %eax,(%esp)
80104aef:	e8 18 c5 ff ff       	call   8010100c <fileclose>
      proc->ofile[fd] = 0;
80104af4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104afa:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104afd:	83 c2 08             	add    $0x8,%edx
80104b00:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104b07:	00 
  
  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104b08:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104b0c:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104b10:	7e b6                	jle    80104ac8 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }
  
  proc->exitStatus = status;
80104b12:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b18:	8b 55 08             	mov    0x8(%ebp),%edx
80104b1b:	89 50 7c             	mov    %edx,0x7c(%eax)

  begin_op();
80104b1e:	e8 7a e9 ff ff       	call   8010349d <begin_op>
  iput(proc->cwd);
80104b23:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b29:	8b 40 68             	mov    0x68(%eax),%eax
80104b2c:	89 04 24             	mov    %eax,(%esp)
80104b2f:	e8 2f cf ff ff       	call   80101a63 <iput>
  end_op();
80104b34:	e8 e5 e9 ff ff       	call   8010351e <end_op>
  proc->cwd = 0;
80104b39:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b3f:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104b46:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
80104b4d:	e8 85 07 00 00       	call   801052d7 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104b52:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b58:	8b 40 14             	mov    0x14(%eax),%eax
80104b5b:	89 04 24             	mov    %eax,(%esp)
80104b5e:	e8 29 05 00 00       	call   8010508c <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b63:	c7 45 f4 d4 3c 11 80 	movl   $0x80113cd4,-0xc(%ebp)
80104b6a:	eb 3b                	jmp    80104ba7 <exit+0x10a>
    if(p->parent == proc){
80104b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b6f:	8b 50 14             	mov    0x14(%eax),%edx
80104b72:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b78:	39 c2                	cmp    %eax,%edx
80104b7a:	75 24                	jne    80104ba0 <exit+0x103>
      p->parent = initproc;
80104b7c:	8b 15 48 c6 10 80    	mov    0x8010c648,%edx
80104b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b85:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b8b:	8b 40 0c             	mov    0xc(%eax),%eax
80104b8e:	83 f8 05             	cmp    $0x5,%eax
80104b91:	75 0d                	jne    80104ba0 <exit+0x103>
        wakeup1(initproc);
80104b93:	a1 48 c6 10 80       	mov    0x8010c648,%eax
80104b98:	89 04 24             	mov    %eax,(%esp)
80104b9b:	e8 ec 04 00 00       	call   8010508c <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ba0:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104ba7:	81 7d f4 d4 5d 11 80 	cmpl   $0x80115dd4,-0xc(%ebp)
80104bae:	72 bc                	jb     80104b6c <exit+0xcf>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104bb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bb6:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104bbd:	e8 1f 03 00 00       	call   80104ee1 <sched>
  panic("zombie exit");
80104bc2:	c7 04 24 4c 8d 10 80 	movl   $0x80108d4c,(%esp)
80104bc9:	e8 6f b9 ff ff       	call   8010053d <panic>

80104bce <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(int *status)
{
80104bce:	55                   	push   %ebp
80104bcf:	89 e5                	mov    %esp,%ebp
80104bd1:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104bd4:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
80104bdb:	e8 f7 06 00 00       	call   801052d7 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104be0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104be7:	c7 45 f4 d4 3c 11 80 	movl   $0x80113cd4,-0xc(%ebp)
80104bee:	e9 bd 00 00 00       	jmp    80104cb0 <wait+0xe2>
      if(p->parent != proc)
80104bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf6:	8b 50 14             	mov    0x14(%eax),%edx
80104bf9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bff:	39 c2                	cmp    %eax,%edx
80104c01:	0f 85 a1 00 00 00    	jne    80104ca8 <wait+0xda>
        continue;
      havekids = 1;
80104c07:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c11:	8b 40 0c             	mov    0xc(%eax),%eax
80104c14:	83 f8 05             	cmp    $0x5,%eax
80104c17:	0f 85 8c 00 00 00    	jne    80104ca9 <wait+0xdb>
        // Found one.
        pid = p->pid;
80104c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c20:	8b 40 10             	mov    0x10(%eax),%eax
80104c23:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	if (status != NULL) {
80104c26:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104c2a:	74 0d                	je     80104c39 <wait+0x6b>
	   *status = p->exitStatus;
80104c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c2f:	8b 50 7c             	mov    0x7c(%eax),%edx
80104c32:	8b 45 08             	mov    0x8(%ebp),%eax
80104c35:	89 10                	mov    %edx,(%eax)
80104c37:	eb 09                	jmp    80104c42 <wait+0x74>
	} else {
	  *status = -2;
80104c39:	8b 45 08             	mov    0x8(%ebp),%eax
80104c3c:	c7 00 fe ff ff ff    	movl   $0xfffffffe,(%eax)
	}
	
        kfree(p->kstack);
80104c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c45:	8b 40 08             	mov    0x8(%eax),%eax
80104c48:	89 04 24             	mov    %eax,(%esp)
80104c4b:	e8 5e de ff ff       	call   80102aae <kfree>
        p->kstack = 0;
80104c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c53:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c5d:	8b 40 04             	mov    0x4(%eax),%eax
80104c60:	89 04 24             	mov    %eax,(%esp)
80104c63:	e8 61 3a 00 00       	call   801086c9 <freevm>
        p->state = UNUSED;
80104c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c6b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c75:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104c7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c7f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c89:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c90:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104c97:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
80104c9e:	e8 96 06 00 00       	call   80105339 <release>
	
        return pid;
80104ca3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ca6:	eb 56                	jmp    80104cfe <wait+0x130>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104ca8:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ca9:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104cb0:	81 7d f4 d4 5d 11 80 	cmpl   $0x80115dd4,-0xc(%ebp)
80104cb7:	0f 82 36 ff ff ff    	jb     80104bf3 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104cbd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104cc1:	74 0d                	je     80104cd0 <wait+0x102>
80104cc3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cc9:	8b 40 24             	mov    0x24(%eax),%eax
80104ccc:	85 c0                	test   %eax,%eax
80104cce:	74 13                	je     80104ce3 <wait+0x115>
      release(&ptable.lock);
80104cd0:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
80104cd7:	e8 5d 06 00 00       	call   80105339 <release>
      return -1;
80104cdc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ce1:	eb 1b                	jmp    80104cfe <wait+0x130>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104ce3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ce9:	c7 44 24 04 a0 3c 11 	movl   $0x80113ca0,0x4(%esp)
80104cf0:	80 
80104cf1:	89 04 24             	mov    %eax,(%esp)
80104cf4:	e8 f8 02 00 00       	call   80104ff1 <sleep>
  }
80104cf9:	e9 e2 fe ff ff       	jmp    80104be0 <wait+0x12>
}
80104cfe:	c9                   	leave  
80104cff:	c3                   	ret    

80104d00 <waitpid>:
// if BLOCKING - Wait for a process with id: pid to exit and return its status.
// if BLOCKING - return its status or -1.
// Return -1 if this process has no children.
int 
waitpid(int pid, int *status, int options)
{
80104d00:	55                   	push   %ebp
80104d01:	89 e5                	mov    %esp,%ebp
80104d03:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int is_exists = 0;
80104d06:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  acquire(&ptable.lock);
80104d0d:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
80104d14:	e8 be 05 00 00       	call   801052d7 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d19:	c7 45 f4 d4 3c 11 80 	movl   $0x80113cd4,-0xc(%ebp)
80104d20:	e9 d0 00 00 00       	jmp    80104df5 <waitpid+0xf5>
      if (p-> pid == pid) {
80104d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d28:	8b 40 10             	mov    0x10(%eax),%eax
80104d2b:	3b 45 08             	cmp    0x8(%ebp),%eax
80104d2e:	0f 85 ba 00 00 00    	jne    80104dee <waitpid+0xee>
	is_exists = 1;
80104d34:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	
	if(p->state == ZOMBIE){
80104d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d3e:	8b 40 0c             	mov    0xc(%eax),%eax
80104d41:	83 f8 05             	cmp    $0x5,%eax
80104d44:	0f 85 8b 00 00 00    	jne    80104dd5 <waitpid+0xd5>
	  // Found one.
	  pid = p->pid;
80104d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d4d:	8b 40 10             	mov    0x10(%eax),%eax
80104d50:	89 45 08             	mov    %eax,0x8(%ebp)
	
	  if (status != NULL) {
80104d53:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104d57:	74 0d                	je     80104d66 <waitpid+0x66>
	    *status = p->exitStatus;
80104d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d5c:	8b 50 7c             	mov    0x7c(%eax),%edx
80104d5f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d62:	89 10                	mov    %edx,(%eax)
80104d64:	eb 09                	jmp    80104d6f <waitpid+0x6f>
	  } else {
	    *status = -2;
80104d66:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d69:	c7 00 fe ff ff ff    	movl   $0xfffffffe,(%eax)
	  }
	  
	  kfree(p->kstack);
80104d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d72:	8b 40 08             	mov    0x8(%eax),%eax
80104d75:	89 04 24             	mov    %eax,(%esp)
80104d78:	e8 31 dd ff ff       	call   80102aae <kfree>
	  p->kstack = 0;
80104d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d80:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	  freevm(p->pgdir);
80104d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d8a:	8b 40 04             	mov    0x4(%eax),%eax
80104d8d:	89 04 24             	mov    %eax,(%esp)
80104d90:	e8 34 39 00 00       	call   801086c9 <freevm>
	  p->state = UNUSED;
80104d95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d98:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	  p->pid = 0;
80104d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104da2:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
	  p->parent = 0;
80104da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dac:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
	  p->name[0] = 0;
80104db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104db6:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
	  p->killed = 0;
80104dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dbd:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
	  release(&ptable.lock);
80104dc4:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
80104dcb:	e8 69 05 00 00       	call   80105339 <release>
	  
	  return pid;
80104dd0:	8b 45 08             	mov    0x8(%ebp),%eax
80104dd3:	eb 6e                	jmp    80104e43 <waitpid+0x143>
	}
	
	if (options == NON_BLOCKING) {
80104dd5:	83 7d 10 65          	cmpl   $0x65,0x10(%ebp)
80104dd9:	75 13                	jne    80104dee <waitpid+0xee>
	  release(&ptable.lock);
80104ddb:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
80104de2:	e8 52 05 00 00       	call   80105339 <release>
	  return -1;
80104de7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dec:	eb 55                	jmp    80104e43 <waitpid+0x143>
  int is_exists = 0;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dee:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104df5:	81 7d f4 d4 5d 11 80 	cmpl   $0x80115dd4,-0xc(%ebp)
80104dfc:	0f 82 23 ff ff ff    	jb     80104d25 <waitpid+0x25>
      
      
    }

    // No point waiting if we don't have any children.
    if(!is_exists || proc->killed){
80104e02:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104e06:	74 0d                	je     80104e15 <waitpid+0x115>
80104e08:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e0e:	8b 40 24             	mov    0x24(%eax),%eax
80104e11:	85 c0                	test   %eax,%eax
80104e13:	74 13                	je     80104e28 <waitpid+0x128>
      release(&ptable.lock);
80104e15:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
80104e1c:	e8 18 05 00 00       	call   80105339 <release>
      return -1;
80104e21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e26:	eb 1b                	jmp    80104e43 <waitpid+0x143>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104e28:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e2e:	c7 44 24 04 a0 3c 11 	movl   $0x80113ca0,0x4(%esp)
80104e35:	80 
80104e36:	89 04 24             	mov    %eax,(%esp)
80104e39:	e8 b3 01 00 00       	call   80104ff1 <sleep>
  }
80104e3e:	e9 d6 fe ff ff       	jmp    80104d19 <waitpid+0x19>
}
80104e43:	c9                   	leave  
80104e44:	c3                   	ret    

80104e45 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104e45:	55                   	push   %ebp
80104e46:	89 e5                	mov    %esp,%ebp
80104e48:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104e4b:	e8 49 f5 ff ff       	call   80104399 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104e50:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
80104e57:	e8 7b 04 00 00       	call   801052d7 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e5c:	c7 45 f4 d4 3c 11 80 	movl   $0x80113cd4,-0xc(%ebp)
80104e63:	eb 62                	jmp    80104ec7 <scheduler+0x82>
      if(p->state != RUNNABLE)
80104e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e68:	8b 40 0c             	mov    0xc(%eax),%eax
80104e6b:	83 f8 03             	cmp    $0x3,%eax
80104e6e:	75 4f                	jne    80104ebf <scheduler+0x7a>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e73:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e7c:	89 04 24             	mov    %eax,(%esp)
80104e7f:	e8 ce 33 00 00       	call   80108252 <switchuvm>
      p->state = RUNNING;
80104e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e87:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104e8e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e94:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e97:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104e9e:	83 c2 04             	add    $0x4,%edx
80104ea1:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ea5:	89 14 24             	mov    %edx,(%esp)
80104ea8:	e8 1f 09 00 00       	call   801057cc <swtch>
      switchkvm();
80104ead:	e8 83 33 00 00       	call   80108235 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104eb2:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104eb9:	00 00 00 00 
80104ebd:	eb 01                	jmp    80104ec0 <scheduler+0x7b>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104ebf:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ec0:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104ec7:	81 7d f4 d4 5d 11 80 	cmpl   $0x80115dd4,-0xc(%ebp)
80104ece:	72 95                	jb     80104e65 <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104ed0:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
80104ed7:	e8 5d 04 00 00       	call   80105339 <release>

  }
80104edc:	e9 6a ff ff ff       	jmp    80104e4b <scheduler+0x6>

80104ee1 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104ee1:	55                   	push   %ebp
80104ee2:	89 e5                	mov    %esp,%ebp
80104ee4:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104ee7:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
80104eee:	e8 02 05 00 00       	call   801053f5 <holding>
80104ef3:	85 c0                	test   %eax,%eax
80104ef5:	75 0c                	jne    80104f03 <sched+0x22>
    panic("sched ptable.lock");
80104ef7:	c7 04 24 58 8d 10 80 	movl   $0x80108d58,(%esp)
80104efe:	e8 3a b6 ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
80104f03:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f09:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104f0f:	83 f8 01             	cmp    $0x1,%eax
80104f12:	74 0c                	je     80104f20 <sched+0x3f>
    panic("sched locks");
80104f14:	c7 04 24 6a 8d 10 80 	movl   $0x80108d6a,(%esp)
80104f1b:	e8 1d b6 ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
80104f20:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f26:	8b 40 0c             	mov    0xc(%eax),%eax
80104f29:	83 f8 04             	cmp    $0x4,%eax
80104f2c:	75 0c                	jne    80104f3a <sched+0x59>
    panic("sched running");
80104f2e:	c7 04 24 76 8d 10 80 	movl   $0x80108d76,(%esp)
80104f35:	e8 03 b6 ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
80104f3a:	e8 45 f4 ff ff       	call   80104384 <readeflags>
80104f3f:	25 00 02 00 00       	and    $0x200,%eax
80104f44:	85 c0                	test   %eax,%eax
80104f46:	74 0c                	je     80104f54 <sched+0x73>
    panic("sched interruptible");
80104f48:	c7 04 24 84 8d 10 80 	movl   $0x80108d84,(%esp)
80104f4f:	e8 e9 b5 ff ff       	call   8010053d <panic>
  intena = cpu->intena;
80104f54:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f5a:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104f60:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104f63:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f69:	8b 40 04             	mov    0x4(%eax),%eax
80104f6c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104f73:	83 c2 1c             	add    $0x1c,%edx
80104f76:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f7a:	89 14 24             	mov    %edx,(%esp)
80104f7d:	e8 4a 08 00 00       	call   801057cc <swtch>
  cpu->intena = intena;
80104f82:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104f88:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f8b:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104f91:	c9                   	leave  
80104f92:	c3                   	ret    

80104f93 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104f93:	55                   	push   %ebp
80104f94:	89 e5                	mov    %esp,%ebp
80104f96:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104f99:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
80104fa0:	e8 32 03 00 00       	call   801052d7 <acquire>
  proc->state = RUNNABLE;
80104fa5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104fab:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104fb2:	e8 2a ff ff ff       	call   80104ee1 <sched>
  release(&ptable.lock);
80104fb7:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
80104fbe:	e8 76 03 00 00       	call   80105339 <release>
}
80104fc3:	c9                   	leave  
80104fc4:	c3                   	ret    

80104fc5 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104fc5:	55                   	push   %ebp
80104fc6:	89 e5                	mov    %esp,%ebp
80104fc8:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104fcb:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
80104fd2:	e8 62 03 00 00       	call   80105339 <release>

  if (first) {
80104fd7:	a1 24 c0 10 80       	mov    0x8010c024,%eax
80104fdc:	85 c0                	test   %eax,%eax
80104fde:	74 0f                	je     80104fef <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104fe0:	c7 05 24 c0 10 80 00 	movl   $0x0,0x8010c024
80104fe7:	00 00 00 
    initlog();
80104fea:	e8 a1 e2 ff ff       	call   80103290 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104fef:	c9                   	leave  
80104ff0:	c3                   	ret    

80104ff1 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104ff1:	55                   	push   %ebp
80104ff2:	89 e5                	mov    %esp,%ebp
80104ff4:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104ff7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ffd:	85 c0                	test   %eax,%eax
80104fff:	75 0c                	jne    8010500d <sleep+0x1c>
    panic("sleep");
80105001:	c7 04 24 98 8d 10 80 	movl   $0x80108d98,(%esp)
80105008:	e8 30 b5 ff ff       	call   8010053d <panic>

  if(lk == 0)
8010500d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105011:	75 0c                	jne    8010501f <sleep+0x2e>
    panic("sleep without lk");
80105013:	c7 04 24 9e 8d 10 80 	movl   $0x80108d9e,(%esp)
8010501a:	e8 1e b5 ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010501f:	81 7d 0c a0 3c 11 80 	cmpl   $0x80113ca0,0xc(%ebp)
80105026:	74 17                	je     8010503f <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80105028:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
8010502f:	e8 a3 02 00 00       	call   801052d7 <acquire>
    release(lk);
80105034:	8b 45 0c             	mov    0xc(%ebp),%eax
80105037:	89 04 24             	mov    %eax,(%esp)
8010503a:	e8 fa 02 00 00       	call   80105339 <release>
  }

  // Go to sleep.
  proc->chan = chan;
8010503f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105045:	8b 55 08             	mov    0x8(%ebp),%edx
80105048:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
8010504b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105051:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80105058:	e8 84 fe ff ff       	call   80104ee1 <sched>

  // Tidy up.
  proc->chan = 0;
8010505d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105063:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010506a:	81 7d 0c a0 3c 11 80 	cmpl   $0x80113ca0,0xc(%ebp)
80105071:	74 17                	je     8010508a <sleep+0x99>
    release(&ptable.lock);
80105073:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
8010507a:	e8 ba 02 00 00       	call   80105339 <release>
    acquire(lk);
8010507f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105082:	89 04 24             	mov    %eax,(%esp)
80105085:	e8 4d 02 00 00       	call   801052d7 <acquire>
  }
}
8010508a:	c9                   	leave  
8010508b:	c3                   	ret    

8010508c <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010508c:	55                   	push   %ebp
8010508d:	89 e5                	mov    %esp,%ebp
8010508f:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105092:	c7 45 fc d4 3c 11 80 	movl   $0x80113cd4,-0x4(%ebp)
80105099:	eb 27                	jmp    801050c2 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
8010509b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010509e:	8b 40 0c             	mov    0xc(%eax),%eax
801050a1:	83 f8 02             	cmp    $0x2,%eax
801050a4:	75 15                	jne    801050bb <wakeup1+0x2f>
801050a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050a9:	8b 40 20             	mov    0x20(%eax),%eax
801050ac:	3b 45 08             	cmp    0x8(%ebp),%eax
801050af:	75 0a                	jne    801050bb <wakeup1+0x2f>
      p->state = RUNNABLE;
801050b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050b4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801050bb:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
801050c2:	81 7d fc d4 5d 11 80 	cmpl   $0x80115dd4,-0x4(%ebp)
801050c9:	72 d0                	jb     8010509b <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
801050cb:	c9                   	leave  
801050cc:	c3                   	ret    

801050cd <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801050cd:	55                   	push   %ebp
801050ce:	89 e5                	mov    %esp,%ebp
801050d0:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
801050d3:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
801050da:	e8 f8 01 00 00       	call   801052d7 <acquire>
  wakeup1(chan);
801050df:	8b 45 08             	mov    0x8(%ebp),%eax
801050e2:	89 04 24             	mov    %eax,(%esp)
801050e5:	e8 a2 ff ff ff       	call   8010508c <wakeup1>
  release(&ptable.lock);
801050ea:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
801050f1:	e8 43 02 00 00       	call   80105339 <release>
}
801050f6:	c9                   	leave  
801050f7:	c3                   	ret    

801050f8 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801050f8:	55                   	push   %ebp
801050f9:	89 e5                	mov    %esp,%ebp
801050fb:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
801050fe:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
80105105:	e8 cd 01 00 00       	call   801052d7 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010510a:	c7 45 f4 d4 3c 11 80 	movl   $0x80113cd4,-0xc(%ebp)
80105111:	eb 44                	jmp    80105157 <kill+0x5f>
    if(p->pid == pid){
80105113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105116:	8b 40 10             	mov    0x10(%eax),%eax
80105119:	3b 45 08             	cmp    0x8(%ebp),%eax
8010511c:	75 32                	jne    80105150 <kill+0x58>
      p->killed = 1;
8010511e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105121:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80105128:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010512b:	8b 40 0c             	mov    0xc(%eax),%eax
8010512e:	83 f8 02             	cmp    $0x2,%eax
80105131:	75 0a                	jne    8010513d <kill+0x45>
        p->state = RUNNABLE;
80105133:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105136:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010513d:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
80105144:	e8 f0 01 00 00       	call   80105339 <release>
      return 0;
80105149:	b8 00 00 00 00       	mov    $0x0,%eax
8010514e:	eb 21                	jmp    80105171 <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105150:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80105157:	81 7d f4 d4 5d 11 80 	cmpl   $0x80115dd4,-0xc(%ebp)
8010515e:	72 b3                	jb     80105113 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105160:	c7 04 24 a0 3c 11 80 	movl   $0x80113ca0,(%esp)
80105167:	e8 cd 01 00 00       	call   80105339 <release>
  return -1;
8010516c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105171:	c9                   	leave  
80105172:	c3                   	ret    

80105173 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105173:	55                   	push   %ebp
80105174:	89 e5                	mov    %esp,%ebp
80105176:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105179:	c7 45 f0 d4 3c 11 80 	movl   $0x80113cd4,-0x10(%ebp)
80105180:	e9 db 00 00 00       	jmp    80105260 <procdump+0xed>
    if(p->state == UNUSED)
80105185:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105188:	8b 40 0c             	mov    0xc(%eax),%eax
8010518b:	85 c0                	test   %eax,%eax
8010518d:	0f 84 c5 00 00 00    	je     80105258 <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105193:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105196:	8b 40 0c             	mov    0xc(%eax),%eax
80105199:	83 f8 05             	cmp    $0x5,%eax
8010519c:	77 23                	ja     801051c1 <procdump+0x4e>
8010519e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051a1:	8b 40 0c             	mov    0xc(%eax),%eax
801051a4:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
801051ab:	85 c0                	test   %eax,%eax
801051ad:	74 12                	je     801051c1 <procdump+0x4e>
      state = states[p->state];
801051af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051b2:	8b 40 0c             	mov    0xc(%eax),%eax
801051b5:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
801051bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
801051bf:	eb 07                	jmp    801051c8 <procdump+0x55>
    else
      state = "???";
801051c1:	c7 45 ec af 8d 10 80 	movl   $0x80108daf,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801051c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051cb:	8d 50 6c             	lea    0x6c(%eax),%edx
801051ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051d1:	8b 40 10             	mov    0x10(%eax),%eax
801051d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
801051d8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801051db:	89 54 24 08          	mov    %edx,0x8(%esp)
801051df:	89 44 24 04          	mov    %eax,0x4(%esp)
801051e3:	c7 04 24 b3 8d 10 80 	movl   $0x80108db3,(%esp)
801051ea:	e8 b2 b1 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
801051ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051f2:	8b 40 0c             	mov    0xc(%eax),%eax
801051f5:	83 f8 02             	cmp    $0x2,%eax
801051f8:	75 50                	jne    8010524a <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801051fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051fd:	8b 40 1c             	mov    0x1c(%eax),%eax
80105200:	8b 40 0c             	mov    0xc(%eax),%eax
80105203:	83 c0 08             	add    $0x8,%eax
80105206:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80105209:	89 54 24 04          	mov    %edx,0x4(%esp)
8010520d:	89 04 24             	mov    %eax,(%esp)
80105210:	e8 73 01 00 00       	call   80105388 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80105215:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010521c:	eb 1b                	jmp    80105239 <procdump+0xc6>
        cprintf(" %p", pc[i]);
8010521e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105221:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105225:	89 44 24 04          	mov    %eax,0x4(%esp)
80105229:	c7 04 24 bc 8d 10 80 	movl   $0x80108dbc,(%esp)
80105230:	e8 6c b1 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105235:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105239:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010523d:	7f 0b                	jg     8010524a <procdump+0xd7>
8010523f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105242:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105246:	85 c0                	test   %eax,%eax
80105248:	75 d4                	jne    8010521e <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
8010524a:	c7 04 24 c0 8d 10 80 	movl   $0x80108dc0,(%esp)
80105251:	e8 4b b1 ff ff       	call   801003a1 <cprintf>
80105256:	eb 01                	jmp    80105259 <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105258:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105259:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80105260:	81 7d f0 d4 5d 11 80 	cmpl   $0x80115dd4,-0x10(%ebp)
80105267:	0f 82 18 ff ff ff    	jb     80105185 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
8010526d:	c9                   	leave  
8010526e:	c3                   	ret    
	...

80105270 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105270:	55                   	push   %ebp
80105271:	89 e5                	mov    %esp,%ebp
80105273:	53                   	push   %ebx
80105274:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105277:	9c                   	pushf  
80105278:	5b                   	pop    %ebx
80105279:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
8010527c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010527f:	83 c4 10             	add    $0x10,%esp
80105282:	5b                   	pop    %ebx
80105283:	5d                   	pop    %ebp
80105284:	c3                   	ret    

80105285 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105285:	55                   	push   %ebp
80105286:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105288:	fa                   	cli    
}
80105289:	5d                   	pop    %ebp
8010528a:	c3                   	ret    

8010528b <sti>:

static inline void
sti(void)
{
8010528b:	55                   	push   %ebp
8010528c:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010528e:	fb                   	sti    
}
8010528f:	5d                   	pop    %ebp
80105290:	c3                   	ret    

80105291 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105291:	55                   	push   %ebp
80105292:	89 e5                	mov    %esp,%ebp
80105294:	53                   	push   %ebx
80105295:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80105298:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010529b:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
8010529e:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801052a1:	89 c3                	mov    %eax,%ebx
801052a3:	89 d8                	mov    %ebx,%eax
801052a5:	f0 87 02             	lock xchg %eax,(%edx)
801052a8:	89 c3                	mov    %eax,%ebx
801052aa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801052ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801052b0:	83 c4 10             	add    $0x10,%esp
801052b3:	5b                   	pop    %ebx
801052b4:	5d                   	pop    %ebp
801052b5:	c3                   	ret    

801052b6 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801052b6:	55                   	push   %ebp
801052b7:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801052b9:	8b 45 08             	mov    0x8(%ebp),%eax
801052bc:	8b 55 0c             	mov    0xc(%ebp),%edx
801052bf:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801052c2:	8b 45 08             	mov    0x8(%ebp),%eax
801052c5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801052cb:	8b 45 08             	mov    0x8(%ebp),%eax
801052ce:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801052d5:	5d                   	pop    %ebp
801052d6:	c3                   	ret    

801052d7 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801052d7:	55                   	push   %ebp
801052d8:	89 e5                	mov    %esp,%ebp
801052da:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801052dd:	e8 3d 01 00 00       	call   8010541f <pushcli>
  if(holding(lk))
801052e2:	8b 45 08             	mov    0x8(%ebp),%eax
801052e5:	89 04 24             	mov    %eax,(%esp)
801052e8:	e8 08 01 00 00       	call   801053f5 <holding>
801052ed:	85 c0                	test   %eax,%eax
801052ef:	74 0c                	je     801052fd <acquire+0x26>
    panic("acquire");
801052f1:	c7 04 24 ec 8d 10 80 	movl   $0x80108dec,(%esp)
801052f8:	e8 40 b2 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801052fd:	90                   	nop
801052fe:	8b 45 08             	mov    0x8(%ebp),%eax
80105301:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105308:	00 
80105309:	89 04 24             	mov    %eax,(%esp)
8010530c:	e8 80 ff ff ff       	call   80105291 <xchg>
80105311:	85 c0                	test   %eax,%eax
80105313:	75 e9                	jne    801052fe <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105315:	8b 45 08             	mov    0x8(%ebp),%eax
80105318:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010531f:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105322:	8b 45 08             	mov    0x8(%ebp),%eax
80105325:	83 c0 0c             	add    $0xc,%eax
80105328:	89 44 24 04          	mov    %eax,0x4(%esp)
8010532c:	8d 45 08             	lea    0x8(%ebp),%eax
8010532f:	89 04 24             	mov    %eax,(%esp)
80105332:	e8 51 00 00 00       	call   80105388 <getcallerpcs>
}
80105337:	c9                   	leave  
80105338:	c3                   	ret    

80105339 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105339:	55                   	push   %ebp
8010533a:	89 e5                	mov    %esp,%ebp
8010533c:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
8010533f:	8b 45 08             	mov    0x8(%ebp),%eax
80105342:	89 04 24             	mov    %eax,(%esp)
80105345:	e8 ab 00 00 00       	call   801053f5 <holding>
8010534a:	85 c0                	test   %eax,%eax
8010534c:	75 0c                	jne    8010535a <release+0x21>
    panic("release");
8010534e:	c7 04 24 f4 8d 10 80 	movl   $0x80108df4,(%esp)
80105355:	e8 e3 b1 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
8010535a:	8b 45 08             	mov    0x8(%ebp),%eax
8010535d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105364:	8b 45 08             	mov    0x8(%ebp),%eax
80105367:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
8010536e:	8b 45 08             	mov    0x8(%ebp),%eax
80105371:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105378:	00 
80105379:	89 04 24             	mov    %eax,(%esp)
8010537c:	e8 10 ff ff ff       	call   80105291 <xchg>

  popcli();
80105381:	e8 e1 00 00 00       	call   80105467 <popcli>
}
80105386:	c9                   	leave  
80105387:	c3                   	ret    

80105388 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105388:	55                   	push   %ebp
80105389:	89 e5                	mov    %esp,%ebp
8010538b:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
8010538e:	8b 45 08             	mov    0x8(%ebp),%eax
80105391:	83 e8 08             	sub    $0x8,%eax
80105394:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105397:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010539e:	eb 32                	jmp    801053d2 <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801053a0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801053a4:	74 47                	je     801053ed <getcallerpcs+0x65>
801053a6:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801053ad:	76 3e                	jbe    801053ed <getcallerpcs+0x65>
801053af:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801053b3:	74 38                	je     801053ed <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
801053b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053b8:	c1 e0 02             	shl    $0x2,%eax
801053bb:	03 45 0c             	add    0xc(%ebp),%eax
801053be:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053c1:	8b 52 04             	mov    0x4(%edx),%edx
801053c4:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
801053c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053c9:	8b 00                	mov    (%eax),%eax
801053cb:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801053ce:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801053d2:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801053d6:	7e c8                	jle    801053a0 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801053d8:	eb 13                	jmp    801053ed <getcallerpcs+0x65>
    pcs[i] = 0;
801053da:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053dd:	c1 e0 02             	shl    $0x2,%eax
801053e0:	03 45 0c             	add    0xc(%ebp),%eax
801053e3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801053e9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801053ed:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801053f1:	7e e7                	jle    801053da <getcallerpcs+0x52>
    pcs[i] = 0;
}
801053f3:	c9                   	leave  
801053f4:	c3                   	ret    

801053f5 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801053f5:	55                   	push   %ebp
801053f6:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801053f8:	8b 45 08             	mov    0x8(%ebp),%eax
801053fb:	8b 00                	mov    (%eax),%eax
801053fd:	85 c0                	test   %eax,%eax
801053ff:	74 17                	je     80105418 <holding+0x23>
80105401:	8b 45 08             	mov    0x8(%ebp),%eax
80105404:	8b 50 08             	mov    0x8(%eax),%edx
80105407:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010540d:	39 c2                	cmp    %eax,%edx
8010540f:	75 07                	jne    80105418 <holding+0x23>
80105411:	b8 01 00 00 00       	mov    $0x1,%eax
80105416:	eb 05                	jmp    8010541d <holding+0x28>
80105418:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010541d:	5d                   	pop    %ebp
8010541e:	c3                   	ret    

8010541f <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010541f:	55                   	push   %ebp
80105420:	89 e5                	mov    %esp,%ebp
80105422:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105425:	e8 46 fe ff ff       	call   80105270 <readeflags>
8010542a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
8010542d:	e8 53 fe ff ff       	call   80105285 <cli>
  if(cpu->ncli++ == 0)
80105432:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105438:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010543e:	85 d2                	test   %edx,%edx
80105440:	0f 94 c1             	sete   %cl
80105443:	83 c2 01             	add    $0x1,%edx
80105446:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010544c:	84 c9                	test   %cl,%cl
8010544e:	74 15                	je     80105465 <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80105450:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105456:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105459:	81 e2 00 02 00 00    	and    $0x200,%edx
8010545f:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105465:	c9                   	leave  
80105466:	c3                   	ret    

80105467 <popcli>:

void
popcli(void)
{
80105467:	55                   	push   %ebp
80105468:	89 e5                	mov    %esp,%ebp
8010546a:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
8010546d:	e8 fe fd ff ff       	call   80105270 <readeflags>
80105472:	25 00 02 00 00       	and    $0x200,%eax
80105477:	85 c0                	test   %eax,%eax
80105479:	74 0c                	je     80105487 <popcli+0x20>
    panic("popcli - interruptible");
8010547b:	c7 04 24 fc 8d 10 80 	movl   $0x80108dfc,(%esp)
80105482:	e8 b6 b0 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
80105487:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010548d:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105493:	83 ea 01             	sub    $0x1,%edx
80105496:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010549c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801054a2:	85 c0                	test   %eax,%eax
801054a4:	79 0c                	jns    801054b2 <popcli+0x4b>
    panic("popcli");
801054a6:	c7 04 24 13 8e 10 80 	movl   $0x80108e13,(%esp)
801054ad:	e8 8b b0 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
801054b2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801054b8:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801054be:	85 c0                	test   %eax,%eax
801054c0:	75 15                	jne    801054d7 <popcli+0x70>
801054c2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801054c8:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801054ce:	85 c0                	test   %eax,%eax
801054d0:	74 05                	je     801054d7 <popcli+0x70>
    sti();
801054d2:	e8 b4 fd ff ff       	call   8010528b <sti>
}
801054d7:	c9                   	leave  
801054d8:	c3                   	ret    
801054d9:	00 00                	add    %al,(%eax)
	...

801054dc <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801054dc:	55                   	push   %ebp
801054dd:	89 e5                	mov    %esp,%ebp
801054df:	57                   	push   %edi
801054e0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801054e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
801054e4:	8b 55 10             	mov    0x10(%ebp),%edx
801054e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ea:	89 cb                	mov    %ecx,%ebx
801054ec:	89 df                	mov    %ebx,%edi
801054ee:	89 d1                	mov    %edx,%ecx
801054f0:	fc                   	cld    
801054f1:	f3 aa                	rep stos %al,%es:(%edi)
801054f3:	89 ca                	mov    %ecx,%edx
801054f5:	89 fb                	mov    %edi,%ebx
801054f7:	89 5d 08             	mov    %ebx,0x8(%ebp)
801054fa:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801054fd:	5b                   	pop    %ebx
801054fe:	5f                   	pop    %edi
801054ff:	5d                   	pop    %ebp
80105500:	c3                   	ret    

80105501 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105501:	55                   	push   %ebp
80105502:	89 e5                	mov    %esp,%ebp
80105504:	57                   	push   %edi
80105505:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105506:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105509:	8b 55 10             	mov    0x10(%ebp),%edx
8010550c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010550f:	89 cb                	mov    %ecx,%ebx
80105511:	89 df                	mov    %ebx,%edi
80105513:	89 d1                	mov    %edx,%ecx
80105515:	fc                   	cld    
80105516:	f3 ab                	rep stos %eax,%es:(%edi)
80105518:	89 ca                	mov    %ecx,%edx
8010551a:	89 fb                	mov    %edi,%ebx
8010551c:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010551f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105522:	5b                   	pop    %ebx
80105523:	5f                   	pop    %edi
80105524:	5d                   	pop    %ebp
80105525:	c3                   	ret    

80105526 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105526:	55                   	push   %ebp
80105527:	89 e5                	mov    %esp,%ebp
80105529:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
8010552c:	8b 45 08             	mov    0x8(%ebp),%eax
8010552f:	83 e0 03             	and    $0x3,%eax
80105532:	85 c0                	test   %eax,%eax
80105534:	75 49                	jne    8010557f <memset+0x59>
80105536:	8b 45 10             	mov    0x10(%ebp),%eax
80105539:	83 e0 03             	and    $0x3,%eax
8010553c:	85 c0                	test   %eax,%eax
8010553e:	75 3f                	jne    8010557f <memset+0x59>
    c &= 0xFF;
80105540:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105547:	8b 45 10             	mov    0x10(%ebp),%eax
8010554a:	c1 e8 02             	shr    $0x2,%eax
8010554d:	89 c2                	mov    %eax,%edx
8010554f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105552:	89 c1                	mov    %eax,%ecx
80105554:	c1 e1 18             	shl    $0x18,%ecx
80105557:	8b 45 0c             	mov    0xc(%ebp),%eax
8010555a:	c1 e0 10             	shl    $0x10,%eax
8010555d:	09 c1                	or     %eax,%ecx
8010555f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105562:	c1 e0 08             	shl    $0x8,%eax
80105565:	09 c8                	or     %ecx,%eax
80105567:	0b 45 0c             	or     0xc(%ebp),%eax
8010556a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010556e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105572:	8b 45 08             	mov    0x8(%ebp),%eax
80105575:	89 04 24             	mov    %eax,(%esp)
80105578:	e8 84 ff ff ff       	call   80105501 <stosl>
8010557d:	eb 19                	jmp    80105598 <memset+0x72>
  } else
    stosb(dst, c, n);
8010557f:	8b 45 10             	mov    0x10(%ebp),%eax
80105582:	89 44 24 08          	mov    %eax,0x8(%esp)
80105586:	8b 45 0c             	mov    0xc(%ebp),%eax
80105589:	89 44 24 04          	mov    %eax,0x4(%esp)
8010558d:	8b 45 08             	mov    0x8(%ebp),%eax
80105590:	89 04 24             	mov    %eax,(%esp)
80105593:	e8 44 ff ff ff       	call   801054dc <stosb>
  return dst;
80105598:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010559b:	c9                   	leave  
8010559c:	c3                   	ret    

8010559d <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010559d:	55                   	push   %ebp
8010559e:	89 e5                	mov    %esp,%ebp
801055a0:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801055a3:	8b 45 08             	mov    0x8(%ebp),%eax
801055a6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801055a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ac:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801055af:	eb 32                	jmp    801055e3 <memcmp+0x46>
    if(*s1 != *s2)
801055b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055b4:	0f b6 10             	movzbl (%eax),%edx
801055b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055ba:	0f b6 00             	movzbl (%eax),%eax
801055bd:	38 c2                	cmp    %al,%dl
801055bf:	74 1a                	je     801055db <memcmp+0x3e>
      return *s1 - *s2;
801055c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055c4:	0f b6 00             	movzbl (%eax),%eax
801055c7:	0f b6 d0             	movzbl %al,%edx
801055ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055cd:	0f b6 00             	movzbl (%eax),%eax
801055d0:	0f b6 c0             	movzbl %al,%eax
801055d3:	89 d1                	mov    %edx,%ecx
801055d5:	29 c1                	sub    %eax,%ecx
801055d7:	89 c8                	mov    %ecx,%eax
801055d9:	eb 1c                	jmp    801055f7 <memcmp+0x5a>
    s1++, s2++;
801055db:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055df:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801055e3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055e7:	0f 95 c0             	setne  %al
801055ea:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801055ee:	84 c0                	test   %al,%al
801055f0:	75 bf                	jne    801055b1 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801055f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055f7:	c9                   	leave  
801055f8:	c3                   	ret    

801055f9 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801055f9:	55                   	push   %ebp
801055fa:	89 e5                	mov    %esp,%ebp
801055fc:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801055ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105602:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105605:	8b 45 08             	mov    0x8(%ebp),%eax
80105608:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010560b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010560e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105611:	73 54                	jae    80105667 <memmove+0x6e>
80105613:	8b 45 10             	mov    0x10(%ebp),%eax
80105616:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105619:	01 d0                	add    %edx,%eax
8010561b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010561e:	76 47                	jbe    80105667 <memmove+0x6e>
    s += n;
80105620:	8b 45 10             	mov    0x10(%ebp),%eax
80105623:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105626:	8b 45 10             	mov    0x10(%ebp),%eax
80105629:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010562c:	eb 13                	jmp    80105641 <memmove+0x48>
      *--d = *--s;
8010562e:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105632:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105636:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105639:	0f b6 10             	movzbl (%eax),%edx
8010563c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010563f:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105641:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105645:	0f 95 c0             	setne  %al
80105648:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010564c:	84 c0                	test   %al,%al
8010564e:	75 de                	jne    8010562e <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105650:	eb 25                	jmp    80105677 <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105652:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105655:	0f b6 10             	movzbl (%eax),%edx
80105658:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010565b:	88 10                	mov    %dl,(%eax)
8010565d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105661:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105665:	eb 01                	jmp    80105668 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105667:	90                   	nop
80105668:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010566c:	0f 95 c0             	setne  %al
8010566f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105673:	84 c0                	test   %al,%al
80105675:	75 db                	jne    80105652 <memmove+0x59>
      *d++ = *s++;

  return dst;
80105677:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010567a:	c9                   	leave  
8010567b:	c3                   	ret    

8010567c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010567c:	55                   	push   %ebp
8010567d:	89 e5                	mov    %esp,%ebp
8010567f:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105682:	8b 45 10             	mov    0x10(%ebp),%eax
80105685:	89 44 24 08          	mov    %eax,0x8(%esp)
80105689:	8b 45 0c             	mov    0xc(%ebp),%eax
8010568c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105690:	8b 45 08             	mov    0x8(%ebp),%eax
80105693:	89 04 24             	mov    %eax,(%esp)
80105696:	e8 5e ff ff ff       	call   801055f9 <memmove>
}
8010569b:	c9                   	leave  
8010569c:	c3                   	ret    

8010569d <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010569d:	55                   	push   %ebp
8010569e:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801056a0:	eb 0c                	jmp    801056ae <strncmp+0x11>
    n--, p++, q++;
801056a2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801056a6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801056aa:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801056ae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056b2:	74 1a                	je     801056ce <strncmp+0x31>
801056b4:	8b 45 08             	mov    0x8(%ebp),%eax
801056b7:	0f b6 00             	movzbl (%eax),%eax
801056ba:	84 c0                	test   %al,%al
801056bc:	74 10                	je     801056ce <strncmp+0x31>
801056be:	8b 45 08             	mov    0x8(%ebp),%eax
801056c1:	0f b6 10             	movzbl (%eax),%edx
801056c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801056c7:	0f b6 00             	movzbl (%eax),%eax
801056ca:	38 c2                	cmp    %al,%dl
801056cc:	74 d4                	je     801056a2 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801056ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056d2:	75 07                	jne    801056db <strncmp+0x3e>
    return 0;
801056d4:	b8 00 00 00 00       	mov    $0x0,%eax
801056d9:	eb 18                	jmp    801056f3 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
801056db:	8b 45 08             	mov    0x8(%ebp),%eax
801056de:	0f b6 00             	movzbl (%eax),%eax
801056e1:	0f b6 d0             	movzbl %al,%edx
801056e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801056e7:	0f b6 00             	movzbl (%eax),%eax
801056ea:	0f b6 c0             	movzbl %al,%eax
801056ed:	89 d1                	mov    %edx,%ecx
801056ef:	29 c1                	sub    %eax,%ecx
801056f1:	89 c8                	mov    %ecx,%eax
}
801056f3:	5d                   	pop    %ebp
801056f4:	c3                   	ret    

801056f5 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801056f5:	55                   	push   %ebp
801056f6:	89 e5                	mov    %esp,%ebp
801056f8:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801056fb:	8b 45 08             	mov    0x8(%ebp),%eax
801056fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105701:	90                   	nop
80105702:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105706:	0f 9f c0             	setg   %al
80105709:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010570d:	84 c0                	test   %al,%al
8010570f:	74 30                	je     80105741 <strncpy+0x4c>
80105711:	8b 45 0c             	mov    0xc(%ebp),%eax
80105714:	0f b6 10             	movzbl (%eax),%edx
80105717:	8b 45 08             	mov    0x8(%ebp),%eax
8010571a:	88 10                	mov    %dl,(%eax)
8010571c:	8b 45 08             	mov    0x8(%ebp),%eax
8010571f:	0f b6 00             	movzbl (%eax),%eax
80105722:	84 c0                	test   %al,%al
80105724:	0f 95 c0             	setne  %al
80105727:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010572b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
8010572f:	84 c0                	test   %al,%al
80105731:	75 cf                	jne    80105702 <strncpy+0xd>
    ;
  while(n-- > 0)
80105733:	eb 0c                	jmp    80105741 <strncpy+0x4c>
    *s++ = 0;
80105735:	8b 45 08             	mov    0x8(%ebp),%eax
80105738:	c6 00 00             	movb   $0x0,(%eax)
8010573b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010573f:	eb 01                	jmp    80105742 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105741:	90                   	nop
80105742:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105746:	0f 9f c0             	setg   %al
80105749:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010574d:	84 c0                	test   %al,%al
8010574f:	75 e4                	jne    80105735 <strncpy+0x40>
    *s++ = 0;
  return os;
80105751:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105754:	c9                   	leave  
80105755:	c3                   	ret    

80105756 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105756:	55                   	push   %ebp
80105757:	89 e5                	mov    %esp,%ebp
80105759:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010575c:	8b 45 08             	mov    0x8(%ebp),%eax
8010575f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105762:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105766:	7f 05                	jg     8010576d <safestrcpy+0x17>
    return os;
80105768:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010576b:	eb 35                	jmp    801057a2 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
8010576d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105771:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105775:	7e 22                	jle    80105799 <safestrcpy+0x43>
80105777:	8b 45 0c             	mov    0xc(%ebp),%eax
8010577a:	0f b6 10             	movzbl (%eax),%edx
8010577d:	8b 45 08             	mov    0x8(%ebp),%eax
80105780:	88 10                	mov    %dl,(%eax)
80105782:	8b 45 08             	mov    0x8(%ebp),%eax
80105785:	0f b6 00             	movzbl (%eax),%eax
80105788:	84 c0                	test   %al,%al
8010578a:	0f 95 c0             	setne  %al
8010578d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105791:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105795:	84 c0                	test   %al,%al
80105797:	75 d4                	jne    8010576d <safestrcpy+0x17>
    ;
  *s = 0;
80105799:	8b 45 08             	mov    0x8(%ebp),%eax
8010579c:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010579f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057a2:	c9                   	leave  
801057a3:	c3                   	ret    

801057a4 <strlen>:

int
strlen(const char *s)
{
801057a4:	55                   	push   %ebp
801057a5:	89 e5                	mov    %esp,%ebp
801057a7:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801057aa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057b1:	eb 04                	jmp    801057b7 <strlen+0x13>
801057b3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057ba:	03 45 08             	add    0x8(%ebp),%eax
801057bd:	0f b6 00             	movzbl (%eax),%eax
801057c0:	84 c0                	test   %al,%al
801057c2:	75 ef                	jne    801057b3 <strlen+0xf>
    ;
  return n;
801057c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801057c7:	c9                   	leave  
801057c8:	c3                   	ret    
801057c9:	00 00                	add    %al,(%eax)
	...

801057cc <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801057cc:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801057d0:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801057d4:	55                   	push   %ebp
  pushl %ebx
801057d5:	53                   	push   %ebx
  pushl %esi
801057d6:	56                   	push   %esi
  pushl %edi
801057d7:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801057d8:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801057da:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801057dc:	5f                   	pop    %edi
  popl %esi
801057dd:	5e                   	pop    %esi
  popl %ebx
801057de:	5b                   	pop    %ebx
  popl %ebp
801057df:	5d                   	pop    %ebp
  ret
801057e0:	c3                   	ret    
801057e1:	00 00                	add    %al,(%eax)
	...

801057e4 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801057e4:	55                   	push   %ebp
801057e5:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801057e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057ed:	8b 00                	mov    (%eax),%eax
801057ef:	3b 45 08             	cmp    0x8(%ebp),%eax
801057f2:	76 12                	jbe    80105806 <fetchint+0x22>
801057f4:	8b 45 08             	mov    0x8(%ebp),%eax
801057f7:	8d 50 04             	lea    0x4(%eax),%edx
801057fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105800:	8b 00                	mov    (%eax),%eax
80105802:	39 c2                	cmp    %eax,%edx
80105804:	76 07                	jbe    8010580d <fetchint+0x29>
    return -1;
80105806:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010580b:	eb 0f                	jmp    8010581c <fetchint+0x38>
  *ip = *(int*)(addr);
8010580d:	8b 45 08             	mov    0x8(%ebp),%eax
80105810:	8b 10                	mov    (%eax),%edx
80105812:	8b 45 0c             	mov    0xc(%ebp),%eax
80105815:	89 10                	mov    %edx,(%eax)
  return 0;
80105817:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010581c:	5d                   	pop    %ebp
8010581d:	c3                   	ret    

8010581e <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010581e:	55                   	push   %ebp
8010581f:	89 e5                	mov    %esp,%ebp
80105821:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105824:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010582a:	8b 00                	mov    (%eax),%eax
8010582c:	3b 45 08             	cmp    0x8(%ebp),%eax
8010582f:	77 07                	ja     80105838 <fetchstr+0x1a>
    return -1;
80105831:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105836:	eb 48                	jmp    80105880 <fetchstr+0x62>
  *pp = (char*)addr;
80105838:	8b 55 08             	mov    0x8(%ebp),%edx
8010583b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010583e:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105840:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105846:	8b 00                	mov    (%eax),%eax
80105848:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010584b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010584e:	8b 00                	mov    (%eax),%eax
80105850:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105853:	eb 1e                	jmp    80105873 <fetchstr+0x55>
    if(*s == 0)
80105855:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105858:	0f b6 00             	movzbl (%eax),%eax
8010585b:	84 c0                	test   %al,%al
8010585d:	75 10                	jne    8010586f <fetchstr+0x51>
      return s - *pp;
8010585f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105862:	8b 45 0c             	mov    0xc(%ebp),%eax
80105865:	8b 00                	mov    (%eax),%eax
80105867:	89 d1                	mov    %edx,%ecx
80105869:	29 c1                	sub    %eax,%ecx
8010586b:	89 c8                	mov    %ecx,%eax
8010586d:	eb 11                	jmp    80105880 <fetchstr+0x62>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
8010586f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105873:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105876:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105879:	72 da                	jb     80105855 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
8010587b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105880:	c9                   	leave  
80105881:	c3                   	ret    

80105882 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105882:	55                   	push   %ebp
80105883:	89 e5                	mov    %esp,%ebp
80105885:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105888:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010588e:	8b 40 18             	mov    0x18(%eax),%eax
80105891:	8b 50 44             	mov    0x44(%eax),%edx
80105894:	8b 45 08             	mov    0x8(%ebp),%eax
80105897:	c1 e0 02             	shl    $0x2,%eax
8010589a:	01 d0                	add    %edx,%eax
8010589c:	8d 50 04             	lea    0x4(%eax),%edx
8010589f:	8b 45 0c             	mov    0xc(%ebp),%eax
801058a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801058a6:	89 14 24             	mov    %edx,(%esp)
801058a9:	e8 36 ff ff ff       	call   801057e4 <fetchint>
}
801058ae:	c9                   	leave  
801058af:	c3                   	ret    

801058b0 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801058b0:	55                   	push   %ebp
801058b1:	89 e5                	mov    %esp,%ebp
801058b3:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
801058b6:	8d 45 fc             	lea    -0x4(%ebp),%eax
801058b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801058bd:	8b 45 08             	mov    0x8(%ebp),%eax
801058c0:	89 04 24             	mov    %eax,(%esp)
801058c3:	e8 ba ff ff ff       	call   80105882 <argint>
801058c8:	85 c0                	test   %eax,%eax
801058ca:	79 07                	jns    801058d3 <argptr+0x23>
    return -1;
801058cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058d1:	eb 3d                	jmp    80105910 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801058d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058d6:	89 c2                	mov    %eax,%edx
801058d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058de:	8b 00                	mov    (%eax),%eax
801058e0:	39 c2                	cmp    %eax,%edx
801058e2:	73 16                	jae    801058fa <argptr+0x4a>
801058e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058e7:	89 c2                	mov    %eax,%edx
801058e9:	8b 45 10             	mov    0x10(%ebp),%eax
801058ec:	01 c2                	add    %eax,%edx
801058ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058f4:	8b 00                	mov    (%eax),%eax
801058f6:	39 c2                	cmp    %eax,%edx
801058f8:	76 07                	jbe    80105901 <argptr+0x51>
    return -1;
801058fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058ff:	eb 0f                	jmp    80105910 <argptr+0x60>
  *pp = (char*)i;
80105901:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105904:	89 c2                	mov    %eax,%edx
80105906:	8b 45 0c             	mov    0xc(%ebp),%eax
80105909:	89 10                	mov    %edx,(%eax)
  return 0;
8010590b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105910:	c9                   	leave  
80105911:	c3                   	ret    

80105912 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105912:	55                   	push   %ebp
80105913:	89 e5                	mov    %esp,%ebp
80105915:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105918:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010591b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010591f:	8b 45 08             	mov    0x8(%ebp),%eax
80105922:	89 04 24             	mov    %eax,(%esp)
80105925:	e8 58 ff ff ff       	call   80105882 <argint>
8010592a:	85 c0                	test   %eax,%eax
8010592c:	79 07                	jns    80105935 <argstr+0x23>
    return -1;
8010592e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105933:	eb 12                	jmp    80105947 <argstr+0x35>
  return fetchstr(addr, pp);
80105935:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105938:	8b 55 0c             	mov    0xc(%ebp),%edx
8010593b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010593f:	89 04 24             	mov    %eax,(%esp)
80105942:	e8 d7 fe ff ff       	call   8010581e <fetchstr>
}
80105947:	c9                   	leave  
80105948:	c3                   	ret    

80105949 <syscall>:
[SYS_forkjob]	sys_forkjob,
};

void
syscall(void)
{
80105949:	55                   	push   %ebp
8010594a:	89 e5                	mov    %esp,%ebp
8010594c:	53                   	push   %ebx
8010594d:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105950:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105956:	8b 40 18             	mov    0x18(%eax),%eax
80105959:	8b 40 1c             	mov    0x1c(%eax),%eax
8010595c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010595f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105963:	7e 30                	jle    80105995 <syscall+0x4c>
80105965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105968:	83 f8 17             	cmp    $0x17,%eax
8010596b:	77 28                	ja     80105995 <syscall+0x4c>
8010596d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105970:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105977:	85 c0                	test   %eax,%eax
80105979:	74 1a                	je     80105995 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
8010597b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105981:	8b 58 18             	mov    0x18(%eax),%ebx
80105984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105987:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
8010598e:	ff d0                	call   *%eax
80105990:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105993:	eb 3d                	jmp    801059d2 <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105995:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010599b:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010599e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801059a4:	8b 40 10             	mov    0x10(%eax),%eax
801059a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059aa:	89 54 24 0c          	mov    %edx,0xc(%esp)
801059ae:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801059b2:	89 44 24 04          	mov    %eax,0x4(%esp)
801059b6:	c7 04 24 1a 8e 10 80 	movl   $0x80108e1a,(%esp)
801059bd:	e8 df a9 ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801059c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059c8:	8b 40 18             	mov    0x18(%eax),%eax
801059cb:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801059d2:	83 c4 24             	add    $0x24,%esp
801059d5:	5b                   	pop    %ebx
801059d6:	5d                   	pop    %ebp
801059d7:	c3                   	ret    

801059d8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801059d8:	55                   	push   %ebp
801059d9:	89 e5                	mov    %esp,%ebp
801059db:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801059de:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801059e5:	8b 45 08             	mov    0x8(%ebp),%eax
801059e8:	89 04 24             	mov    %eax,(%esp)
801059eb:	e8 92 fe ff ff       	call   80105882 <argint>
801059f0:	85 c0                	test   %eax,%eax
801059f2:	79 07                	jns    801059fb <argfd+0x23>
    return -1;
801059f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059f9:	eb 50                	jmp    80105a4b <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801059fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059fe:	85 c0                	test   %eax,%eax
80105a00:	78 21                	js     80105a23 <argfd+0x4b>
80105a02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a05:	83 f8 0f             	cmp    $0xf,%eax
80105a08:	7f 19                	jg     80105a23 <argfd+0x4b>
80105a0a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a10:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a13:	83 c2 08             	add    $0x8,%edx
80105a16:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a1d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a21:	75 07                	jne    80105a2a <argfd+0x52>
    return -1;
80105a23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a28:	eb 21                	jmp    80105a4b <argfd+0x73>
  if(pfd)
80105a2a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105a2e:	74 08                	je     80105a38 <argfd+0x60>
    *pfd = fd;
80105a30:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a33:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a36:	89 10                	mov    %edx,(%eax)
  if(pf)
80105a38:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a3c:	74 08                	je     80105a46 <argfd+0x6e>
    *pf = f;
80105a3e:	8b 45 10             	mov    0x10(%ebp),%eax
80105a41:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a44:	89 10                	mov    %edx,(%eax)
  return 0;
80105a46:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a4b:	c9                   	leave  
80105a4c:	c3                   	ret    

80105a4d <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105a4d:	55                   	push   %ebp
80105a4e:	89 e5                	mov    %esp,%ebp
80105a50:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105a53:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105a5a:	eb 30                	jmp    80105a8c <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105a5c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a62:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105a65:	83 c2 08             	add    $0x8,%edx
80105a68:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105a6c:	85 c0                	test   %eax,%eax
80105a6e:	75 18                	jne    80105a88 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105a70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a76:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105a79:	8d 4a 08             	lea    0x8(%edx),%ecx
80105a7c:	8b 55 08             	mov    0x8(%ebp),%edx
80105a7f:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105a83:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a86:	eb 0f                	jmp    80105a97 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105a88:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105a8c:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105a90:	7e ca                	jle    80105a5c <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105a92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a97:	c9                   	leave  
80105a98:	c3                   	ret    

80105a99 <sys_dup>:

int
sys_dup(void)
{
80105a99:	55                   	push   %ebp
80105a9a:	89 e5                	mov    %esp,%ebp
80105a9c:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105a9f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105aa2:	89 44 24 08          	mov    %eax,0x8(%esp)
80105aa6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105aad:	00 
80105aae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ab5:	e8 1e ff ff ff       	call   801059d8 <argfd>
80105aba:	85 c0                	test   %eax,%eax
80105abc:	79 07                	jns    80105ac5 <sys_dup+0x2c>
    return -1;
80105abe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ac3:	eb 29                	jmp    80105aee <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ac8:	89 04 24             	mov    %eax,(%esp)
80105acb:	e8 7d ff ff ff       	call   80105a4d <fdalloc>
80105ad0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ad3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ad7:	79 07                	jns    80105ae0 <sys_dup+0x47>
    return -1;
80105ad9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ade:	eb 0e                	jmp    80105aee <sys_dup+0x55>
  filedup(f);
80105ae0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae3:	89 04 24             	mov    %eax,(%esp)
80105ae6:	e8 d9 b4 ff ff       	call   80100fc4 <filedup>
  return fd;
80105aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105aee:	c9                   	leave  
80105aef:	c3                   	ret    

80105af0 <sys_read>:

int
sys_read(void)
{
80105af0:	55                   	push   %ebp
80105af1:	89 e5                	mov    %esp,%ebp
80105af3:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105af6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105af9:	89 44 24 08          	mov    %eax,0x8(%esp)
80105afd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b04:	00 
80105b05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b0c:	e8 c7 fe ff ff       	call   801059d8 <argfd>
80105b11:	85 c0                	test   %eax,%eax
80105b13:	78 35                	js     80105b4a <sys_read+0x5a>
80105b15:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b18:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b1c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105b23:	e8 5a fd ff ff       	call   80105882 <argint>
80105b28:	85 c0                	test   %eax,%eax
80105b2a:	78 1e                	js     80105b4a <sys_read+0x5a>
80105b2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b2f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b33:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b36:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b3a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b41:	e8 6a fd ff ff       	call   801058b0 <argptr>
80105b46:	85 c0                	test   %eax,%eax
80105b48:	79 07                	jns    80105b51 <sys_read+0x61>
    return -1;
80105b4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b4f:	eb 19                	jmp    80105b6a <sys_read+0x7a>
  return fileread(f, p, n);
80105b51:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105b54:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b5a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105b5e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b62:	89 04 24             	mov    %eax,(%esp)
80105b65:	e8 c7 b5 ff ff       	call   80101131 <fileread>
}
80105b6a:	c9                   	leave  
80105b6b:	c3                   	ret    

80105b6c <sys_write>:

int
sys_write(void)
{
80105b6c:	55                   	push   %ebp
80105b6d:	89 e5                	mov    %esp,%ebp
80105b6f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b72:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b75:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b79:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b80:	00 
80105b81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b88:	e8 4b fe ff ff       	call   801059d8 <argfd>
80105b8d:	85 c0                	test   %eax,%eax
80105b8f:	78 35                	js     80105bc6 <sys_write+0x5a>
80105b91:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b94:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b98:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105b9f:	e8 de fc ff ff       	call   80105882 <argint>
80105ba4:	85 c0                	test   %eax,%eax
80105ba6:	78 1e                	js     80105bc6 <sys_write+0x5a>
80105ba8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bab:	89 44 24 08          	mov    %eax,0x8(%esp)
80105baf:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bb2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bb6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105bbd:	e8 ee fc ff ff       	call   801058b0 <argptr>
80105bc2:	85 c0                	test   %eax,%eax
80105bc4:	79 07                	jns    80105bcd <sys_write+0x61>
    return -1;
80105bc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bcb:	eb 19                	jmp    80105be6 <sys_write+0x7a>
  return filewrite(f, p, n);
80105bcd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105bd0:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105bda:	89 54 24 04          	mov    %edx,0x4(%esp)
80105bde:	89 04 24             	mov    %eax,(%esp)
80105be1:	e8 07 b6 ff ff       	call   801011ed <filewrite>
}
80105be6:	c9                   	leave  
80105be7:	c3                   	ret    

80105be8 <sys_close>:

int
sys_close(void)
{
80105be8:	55                   	push   %ebp
80105be9:	89 e5                	mov    %esp,%ebp
80105beb:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105bee:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bf1:	89 44 24 08          	mov    %eax,0x8(%esp)
80105bf5:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bf8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bfc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c03:	e8 d0 fd ff ff       	call   801059d8 <argfd>
80105c08:	85 c0                	test   %eax,%eax
80105c0a:	79 07                	jns    80105c13 <sys_close+0x2b>
    return -1;
80105c0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c11:	eb 24                	jmp    80105c37 <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105c13:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c19:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c1c:	83 c2 08             	add    $0x8,%edx
80105c1f:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105c26:	00 
  fileclose(f);
80105c27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c2a:	89 04 24             	mov    %eax,(%esp)
80105c2d:	e8 da b3 ff ff       	call   8010100c <fileclose>
  return 0;
80105c32:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c37:	c9                   	leave  
80105c38:	c3                   	ret    

80105c39 <sys_fstat>:

int
sys_fstat(void)
{
80105c39:	55                   	push   %ebp
80105c3a:	89 e5                	mov    %esp,%ebp
80105c3c:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105c3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c42:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c46:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105c4d:	00 
80105c4e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c55:	e8 7e fd ff ff       	call   801059d8 <argfd>
80105c5a:	85 c0                	test   %eax,%eax
80105c5c:	78 1f                	js     80105c7d <sys_fstat+0x44>
80105c5e:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105c65:	00 
80105c66:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c69:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c6d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105c74:	e8 37 fc ff ff       	call   801058b0 <argptr>
80105c79:	85 c0                	test   %eax,%eax
80105c7b:	79 07                	jns    80105c84 <sys_fstat+0x4b>
    return -1;
80105c7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c82:	eb 12                	jmp    80105c96 <sys_fstat+0x5d>
  return filestat(f, st);
80105c84:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c8a:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c8e:	89 04 24             	mov    %eax,(%esp)
80105c91:	e8 4c b4 ff ff       	call   801010e2 <filestat>
}
80105c96:	c9                   	leave  
80105c97:	c3                   	ret    

80105c98 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105c98:	55                   	push   %ebp
80105c99:	89 e5                	mov    %esp,%ebp
80105c9b:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105c9e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105ca1:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ca5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105cac:	e8 61 fc ff ff       	call   80105912 <argstr>
80105cb1:	85 c0                	test   %eax,%eax
80105cb3:	78 17                	js     80105ccc <sys_link+0x34>
80105cb5:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105cb8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cbc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105cc3:	e8 4a fc ff ff       	call   80105912 <argstr>
80105cc8:	85 c0                	test   %eax,%eax
80105cca:	79 0a                	jns    80105cd6 <sys_link+0x3e>
    return -1;
80105ccc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cd1:	e9 41 01 00 00       	jmp    80105e17 <sys_link+0x17f>

  begin_op();
80105cd6:	e8 c2 d7 ff ff       	call   8010349d <begin_op>
  if((ip = namei(old)) == 0){
80105cdb:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105cde:	89 04 24             	mov    %eax,(%esp)
80105ce1:	e8 6c c7 ff ff       	call   80102452 <namei>
80105ce6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ce9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ced:	75 0f                	jne    80105cfe <sys_link+0x66>
    end_op();
80105cef:	e8 2a d8 ff ff       	call   8010351e <end_op>
    return -1;
80105cf4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cf9:	e9 19 01 00 00       	jmp    80105e17 <sys_link+0x17f>
  }

  ilock(ip);
80105cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d01:	89 04 24             	mov    %eax,(%esp)
80105d04:	e8 a7 bb ff ff       	call   801018b0 <ilock>
  if(ip->type == T_DIR){
80105d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d0c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d10:	66 83 f8 01          	cmp    $0x1,%ax
80105d14:	75 1a                	jne    80105d30 <sys_link+0x98>
    iunlockput(ip);
80105d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d19:	89 04 24             	mov    %eax,(%esp)
80105d1c:	e8 13 be ff ff       	call   80101b34 <iunlockput>
    end_op();
80105d21:	e8 f8 d7 ff ff       	call   8010351e <end_op>
    return -1;
80105d26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d2b:	e9 e7 00 00 00       	jmp    80105e17 <sys_link+0x17f>
  }

  ip->nlink++;
80105d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d33:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d37:	8d 50 01             	lea    0x1(%eax),%edx
80105d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d3d:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d44:	89 04 24             	mov    %eax,(%esp)
80105d47:	e8 a8 b9 ff ff       	call   801016f4 <iupdate>
  iunlock(ip);
80105d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4f:	89 04 24             	mov    %eax,(%esp)
80105d52:	e8 a7 bc ff ff       	call   801019fe <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105d57:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105d5a:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105d5d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d61:	89 04 24             	mov    %eax,(%esp)
80105d64:	e8 0b c7 ff ff       	call   80102474 <nameiparent>
80105d69:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d6c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d70:	74 68                	je     80105dda <sys_link+0x142>
    goto bad;
  ilock(dp);
80105d72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d75:	89 04 24             	mov    %eax,(%esp)
80105d78:	e8 33 bb ff ff       	call   801018b0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105d7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d80:	8b 10                	mov    (%eax),%edx
80105d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d85:	8b 00                	mov    (%eax),%eax
80105d87:	39 c2                	cmp    %eax,%edx
80105d89:	75 20                	jne    80105dab <sys_link+0x113>
80105d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d8e:	8b 40 04             	mov    0x4(%eax),%eax
80105d91:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d95:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105d98:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d9f:	89 04 24             	mov    %eax,(%esp)
80105da2:	e8 ea c3 ff ff       	call   80102191 <dirlink>
80105da7:	85 c0                	test   %eax,%eax
80105da9:	79 0d                	jns    80105db8 <sys_link+0x120>
    iunlockput(dp);
80105dab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dae:	89 04 24             	mov    %eax,(%esp)
80105db1:	e8 7e bd ff ff       	call   80101b34 <iunlockput>
    goto bad;
80105db6:	eb 23                	jmp    80105ddb <sys_link+0x143>
  }
  iunlockput(dp);
80105db8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dbb:	89 04 24             	mov    %eax,(%esp)
80105dbe:	e8 71 bd ff ff       	call   80101b34 <iunlockput>
  iput(ip);
80105dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc6:	89 04 24             	mov    %eax,(%esp)
80105dc9:	e8 95 bc ff ff       	call   80101a63 <iput>

  end_op();
80105dce:	e8 4b d7 ff ff       	call   8010351e <end_op>

  return 0;
80105dd3:	b8 00 00 00 00       	mov    $0x0,%eax
80105dd8:	eb 3d                	jmp    80105e17 <sys_link+0x17f>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105dda:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80105ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dde:	89 04 24             	mov    %eax,(%esp)
80105de1:	e8 ca ba ff ff       	call   801018b0 <ilock>
  ip->nlink--;
80105de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de9:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ded:	8d 50 ff             	lea    -0x1(%eax),%edx
80105df0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df3:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dfa:	89 04 24             	mov    %eax,(%esp)
80105dfd:	e8 f2 b8 ff ff       	call   801016f4 <iupdate>
  iunlockput(ip);
80105e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e05:	89 04 24             	mov    %eax,(%esp)
80105e08:	e8 27 bd ff ff       	call   80101b34 <iunlockput>
  end_op();
80105e0d:	e8 0c d7 ff ff       	call   8010351e <end_op>
  return -1;
80105e12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e17:	c9                   	leave  
80105e18:	c3                   	ret    

80105e19 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105e19:	55                   	push   %ebp
80105e1a:	89 e5                	mov    %esp,%ebp
80105e1c:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e1f:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105e26:	eb 4b                	jmp    80105e73 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e2b:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105e32:	00 
80105e33:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e37:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e3a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e3e:	8b 45 08             	mov    0x8(%ebp),%eax
80105e41:	89 04 24             	mov    %eax,(%esp)
80105e44:	e8 5d bf ff ff       	call   80101da6 <readi>
80105e49:	83 f8 10             	cmp    $0x10,%eax
80105e4c:	74 0c                	je     80105e5a <isdirempty+0x41>
      panic("isdirempty: readi");
80105e4e:	c7 04 24 36 8e 10 80 	movl   $0x80108e36,(%esp)
80105e55:	e8 e3 a6 ff ff       	call   8010053d <panic>
    if(de.inum != 0)
80105e5a:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105e5e:	66 85 c0             	test   %ax,%ax
80105e61:	74 07                	je     80105e6a <isdirempty+0x51>
      return 0;
80105e63:	b8 00 00 00 00       	mov    $0x0,%eax
80105e68:	eb 1b                	jmp    80105e85 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e6d:	83 c0 10             	add    $0x10,%eax
80105e70:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e73:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e76:	8b 45 08             	mov    0x8(%ebp),%eax
80105e79:	8b 40 18             	mov    0x18(%eax),%eax
80105e7c:	39 c2                	cmp    %eax,%edx
80105e7e:	72 a8                	jb     80105e28 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105e80:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105e85:	c9                   	leave  
80105e86:	c3                   	ret    

80105e87 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105e87:	55                   	push   %ebp
80105e88:	89 e5                	mov    %esp,%ebp
80105e8a:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105e8d:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105e90:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e9b:	e8 72 fa ff ff       	call   80105912 <argstr>
80105ea0:	85 c0                	test   %eax,%eax
80105ea2:	79 0a                	jns    80105eae <sys_unlink+0x27>
    return -1;
80105ea4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ea9:	e9 af 01 00 00       	jmp    8010605d <sys_unlink+0x1d6>

  begin_op();
80105eae:	e8 ea d5 ff ff       	call   8010349d <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105eb3:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105eb6:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105eb9:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ebd:	89 04 24             	mov    %eax,(%esp)
80105ec0:	e8 af c5 ff ff       	call   80102474 <nameiparent>
80105ec5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ec8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ecc:	75 0f                	jne    80105edd <sys_unlink+0x56>
    end_op();
80105ece:	e8 4b d6 ff ff       	call   8010351e <end_op>
    return -1;
80105ed3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ed8:	e9 80 01 00 00       	jmp    8010605d <sys_unlink+0x1d6>
  }

  ilock(dp);
80105edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee0:	89 04 24             	mov    %eax,(%esp)
80105ee3:	e8 c8 b9 ff ff       	call   801018b0 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105ee8:	c7 44 24 04 48 8e 10 	movl   $0x80108e48,0x4(%esp)
80105eef:	80 
80105ef0:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ef3:	89 04 24             	mov    %eax,(%esp)
80105ef6:	e8 ac c1 ff ff       	call   801020a7 <namecmp>
80105efb:	85 c0                	test   %eax,%eax
80105efd:	0f 84 45 01 00 00    	je     80106048 <sys_unlink+0x1c1>
80105f03:	c7 44 24 04 4a 8e 10 	movl   $0x80108e4a,0x4(%esp)
80105f0a:	80 
80105f0b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f0e:	89 04 24             	mov    %eax,(%esp)
80105f11:	e8 91 c1 ff ff       	call   801020a7 <namecmp>
80105f16:	85 c0                	test   %eax,%eax
80105f18:	0f 84 2a 01 00 00    	je     80106048 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105f1e:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105f21:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f25:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f28:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f2f:	89 04 24             	mov    %eax,(%esp)
80105f32:	e8 92 c1 ff ff       	call   801020c9 <dirlookup>
80105f37:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f3a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f3e:	0f 84 03 01 00 00    	je     80106047 <sys_unlink+0x1c0>
    goto bad;
  ilock(ip);
80105f44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f47:	89 04 24             	mov    %eax,(%esp)
80105f4a:	e8 61 b9 ff ff       	call   801018b0 <ilock>

  if(ip->nlink < 1)
80105f4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f52:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f56:	66 85 c0             	test   %ax,%ax
80105f59:	7f 0c                	jg     80105f67 <sys_unlink+0xe0>
    panic("unlink: nlink < 1");
80105f5b:	c7 04 24 4d 8e 10 80 	movl   $0x80108e4d,(%esp)
80105f62:	e8 d6 a5 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105f67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f6a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105f6e:	66 83 f8 01          	cmp    $0x1,%ax
80105f72:	75 1f                	jne    80105f93 <sys_unlink+0x10c>
80105f74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f77:	89 04 24             	mov    %eax,(%esp)
80105f7a:	e8 9a fe ff ff       	call   80105e19 <isdirempty>
80105f7f:	85 c0                	test   %eax,%eax
80105f81:	75 10                	jne    80105f93 <sys_unlink+0x10c>
    iunlockput(ip);
80105f83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f86:	89 04 24             	mov    %eax,(%esp)
80105f89:	e8 a6 bb ff ff       	call   80101b34 <iunlockput>
    goto bad;
80105f8e:	e9 b5 00 00 00       	jmp    80106048 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105f93:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105f9a:	00 
80105f9b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105fa2:	00 
80105fa3:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105fa6:	89 04 24             	mov    %eax,(%esp)
80105fa9:	e8 78 f5 ff ff       	call   80105526 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105fae:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105fb1:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105fb8:	00 
80105fb9:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fbd:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105fc0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc7:	89 04 24             	mov    %eax,(%esp)
80105fca:	e8 42 bf ff ff       	call   80101f11 <writei>
80105fcf:	83 f8 10             	cmp    $0x10,%eax
80105fd2:	74 0c                	je     80105fe0 <sys_unlink+0x159>
    panic("unlink: writei");
80105fd4:	c7 04 24 5f 8e 10 80 	movl   $0x80108e5f,(%esp)
80105fdb:	e8 5d a5 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
80105fe0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105fe7:	66 83 f8 01          	cmp    $0x1,%ax
80105feb:	75 1c                	jne    80106009 <sys_unlink+0x182>
    dp->nlink--;
80105fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ff0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ff4:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ffa:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105ffe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106001:	89 04 24             	mov    %eax,(%esp)
80106004:	e8 eb b6 ff ff       	call   801016f4 <iupdate>
  }
  iunlockput(dp);
80106009:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010600c:	89 04 24             	mov    %eax,(%esp)
8010600f:	e8 20 bb ff ff       	call   80101b34 <iunlockput>

  ip->nlink--;
80106014:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106017:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010601b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010601e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106021:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106025:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106028:	89 04 24             	mov    %eax,(%esp)
8010602b:	e8 c4 b6 ff ff       	call   801016f4 <iupdate>
  iunlockput(ip);
80106030:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106033:	89 04 24             	mov    %eax,(%esp)
80106036:	e8 f9 ba ff ff       	call   80101b34 <iunlockput>

  end_op();
8010603b:	e8 de d4 ff ff       	call   8010351e <end_op>

  return 0;
80106040:	b8 00 00 00 00       	mov    $0x0,%eax
80106045:	eb 16                	jmp    8010605d <sys_unlink+0x1d6>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80106047:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80106048:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010604b:	89 04 24             	mov    %eax,(%esp)
8010604e:	e8 e1 ba ff ff       	call   80101b34 <iunlockput>
  end_op();
80106053:	e8 c6 d4 ff ff       	call   8010351e <end_op>
  return -1;
80106058:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010605d:	c9                   	leave  
8010605e:	c3                   	ret    

8010605f <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010605f:	55                   	push   %ebp
80106060:	89 e5                	mov    %esp,%ebp
80106062:	83 ec 48             	sub    $0x48,%esp
80106065:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106068:	8b 55 10             	mov    0x10(%ebp),%edx
8010606b:	8b 45 14             	mov    0x14(%ebp),%eax
8010606e:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106072:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106076:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010607a:	8d 45 de             	lea    -0x22(%ebp),%eax
8010607d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106081:	8b 45 08             	mov    0x8(%ebp),%eax
80106084:	89 04 24             	mov    %eax,(%esp)
80106087:	e8 e8 c3 ff ff       	call   80102474 <nameiparent>
8010608c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010608f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106093:	75 0a                	jne    8010609f <create+0x40>
    return 0;
80106095:	b8 00 00 00 00       	mov    $0x0,%eax
8010609a:	e9 7e 01 00 00       	jmp    8010621d <create+0x1be>
  ilock(dp);
8010609f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060a2:	89 04 24             	mov    %eax,(%esp)
801060a5:	e8 06 b8 ff ff       	call   801018b0 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
801060aa:	8d 45 ec             	lea    -0x14(%ebp),%eax
801060ad:	89 44 24 08          	mov    %eax,0x8(%esp)
801060b1:	8d 45 de             	lea    -0x22(%ebp),%eax
801060b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801060b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060bb:	89 04 24             	mov    %eax,(%esp)
801060be:	e8 06 c0 ff ff       	call   801020c9 <dirlookup>
801060c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060c6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060ca:	74 47                	je     80106113 <create+0xb4>
    iunlockput(dp);
801060cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060cf:	89 04 24             	mov    %eax,(%esp)
801060d2:	e8 5d ba ff ff       	call   80101b34 <iunlockput>
    ilock(ip);
801060d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060da:	89 04 24             	mov    %eax,(%esp)
801060dd:	e8 ce b7 ff ff       	call   801018b0 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801060e2:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801060e7:	75 15                	jne    801060fe <create+0x9f>
801060e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ec:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801060f0:	66 83 f8 02          	cmp    $0x2,%ax
801060f4:	75 08                	jne    801060fe <create+0x9f>
      return ip;
801060f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f9:	e9 1f 01 00 00       	jmp    8010621d <create+0x1be>
    iunlockput(ip);
801060fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106101:	89 04 24             	mov    %eax,(%esp)
80106104:	e8 2b ba ff ff       	call   80101b34 <iunlockput>
    return 0;
80106109:	b8 00 00 00 00       	mov    $0x0,%eax
8010610e:	e9 0a 01 00 00       	jmp    8010621d <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106113:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010611a:	8b 00                	mov    (%eax),%eax
8010611c:	89 54 24 04          	mov    %edx,0x4(%esp)
80106120:	89 04 24             	mov    %eax,(%esp)
80106123:	e8 ef b4 ff ff       	call   80101617 <ialloc>
80106128:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010612b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010612f:	75 0c                	jne    8010613d <create+0xde>
    panic("create: ialloc");
80106131:	c7 04 24 6e 8e 10 80 	movl   $0x80108e6e,(%esp)
80106138:	e8 00 a4 ff ff       	call   8010053d <panic>

  ilock(ip);
8010613d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106140:	89 04 24             	mov    %eax,(%esp)
80106143:	e8 68 b7 ff ff       	call   801018b0 <ilock>
  ip->major = major;
80106148:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010614b:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010614f:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106153:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106156:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010615a:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
8010615e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106161:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106167:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010616a:	89 04 24             	mov    %eax,(%esp)
8010616d:	e8 82 b5 ff ff       	call   801016f4 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80106172:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106177:	75 6a                	jne    801061e3 <create+0x184>
    dp->nlink++;  // for ".."
80106179:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010617c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106180:	8d 50 01             	lea    0x1(%eax),%edx
80106183:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106186:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
8010618a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010618d:	89 04 24             	mov    %eax,(%esp)
80106190:	e8 5f b5 ff ff       	call   801016f4 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106195:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106198:	8b 40 04             	mov    0x4(%eax),%eax
8010619b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010619f:	c7 44 24 04 48 8e 10 	movl   $0x80108e48,0x4(%esp)
801061a6:	80 
801061a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061aa:	89 04 24             	mov    %eax,(%esp)
801061ad:	e8 df bf ff ff       	call   80102191 <dirlink>
801061b2:	85 c0                	test   %eax,%eax
801061b4:	78 21                	js     801061d7 <create+0x178>
801061b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061b9:	8b 40 04             	mov    0x4(%eax),%eax
801061bc:	89 44 24 08          	mov    %eax,0x8(%esp)
801061c0:	c7 44 24 04 4a 8e 10 	movl   $0x80108e4a,0x4(%esp)
801061c7:	80 
801061c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061cb:	89 04 24             	mov    %eax,(%esp)
801061ce:	e8 be bf ff ff       	call   80102191 <dirlink>
801061d3:	85 c0                	test   %eax,%eax
801061d5:	79 0c                	jns    801061e3 <create+0x184>
      panic("create dots");
801061d7:	c7 04 24 7d 8e 10 80 	movl   $0x80108e7d,(%esp)
801061de:	e8 5a a3 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801061e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061e6:	8b 40 04             	mov    0x4(%eax),%eax
801061e9:	89 44 24 08          	mov    %eax,0x8(%esp)
801061ed:	8d 45 de             	lea    -0x22(%ebp),%eax
801061f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801061f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f7:	89 04 24             	mov    %eax,(%esp)
801061fa:	e8 92 bf ff ff       	call   80102191 <dirlink>
801061ff:	85 c0                	test   %eax,%eax
80106201:	79 0c                	jns    8010620f <create+0x1b0>
    panic("create: dirlink");
80106203:	c7 04 24 89 8e 10 80 	movl   $0x80108e89,(%esp)
8010620a:	e8 2e a3 ff ff       	call   8010053d <panic>

  iunlockput(dp);
8010620f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106212:	89 04 24             	mov    %eax,(%esp)
80106215:	e8 1a b9 ff ff       	call   80101b34 <iunlockput>

  return ip;
8010621a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010621d:	c9                   	leave  
8010621e:	c3                   	ret    

8010621f <sys_open>:

int
sys_open(void)
{
8010621f:	55                   	push   %ebp
80106220:	89 e5                	mov    %esp,%ebp
80106222:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106225:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106228:	89 44 24 04          	mov    %eax,0x4(%esp)
8010622c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106233:	e8 da f6 ff ff       	call   80105912 <argstr>
80106238:	85 c0                	test   %eax,%eax
8010623a:	78 17                	js     80106253 <sys_open+0x34>
8010623c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010623f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106243:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010624a:	e8 33 f6 ff ff       	call   80105882 <argint>
8010624f:	85 c0                	test   %eax,%eax
80106251:	79 0a                	jns    8010625d <sys_open+0x3e>
    return -1;
80106253:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106258:	e9 5a 01 00 00       	jmp    801063b7 <sys_open+0x198>

  begin_op();
8010625d:	e8 3b d2 ff ff       	call   8010349d <begin_op>

  if(omode & O_CREATE){
80106262:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106265:	25 00 02 00 00       	and    $0x200,%eax
8010626a:	85 c0                	test   %eax,%eax
8010626c:	74 3b                	je     801062a9 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
8010626e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106271:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106278:	00 
80106279:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106280:	00 
80106281:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106288:	00 
80106289:	89 04 24             	mov    %eax,(%esp)
8010628c:	e8 ce fd ff ff       	call   8010605f <create>
80106291:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106294:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106298:	75 6b                	jne    80106305 <sys_open+0xe6>
      end_op();
8010629a:	e8 7f d2 ff ff       	call   8010351e <end_op>
      return -1;
8010629f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062a4:	e9 0e 01 00 00       	jmp    801063b7 <sys_open+0x198>
    }
  } else {
    if((ip = namei(path)) == 0){
801062a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062ac:	89 04 24             	mov    %eax,(%esp)
801062af:	e8 9e c1 ff ff       	call   80102452 <namei>
801062b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062bb:	75 0f                	jne    801062cc <sys_open+0xad>
      end_op();
801062bd:	e8 5c d2 ff ff       	call   8010351e <end_op>
      return -1;
801062c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062c7:	e9 eb 00 00 00       	jmp    801063b7 <sys_open+0x198>
    }
    ilock(ip);
801062cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062cf:	89 04 24             	mov    %eax,(%esp)
801062d2:	e8 d9 b5 ff ff       	call   801018b0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801062d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062da:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801062de:	66 83 f8 01          	cmp    $0x1,%ax
801062e2:	75 21                	jne    80106305 <sys_open+0xe6>
801062e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062e7:	85 c0                	test   %eax,%eax
801062e9:	74 1a                	je     80106305 <sys_open+0xe6>
      iunlockput(ip);
801062eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ee:	89 04 24             	mov    %eax,(%esp)
801062f1:	e8 3e b8 ff ff       	call   80101b34 <iunlockput>
      end_op();
801062f6:	e8 23 d2 ff ff       	call   8010351e <end_op>
      return -1;
801062fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106300:	e9 b2 00 00 00       	jmp    801063b7 <sys_open+0x198>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106305:	e8 5a ac ff ff       	call   80100f64 <filealloc>
8010630a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010630d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106311:	74 14                	je     80106327 <sys_open+0x108>
80106313:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106316:	89 04 24             	mov    %eax,(%esp)
80106319:	e8 2f f7 ff ff       	call   80105a4d <fdalloc>
8010631e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106321:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106325:	79 28                	jns    8010634f <sys_open+0x130>
    if(f)
80106327:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010632b:	74 0b                	je     80106338 <sys_open+0x119>
      fileclose(f);
8010632d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106330:	89 04 24             	mov    %eax,(%esp)
80106333:	e8 d4 ac ff ff       	call   8010100c <fileclose>
    iunlockput(ip);
80106338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010633b:	89 04 24             	mov    %eax,(%esp)
8010633e:	e8 f1 b7 ff ff       	call   80101b34 <iunlockput>
    end_op();
80106343:	e8 d6 d1 ff ff       	call   8010351e <end_op>
    return -1;
80106348:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010634d:	eb 68                	jmp    801063b7 <sys_open+0x198>
  }
  iunlock(ip);
8010634f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106352:	89 04 24             	mov    %eax,(%esp)
80106355:	e8 a4 b6 ff ff       	call   801019fe <iunlock>
  end_op();
8010635a:	e8 bf d1 ff ff       	call   8010351e <end_op>

  f->type = FD_INODE;
8010635f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106362:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106368:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010636b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010636e:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106371:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106374:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010637b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010637e:	83 e0 01             	and    $0x1,%eax
80106381:	85 c0                	test   %eax,%eax
80106383:	0f 94 c2             	sete   %dl
80106386:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106389:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010638c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010638f:	83 e0 01             	and    $0x1,%eax
80106392:	84 c0                	test   %al,%al
80106394:	75 0a                	jne    801063a0 <sys_open+0x181>
80106396:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106399:	83 e0 02             	and    $0x2,%eax
8010639c:	85 c0                	test   %eax,%eax
8010639e:	74 07                	je     801063a7 <sys_open+0x188>
801063a0:	b8 01 00 00 00       	mov    $0x1,%eax
801063a5:	eb 05                	jmp    801063ac <sys_open+0x18d>
801063a7:	b8 00 00 00 00       	mov    $0x0,%eax
801063ac:	89 c2                	mov    %eax,%edx
801063ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063b1:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801063b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801063b7:	c9                   	leave  
801063b8:	c3                   	ret    

801063b9 <sys_mkdir>:

int
sys_mkdir(void)
{
801063b9:	55                   	push   %ebp
801063ba:	89 e5                	mov    %esp,%ebp
801063bc:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801063bf:	e8 d9 d0 ff ff       	call   8010349d <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801063c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801063cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063d2:	e8 3b f5 ff ff       	call   80105912 <argstr>
801063d7:	85 c0                	test   %eax,%eax
801063d9:	78 2c                	js     80106407 <sys_mkdir+0x4e>
801063db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063de:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801063e5:	00 
801063e6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801063ed:	00 
801063ee:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801063f5:	00 
801063f6:	89 04 24             	mov    %eax,(%esp)
801063f9:	e8 61 fc ff ff       	call   8010605f <create>
801063fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106401:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106405:	75 0c                	jne    80106413 <sys_mkdir+0x5a>
    end_op();
80106407:	e8 12 d1 ff ff       	call   8010351e <end_op>
    return -1;
8010640c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106411:	eb 15                	jmp    80106428 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106416:	89 04 24             	mov    %eax,(%esp)
80106419:	e8 16 b7 ff ff       	call   80101b34 <iunlockput>
  end_op();
8010641e:	e8 fb d0 ff ff       	call   8010351e <end_op>
  return 0;
80106423:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106428:	c9                   	leave  
80106429:	c3                   	ret    

8010642a <sys_mknod>:

int
sys_mknod(void)
{
8010642a:	55                   	push   %ebp
8010642b:	89 e5                	mov    %esp,%ebp
8010642d:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106430:	e8 68 d0 ff ff       	call   8010349d <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106435:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106438:	89 44 24 04          	mov    %eax,0x4(%esp)
8010643c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106443:	e8 ca f4 ff ff       	call   80105912 <argstr>
80106448:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010644b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010644f:	78 5e                	js     801064af <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80106451:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106454:	89 44 24 04          	mov    %eax,0x4(%esp)
80106458:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010645f:	e8 1e f4 ff ff       	call   80105882 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106464:	85 c0                	test   %eax,%eax
80106466:	78 47                	js     801064af <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106468:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010646b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010646f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106476:	e8 07 f4 ff ff       	call   80105882 <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010647b:	85 c0                	test   %eax,%eax
8010647d:	78 30                	js     801064af <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010647f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106482:	0f bf c8             	movswl %ax,%ecx
80106485:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106488:	0f bf d0             	movswl %ax,%edx
8010648b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010648e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106492:	89 54 24 08          	mov    %edx,0x8(%esp)
80106496:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010649d:	00 
8010649e:	89 04 24             	mov    %eax,(%esp)
801064a1:	e8 b9 fb ff ff       	call   8010605f <create>
801064a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064ad:	75 0c                	jne    801064bb <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801064af:	e8 6a d0 ff ff       	call   8010351e <end_op>
    return -1;
801064b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064b9:	eb 15                	jmp    801064d0 <sys_mknod+0xa6>
  }
  iunlockput(ip);
801064bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064be:	89 04 24             	mov    %eax,(%esp)
801064c1:	e8 6e b6 ff ff       	call   80101b34 <iunlockput>
  end_op();
801064c6:	e8 53 d0 ff ff       	call   8010351e <end_op>
  return 0;
801064cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064d0:	c9                   	leave  
801064d1:	c3                   	ret    

801064d2 <sys_chdir>:

int
sys_chdir(void)
{
801064d2:	55                   	push   %ebp
801064d3:	89 e5                	mov    %esp,%ebp
801064d5:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801064d8:	e8 c0 cf ff ff       	call   8010349d <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801064dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801064e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064eb:	e8 22 f4 ff ff       	call   80105912 <argstr>
801064f0:	85 c0                	test   %eax,%eax
801064f2:	78 14                	js     80106508 <sys_chdir+0x36>
801064f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064f7:	89 04 24             	mov    %eax,(%esp)
801064fa:	e8 53 bf ff ff       	call   80102452 <namei>
801064ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106502:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106506:	75 0c                	jne    80106514 <sys_chdir+0x42>
    end_op();
80106508:	e8 11 d0 ff ff       	call   8010351e <end_op>
    return -1;
8010650d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106512:	eb 61                	jmp    80106575 <sys_chdir+0xa3>
  }
  ilock(ip);
80106514:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106517:	89 04 24             	mov    %eax,(%esp)
8010651a:	e8 91 b3 ff ff       	call   801018b0 <ilock>
  if(ip->type != T_DIR){
8010651f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106522:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106526:	66 83 f8 01          	cmp    $0x1,%ax
8010652a:	74 17                	je     80106543 <sys_chdir+0x71>
    iunlockput(ip);
8010652c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010652f:	89 04 24             	mov    %eax,(%esp)
80106532:	e8 fd b5 ff ff       	call   80101b34 <iunlockput>
    end_op();
80106537:	e8 e2 cf ff ff       	call   8010351e <end_op>
    return -1;
8010653c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106541:	eb 32                	jmp    80106575 <sys_chdir+0xa3>
  }
  iunlock(ip);
80106543:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106546:	89 04 24             	mov    %eax,(%esp)
80106549:	e8 b0 b4 ff ff       	call   801019fe <iunlock>
  iput(proc->cwd);
8010654e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106554:	8b 40 68             	mov    0x68(%eax),%eax
80106557:	89 04 24             	mov    %eax,(%esp)
8010655a:	e8 04 b5 ff ff       	call   80101a63 <iput>
  end_op();
8010655f:	e8 ba cf ff ff       	call   8010351e <end_op>
  proc->cwd = ip;
80106564:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010656a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010656d:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106570:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106575:	c9                   	leave  
80106576:	c3                   	ret    

80106577 <sys_exec>:

int
sys_exec(void)
{
80106577:	55                   	push   %ebp
80106578:	89 e5                	mov    %esp,%ebp
8010657a:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106580:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106583:	89 44 24 04          	mov    %eax,0x4(%esp)
80106587:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010658e:	e8 7f f3 ff ff       	call   80105912 <argstr>
80106593:	85 c0                	test   %eax,%eax
80106595:	78 1a                	js     801065b1 <sys_exec+0x3a>
80106597:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010659d:	89 44 24 04          	mov    %eax,0x4(%esp)
801065a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801065a8:	e8 d5 f2 ff ff       	call   80105882 <argint>
801065ad:	85 c0                	test   %eax,%eax
801065af:	79 0a                	jns    801065bb <sys_exec+0x44>
    return -1;
801065b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065b6:	e9 cc 00 00 00       	jmp    80106687 <sys_exec+0x110>
  }
  memset(argv, 0, sizeof(argv));
801065bb:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801065c2:	00 
801065c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801065ca:	00 
801065cb:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801065d1:	89 04 24             	mov    %eax,(%esp)
801065d4:	e8 4d ef ff ff       	call   80105526 <memset>
  for(i=0;; i++){
801065d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801065e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065e3:	83 f8 1f             	cmp    $0x1f,%eax
801065e6:	76 0a                	jbe    801065f2 <sys_exec+0x7b>
      return -1;
801065e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065ed:	e9 95 00 00 00       	jmp    80106687 <sys_exec+0x110>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801065f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065f5:	c1 e0 02             	shl    $0x2,%eax
801065f8:	89 c2                	mov    %eax,%edx
801065fa:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106600:	01 c2                	add    %eax,%edx
80106602:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106608:	89 44 24 04          	mov    %eax,0x4(%esp)
8010660c:	89 14 24             	mov    %edx,(%esp)
8010660f:	e8 d0 f1 ff ff       	call   801057e4 <fetchint>
80106614:	85 c0                	test   %eax,%eax
80106616:	79 07                	jns    8010661f <sys_exec+0xa8>
      return -1;
80106618:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010661d:	eb 68                	jmp    80106687 <sys_exec+0x110>
    if(uarg == 0){
8010661f:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106625:	85 c0                	test   %eax,%eax
80106627:	75 26                	jne    8010664f <sys_exec+0xd8>
      argv[i] = 0;
80106629:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010662c:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106633:	00 00 00 00 
      break;
80106637:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106638:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010663b:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106641:	89 54 24 04          	mov    %edx,0x4(%esp)
80106645:	89 04 24             	mov    %eax,(%esp)
80106648:	e8 af a4 ff ff       	call   80100afc <exec>
8010664d:	eb 38                	jmp    80106687 <sys_exec+0x110>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010664f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106652:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106659:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010665f:	01 c2                	add    %eax,%edx
80106661:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106667:	89 54 24 04          	mov    %edx,0x4(%esp)
8010666b:	89 04 24             	mov    %eax,(%esp)
8010666e:	e8 ab f1 ff ff       	call   8010581e <fetchstr>
80106673:	85 c0                	test   %eax,%eax
80106675:	79 07                	jns    8010667e <sys_exec+0x107>
      return -1;
80106677:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010667c:	eb 09                	jmp    80106687 <sys_exec+0x110>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010667e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106682:	e9 59 ff ff ff       	jmp    801065e0 <sys_exec+0x69>
  return exec(path, argv);
}
80106687:	c9                   	leave  
80106688:	c3                   	ret    

80106689 <sys_pipe>:

int
sys_pipe(void)
{
80106689:	55                   	push   %ebp
8010668a:	89 e5                	mov    %esp,%ebp
8010668c:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010668f:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106696:	00 
80106697:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010669a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010669e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066a5:	e8 06 f2 ff ff       	call   801058b0 <argptr>
801066aa:	85 c0                	test   %eax,%eax
801066ac:	79 0a                	jns    801066b8 <sys_pipe+0x2f>
    return -1;
801066ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066b3:	e9 9b 00 00 00       	jmp    80106753 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
801066b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801066bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801066bf:	8d 45 e8             	lea    -0x18(%ebp),%eax
801066c2:	89 04 24             	mov    %eax,(%esp)
801066c5:	e8 02 d9 ff ff       	call   80103fcc <pipealloc>
801066ca:	85 c0                	test   %eax,%eax
801066cc:	79 07                	jns    801066d5 <sys_pipe+0x4c>
    return -1;
801066ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066d3:	eb 7e                	jmp    80106753 <sys_pipe+0xca>
  fd0 = -1;
801066d5:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801066dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801066df:	89 04 24             	mov    %eax,(%esp)
801066e2:	e8 66 f3 ff ff       	call   80105a4d <fdalloc>
801066e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801066ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066ee:	78 14                	js     80106704 <sys_pipe+0x7b>
801066f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801066f3:	89 04 24             	mov    %eax,(%esp)
801066f6:	e8 52 f3 ff ff       	call   80105a4d <fdalloc>
801066fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801066fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106702:	79 37                	jns    8010673b <sys_pipe+0xb2>
    if(fd0 >= 0)
80106704:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106708:	78 14                	js     8010671e <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
8010670a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106710:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106713:	83 c2 08             	add    $0x8,%edx
80106716:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010671d:	00 
    fileclose(rf);
8010671e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106721:	89 04 24             	mov    %eax,(%esp)
80106724:	e8 e3 a8 ff ff       	call   8010100c <fileclose>
    fileclose(wf);
80106729:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010672c:	89 04 24             	mov    %eax,(%esp)
8010672f:	e8 d8 a8 ff ff       	call   8010100c <fileclose>
    return -1;
80106734:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106739:	eb 18                	jmp    80106753 <sys_pipe+0xca>
  }
  fd[0] = fd0;
8010673b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010673e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106741:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106743:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106746:	8d 50 04             	lea    0x4(%eax),%edx
80106749:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010674c:	89 02                	mov    %eax,(%edx)
  return 0;
8010674e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106753:	c9                   	leave  
80106754:	c3                   	ret    
80106755:	00 00                	add    %al,(%eax)
	...

80106758 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106758:	55                   	push   %ebp
80106759:	89 e5                	mov    %esp,%ebp
8010675b:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010675e:	e8 ea df ff ff       	call   8010474d <fork>
}
80106763:	c9                   	leave  
80106764:	c3                   	ret    

80106765 <sys_forkjob>:

int
sys_forkjob(void)
{
80106765:	55                   	push   %ebp
80106766:	89 e5                	mov    %esp,%ebp
80106768:	83 ec 28             	sub    $0x28,%esp
  char* command;
  argptr(0, (char**) &command, sizeof(char*));
8010676b:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80106772:	00 
80106773:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106776:	89 44 24 04          	mov    %eax,0x4(%esp)
8010677a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106781:	e8 2a f1 ff ff       	call   801058b0 <argptr>
  
  return forkjob(command);
80106786:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106789:	89 04 24             	mov    %eax,(%esp)
8010678c:	e8 76 e1 ff ff       	call   80104907 <forkjob>
}
80106791:	c9                   	leave  
80106792:	c3                   	ret    

80106793 <sys_exit>:

int
sys_exit()
{
80106793:	55                   	push   %ebp
80106794:	89 e5                	mov    %esp,%ebp
80106796:	83 ec 28             	sub    $0x28,%esp
  int status;
  argint(0, &status);
80106799:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010679c:	89 44 24 04          	mov    %eax,0x4(%esp)
801067a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067a7:	e8 d6 f0 ff ff       	call   80105882 <argint>
  //cprintf("enterted: sys_exit, %d\n", status);
  exit(status);
801067ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067af:	89 04 24             	mov    %eax,(%esp)
801067b2:	e8 e6 e2 ff ff       	call   80104a9d <exit>
  return 0;  // not reached
801067b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067bc:	c9                   	leave  
801067bd:	c3                   	ret    

801067be <sys_wait>:

int
sys_wait(void)
{
801067be:	55                   	push   %ebp
801067bf:	89 e5                	mov    %esp,%ebp
801067c1:	83 ec 28             	sub    $0x28,%esp
  int* status;
  argptr(0, (char**) &status, sizeof(int*));
801067c4:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801067cb:	00 
801067cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801067cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801067d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067da:	e8 d1 f0 ff ff       	call   801058b0 <argptr>
  return wait(status);
801067df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e2:	89 04 24             	mov    %eax,(%esp)
801067e5:	e8 e4 e3 ff ff       	call   80104bce <wait>
}
801067ea:	c9                   	leave  
801067eb:	c3                   	ret    

801067ec <sys_waitpid>:


int
sys_waitpid(void)
{
801067ec:	55                   	push   %ebp
801067ed:	89 e5                	mov    %esp,%ebp
801067ef:	83 ec 28             	sub    $0x28,%esp
  int 	pid;
  int* 	status;
  int 	options;
  
  argint(0, &pid);
801067f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801067f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801067f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106800:	e8 7d f0 ff ff       	call   80105882 <argint>
  argptr(1, (char**) &status, sizeof(int*));
80106805:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
8010680c:	00 
8010680d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106810:	89 44 24 04          	mov    %eax,0x4(%esp)
80106814:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010681b:	e8 90 f0 ff ff       	call   801058b0 <argptr>
  argint(2, &options);
80106820:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106823:	89 44 24 04          	mov    %eax,0x4(%esp)
80106827:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010682e:	e8 4f f0 ff ff       	call   80105882 <argint>
  
  cprintf("pid = %d, status = %d, options = %d\n", pid, status, options );
80106833:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80106836:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010683c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106840:	89 54 24 08          	mov    %edx,0x8(%esp)
80106844:	89 44 24 04          	mov    %eax,0x4(%esp)
80106848:	c7 04 24 9c 8e 10 80 	movl   $0x80108e9c,(%esp)
8010684f:	e8 4d 9b ff ff       	call   801003a1 <cprintf>
  
  return waitpid(pid, status, options);
80106854:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80106857:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010685a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010685d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106861:	89 54 24 04          	mov    %edx,0x4(%esp)
80106865:	89 04 24             	mov    %eax,(%esp)
80106868:	e8 93 e4 ff ff       	call   80104d00 <waitpid>
}
8010686d:	c9                   	leave  
8010686e:	c3                   	ret    

8010686f <sys_kill>:

int
sys_kill(void)
{
8010686f:	55                   	push   %ebp
80106870:	89 e5                	mov    %esp,%ebp
80106872:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106875:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106878:	89 44 24 04          	mov    %eax,0x4(%esp)
8010687c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106883:	e8 fa ef ff ff       	call   80105882 <argint>
80106888:	85 c0                	test   %eax,%eax
8010688a:	79 07                	jns    80106893 <sys_kill+0x24>
    return -1;
8010688c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106891:	eb 0b                	jmp    8010689e <sys_kill+0x2f>
  return kill(pid);
80106893:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106896:	89 04 24             	mov    %eax,(%esp)
80106899:	e8 5a e8 ff ff       	call   801050f8 <kill>
}
8010689e:	c9                   	leave  
8010689f:	c3                   	ret    

801068a0 <sys_getpid>:

int
sys_getpid(void)
{
801068a0:	55                   	push   %ebp
801068a1:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801068a3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068a9:	8b 40 10             	mov    0x10(%eax),%eax
}
801068ac:	5d                   	pop    %ebp
801068ad:	c3                   	ret    

801068ae <sys_sbrk>:

int
sys_sbrk(void)
{
801068ae:	55                   	push   %ebp
801068af:	89 e5                	mov    %esp,%ebp
801068b1:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801068b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801068bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068c2:	e8 bb ef ff ff       	call   80105882 <argint>
801068c7:	85 c0                	test   %eax,%eax
801068c9:	79 07                	jns    801068d2 <sys_sbrk+0x24>
    return -1;
801068cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068d0:	eb 24                	jmp    801068f6 <sys_sbrk+0x48>
  addr = proc->sz;
801068d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068d8:	8b 00                	mov    (%eax),%eax
801068da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801068dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068e0:	89 04 24             	mov    %eax,(%esp)
801068e3:	e8 7d dd ff ff       	call   80104665 <growproc>
801068e8:	85 c0                	test   %eax,%eax
801068ea:	79 07                	jns    801068f3 <sys_sbrk+0x45>
    return -1;
801068ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068f1:	eb 03                	jmp    801068f6 <sys_sbrk+0x48>
  return addr;
801068f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801068f6:	c9                   	leave  
801068f7:	c3                   	ret    

801068f8 <sys_sleep>:

int
sys_sleep(void)
{
801068f8:	55                   	push   %ebp
801068f9:	89 e5                	mov    %esp,%ebp
801068fb:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801068fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106901:	89 44 24 04          	mov    %eax,0x4(%esp)
80106905:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010690c:	e8 71 ef ff ff       	call   80105882 <argint>
80106911:	85 c0                	test   %eax,%eax
80106913:	79 07                	jns    8010691c <sys_sleep+0x24>
    return -1;
80106915:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010691a:	eb 6c                	jmp    80106988 <sys_sleep+0x90>
  acquire(&tickslock);
8010691c:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
80106923:	e8 af e9 ff ff       	call   801052d7 <acquire>
  ticks0 = ticks;
80106928:	a1 20 66 11 80       	mov    0x80116620,%eax
8010692d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106930:	eb 34                	jmp    80106966 <sys_sleep+0x6e>
    if(proc->killed){
80106932:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106938:	8b 40 24             	mov    0x24(%eax),%eax
8010693b:	85 c0                	test   %eax,%eax
8010693d:	74 13                	je     80106952 <sys_sleep+0x5a>
      release(&tickslock);
8010693f:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
80106946:	e8 ee e9 ff ff       	call   80105339 <release>
      return -1;
8010694b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106950:	eb 36                	jmp    80106988 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106952:	c7 44 24 04 e0 5d 11 	movl   $0x80115de0,0x4(%esp)
80106959:	80 
8010695a:	c7 04 24 20 66 11 80 	movl   $0x80116620,(%esp)
80106961:	e8 8b e6 ff ff       	call   80104ff1 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106966:	a1 20 66 11 80       	mov    0x80116620,%eax
8010696b:	89 c2                	mov    %eax,%edx
8010696d:	2b 55 f4             	sub    -0xc(%ebp),%edx
80106970:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106973:	39 c2                	cmp    %eax,%edx
80106975:	72 bb                	jb     80106932 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106977:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
8010697e:	e8 b6 e9 ff ff       	call   80105339 <release>
  return 0;
80106983:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106988:	c9                   	leave  
80106989:	c3                   	ret    

8010698a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010698a:	55                   	push   %ebp
8010698b:	89 e5                	mov    %esp,%ebp
8010698d:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
80106990:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
80106997:	e8 3b e9 ff ff       	call   801052d7 <acquire>
  xticks = ticks;
8010699c:	a1 20 66 11 80       	mov    0x80116620,%eax
801069a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801069a4:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
801069ab:	e8 89 e9 ff ff       	call   80105339 <release>
  return xticks;
801069b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801069b3:	c9                   	leave  
801069b4:	c3                   	ret    
801069b5:	00 00                	add    %al,(%eax)
	...

801069b8 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801069b8:	55                   	push   %ebp
801069b9:	89 e5                	mov    %esp,%ebp
801069bb:	83 ec 08             	sub    $0x8,%esp
801069be:	8b 55 08             	mov    0x8(%ebp),%edx
801069c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801069c4:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801069c8:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801069cb:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801069cf:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801069d3:	ee                   	out    %al,(%dx)
}
801069d4:	c9                   	leave  
801069d5:	c3                   	ret    

801069d6 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801069d6:	55                   	push   %ebp
801069d7:	89 e5                	mov    %esp,%ebp
801069d9:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801069dc:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
801069e3:	00 
801069e4:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
801069eb:	e8 c8 ff ff ff       	call   801069b8 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801069f0:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
801069f7:	00 
801069f8:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801069ff:	e8 b4 ff ff ff       	call   801069b8 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106a04:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106a0b:	00 
80106a0c:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106a13:	e8 a0 ff ff ff       	call   801069b8 <outb>
  picenable(IRQ_TIMER);
80106a18:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a1f:	e8 31 d4 ff ff       	call   80103e55 <picenable>
}
80106a24:	c9                   	leave  
80106a25:	c3                   	ret    
	...

80106a28 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106a28:	1e                   	push   %ds
  pushl %es
80106a29:	06                   	push   %es
  pushl %fs
80106a2a:	0f a0                	push   %fs
  pushl %gs
80106a2c:	0f a8                	push   %gs
  pushal
80106a2e:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106a2f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106a33:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106a35:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106a37:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106a3b:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106a3d:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106a3f:	54                   	push   %esp
  call trap
80106a40:	e8 de 01 00 00       	call   80106c23 <trap>
  addl $4, %esp
80106a45:	83 c4 04             	add    $0x4,%esp

80106a48 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106a48:	61                   	popa   
  popl %gs
80106a49:	0f a9                	pop    %gs
  popl %fs
80106a4b:	0f a1                	pop    %fs
  popl %es
80106a4d:	07                   	pop    %es
  popl %ds
80106a4e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106a4f:	83 c4 08             	add    $0x8,%esp
  iret
80106a52:	cf                   	iret   
	...

80106a54 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106a54:	55                   	push   %ebp
80106a55:	89 e5                	mov    %esp,%ebp
80106a57:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a5d:	83 e8 01             	sub    $0x1,%eax
80106a60:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106a64:	8b 45 08             	mov    0x8(%ebp),%eax
80106a67:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106a6b:	8b 45 08             	mov    0x8(%ebp),%eax
80106a6e:	c1 e8 10             	shr    $0x10,%eax
80106a71:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106a75:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106a78:	0f 01 18             	lidtl  (%eax)
}
80106a7b:	c9                   	leave  
80106a7c:	c3                   	ret    

80106a7d <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106a7d:	55                   	push   %ebp
80106a7e:	89 e5                	mov    %esp,%ebp
80106a80:	53                   	push   %ebx
80106a81:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106a84:	0f 20 d3             	mov    %cr2,%ebx
80106a87:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
80106a8a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80106a8d:	83 c4 10             	add    $0x10,%esp
80106a90:	5b                   	pop    %ebx
80106a91:	5d                   	pop    %ebp
80106a92:	c3                   	ret    

80106a93 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106a93:	55                   	push   %ebp
80106a94:	89 e5                	mov    %esp,%ebp
80106a96:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106a99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106aa0:	e9 c3 00 00 00       	jmp    80106b68 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aa8:	8b 04 85 a0 c0 10 80 	mov    -0x7fef3f60(,%eax,4),%eax
80106aaf:	89 c2                	mov    %eax,%edx
80106ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ab4:	66 89 14 c5 20 5e 11 	mov    %dx,-0x7feea1e0(,%eax,8)
80106abb:	80 
80106abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106abf:	66 c7 04 c5 22 5e 11 	movw   $0x8,-0x7feea1de(,%eax,8)
80106ac6:	80 08 00 
80106ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106acc:	0f b6 14 c5 24 5e 11 	movzbl -0x7feea1dc(,%eax,8),%edx
80106ad3:	80 
80106ad4:	83 e2 e0             	and    $0xffffffe0,%edx
80106ad7:	88 14 c5 24 5e 11 80 	mov    %dl,-0x7feea1dc(,%eax,8)
80106ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ae1:	0f b6 14 c5 24 5e 11 	movzbl -0x7feea1dc(,%eax,8),%edx
80106ae8:	80 
80106ae9:	83 e2 1f             	and    $0x1f,%edx
80106aec:	88 14 c5 24 5e 11 80 	mov    %dl,-0x7feea1dc(,%eax,8)
80106af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106af6:	0f b6 14 c5 25 5e 11 	movzbl -0x7feea1db(,%eax,8),%edx
80106afd:	80 
80106afe:	83 e2 f0             	and    $0xfffffff0,%edx
80106b01:	83 ca 0e             	or     $0xe,%edx
80106b04:	88 14 c5 25 5e 11 80 	mov    %dl,-0x7feea1db(,%eax,8)
80106b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b0e:	0f b6 14 c5 25 5e 11 	movzbl -0x7feea1db(,%eax,8),%edx
80106b15:	80 
80106b16:	83 e2 ef             	and    $0xffffffef,%edx
80106b19:	88 14 c5 25 5e 11 80 	mov    %dl,-0x7feea1db(,%eax,8)
80106b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b23:	0f b6 14 c5 25 5e 11 	movzbl -0x7feea1db(,%eax,8),%edx
80106b2a:	80 
80106b2b:	83 e2 9f             	and    $0xffffff9f,%edx
80106b2e:	88 14 c5 25 5e 11 80 	mov    %dl,-0x7feea1db(,%eax,8)
80106b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b38:	0f b6 14 c5 25 5e 11 	movzbl -0x7feea1db(,%eax,8),%edx
80106b3f:	80 
80106b40:	83 ca 80             	or     $0xffffff80,%edx
80106b43:	88 14 c5 25 5e 11 80 	mov    %dl,-0x7feea1db(,%eax,8)
80106b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b4d:	8b 04 85 a0 c0 10 80 	mov    -0x7fef3f60(,%eax,4),%eax
80106b54:	c1 e8 10             	shr    $0x10,%eax
80106b57:	89 c2                	mov    %eax,%edx
80106b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b5c:	66 89 14 c5 26 5e 11 	mov    %dx,-0x7feea1da(,%eax,8)
80106b63:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106b64:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106b68:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106b6f:	0f 8e 30 ff ff ff    	jle    80106aa5 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106b75:	a1 a0 c1 10 80       	mov    0x8010c1a0,%eax
80106b7a:	66 a3 20 60 11 80    	mov    %ax,0x80116020
80106b80:	66 c7 05 22 60 11 80 	movw   $0x8,0x80116022
80106b87:	08 00 
80106b89:	0f b6 05 24 60 11 80 	movzbl 0x80116024,%eax
80106b90:	83 e0 e0             	and    $0xffffffe0,%eax
80106b93:	a2 24 60 11 80       	mov    %al,0x80116024
80106b98:	0f b6 05 24 60 11 80 	movzbl 0x80116024,%eax
80106b9f:	83 e0 1f             	and    $0x1f,%eax
80106ba2:	a2 24 60 11 80       	mov    %al,0x80116024
80106ba7:	0f b6 05 25 60 11 80 	movzbl 0x80116025,%eax
80106bae:	83 c8 0f             	or     $0xf,%eax
80106bb1:	a2 25 60 11 80       	mov    %al,0x80116025
80106bb6:	0f b6 05 25 60 11 80 	movzbl 0x80116025,%eax
80106bbd:	83 e0 ef             	and    $0xffffffef,%eax
80106bc0:	a2 25 60 11 80       	mov    %al,0x80116025
80106bc5:	0f b6 05 25 60 11 80 	movzbl 0x80116025,%eax
80106bcc:	83 c8 60             	or     $0x60,%eax
80106bcf:	a2 25 60 11 80       	mov    %al,0x80116025
80106bd4:	0f b6 05 25 60 11 80 	movzbl 0x80116025,%eax
80106bdb:	83 c8 80             	or     $0xffffff80,%eax
80106bde:	a2 25 60 11 80       	mov    %al,0x80116025
80106be3:	a1 a0 c1 10 80       	mov    0x8010c1a0,%eax
80106be8:	c1 e8 10             	shr    $0x10,%eax
80106beb:	66 a3 26 60 11 80    	mov    %ax,0x80116026
  
  initlock(&tickslock, "time");
80106bf1:	c7 44 24 04 c4 8e 10 	movl   $0x80108ec4,0x4(%esp)
80106bf8:	80 
80106bf9:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
80106c00:	e8 b1 e6 ff ff       	call   801052b6 <initlock>
}
80106c05:	c9                   	leave  
80106c06:	c3                   	ret    

80106c07 <idtinit>:

void
idtinit(void)
{
80106c07:	55                   	push   %ebp
80106c08:	89 e5                	mov    %esp,%ebp
80106c0a:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106c0d:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106c14:	00 
80106c15:	c7 04 24 20 5e 11 80 	movl   $0x80115e20,(%esp)
80106c1c:	e8 33 fe ff ff       	call   80106a54 <lidt>
}
80106c21:	c9                   	leave  
80106c22:	c3                   	ret    

80106c23 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106c23:	55                   	push   %ebp
80106c24:	89 e5                	mov    %esp,%ebp
80106c26:	57                   	push   %edi
80106c27:	56                   	push   %esi
80106c28:	53                   	push   %ebx
80106c29:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106c2c:	8b 45 08             	mov    0x8(%ebp),%eax
80106c2f:	8b 40 30             	mov    0x30(%eax),%eax
80106c32:	83 f8 40             	cmp    $0x40,%eax
80106c35:	75 4c                	jne    80106c83 <trap+0x60>
    if(proc->killed)
80106c37:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c3d:	8b 40 24             	mov    0x24(%eax),%eax
80106c40:	85 c0                	test   %eax,%eax
80106c42:	74 0c                	je     80106c50 <trap+0x2d>
      exit(EXIT_STATUS_KILLED);
80106c44:	c7 04 24 de 00 00 00 	movl   $0xde,(%esp)
80106c4b:	e8 4d de ff ff       	call   80104a9d <exit>
    proc->tf = tf;
80106c50:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c56:	8b 55 08             	mov    0x8(%ebp),%edx
80106c59:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106c5c:	e8 e8 ec ff ff       	call   80105949 <syscall>
    if(proc->killed)
80106c61:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c67:	8b 40 24             	mov    0x24(%eax),%eax
80106c6a:	85 c0                	test   %eax,%eax
80106c6c:	0f 84 49 02 00 00    	je     80106ebb <trap+0x298>
      exit(EXIT_STATUS_KILLED);
80106c72:	c7 04 24 de 00 00 00 	movl   $0xde,(%esp)
80106c79:	e8 1f de ff ff       	call   80104a9d <exit>
    return;
80106c7e:	e9 38 02 00 00       	jmp    80106ebb <trap+0x298>
  }

  switch(tf->trapno){
80106c83:	8b 45 08             	mov    0x8(%ebp),%eax
80106c86:	8b 40 30             	mov    0x30(%eax),%eax
80106c89:	83 e8 20             	sub    $0x20,%eax
80106c8c:	83 f8 1f             	cmp    $0x1f,%eax
80106c8f:	0f 87 bc 00 00 00    	ja     80106d51 <trap+0x12e>
80106c95:	8b 04 85 6c 8f 10 80 	mov    -0x7fef7094(,%eax,4),%eax
80106c9c:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106c9e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106ca4:	0f b6 00             	movzbl (%eax),%eax
80106ca7:	84 c0                	test   %al,%al
80106ca9:	75 31                	jne    80106cdc <trap+0xb9>
      acquire(&tickslock);
80106cab:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
80106cb2:	e8 20 e6 ff ff       	call   801052d7 <acquire>
      ticks++;
80106cb7:	a1 20 66 11 80       	mov    0x80116620,%eax
80106cbc:	83 c0 01             	add    $0x1,%eax
80106cbf:	a3 20 66 11 80       	mov    %eax,0x80116620
      wakeup(&ticks);
80106cc4:	c7 04 24 20 66 11 80 	movl   $0x80116620,(%esp)
80106ccb:	e8 fd e3 ff ff       	call   801050cd <wakeup>
      release(&tickslock);
80106cd0:	c7 04 24 e0 5d 11 80 	movl   $0x80115de0,(%esp)
80106cd7:	e8 5d e6 ff ff       	call   80105339 <release>
    }
    lapiceoi();
80106cdc:	e8 7a c2 ff ff       	call   80102f5b <lapiceoi>
    break;
80106ce1:	e9 41 01 00 00       	jmp    80106e27 <trap+0x204>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106ce6:	e8 4e ba ff ff       	call   80102739 <ideintr>
    lapiceoi();
80106ceb:	e8 6b c2 ff ff       	call   80102f5b <lapiceoi>
    break;
80106cf0:	e9 32 01 00 00       	jmp    80106e27 <trap+0x204>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106cf5:	e8 15 c0 ff ff       	call   80102d0f <kbdintr>
    lapiceoi();
80106cfa:	e8 5c c2 ff ff       	call   80102f5b <lapiceoi>
    break;
80106cff:	e9 23 01 00 00       	jmp    80106e27 <trap+0x204>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106d04:	e8 b7 03 00 00       	call   801070c0 <uartintr>
    lapiceoi();
80106d09:	e8 4d c2 ff ff       	call   80102f5b <lapiceoi>
    break;
80106d0e:	e9 14 01 00 00       	jmp    80106e27 <trap+0x204>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80106d13:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106d16:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106d19:	8b 45 08             	mov    0x8(%ebp),%eax
80106d1c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106d20:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106d23:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106d29:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106d2c:	0f b6 c0             	movzbl %al,%eax
80106d2f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106d33:	89 54 24 08          	mov    %edx,0x8(%esp)
80106d37:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d3b:	c7 04 24 cc 8e 10 80 	movl   $0x80108ecc,(%esp)
80106d42:	e8 5a 96 ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106d47:	e8 0f c2 ff ff       	call   80102f5b <lapiceoi>
    break;
80106d4c:	e9 d6 00 00 00       	jmp    80106e27 <trap+0x204>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106d51:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d57:	85 c0                	test   %eax,%eax
80106d59:	74 11                	je     80106d6c <trap+0x149>
80106d5b:	8b 45 08             	mov    0x8(%ebp),%eax
80106d5e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d62:	0f b7 c0             	movzwl %ax,%eax
80106d65:	83 e0 03             	and    $0x3,%eax
80106d68:	85 c0                	test   %eax,%eax
80106d6a:	75 46                	jne    80106db2 <trap+0x18f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106d6c:	e8 0c fd ff ff       	call   80106a7d <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80106d71:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106d74:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106d77:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106d7e:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106d81:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106d84:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106d87:	8b 52 30             	mov    0x30(%edx),%edx
80106d8a:	89 44 24 10          	mov    %eax,0x10(%esp)
80106d8e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106d92:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106d96:	89 54 24 04          	mov    %edx,0x4(%esp)
80106d9a:	c7 04 24 f0 8e 10 80 	movl   $0x80108ef0,(%esp)
80106da1:	e8 fb 95 ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106da6:	c7 04 24 22 8f 10 80 	movl   $0x80108f22,(%esp)
80106dad:	e8 8b 97 ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106db2:	e8 c6 fc ff ff       	call   80106a7d <rcr2>
80106db7:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106db9:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106dbc:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106dbf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106dc5:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106dc8:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106dcb:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106dce:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106dd1:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106dd4:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106dd7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ddd:	83 c0 6c             	add    $0x6c,%eax
80106de0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106de3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106de9:	8b 40 10             	mov    0x10(%eax),%eax
80106dec:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106df0:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106df4:	89 74 24 14          	mov    %esi,0x14(%esp)
80106df8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106dfc:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106e00:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106e03:	89 54 24 08          	mov    %edx,0x8(%esp)
80106e07:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e0b:	c7 04 24 28 8f 10 80 	movl   $0x80108f28,(%esp)
80106e12:	e8 8a 95 ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106e17:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e1d:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106e24:	eb 01                	jmp    80106e27 <trap+0x204>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106e26:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106e27:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e2d:	85 c0                	test   %eax,%eax
80106e2f:	74 2b                	je     80106e5c <trap+0x239>
80106e31:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e37:	8b 40 24             	mov    0x24(%eax),%eax
80106e3a:	85 c0                	test   %eax,%eax
80106e3c:	74 1e                	je     80106e5c <trap+0x239>
80106e3e:	8b 45 08             	mov    0x8(%ebp),%eax
80106e41:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e45:	0f b7 c0             	movzwl %ax,%eax
80106e48:	83 e0 03             	and    $0x3,%eax
80106e4b:	83 f8 03             	cmp    $0x3,%eax
80106e4e:	75 0c                	jne    80106e5c <trap+0x239>
    exit(EXIT_STATUS_KILLED);
80106e50:	c7 04 24 de 00 00 00 	movl   $0xde,(%esp)
80106e57:	e8 41 dc ff ff       	call   80104a9d <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106e5c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e62:	85 c0                	test   %eax,%eax
80106e64:	74 1e                	je     80106e84 <trap+0x261>
80106e66:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e6c:	8b 40 0c             	mov    0xc(%eax),%eax
80106e6f:	83 f8 04             	cmp    $0x4,%eax
80106e72:	75 10                	jne    80106e84 <trap+0x261>
80106e74:	8b 45 08             	mov    0x8(%ebp),%eax
80106e77:	8b 40 30             	mov    0x30(%eax),%eax
80106e7a:	83 f8 20             	cmp    $0x20,%eax
80106e7d:	75 05                	jne    80106e84 <trap+0x261>
    yield();
80106e7f:	e8 0f e1 ff ff       	call   80104f93 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106e84:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e8a:	85 c0                	test   %eax,%eax
80106e8c:	74 2e                	je     80106ebc <trap+0x299>
80106e8e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e94:	8b 40 24             	mov    0x24(%eax),%eax
80106e97:	85 c0                	test   %eax,%eax
80106e99:	74 21                	je     80106ebc <trap+0x299>
80106e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80106e9e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ea2:	0f b7 c0             	movzwl %ax,%eax
80106ea5:	83 e0 03             	and    $0x3,%eax
80106ea8:	83 f8 03             	cmp    $0x3,%eax
80106eab:	75 0f                	jne    80106ebc <trap+0x299>
    exit(EXIT_STATUS_KILLED);
80106ead:	c7 04 24 de 00 00 00 	movl   $0xde,(%esp)
80106eb4:	e8 e4 db ff ff       	call   80104a9d <exit>
80106eb9:	eb 01                	jmp    80106ebc <trap+0x299>
      exit(EXIT_STATUS_KILLED);
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit(EXIT_STATUS_KILLED);
    return;
80106ebb:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit(EXIT_STATUS_KILLED);
}
80106ebc:	83 c4 3c             	add    $0x3c,%esp
80106ebf:	5b                   	pop    %ebx
80106ec0:	5e                   	pop    %esi
80106ec1:	5f                   	pop    %edi
80106ec2:	5d                   	pop    %ebp
80106ec3:	c3                   	ret    

80106ec4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106ec4:	55                   	push   %ebp
80106ec5:	89 e5                	mov    %esp,%ebp
80106ec7:	53                   	push   %ebx
80106ec8:	83 ec 14             	sub    $0x14,%esp
80106ecb:	8b 45 08             	mov    0x8(%ebp),%eax
80106ece:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106ed2:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80106ed6:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80106eda:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80106ede:	ec                   	in     (%dx),%al
80106edf:	89 c3                	mov    %eax,%ebx
80106ee1:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80106ee4:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80106ee8:	83 c4 14             	add    $0x14,%esp
80106eeb:	5b                   	pop    %ebx
80106eec:	5d                   	pop    %ebp
80106eed:	c3                   	ret    

80106eee <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106eee:	55                   	push   %ebp
80106eef:	89 e5                	mov    %esp,%ebp
80106ef1:	83 ec 08             	sub    $0x8,%esp
80106ef4:	8b 55 08             	mov    0x8(%ebp),%edx
80106ef7:	8b 45 0c             	mov    0xc(%ebp),%eax
80106efa:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106efe:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106f01:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106f05:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106f09:	ee                   	out    %al,(%dx)
}
80106f0a:	c9                   	leave  
80106f0b:	c3                   	ret    

80106f0c <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106f0c:	55                   	push   %ebp
80106f0d:	89 e5                	mov    %esp,%ebp
80106f0f:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106f12:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106f19:	00 
80106f1a:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106f21:	e8 c8 ff ff ff       	call   80106eee <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106f26:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106f2d:	00 
80106f2e:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106f35:	e8 b4 ff ff ff       	call   80106eee <outb>
  outb(COM1+0, 115200/9600);
80106f3a:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106f41:	00 
80106f42:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106f49:	e8 a0 ff ff ff       	call   80106eee <outb>
  outb(COM1+1, 0);
80106f4e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106f55:	00 
80106f56:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106f5d:	e8 8c ff ff ff       	call   80106eee <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106f62:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106f69:	00 
80106f6a:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106f71:	e8 78 ff ff ff       	call   80106eee <outb>
  outb(COM1+4, 0);
80106f76:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106f7d:	00 
80106f7e:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106f85:	e8 64 ff ff ff       	call   80106eee <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106f8a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106f91:	00 
80106f92:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106f99:	e8 50 ff ff ff       	call   80106eee <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106f9e:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106fa5:	e8 1a ff ff ff       	call   80106ec4 <inb>
80106faa:	3c ff                	cmp    $0xff,%al
80106fac:	74 6c                	je     8010701a <uartinit+0x10e>
    return;
  uart = 1;
80106fae:	c7 05 4c c6 10 80 01 	movl   $0x1,0x8010c64c
80106fb5:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106fb8:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106fbf:	e8 00 ff ff ff       	call   80106ec4 <inb>
  inb(COM1+0);
80106fc4:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106fcb:	e8 f4 fe ff ff       	call   80106ec4 <inb>
  picenable(IRQ_COM1);
80106fd0:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106fd7:	e8 79 ce ff ff       	call   80103e55 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106fdc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106fe3:	00 
80106fe4:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106feb:	e8 ce b9 ff ff       	call   801029be <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106ff0:	c7 45 f4 ec 8f 10 80 	movl   $0x80108fec,-0xc(%ebp)
80106ff7:	eb 15                	jmp    8010700e <uartinit+0x102>
    uartputc(*p);
80106ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ffc:	0f b6 00             	movzbl (%eax),%eax
80106fff:	0f be c0             	movsbl %al,%eax
80107002:	89 04 24             	mov    %eax,(%esp)
80107005:	e8 13 00 00 00       	call   8010701d <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010700a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010700e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107011:	0f b6 00             	movzbl (%eax),%eax
80107014:	84 c0                	test   %al,%al
80107016:	75 e1                	jne    80106ff9 <uartinit+0xed>
80107018:	eb 01                	jmp    8010701b <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
8010701a:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
8010701b:	c9                   	leave  
8010701c:	c3                   	ret    

8010701d <uartputc>:

void
uartputc(int c)
{
8010701d:	55                   	push   %ebp
8010701e:	89 e5                	mov    %esp,%ebp
80107020:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80107023:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80107028:	85 c0                	test   %eax,%eax
8010702a:	74 4d                	je     80107079 <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010702c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107033:	eb 10                	jmp    80107045 <uartputc+0x28>
    microdelay(10);
80107035:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
8010703c:	e8 3f bf ff ff       	call   80102f80 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107041:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107045:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107049:	7f 16                	jg     80107061 <uartputc+0x44>
8010704b:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107052:	e8 6d fe ff ff       	call   80106ec4 <inb>
80107057:	0f b6 c0             	movzbl %al,%eax
8010705a:	83 e0 20             	and    $0x20,%eax
8010705d:	85 c0                	test   %eax,%eax
8010705f:	74 d4                	je     80107035 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107061:	8b 45 08             	mov    0x8(%ebp),%eax
80107064:	0f b6 c0             	movzbl %al,%eax
80107067:	89 44 24 04          	mov    %eax,0x4(%esp)
8010706b:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107072:	e8 77 fe ff ff       	call   80106eee <outb>
80107077:	eb 01                	jmp    8010707a <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107079:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
8010707a:	c9                   	leave  
8010707b:	c3                   	ret    

8010707c <uartgetc>:

static int
uartgetc(void)
{
8010707c:	55                   	push   %ebp
8010707d:	89 e5                	mov    %esp,%ebp
8010707f:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80107082:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80107087:	85 c0                	test   %eax,%eax
80107089:	75 07                	jne    80107092 <uartgetc+0x16>
    return -1;
8010708b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107090:	eb 2c                	jmp    801070be <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80107092:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107099:	e8 26 fe ff ff       	call   80106ec4 <inb>
8010709e:	0f b6 c0             	movzbl %al,%eax
801070a1:	83 e0 01             	and    $0x1,%eax
801070a4:	85 c0                	test   %eax,%eax
801070a6:	75 07                	jne    801070af <uartgetc+0x33>
    return -1;
801070a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070ad:	eb 0f                	jmp    801070be <uartgetc+0x42>
  return inb(COM1+0);
801070af:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801070b6:	e8 09 fe ff ff       	call   80106ec4 <inb>
801070bb:	0f b6 c0             	movzbl %al,%eax
}
801070be:	c9                   	leave  
801070bf:	c3                   	ret    

801070c0 <uartintr>:

void
uartintr(void)
{
801070c0:	55                   	push   %ebp
801070c1:	89 e5                	mov    %esp,%ebp
801070c3:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
801070c6:	c7 04 24 7c 70 10 80 	movl   $0x8010707c,(%esp)
801070cd:	e8 db 96 ff ff       	call   801007ad <consoleintr>
}
801070d2:	c9                   	leave  
801070d3:	c3                   	ret    

801070d4 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801070d4:	6a 00                	push   $0x0
  pushl $0
801070d6:	6a 00                	push   $0x0
  jmp alltraps
801070d8:	e9 4b f9 ff ff       	jmp    80106a28 <alltraps>

801070dd <vector1>:
.globl vector1
vector1:
  pushl $0
801070dd:	6a 00                	push   $0x0
  pushl $1
801070df:	6a 01                	push   $0x1
  jmp alltraps
801070e1:	e9 42 f9 ff ff       	jmp    80106a28 <alltraps>

801070e6 <vector2>:
.globl vector2
vector2:
  pushl $0
801070e6:	6a 00                	push   $0x0
  pushl $2
801070e8:	6a 02                	push   $0x2
  jmp alltraps
801070ea:	e9 39 f9 ff ff       	jmp    80106a28 <alltraps>

801070ef <vector3>:
.globl vector3
vector3:
  pushl $0
801070ef:	6a 00                	push   $0x0
  pushl $3
801070f1:	6a 03                	push   $0x3
  jmp alltraps
801070f3:	e9 30 f9 ff ff       	jmp    80106a28 <alltraps>

801070f8 <vector4>:
.globl vector4
vector4:
  pushl $0
801070f8:	6a 00                	push   $0x0
  pushl $4
801070fa:	6a 04                	push   $0x4
  jmp alltraps
801070fc:	e9 27 f9 ff ff       	jmp    80106a28 <alltraps>

80107101 <vector5>:
.globl vector5
vector5:
  pushl $0
80107101:	6a 00                	push   $0x0
  pushl $5
80107103:	6a 05                	push   $0x5
  jmp alltraps
80107105:	e9 1e f9 ff ff       	jmp    80106a28 <alltraps>

8010710a <vector6>:
.globl vector6
vector6:
  pushl $0
8010710a:	6a 00                	push   $0x0
  pushl $6
8010710c:	6a 06                	push   $0x6
  jmp alltraps
8010710e:	e9 15 f9 ff ff       	jmp    80106a28 <alltraps>

80107113 <vector7>:
.globl vector7
vector7:
  pushl $0
80107113:	6a 00                	push   $0x0
  pushl $7
80107115:	6a 07                	push   $0x7
  jmp alltraps
80107117:	e9 0c f9 ff ff       	jmp    80106a28 <alltraps>

8010711c <vector8>:
.globl vector8
vector8:
  pushl $8
8010711c:	6a 08                	push   $0x8
  jmp alltraps
8010711e:	e9 05 f9 ff ff       	jmp    80106a28 <alltraps>

80107123 <vector9>:
.globl vector9
vector9:
  pushl $0
80107123:	6a 00                	push   $0x0
  pushl $9
80107125:	6a 09                	push   $0x9
  jmp alltraps
80107127:	e9 fc f8 ff ff       	jmp    80106a28 <alltraps>

8010712c <vector10>:
.globl vector10
vector10:
  pushl $10
8010712c:	6a 0a                	push   $0xa
  jmp alltraps
8010712e:	e9 f5 f8 ff ff       	jmp    80106a28 <alltraps>

80107133 <vector11>:
.globl vector11
vector11:
  pushl $11
80107133:	6a 0b                	push   $0xb
  jmp alltraps
80107135:	e9 ee f8 ff ff       	jmp    80106a28 <alltraps>

8010713a <vector12>:
.globl vector12
vector12:
  pushl $12
8010713a:	6a 0c                	push   $0xc
  jmp alltraps
8010713c:	e9 e7 f8 ff ff       	jmp    80106a28 <alltraps>

80107141 <vector13>:
.globl vector13
vector13:
  pushl $13
80107141:	6a 0d                	push   $0xd
  jmp alltraps
80107143:	e9 e0 f8 ff ff       	jmp    80106a28 <alltraps>

80107148 <vector14>:
.globl vector14
vector14:
  pushl $14
80107148:	6a 0e                	push   $0xe
  jmp alltraps
8010714a:	e9 d9 f8 ff ff       	jmp    80106a28 <alltraps>

8010714f <vector15>:
.globl vector15
vector15:
  pushl $0
8010714f:	6a 00                	push   $0x0
  pushl $15
80107151:	6a 0f                	push   $0xf
  jmp alltraps
80107153:	e9 d0 f8 ff ff       	jmp    80106a28 <alltraps>

80107158 <vector16>:
.globl vector16
vector16:
  pushl $0
80107158:	6a 00                	push   $0x0
  pushl $16
8010715a:	6a 10                	push   $0x10
  jmp alltraps
8010715c:	e9 c7 f8 ff ff       	jmp    80106a28 <alltraps>

80107161 <vector17>:
.globl vector17
vector17:
  pushl $17
80107161:	6a 11                	push   $0x11
  jmp alltraps
80107163:	e9 c0 f8 ff ff       	jmp    80106a28 <alltraps>

80107168 <vector18>:
.globl vector18
vector18:
  pushl $0
80107168:	6a 00                	push   $0x0
  pushl $18
8010716a:	6a 12                	push   $0x12
  jmp alltraps
8010716c:	e9 b7 f8 ff ff       	jmp    80106a28 <alltraps>

80107171 <vector19>:
.globl vector19
vector19:
  pushl $0
80107171:	6a 00                	push   $0x0
  pushl $19
80107173:	6a 13                	push   $0x13
  jmp alltraps
80107175:	e9 ae f8 ff ff       	jmp    80106a28 <alltraps>

8010717a <vector20>:
.globl vector20
vector20:
  pushl $0
8010717a:	6a 00                	push   $0x0
  pushl $20
8010717c:	6a 14                	push   $0x14
  jmp alltraps
8010717e:	e9 a5 f8 ff ff       	jmp    80106a28 <alltraps>

80107183 <vector21>:
.globl vector21
vector21:
  pushl $0
80107183:	6a 00                	push   $0x0
  pushl $21
80107185:	6a 15                	push   $0x15
  jmp alltraps
80107187:	e9 9c f8 ff ff       	jmp    80106a28 <alltraps>

8010718c <vector22>:
.globl vector22
vector22:
  pushl $0
8010718c:	6a 00                	push   $0x0
  pushl $22
8010718e:	6a 16                	push   $0x16
  jmp alltraps
80107190:	e9 93 f8 ff ff       	jmp    80106a28 <alltraps>

80107195 <vector23>:
.globl vector23
vector23:
  pushl $0
80107195:	6a 00                	push   $0x0
  pushl $23
80107197:	6a 17                	push   $0x17
  jmp alltraps
80107199:	e9 8a f8 ff ff       	jmp    80106a28 <alltraps>

8010719e <vector24>:
.globl vector24
vector24:
  pushl $0
8010719e:	6a 00                	push   $0x0
  pushl $24
801071a0:	6a 18                	push   $0x18
  jmp alltraps
801071a2:	e9 81 f8 ff ff       	jmp    80106a28 <alltraps>

801071a7 <vector25>:
.globl vector25
vector25:
  pushl $0
801071a7:	6a 00                	push   $0x0
  pushl $25
801071a9:	6a 19                	push   $0x19
  jmp alltraps
801071ab:	e9 78 f8 ff ff       	jmp    80106a28 <alltraps>

801071b0 <vector26>:
.globl vector26
vector26:
  pushl $0
801071b0:	6a 00                	push   $0x0
  pushl $26
801071b2:	6a 1a                	push   $0x1a
  jmp alltraps
801071b4:	e9 6f f8 ff ff       	jmp    80106a28 <alltraps>

801071b9 <vector27>:
.globl vector27
vector27:
  pushl $0
801071b9:	6a 00                	push   $0x0
  pushl $27
801071bb:	6a 1b                	push   $0x1b
  jmp alltraps
801071bd:	e9 66 f8 ff ff       	jmp    80106a28 <alltraps>

801071c2 <vector28>:
.globl vector28
vector28:
  pushl $0
801071c2:	6a 00                	push   $0x0
  pushl $28
801071c4:	6a 1c                	push   $0x1c
  jmp alltraps
801071c6:	e9 5d f8 ff ff       	jmp    80106a28 <alltraps>

801071cb <vector29>:
.globl vector29
vector29:
  pushl $0
801071cb:	6a 00                	push   $0x0
  pushl $29
801071cd:	6a 1d                	push   $0x1d
  jmp alltraps
801071cf:	e9 54 f8 ff ff       	jmp    80106a28 <alltraps>

801071d4 <vector30>:
.globl vector30
vector30:
  pushl $0
801071d4:	6a 00                	push   $0x0
  pushl $30
801071d6:	6a 1e                	push   $0x1e
  jmp alltraps
801071d8:	e9 4b f8 ff ff       	jmp    80106a28 <alltraps>

801071dd <vector31>:
.globl vector31
vector31:
  pushl $0
801071dd:	6a 00                	push   $0x0
  pushl $31
801071df:	6a 1f                	push   $0x1f
  jmp alltraps
801071e1:	e9 42 f8 ff ff       	jmp    80106a28 <alltraps>

801071e6 <vector32>:
.globl vector32
vector32:
  pushl $0
801071e6:	6a 00                	push   $0x0
  pushl $32
801071e8:	6a 20                	push   $0x20
  jmp alltraps
801071ea:	e9 39 f8 ff ff       	jmp    80106a28 <alltraps>

801071ef <vector33>:
.globl vector33
vector33:
  pushl $0
801071ef:	6a 00                	push   $0x0
  pushl $33
801071f1:	6a 21                	push   $0x21
  jmp alltraps
801071f3:	e9 30 f8 ff ff       	jmp    80106a28 <alltraps>

801071f8 <vector34>:
.globl vector34
vector34:
  pushl $0
801071f8:	6a 00                	push   $0x0
  pushl $34
801071fa:	6a 22                	push   $0x22
  jmp alltraps
801071fc:	e9 27 f8 ff ff       	jmp    80106a28 <alltraps>

80107201 <vector35>:
.globl vector35
vector35:
  pushl $0
80107201:	6a 00                	push   $0x0
  pushl $35
80107203:	6a 23                	push   $0x23
  jmp alltraps
80107205:	e9 1e f8 ff ff       	jmp    80106a28 <alltraps>

8010720a <vector36>:
.globl vector36
vector36:
  pushl $0
8010720a:	6a 00                	push   $0x0
  pushl $36
8010720c:	6a 24                	push   $0x24
  jmp alltraps
8010720e:	e9 15 f8 ff ff       	jmp    80106a28 <alltraps>

80107213 <vector37>:
.globl vector37
vector37:
  pushl $0
80107213:	6a 00                	push   $0x0
  pushl $37
80107215:	6a 25                	push   $0x25
  jmp alltraps
80107217:	e9 0c f8 ff ff       	jmp    80106a28 <alltraps>

8010721c <vector38>:
.globl vector38
vector38:
  pushl $0
8010721c:	6a 00                	push   $0x0
  pushl $38
8010721e:	6a 26                	push   $0x26
  jmp alltraps
80107220:	e9 03 f8 ff ff       	jmp    80106a28 <alltraps>

80107225 <vector39>:
.globl vector39
vector39:
  pushl $0
80107225:	6a 00                	push   $0x0
  pushl $39
80107227:	6a 27                	push   $0x27
  jmp alltraps
80107229:	e9 fa f7 ff ff       	jmp    80106a28 <alltraps>

8010722e <vector40>:
.globl vector40
vector40:
  pushl $0
8010722e:	6a 00                	push   $0x0
  pushl $40
80107230:	6a 28                	push   $0x28
  jmp alltraps
80107232:	e9 f1 f7 ff ff       	jmp    80106a28 <alltraps>

80107237 <vector41>:
.globl vector41
vector41:
  pushl $0
80107237:	6a 00                	push   $0x0
  pushl $41
80107239:	6a 29                	push   $0x29
  jmp alltraps
8010723b:	e9 e8 f7 ff ff       	jmp    80106a28 <alltraps>

80107240 <vector42>:
.globl vector42
vector42:
  pushl $0
80107240:	6a 00                	push   $0x0
  pushl $42
80107242:	6a 2a                	push   $0x2a
  jmp alltraps
80107244:	e9 df f7 ff ff       	jmp    80106a28 <alltraps>

80107249 <vector43>:
.globl vector43
vector43:
  pushl $0
80107249:	6a 00                	push   $0x0
  pushl $43
8010724b:	6a 2b                	push   $0x2b
  jmp alltraps
8010724d:	e9 d6 f7 ff ff       	jmp    80106a28 <alltraps>

80107252 <vector44>:
.globl vector44
vector44:
  pushl $0
80107252:	6a 00                	push   $0x0
  pushl $44
80107254:	6a 2c                	push   $0x2c
  jmp alltraps
80107256:	e9 cd f7 ff ff       	jmp    80106a28 <alltraps>

8010725b <vector45>:
.globl vector45
vector45:
  pushl $0
8010725b:	6a 00                	push   $0x0
  pushl $45
8010725d:	6a 2d                	push   $0x2d
  jmp alltraps
8010725f:	e9 c4 f7 ff ff       	jmp    80106a28 <alltraps>

80107264 <vector46>:
.globl vector46
vector46:
  pushl $0
80107264:	6a 00                	push   $0x0
  pushl $46
80107266:	6a 2e                	push   $0x2e
  jmp alltraps
80107268:	e9 bb f7 ff ff       	jmp    80106a28 <alltraps>

8010726d <vector47>:
.globl vector47
vector47:
  pushl $0
8010726d:	6a 00                	push   $0x0
  pushl $47
8010726f:	6a 2f                	push   $0x2f
  jmp alltraps
80107271:	e9 b2 f7 ff ff       	jmp    80106a28 <alltraps>

80107276 <vector48>:
.globl vector48
vector48:
  pushl $0
80107276:	6a 00                	push   $0x0
  pushl $48
80107278:	6a 30                	push   $0x30
  jmp alltraps
8010727a:	e9 a9 f7 ff ff       	jmp    80106a28 <alltraps>

8010727f <vector49>:
.globl vector49
vector49:
  pushl $0
8010727f:	6a 00                	push   $0x0
  pushl $49
80107281:	6a 31                	push   $0x31
  jmp alltraps
80107283:	e9 a0 f7 ff ff       	jmp    80106a28 <alltraps>

80107288 <vector50>:
.globl vector50
vector50:
  pushl $0
80107288:	6a 00                	push   $0x0
  pushl $50
8010728a:	6a 32                	push   $0x32
  jmp alltraps
8010728c:	e9 97 f7 ff ff       	jmp    80106a28 <alltraps>

80107291 <vector51>:
.globl vector51
vector51:
  pushl $0
80107291:	6a 00                	push   $0x0
  pushl $51
80107293:	6a 33                	push   $0x33
  jmp alltraps
80107295:	e9 8e f7 ff ff       	jmp    80106a28 <alltraps>

8010729a <vector52>:
.globl vector52
vector52:
  pushl $0
8010729a:	6a 00                	push   $0x0
  pushl $52
8010729c:	6a 34                	push   $0x34
  jmp alltraps
8010729e:	e9 85 f7 ff ff       	jmp    80106a28 <alltraps>

801072a3 <vector53>:
.globl vector53
vector53:
  pushl $0
801072a3:	6a 00                	push   $0x0
  pushl $53
801072a5:	6a 35                	push   $0x35
  jmp alltraps
801072a7:	e9 7c f7 ff ff       	jmp    80106a28 <alltraps>

801072ac <vector54>:
.globl vector54
vector54:
  pushl $0
801072ac:	6a 00                	push   $0x0
  pushl $54
801072ae:	6a 36                	push   $0x36
  jmp alltraps
801072b0:	e9 73 f7 ff ff       	jmp    80106a28 <alltraps>

801072b5 <vector55>:
.globl vector55
vector55:
  pushl $0
801072b5:	6a 00                	push   $0x0
  pushl $55
801072b7:	6a 37                	push   $0x37
  jmp alltraps
801072b9:	e9 6a f7 ff ff       	jmp    80106a28 <alltraps>

801072be <vector56>:
.globl vector56
vector56:
  pushl $0
801072be:	6a 00                	push   $0x0
  pushl $56
801072c0:	6a 38                	push   $0x38
  jmp alltraps
801072c2:	e9 61 f7 ff ff       	jmp    80106a28 <alltraps>

801072c7 <vector57>:
.globl vector57
vector57:
  pushl $0
801072c7:	6a 00                	push   $0x0
  pushl $57
801072c9:	6a 39                	push   $0x39
  jmp alltraps
801072cb:	e9 58 f7 ff ff       	jmp    80106a28 <alltraps>

801072d0 <vector58>:
.globl vector58
vector58:
  pushl $0
801072d0:	6a 00                	push   $0x0
  pushl $58
801072d2:	6a 3a                	push   $0x3a
  jmp alltraps
801072d4:	e9 4f f7 ff ff       	jmp    80106a28 <alltraps>

801072d9 <vector59>:
.globl vector59
vector59:
  pushl $0
801072d9:	6a 00                	push   $0x0
  pushl $59
801072db:	6a 3b                	push   $0x3b
  jmp alltraps
801072dd:	e9 46 f7 ff ff       	jmp    80106a28 <alltraps>

801072e2 <vector60>:
.globl vector60
vector60:
  pushl $0
801072e2:	6a 00                	push   $0x0
  pushl $60
801072e4:	6a 3c                	push   $0x3c
  jmp alltraps
801072e6:	e9 3d f7 ff ff       	jmp    80106a28 <alltraps>

801072eb <vector61>:
.globl vector61
vector61:
  pushl $0
801072eb:	6a 00                	push   $0x0
  pushl $61
801072ed:	6a 3d                	push   $0x3d
  jmp alltraps
801072ef:	e9 34 f7 ff ff       	jmp    80106a28 <alltraps>

801072f4 <vector62>:
.globl vector62
vector62:
  pushl $0
801072f4:	6a 00                	push   $0x0
  pushl $62
801072f6:	6a 3e                	push   $0x3e
  jmp alltraps
801072f8:	e9 2b f7 ff ff       	jmp    80106a28 <alltraps>

801072fd <vector63>:
.globl vector63
vector63:
  pushl $0
801072fd:	6a 00                	push   $0x0
  pushl $63
801072ff:	6a 3f                	push   $0x3f
  jmp alltraps
80107301:	e9 22 f7 ff ff       	jmp    80106a28 <alltraps>

80107306 <vector64>:
.globl vector64
vector64:
  pushl $0
80107306:	6a 00                	push   $0x0
  pushl $64
80107308:	6a 40                	push   $0x40
  jmp alltraps
8010730a:	e9 19 f7 ff ff       	jmp    80106a28 <alltraps>

8010730f <vector65>:
.globl vector65
vector65:
  pushl $0
8010730f:	6a 00                	push   $0x0
  pushl $65
80107311:	6a 41                	push   $0x41
  jmp alltraps
80107313:	e9 10 f7 ff ff       	jmp    80106a28 <alltraps>

80107318 <vector66>:
.globl vector66
vector66:
  pushl $0
80107318:	6a 00                	push   $0x0
  pushl $66
8010731a:	6a 42                	push   $0x42
  jmp alltraps
8010731c:	e9 07 f7 ff ff       	jmp    80106a28 <alltraps>

80107321 <vector67>:
.globl vector67
vector67:
  pushl $0
80107321:	6a 00                	push   $0x0
  pushl $67
80107323:	6a 43                	push   $0x43
  jmp alltraps
80107325:	e9 fe f6 ff ff       	jmp    80106a28 <alltraps>

8010732a <vector68>:
.globl vector68
vector68:
  pushl $0
8010732a:	6a 00                	push   $0x0
  pushl $68
8010732c:	6a 44                	push   $0x44
  jmp alltraps
8010732e:	e9 f5 f6 ff ff       	jmp    80106a28 <alltraps>

80107333 <vector69>:
.globl vector69
vector69:
  pushl $0
80107333:	6a 00                	push   $0x0
  pushl $69
80107335:	6a 45                	push   $0x45
  jmp alltraps
80107337:	e9 ec f6 ff ff       	jmp    80106a28 <alltraps>

8010733c <vector70>:
.globl vector70
vector70:
  pushl $0
8010733c:	6a 00                	push   $0x0
  pushl $70
8010733e:	6a 46                	push   $0x46
  jmp alltraps
80107340:	e9 e3 f6 ff ff       	jmp    80106a28 <alltraps>

80107345 <vector71>:
.globl vector71
vector71:
  pushl $0
80107345:	6a 00                	push   $0x0
  pushl $71
80107347:	6a 47                	push   $0x47
  jmp alltraps
80107349:	e9 da f6 ff ff       	jmp    80106a28 <alltraps>

8010734e <vector72>:
.globl vector72
vector72:
  pushl $0
8010734e:	6a 00                	push   $0x0
  pushl $72
80107350:	6a 48                	push   $0x48
  jmp alltraps
80107352:	e9 d1 f6 ff ff       	jmp    80106a28 <alltraps>

80107357 <vector73>:
.globl vector73
vector73:
  pushl $0
80107357:	6a 00                	push   $0x0
  pushl $73
80107359:	6a 49                	push   $0x49
  jmp alltraps
8010735b:	e9 c8 f6 ff ff       	jmp    80106a28 <alltraps>

80107360 <vector74>:
.globl vector74
vector74:
  pushl $0
80107360:	6a 00                	push   $0x0
  pushl $74
80107362:	6a 4a                	push   $0x4a
  jmp alltraps
80107364:	e9 bf f6 ff ff       	jmp    80106a28 <alltraps>

80107369 <vector75>:
.globl vector75
vector75:
  pushl $0
80107369:	6a 00                	push   $0x0
  pushl $75
8010736b:	6a 4b                	push   $0x4b
  jmp alltraps
8010736d:	e9 b6 f6 ff ff       	jmp    80106a28 <alltraps>

80107372 <vector76>:
.globl vector76
vector76:
  pushl $0
80107372:	6a 00                	push   $0x0
  pushl $76
80107374:	6a 4c                	push   $0x4c
  jmp alltraps
80107376:	e9 ad f6 ff ff       	jmp    80106a28 <alltraps>

8010737b <vector77>:
.globl vector77
vector77:
  pushl $0
8010737b:	6a 00                	push   $0x0
  pushl $77
8010737d:	6a 4d                	push   $0x4d
  jmp alltraps
8010737f:	e9 a4 f6 ff ff       	jmp    80106a28 <alltraps>

80107384 <vector78>:
.globl vector78
vector78:
  pushl $0
80107384:	6a 00                	push   $0x0
  pushl $78
80107386:	6a 4e                	push   $0x4e
  jmp alltraps
80107388:	e9 9b f6 ff ff       	jmp    80106a28 <alltraps>

8010738d <vector79>:
.globl vector79
vector79:
  pushl $0
8010738d:	6a 00                	push   $0x0
  pushl $79
8010738f:	6a 4f                	push   $0x4f
  jmp alltraps
80107391:	e9 92 f6 ff ff       	jmp    80106a28 <alltraps>

80107396 <vector80>:
.globl vector80
vector80:
  pushl $0
80107396:	6a 00                	push   $0x0
  pushl $80
80107398:	6a 50                	push   $0x50
  jmp alltraps
8010739a:	e9 89 f6 ff ff       	jmp    80106a28 <alltraps>

8010739f <vector81>:
.globl vector81
vector81:
  pushl $0
8010739f:	6a 00                	push   $0x0
  pushl $81
801073a1:	6a 51                	push   $0x51
  jmp alltraps
801073a3:	e9 80 f6 ff ff       	jmp    80106a28 <alltraps>

801073a8 <vector82>:
.globl vector82
vector82:
  pushl $0
801073a8:	6a 00                	push   $0x0
  pushl $82
801073aa:	6a 52                	push   $0x52
  jmp alltraps
801073ac:	e9 77 f6 ff ff       	jmp    80106a28 <alltraps>

801073b1 <vector83>:
.globl vector83
vector83:
  pushl $0
801073b1:	6a 00                	push   $0x0
  pushl $83
801073b3:	6a 53                	push   $0x53
  jmp alltraps
801073b5:	e9 6e f6 ff ff       	jmp    80106a28 <alltraps>

801073ba <vector84>:
.globl vector84
vector84:
  pushl $0
801073ba:	6a 00                	push   $0x0
  pushl $84
801073bc:	6a 54                	push   $0x54
  jmp alltraps
801073be:	e9 65 f6 ff ff       	jmp    80106a28 <alltraps>

801073c3 <vector85>:
.globl vector85
vector85:
  pushl $0
801073c3:	6a 00                	push   $0x0
  pushl $85
801073c5:	6a 55                	push   $0x55
  jmp alltraps
801073c7:	e9 5c f6 ff ff       	jmp    80106a28 <alltraps>

801073cc <vector86>:
.globl vector86
vector86:
  pushl $0
801073cc:	6a 00                	push   $0x0
  pushl $86
801073ce:	6a 56                	push   $0x56
  jmp alltraps
801073d0:	e9 53 f6 ff ff       	jmp    80106a28 <alltraps>

801073d5 <vector87>:
.globl vector87
vector87:
  pushl $0
801073d5:	6a 00                	push   $0x0
  pushl $87
801073d7:	6a 57                	push   $0x57
  jmp alltraps
801073d9:	e9 4a f6 ff ff       	jmp    80106a28 <alltraps>

801073de <vector88>:
.globl vector88
vector88:
  pushl $0
801073de:	6a 00                	push   $0x0
  pushl $88
801073e0:	6a 58                	push   $0x58
  jmp alltraps
801073e2:	e9 41 f6 ff ff       	jmp    80106a28 <alltraps>

801073e7 <vector89>:
.globl vector89
vector89:
  pushl $0
801073e7:	6a 00                	push   $0x0
  pushl $89
801073e9:	6a 59                	push   $0x59
  jmp alltraps
801073eb:	e9 38 f6 ff ff       	jmp    80106a28 <alltraps>

801073f0 <vector90>:
.globl vector90
vector90:
  pushl $0
801073f0:	6a 00                	push   $0x0
  pushl $90
801073f2:	6a 5a                	push   $0x5a
  jmp alltraps
801073f4:	e9 2f f6 ff ff       	jmp    80106a28 <alltraps>

801073f9 <vector91>:
.globl vector91
vector91:
  pushl $0
801073f9:	6a 00                	push   $0x0
  pushl $91
801073fb:	6a 5b                	push   $0x5b
  jmp alltraps
801073fd:	e9 26 f6 ff ff       	jmp    80106a28 <alltraps>

80107402 <vector92>:
.globl vector92
vector92:
  pushl $0
80107402:	6a 00                	push   $0x0
  pushl $92
80107404:	6a 5c                	push   $0x5c
  jmp alltraps
80107406:	e9 1d f6 ff ff       	jmp    80106a28 <alltraps>

8010740b <vector93>:
.globl vector93
vector93:
  pushl $0
8010740b:	6a 00                	push   $0x0
  pushl $93
8010740d:	6a 5d                	push   $0x5d
  jmp alltraps
8010740f:	e9 14 f6 ff ff       	jmp    80106a28 <alltraps>

80107414 <vector94>:
.globl vector94
vector94:
  pushl $0
80107414:	6a 00                	push   $0x0
  pushl $94
80107416:	6a 5e                	push   $0x5e
  jmp alltraps
80107418:	e9 0b f6 ff ff       	jmp    80106a28 <alltraps>

8010741d <vector95>:
.globl vector95
vector95:
  pushl $0
8010741d:	6a 00                	push   $0x0
  pushl $95
8010741f:	6a 5f                	push   $0x5f
  jmp alltraps
80107421:	e9 02 f6 ff ff       	jmp    80106a28 <alltraps>

80107426 <vector96>:
.globl vector96
vector96:
  pushl $0
80107426:	6a 00                	push   $0x0
  pushl $96
80107428:	6a 60                	push   $0x60
  jmp alltraps
8010742a:	e9 f9 f5 ff ff       	jmp    80106a28 <alltraps>

8010742f <vector97>:
.globl vector97
vector97:
  pushl $0
8010742f:	6a 00                	push   $0x0
  pushl $97
80107431:	6a 61                	push   $0x61
  jmp alltraps
80107433:	e9 f0 f5 ff ff       	jmp    80106a28 <alltraps>

80107438 <vector98>:
.globl vector98
vector98:
  pushl $0
80107438:	6a 00                	push   $0x0
  pushl $98
8010743a:	6a 62                	push   $0x62
  jmp alltraps
8010743c:	e9 e7 f5 ff ff       	jmp    80106a28 <alltraps>

80107441 <vector99>:
.globl vector99
vector99:
  pushl $0
80107441:	6a 00                	push   $0x0
  pushl $99
80107443:	6a 63                	push   $0x63
  jmp alltraps
80107445:	e9 de f5 ff ff       	jmp    80106a28 <alltraps>

8010744a <vector100>:
.globl vector100
vector100:
  pushl $0
8010744a:	6a 00                	push   $0x0
  pushl $100
8010744c:	6a 64                	push   $0x64
  jmp alltraps
8010744e:	e9 d5 f5 ff ff       	jmp    80106a28 <alltraps>

80107453 <vector101>:
.globl vector101
vector101:
  pushl $0
80107453:	6a 00                	push   $0x0
  pushl $101
80107455:	6a 65                	push   $0x65
  jmp alltraps
80107457:	e9 cc f5 ff ff       	jmp    80106a28 <alltraps>

8010745c <vector102>:
.globl vector102
vector102:
  pushl $0
8010745c:	6a 00                	push   $0x0
  pushl $102
8010745e:	6a 66                	push   $0x66
  jmp alltraps
80107460:	e9 c3 f5 ff ff       	jmp    80106a28 <alltraps>

80107465 <vector103>:
.globl vector103
vector103:
  pushl $0
80107465:	6a 00                	push   $0x0
  pushl $103
80107467:	6a 67                	push   $0x67
  jmp alltraps
80107469:	e9 ba f5 ff ff       	jmp    80106a28 <alltraps>

8010746e <vector104>:
.globl vector104
vector104:
  pushl $0
8010746e:	6a 00                	push   $0x0
  pushl $104
80107470:	6a 68                	push   $0x68
  jmp alltraps
80107472:	e9 b1 f5 ff ff       	jmp    80106a28 <alltraps>

80107477 <vector105>:
.globl vector105
vector105:
  pushl $0
80107477:	6a 00                	push   $0x0
  pushl $105
80107479:	6a 69                	push   $0x69
  jmp alltraps
8010747b:	e9 a8 f5 ff ff       	jmp    80106a28 <alltraps>

80107480 <vector106>:
.globl vector106
vector106:
  pushl $0
80107480:	6a 00                	push   $0x0
  pushl $106
80107482:	6a 6a                	push   $0x6a
  jmp alltraps
80107484:	e9 9f f5 ff ff       	jmp    80106a28 <alltraps>

80107489 <vector107>:
.globl vector107
vector107:
  pushl $0
80107489:	6a 00                	push   $0x0
  pushl $107
8010748b:	6a 6b                	push   $0x6b
  jmp alltraps
8010748d:	e9 96 f5 ff ff       	jmp    80106a28 <alltraps>

80107492 <vector108>:
.globl vector108
vector108:
  pushl $0
80107492:	6a 00                	push   $0x0
  pushl $108
80107494:	6a 6c                	push   $0x6c
  jmp alltraps
80107496:	e9 8d f5 ff ff       	jmp    80106a28 <alltraps>

8010749b <vector109>:
.globl vector109
vector109:
  pushl $0
8010749b:	6a 00                	push   $0x0
  pushl $109
8010749d:	6a 6d                	push   $0x6d
  jmp alltraps
8010749f:	e9 84 f5 ff ff       	jmp    80106a28 <alltraps>

801074a4 <vector110>:
.globl vector110
vector110:
  pushl $0
801074a4:	6a 00                	push   $0x0
  pushl $110
801074a6:	6a 6e                	push   $0x6e
  jmp alltraps
801074a8:	e9 7b f5 ff ff       	jmp    80106a28 <alltraps>

801074ad <vector111>:
.globl vector111
vector111:
  pushl $0
801074ad:	6a 00                	push   $0x0
  pushl $111
801074af:	6a 6f                	push   $0x6f
  jmp alltraps
801074b1:	e9 72 f5 ff ff       	jmp    80106a28 <alltraps>

801074b6 <vector112>:
.globl vector112
vector112:
  pushl $0
801074b6:	6a 00                	push   $0x0
  pushl $112
801074b8:	6a 70                	push   $0x70
  jmp alltraps
801074ba:	e9 69 f5 ff ff       	jmp    80106a28 <alltraps>

801074bf <vector113>:
.globl vector113
vector113:
  pushl $0
801074bf:	6a 00                	push   $0x0
  pushl $113
801074c1:	6a 71                	push   $0x71
  jmp alltraps
801074c3:	e9 60 f5 ff ff       	jmp    80106a28 <alltraps>

801074c8 <vector114>:
.globl vector114
vector114:
  pushl $0
801074c8:	6a 00                	push   $0x0
  pushl $114
801074ca:	6a 72                	push   $0x72
  jmp alltraps
801074cc:	e9 57 f5 ff ff       	jmp    80106a28 <alltraps>

801074d1 <vector115>:
.globl vector115
vector115:
  pushl $0
801074d1:	6a 00                	push   $0x0
  pushl $115
801074d3:	6a 73                	push   $0x73
  jmp alltraps
801074d5:	e9 4e f5 ff ff       	jmp    80106a28 <alltraps>

801074da <vector116>:
.globl vector116
vector116:
  pushl $0
801074da:	6a 00                	push   $0x0
  pushl $116
801074dc:	6a 74                	push   $0x74
  jmp alltraps
801074de:	e9 45 f5 ff ff       	jmp    80106a28 <alltraps>

801074e3 <vector117>:
.globl vector117
vector117:
  pushl $0
801074e3:	6a 00                	push   $0x0
  pushl $117
801074e5:	6a 75                	push   $0x75
  jmp alltraps
801074e7:	e9 3c f5 ff ff       	jmp    80106a28 <alltraps>

801074ec <vector118>:
.globl vector118
vector118:
  pushl $0
801074ec:	6a 00                	push   $0x0
  pushl $118
801074ee:	6a 76                	push   $0x76
  jmp alltraps
801074f0:	e9 33 f5 ff ff       	jmp    80106a28 <alltraps>

801074f5 <vector119>:
.globl vector119
vector119:
  pushl $0
801074f5:	6a 00                	push   $0x0
  pushl $119
801074f7:	6a 77                	push   $0x77
  jmp alltraps
801074f9:	e9 2a f5 ff ff       	jmp    80106a28 <alltraps>

801074fe <vector120>:
.globl vector120
vector120:
  pushl $0
801074fe:	6a 00                	push   $0x0
  pushl $120
80107500:	6a 78                	push   $0x78
  jmp alltraps
80107502:	e9 21 f5 ff ff       	jmp    80106a28 <alltraps>

80107507 <vector121>:
.globl vector121
vector121:
  pushl $0
80107507:	6a 00                	push   $0x0
  pushl $121
80107509:	6a 79                	push   $0x79
  jmp alltraps
8010750b:	e9 18 f5 ff ff       	jmp    80106a28 <alltraps>

80107510 <vector122>:
.globl vector122
vector122:
  pushl $0
80107510:	6a 00                	push   $0x0
  pushl $122
80107512:	6a 7a                	push   $0x7a
  jmp alltraps
80107514:	e9 0f f5 ff ff       	jmp    80106a28 <alltraps>

80107519 <vector123>:
.globl vector123
vector123:
  pushl $0
80107519:	6a 00                	push   $0x0
  pushl $123
8010751b:	6a 7b                	push   $0x7b
  jmp alltraps
8010751d:	e9 06 f5 ff ff       	jmp    80106a28 <alltraps>

80107522 <vector124>:
.globl vector124
vector124:
  pushl $0
80107522:	6a 00                	push   $0x0
  pushl $124
80107524:	6a 7c                	push   $0x7c
  jmp alltraps
80107526:	e9 fd f4 ff ff       	jmp    80106a28 <alltraps>

8010752b <vector125>:
.globl vector125
vector125:
  pushl $0
8010752b:	6a 00                	push   $0x0
  pushl $125
8010752d:	6a 7d                	push   $0x7d
  jmp alltraps
8010752f:	e9 f4 f4 ff ff       	jmp    80106a28 <alltraps>

80107534 <vector126>:
.globl vector126
vector126:
  pushl $0
80107534:	6a 00                	push   $0x0
  pushl $126
80107536:	6a 7e                	push   $0x7e
  jmp alltraps
80107538:	e9 eb f4 ff ff       	jmp    80106a28 <alltraps>

8010753d <vector127>:
.globl vector127
vector127:
  pushl $0
8010753d:	6a 00                	push   $0x0
  pushl $127
8010753f:	6a 7f                	push   $0x7f
  jmp alltraps
80107541:	e9 e2 f4 ff ff       	jmp    80106a28 <alltraps>

80107546 <vector128>:
.globl vector128
vector128:
  pushl $0
80107546:	6a 00                	push   $0x0
  pushl $128
80107548:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010754d:	e9 d6 f4 ff ff       	jmp    80106a28 <alltraps>

80107552 <vector129>:
.globl vector129
vector129:
  pushl $0
80107552:	6a 00                	push   $0x0
  pushl $129
80107554:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107559:	e9 ca f4 ff ff       	jmp    80106a28 <alltraps>

8010755e <vector130>:
.globl vector130
vector130:
  pushl $0
8010755e:	6a 00                	push   $0x0
  pushl $130
80107560:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107565:	e9 be f4 ff ff       	jmp    80106a28 <alltraps>

8010756a <vector131>:
.globl vector131
vector131:
  pushl $0
8010756a:	6a 00                	push   $0x0
  pushl $131
8010756c:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107571:	e9 b2 f4 ff ff       	jmp    80106a28 <alltraps>

80107576 <vector132>:
.globl vector132
vector132:
  pushl $0
80107576:	6a 00                	push   $0x0
  pushl $132
80107578:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010757d:	e9 a6 f4 ff ff       	jmp    80106a28 <alltraps>

80107582 <vector133>:
.globl vector133
vector133:
  pushl $0
80107582:	6a 00                	push   $0x0
  pushl $133
80107584:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107589:	e9 9a f4 ff ff       	jmp    80106a28 <alltraps>

8010758e <vector134>:
.globl vector134
vector134:
  pushl $0
8010758e:	6a 00                	push   $0x0
  pushl $134
80107590:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107595:	e9 8e f4 ff ff       	jmp    80106a28 <alltraps>

8010759a <vector135>:
.globl vector135
vector135:
  pushl $0
8010759a:	6a 00                	push   $0x0
  pushl $135
8010759c:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801075a1:	e9 82 f4 ff ff       	jmp    80106a28 <alltraps>

801075a6 <vector136>:
.globl vector136
vector136:
  pushl $0
801075a6:	6a 00                	push   $0x0
  pushl $136
801075a8:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801075ad:	e9 76 f4 ff ff       	jmp    80106a28 <alltraps>

801075b2 <vector137>:
.globl vector137
vector137:
  pushl $0
801075b2:	6a 00                	push   $0x0
  pushl $137
801075b4:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801075b9:	e9 6a f4 ff ff       	jmp    80106a28 <alltraps>

801075be <vector138>:
.globl vector138
vector138:
  pushl $0
801075be:	6a 00                	push   $0x0
  pushl $138
801075c0:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801075c5:	e9 5e f4 ff ff       	jmp    80106a28 <alltraps>

801075ca <vector139>:
.globl vector139
vector139:
  pushl $0
801075ca:	6a 00                	push   $0x0
  pushl $139
801075cc:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801075d1:	e9 52 f4 ff ff       	jmp    80106a28 <alltraps>

801075d6 <vector140>:
.globl vector140
vector140:
  pushl $0
801075d6:	6a 00                	push   $0x0
  pushl $140
801075d8:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801075dd:	e9 46 f4 ff ff       	jmp    80106a28 <alltraps>

801075e2 <vector141>:
.globl vector141
vector141:
  pushl $0
801075e2:	6a 00                	push   $0x0
  pushl $141
801075e4:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801075e9:	e9 3a f4 ff ff       	jmp    80106a28 <alltraps>

801075ee <vector142>:
.globl vector142
vector142:
  pushl $0
801075ee:	6a 00                	push   $0x0
  pushl $142
801075f0:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801075f5:	e9 2e f4 ff ff       	jmp    80106a28 <alltraps>

801075fa <vector143>:
.globl vector143
vector143:
  pushl $0
801075fa:	6a 00                	push   $0x0
  pushl $143
801075fc:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107601:	e9 22 f4 ff ff       	jmp    80106a28 <alltraps>

80107606 <vector144>:
.globl vector144
vector144:
  pushl $0
80107606:	6a 00                	push   $0x0
  pushl $144
80107608:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010760d:	e9 16 f4 ff ff       	jmp    80106a28 <alltraps>

80107612 <vector145>:
.globl vector145
vector145:
  pushl $0
80107612:	6a 00                	push   $0x0
  pushl $145
80107614:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107619:	e9 0a f4 ff ff       	jmp    80106a28 <alltraps>

8010761e <vector146>:
.globl vector146
vector146:
  pushl $0
8010761e:	6a 00                	push   $0x0
  pushl $146
80107620:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107625:	e9 fe f3 ff ff       	jmp    80106a28 <alltraps>

8010762a <vector147>:
.globl vector147
vector147:
  pushl $0
8010762a:	6a 00                	push   $0x0
  pushl $147
8010762c:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107631:	e9 f2 f3 ff ff       	jmp    80106a28 <alltraps>

80107636 <vector148>:
.globl vector148
vector148:
  pushl $0
80107636:	6a 00                	push   $0x0
  pushl $148
80107638:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010763d:	e9 e6 f3 ff ff       	jmp    80106a28 <alltraps>

80107642 <vector149>:
.globl vector149
vector149:
  pushl $0
80107642:	6a 00                	push   $0x0
  pushl $149
80107644:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107649:	e9 da f3 ff ff       	jmp    80106a28 <alltraps>

8010764e <vector150>:
.globl vector150
vector150:
  pushl $0
8010764e:	6a 00                	push   $0x0
  pushl $150
80107650:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107655:	e9 ce f3 ff ff       	jmp    80106a28 <alltraps>

8010765a <vector151>:
.globl vector151
vector151:
  pushl $0
8010765a:	6a 00                	push   $0x0
  pushl $151
8010765c:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107661:	e9 c2 f3 ff ff       	jmp    80106a28 <alltraps>

80107666 <vector152>:
.globl vector152
vector152:
  pushl $0
80107666:	6a 00                	push   $0x0
  pushl $152
80107668:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010766d:	e9 b6 f3 ff ff       	jmp    80106a28 <alltraps>

80107672 <vector153>:
.globl vector153
vector153:
  pushl $0
80107672:	6a 00                	push   $0x0
  pushl $153
80107674:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107679:	e9 aa f3 ff ff       	jmp    80106a28 <alltraps>

8010767e <vector154>:
.globl vector154
vector154:
  pushl $0
8010767e:	6a 00                	push   $0x0
  pushl $154
80107680:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107685:	e9 9e f3 ff ff       	jmp    80106a28 <alltraps>

8010768a <vector155>:
.globl vector155
vector155:
  pushl $0
8010768a:	6a 00                	push   $0x0
  pushl $155
8010768c:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107691:	e9 92 f3 ff ff       	jmp    80106a28 <alltraps>

80107696 <vector156>:
.globl vector156
vector156:
  pushl $0
80107696:	6a 00                	push   $0x0
  pushl $156
80107698:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010769d:	e9 86 f3 ff ff       	jmp    80106a28 <alltraps>

801076a2 <vector157>:
.globl vector157
vector157:
  pushl $0
801076a2:	6a 00                	push   $0x0
  pushl $157
801076a4:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801076a9:	e9 7a f3 ff ff       	jmp    80106a28 <alltraps>

801076ae <vector158>:
.globl vector158
vector158:
  pushl $0
801076ae:	6a 00                	push   $0x0
  pushl $158
801076b0:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801076b5:	e9 6e f3 ff ff       	jmp    80106a28 <alltraps>

801076ba <vector159>:
.globl vector159
vector159:
  pushl $0
801076ba:	6a 00                	push   $0x0
  pushl $159
801076bc:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801076c1:	e9 62 f3 ff ff       	jmp    80106a28 <alltraps>

801076c6 <vector160>:
.globl vector160
vector160:
  pushl $0
801076c6:	6a 00                	push   $0x0
  pushl $160
801076c8:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801076cd:	e9 56 f3 ff ff       	jmp    80106a28 <alltraps>

801076d2 <vector161>:
.globl vector161
vector161:
  pushl $0
801076d2:	6a 00                	push   $0x0
  pushl $161
801076d4:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801076d9:	e9 4a f3 ff ff       	jmp    80106a28 <alltraps>

801076de <vector162>:
.globl vector162
vector162:
  pushl $0
801076de:	6a 00                	push   $0x0
  pushl $162
801076e0:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801076e5:	e9 3e f3 ff ff       	jmp    80106a28 <alltraps>

801076ea <vector163>:
.globl vector163
vector163:
  pushl $0
801076ea:	6a 00                	push   $0x0
  pushl $163
801076ec:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801076f1:	e9 32 f3 ff ff       	jmp    80106a28 <alltraps>

801076f6 <vector164>:
.globl vector164
vector164:
  pushl $0
801076f6:	6a 00                	push   $0x0
  pushl $164
801076f8:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801076fd:	e9 26 f3 ff ff       	jmp    80106a28 <alltraps>

80107702 <vector165>:
.globl vector165
vector165:
  pushl $0
80107702:	6a 00                	push   $0x0
  pushl $165
80107704:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107709:	e9 1a f3 ff ff       	jmp    80106a28 <alltraps>

8010770e <vector166>:
.globl vector166
vector166:
  pushl $0
8010770e:	6a 00                	push   $0x0
  pushl $166
80107710:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107715:	e9 0e f3 ff ff       	jmp    80106a28 <alltraps>

8010771a <vector167>:
.globl vector167
vector167:
  pushl $0
8010771a:	6a 00                	push   $0x0
  pushl $167
8010771c:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107721:	e9 02 f3 ff ff       	jmp    80106a28 <alltraps>

80107726 <vector168>:
.globl vector168
vector168:
  pushl $0
80107726:	6a 00                	push   $0x0
  pushl $168
80107728:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010772d:	e9 f6 f2 ff ff       	jmp    80106a28 <alltraps>

80107732 <vector169>:
.globl vector169
vector169:
  pushl $0
80107732:	6a 00                	push   $0x0
  pushl $169
80107734:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107739:	e9 ea f2 ff ff       	jmp    80106a28 <alltraps>

8010773e <vector170>:
.globl vector170
vector170:
  pushl $0
8010773e:	6a 00                	push   $0x0
  pushl $170
80107740:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107745:	e9 de f2 ff ff       	jmp    80106a28 <alltraps>

8010774a <vector171>:
.globl vector171
vector171:
  pushl $0
8010774a:	6a 00                	push   $0x0
  pushl $171
8010774c:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107751:	e9 d2 f2 ff ff       	jmp    80106a28 <alltraps>

80107756 <vector172>:
.globl vector172
vector172:
  pushl $0
80107756:	6a 00                	push   $0x0
  pushl $172
80107758:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010775d:	e9 c6 f2 ff ff       	jmp    80106a28 <alltraps>

80107762 <vector173>:
.globl vector173
vector173:
  pushl $0
80107762:	6a 00                	push   $0x0
  pushl $173
80107764:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107769:	e9 ba f2 ff ff       	jmp    80106a28 <alltraps>

8010776e <vector174>:
.globl vector174
vector174:
  pushl $0
8010776e:	6a 00                	push   $0x0
  pushl $174
80107770:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107775:	e9 ae f2 ff ff       	jmp    80106a28 <alltraps>

8010777a <vector175>:
.globl vector175
vector175:
  pushl $0
8010777a:	6a 00                	push   $0x0
  pushl $175
8010777c:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107781:	e9 a2 f2 ff ff       	jmp    80106a28 <alltraps>

80107786 <vector176>:
.globl vector176
vector176:
  pushl $0
80107786:	6a 00                	push   $0x0
  pushl $176
80107788:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010778d:	e9 96 f2 ff ff       	jmp    80106a28 <alltraps>

80107792 <vector177>:
.globl vector177
vector177:
  pushl $0
80107792:	6a 00                	push   $0x0
  pushl $177
80107794:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107799:	e9 8a f2 ff ff       	jmp    80106a28 <alltraps>

8010779e <vector178>:
.globl vector178
vector178:
  pushl $0
8010779e:	6a 00                	push   $0x0
  pushl $178
801077a0:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801077a5:	e9 7e f2 ff ff       	jmp    80106a28 <alltraps>

801077aa <vector179>:
.globl vector179
vector179:
  pushl $0
801077aa:	6a 00                	push   $0x0
  pushl $179
801077ac:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801077b1:	e9 72 f2 ff ff       	jmp    80106a28 <alltraps>

801077b6 <vector180>:
.globl vector180
vector180:
  pushl $0
801077b6:	6a 00                	push   $0x0
  pushl $180
801077b8:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801077bd:	e9 66 f2 ff ff       	jmp    80106a28 <alltraps>

801077c2 <vector181>:
.globl vector181
vector181:
  pushl $0
801077c2:	6a 00                	push   $0x0
  pushl $181
801077c4:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801077c9:	e9 5a f2 ff ff       	jmp    80106a28 <alltraps>

801077ce <vector182>:
.globl vector182
vector182:
  pushl $0
801077ce:	6a 00                	push   $0x0
  pushl $182
801077d0:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801077d5:	e9 4e f2 ff ff       	jmp    80106a28 <alltraps>

801077da <vector183>:
.globl vector183
vector183:
  pushl $0
801077da:	6a 00                	push   $0x0
  pushl $183
801077dc:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801077e1:	e9 42 f2 ff ff       	jmp    80106a28 <alltraps>

801077e6 <vector184>:
.globl vector184
vector184:
  pushl $0
801077e6:	6a 00                	push   $0x0
  pushl $184
801077e8:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801077ed:	e9 36 f2 ff ff       	jmp    80106a28 <alltraps>

801077f2 <vector185>:
.globl vector185
vector185:
  pushl $0
801077f2:	6a 00                	push   $0x0
  pushl $185
801077f4:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801077f9:	e9 2a f2 ff ff       	jmp    80106a28 <alltraps>

801077fe <vector186>:
.globl vector186
vector186:
  pushl $0
801077fe:	6a 00                	push   $0x0
  pushl $186
80107800:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107805:	e9 1e f2 ff ff       	jmp    80106a28 <alltraps>

8010780a <vector187>:
.globl vector187
vector187:
  pushl $0
8010780a:	6a 00                	push   $0x0
  pushl $187
8010780c:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107811:	e9 12 f2 ff ff       	jmp    80106a28 <alltraps>

80107816 <vector188>:
.globl vector188
vector188:
  pushl $0
80107816:	6a 00                	push   $0x0
  pushl $188
80107818:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010781d:	e9 06 f2 ff ff       	jmp    80106a28 <alltraps>

80107822 <vector189>:
.globl vector189
vector189:
  pushl $0
80107822:	6a 00                	push   $0x0
  pushl $189
80107824:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107829:	e9 fa f1 ff ff       	jmp    80106a28 <alltraps>

8010782e <vector190>:
.globl vector190
vector190:
  pushl $0
8010782e:	6a 00                	push   $0x0
  pushl $190
80107830:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107835:	e9 ee f1 ff ff       	jmp    80106a28 <alltraps>

8010783a <vector191>:
.globl vector191
vector191:
  pushl $0
8010783a:	6a 00                	push   $0x0
  pushl $191
8010783c:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107841:	e9 e2 f1 ff ff       	jmp    80106a28 <alltraps>

80107846 <vector192>:
.globl vector192
vector192:
  pushl $0
80107846:	6a 00                	push   $0x0
  pushl $192
80107848:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010784d:	e9 d6 f1 ff ff       	jmp    80106a28 <alltraps>

80107852 <vector193>:
.globl vector193
vector193:
  pushl $0
80107852:	6a 00                	push   $0x0
  pushl $193
80107854:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107859:	e9 ca f1 ff ff       	jmp    80106a28 <alltraps>

8010785e <vector194>:
.globl vector194
vector194:
  pushl $0
8010785e:	6a 00                	push   $0x0
  pushl $194
80107860:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107865:	e9 be f1 ff ff       	jmp    80106a28 <alltraps>

8010786a <vector195>:
.globl vector195
vector195:
  pushl $0
8010786a:	6a 00                	push   $0x0
  pushl $195
8010786c:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107871:	e9 b2 f1 ff ff       	jmp    80106a28 <alltraps>

80107876 <vector196>:
.globl vector196
vector196:
  pushl $0
80107876:	6a 00                	push   $0x0
  pushl $196
80107878:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010787d:	e9 a6 f1 ff ff       	jmp    80106a28 <alltraps>

80107882 <vector197>:
.globl vector197
vector197:
  pushl $0
80107882:	6a 00                	push   $0x0
  pushl $197
80107884:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107889:	e9 9a f1 ff ff       	jmp    80106a28 <alltraps>

8010788e <vector198>:
.globl vector198
vector198:
  pushl $0
8010788e:	6a 00                	push   $0x0
  pushl $198
80107890:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107895:	e9 8e f1 ff ff       	jmp    80106a28 <alltraps>

8010789a <vector199>:
.globl vector199
vector199:
  pushl $0
8010789a:	6a 00                	push   $0x0
  pushl $199
8010789c:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801078a1:	e9 82 f1 ff ff       	jmp    80106a28 <alltraps>

801078a6 <vector200>:
.globl vector200
vector200:
  pushl $0
801078a6:	6a 00                	push   $0x0
  pushl $200
801078a8:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801078ad:	e9 76 f1 ff ff       	jmp    80106a28 <alltraps>

801078b2 <vector201>:
.globl vector201
vector201:
  pushl $0
801078b2:	6a 00                	push   $0x0
  pushl $201
801078b4:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801078b9:	e9 6a f1 ff ff       	jmp    80106a28 <alltraps>

801078be <vector202>:
.globl vector202
vector202:
  pushl $0
801078be:	6a 00                	push   $0x0
  pushl $202
801078c0:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801078c5:	e9 5e f1 ff ff       	jmp    80106a28 <alltraps>

801078ca <vector203>:
.globl vector203
vector203:
  pushl $0
801078ca:	6a 00                	push   $0x0
  pushl $203
801078cc:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801078d1:	e9 52 f1 ff ff       	jmp    80106a28 <alltraps>

801078d6 <vector204>:
.globl vector204
vector204:
  pushl $0
801078d6:	6a 00                	push   $0x0
  pushl $204
801078d8:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801078dd:	e9 46 f1 ff ff       	jmp    80106a28 <alltraps>

801078e2 <vector205>:
.globl vector205
vector205:
  pushl $0
801078e2:	6a 00                	push   $0x0
  pushl $205
801078e4:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801078e9:	e9 3a f1 ff ff       	jmp    80106a28 <alltraps>

801078ee <vector206>:
.globl vector206
vector206:
  pushl $0
801078ee:	6a 00                	push   $0x0
  pushl $206
801078f0:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801078f5:	e9 2e f1 ff ff       	jmp    80106a28 <alltraps>

801078fa <vector207>:
.globl vector207
vector207:
  pushl $0
801078fa:	6a 00                	push   $0x0
  pushl $207
801078fc:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107901:	e9 22 f1 ff ff       	jmp    80106a28 <alltraps>

80107906 <vector208>:
.globl vector208
vector208:
  pushl $0
80107906:	6a 00                	push   $0x0
  pushl $208
80107908:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010790d:	e9 16 f1 ff ff       	jmp    80106a28 <alltraps>

80107912 <vector209>:
.globl vector209
vector209:
  pushl $0
80107912:	6a 00                	push   $0x0
  pushl $209
80107914:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107919:	e9 0a f1 ff ff       	jmp    80106a28 <alltraps>

8010791e <vector210>:
.globl vector210
vector210:
  pushl $0
8010791e:	6a 00                	push   $0x0
  pushl $210
80107920:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107925:	e9 fe f0 ff ff       	jmp    80106a28 <alltraps>

8010792a <vector211>:
.globl vector211
vector211:
  pushl $0
8010792a:	6a 00                	push   $0x0
  pushl $211
8010792c:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107931:	e9 f2 f0 ff ff       	jmp    80106a28 <alltraps>

80107936 <vector212>:
.globl vector212
vector212:
  pushl $0
80107936:	6a 00                	push   $0x0
  pushl $212
80107938:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010793d:	e9 e6 f0 ff ff       	jmp    80106a28 <alltraps>

80107942 <vector213>:
.globl vector213
vector213:
  pushl $0
80107942:	6a 00                	push   $0x0
  pushl $213
80107944:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107949:	e9 da f0 ff ff       	jmp    80106a28 <alltraps>

8010794e <vector214>:
.globl vector214
vector214:
  pushl $0
8010794e:	6a 00                	push   $0x0
  pushl $214
80107950:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107955:	e9 ce f0 ff ff       	jmp    80106a28 <alltraps>

8010795a <vector215>:
.globl vector215
vector215:
  pushl $0
8010795a:	6a 00                	push   $0x0
  pushl $215
8010795c:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107961:	e9 c2 f0 ff ff       	jmp    80106a28 <alltraps>

80107966 <vector216>:
.globl vector216
vector216:
  pushl $0
80107966:	6a 00                	push   $0x0
  pushl $216
80107968:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010796d:	e9 b6 f0 ff ff       	jmp    80106a28 <alltraps>

80107972 <vector217>:
.globl vector217
vector217:
  pushl $0
80107972:	6a 00                	push   $0x0
  pushl $217
80107974:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107979:	e9 aa f0 ff ff       	jmp    80106a28 <alltraps>

8010797e <vector218>:
.globl vector218
vector218:
  pushl $0
8010797e:	6a 00                	push   $0x0
  pushl $218
80107980:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107985:	e9 9e f0 ff ff       	jmp    80106a28 <alltraps>

8010798a <vector219>:
.globl vector219
vector219:
  pushl $0
8010798a:	6a 00                	push   $0x0
  pushl $219
8010798c:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107991:	e9 92 f0 ff ff       	jmp    80106a28 <alltraps>

80107996 <vector220>:
.globl vector220
vector220:
  pushl $0
80107996:	6a 00                	push   $0x0
  pushl $220
80107998:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010799d:	e9 86 f0 ff ff       	jmp    80106a28 <alltraps>

801079a2 <vector221>:
.globl vector221
vector221:
  pushl $0
801079a2:	6a 00                	push   $0x0
  pushl $221
801079a4:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801079a9:	e9 7a f0 ff ff       	jmp    80106a28 <alltraps>

801079ae <vector222>:
.globl vector222
vector222:
  pushl $0
801079ae:	6a 00                	push   $0x0
  pushl $222
801079b0:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801079b5:	e9 6e f0 ff ff       	jmp    80106a28 <alltraps>

801079ba <vector223>:
.globl vector223
vector223:
  pushl $0
801079ba:	6a 00                	push   $0x0
  pushl $223
801079bc:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801079c1:	e9 62 f0 ff ff       	jmp    80106a28 <alltraps>

801079c6 <vector224>:
.globl vector224
vector224:
  pushl $0
801079c6:	6a 00                	push   $0x0
  pushl $224
801079c8:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801079cd:	e9 56 f0 ff ff       	jmp    80106a28 <alltraps>

801079d2 <vector225>:
.globl vector225
vector225:
  pushl $0
801079d2:	6a 00                	push   $0x0
  pushl $225
801079d4:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801079d9:	e9 4a f0 ff ff       	jmp    80106a28 <alltraps>

801079de <vector226>:
.globl vector226
vector226:
  pushl $0
801079de:	6a 00                	push   $0x0
  pushl $226
801079e0:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801079e5:	e9 3e f0 ff ff       	jmp    80106a28 <alltraps>

801079ea <vector227>:
.globl vector227
vector227:
  pushl $0
801079ea:	6a 00                	push   $0x0
  pushl $227
801079ec:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801079f1:	e9 32 f0 ff ff       	jmp    80106a28 <alltraps>

801079f6 <vector228>:
.globl vector228
vector228:
  pushl $0
801079f6:	6a 00                	push   $0x0
  pushl $228
801079f8:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801079fd:	e9 26 f0 ff ff       	jmp    80106a28 <alltraps>

80107a02 <vector229>:
.globl vector229
vector229:
  pushl $0
80107a02:	6a 00                	push   $0x0
  pushl $229
80107a04:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107a09:	e9 1a f0 ff ff       	jmp    80106a28 <alltraps>

80107a0e <vector230>:
.globl vector230
vector230:
  pushl $0
80107a0e:	6a 00                	push   $0x0
  pushl $230
80107a10:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107a15:	e9 0e f0 ff ff       	jmp    80106a28 <alltraps>

80107a1a <vector231>:
.globl vector231
vector231:
  pushl $0
80107a1a:	6a 00                	push   $0x0
  pushl $231
80107a1c:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107a21:	e9 02 f0 ff ff       	jmp    80106a28 <alltraps>

80107a26 <vector232>:
.globl vector232
vector232:
  pushl $0
80107a26:	6a 00                	push   $0x0
  pushl $232
80107a28:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107a2d:	e9 f6 ef ff ff       	jmp    80106a28 <alltraps>

80107a32 <vector233>:
.globl vector233
vector233:
  pushl $0
80107a32:	6a 00                	push   $0x0
  pushl $233
80107a34:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107a39:	e9 ea ef ff ff       	jmp    80106a28 <alltraps>

80107a3e <vector234>:
.globl vector234
vector234:
  pushl $0
80107a3e:	6a 00                	push   $0x0
  pushl $234
80107a40:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107a45:	e9 de ef ff ff       	jmp    80106a28 <alltraps>

80107a4a <vector235>:
.globl vector235
vector235:
  pushl $0
80107a4a:	6a 00                	push   $0x0
  pushl $235
80107a4c:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107a51:	e9 d2 ef ff ff       	jmp    80106a28 <alltraps>

80107a56 <vector236>:
.globl vector236
vector236:
  pushl $0
80107a56:	6a 00                	push   $0x0
  pushl $236
80107a58:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107a5d:	e9 c6 ef ff ff       	jmp    80106a28 <alltraps>

80107a62 <vector237>:
.globl vector237
vector237:
  pushl $0
80107a62:	6a 00                	push   $0x0
  pushl $237
80107a64:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107a69:	e9 ba ef ff ff       	jmp    80106a28 <alltraps>

80107a6e <vector238>:
.globl vector238
vector238:
  pushl $0
80107a6e:	6a 00                	push   $0x0
  pushl $238
80107a70:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107a75:	e9 ae ef ff ff       	jmp    80106a28 <alltraps>

80107a7a <vector239>:
.globl vector239
vector239:
  pushl $0
80107a7a:	6a 00                	push   $0x0
  pushl $239
80107a7c:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107a81:	e9 a2 ef ff ff       	jmp    80106a28 <alltraps>

80107a86 <vector240>:
.globl vector240
vector240:
  pushl $0
80107a86:	6a 00                	push   $0x0
  pushl $240
80107a88:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107a8d:	e9 96 ef ff ff       	jmp    80106a28 <alltraps>

80107a92 <vector241>:
.globl vector241
vector241:
  pushl $0
80107a92:	6a 00                	push   $0x0
  pushl $241
80107a94:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107a99:	e9 8a ef ff ff       	jmp    80106a28 <alltraps>

80107a9e <vector242>:
.globl vector242
vector242:
  pushl $0
80107a9e:	6a 00                	push   $0x0
  pushl $242
80107aa0:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107aa5:	e9 7e ef ff ff       	jmp    80106a28 <alltraps>

80107aaa <vector243>:
.globl vector243
vector243:
  pushl $0
80107aaa:	6a 00                	push   $0x0
  pushl $243
80107aac:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107ab1:	e9 72 ef ff ff       	jmp    80106a28 <alltraps>

80107ab6 <vector244>:
.globl vector244
vector244:
  pushl $0
80107ab6:	6a 00                	push   $0x0
  pushl $244
80107ab8:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107abd:	e9 66 ef ff ff       	jmp    80106a28 <alltraps>

80107ac2 <vector245>:
.globl vector245
vector245:
  pushl $0
80107ac2:	6a 00                	push   $0x0
  pushl $245
80107ac4:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107ac9:	e9 5a ef ff ff       	jmp    80106a28 <alltraps>

80107ace <vector246>:
.globl vector246
vector246:
  pushl $0
80107ace:	6a 00                	push   $0x0
  pushl $246
80107ad0:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107ad5:	e9 4e ef ff ff       	jmp    80106a28 <alltraps>

80107ada <vector247>:
.globl vector247
vector247:
  pushl $0
80107ada:	6a 00                	push   $0x0
  pushl $247
80107adc:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107ae1:	e9 42 ef ff ff       	jmp    80106a28 <alltraps>

80107ae6 <vector248>:
.globl vector248
vector248:
  pushl $0
80107ae6:	6a 00                	push   $0x0
  pushl $248
80107ae8:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107aed:	e9 36 ef ff ff       	jmp    80106a28 <alltraps>

80107af2 <vector249>:
.globl vector249
vector249:
  pushl $0
80107af2:	6a 00                	push   $0x0
  pushl $249
80107af4:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107af9:	e9 2a ef ff ff       	jmp    80106a28 <alltraps>

80107afe <vector250>:
.globl vector250
vector250:
  pushl $0
80107afe:	6a 00                	push   $0x0
  pushl $250
80107b00:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107b05:	e9 1e ef ff ff       	jmp    80106a28 <alltraps>

80107b0a <vector251>:
.globl vector251
vector251:
  pushl $0
80107b0a:	6a 00                	push   $0x0
  pushl $251
80107b0c:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107b11:	e9 12 ef ff ff       	jmp    80106a28 <alltraps>

80107b16 <vector252>:
.globl vector252
vector252:
  pushl $0
80107b16:	6a 00                	push   $0x0
  pushl $252
80107b18:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107b1d:	e9 06 ef ff ff       	jmp    80106a28 <alltraps>

80107b22 <vector253>:
.globl vector253
vector253:
  pushl $0
80107b22:	6a 00                	push   $0x0
  pushl $253
80107b24:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107b29:	e9 fa ee ff ff       	jmp    80106a28 <alltraps>

80107b2e <vector254>:
.globl vector254
vector254:
  pushl $0
80107b2e:	6a 00                	push   $0x0
  pushl $254
80107b30:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107b35:	e9 ee ee ff ff       	jmp    80106a28 <alltraps>

80107b3a <vector255>:
.globl vector255
vector255:
  pushl $0
80107b3a:	6a 00                	push   $0x0
  pushl $255
80107b3c:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107b41:	e9 e2 ee ff ff       	jmp    80106a28 <alltraps>
	...

80107b48 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107b48:	55                   	push   %ebp
80107b49:	89 e5                	mov    %esp,%ebp
80107b4b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107b4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b51:	83 e8 01             	sub    $0x1,%eax
80107b54:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107b58:	8b 45 08             	mov    0x8(%ebp),%eax
80107b5b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107b5f:	8b 45 08             	mov    0x8(%ebp),%eax
80107b62:	c1 e8 10             	shr    $0x10,%eax
80107b65:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107b69:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107b6c:	0f 01 10             	lgdtl  (%eax)
}
80107b6f:	c9                   	leave  
80107b70:	c3                   	ret    

80107b71 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107b71:	55                   	push   %ebp
80107b72:	89 e5                	mov    %esp,%ebp
80107b74:	83 ec 04             	sub    $0x4,%esp
80107b77:	8b 45 08             	mov    0x8(%ebp),%eax
80107b7a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107b7e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107b82:	0f 00 d8             	ltr    %ax
}
80107b85:	c9                   	leave  
80107b86:	c3                   	ret    

80107b87 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107b87:	55                   	push   %ebp
80107b88:	89 e5                	mov    %esp,%ebp
80107b8a:	83 ec 04             	sub    $0x4,%esp
80107b8d:	8b 45 08             	mov    0x8(%ebp),%eax
80107b90:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107b94:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107b98:	8e e8                	mov    %eax,%gs
}
80107b9a:	c9                   	leave  
80107b9b:	c3                   	ret    

80107b9c <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107b9c:	55                   	push   %ebp
80107b9d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80107ba2:	0f 22 d8             	mov    %eax,%cr3
}
80107ba5:	5d                   	pop    %ebp
80107ba6:	c3                   	ret    

80107ba7 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107ba7:	55                   	push   %ebp
80107ba8:	89 e5                	mov    %esp,%ebp
80107baa:	8b 45 08             	mov    0x8(%ebp),%eax
80107bad:	05 00 00 00 80       	add    $0x80000000,%eax
80107bb2:	5d                   	pop    %ebp
80107bb3:	c3                   	ret    

80107bb4 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107bb4:	55                   	push   %ebp
80107bb5:	89 e5                	mov    %esp,%ebp
80107bb7:	8b 45 08             	mov    0x8(%ebp),%eax
80107bba:	05 00 00 00 80       	add    $0x80000000,%eax
80107bbf:	5d                   	pop    %ebp
80107bc0:	c3                   	ret    

80107bc1 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107bc1:	55                   	push   %ebp
80107bc2:	89 e5                	mov    %esp,%ebp
80107bc4:	53                   	push   %ebx
80107bc5:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107bc8:	e8 32 b3 ff ff       	call   80102eff <cpunum>
80107bcd:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107bd3:	05 60 33 11 80       	add    $0x80113360,%eax
80107bd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bde:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be7:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf0:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf7:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107bfb:	83 e2 f0             	and    $0xfffffff0,%edx
80107bfe:	83 ca 0a             	or     $0xa,%edx
80107c01:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c07:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c0b:	83 ca 10             	or     $0x10,%edx
80107c0e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c14:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c18:	83 e2 9f             	and    $0xffffff9f,%edx
80107c1b:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c21:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c25:	83 ca 80             	or     $0xffffff80,%edx
80107c28:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c32:	83 ca 0f             	or     $0xf,%edx
80107c35:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c3f:	83 e2 ef             	and    $0xffffffef,%edx
80107c42:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c48:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c4c:	83 e2 df             	and    $0xffffffdf,%edx
80107c4f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c55:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c59:	83 ca 40             	or     $0x40,%edx
80107c5c:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c62:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107c66:	83 ca 80             	or     $0xffffff80,%edx
80107c69:	88 50 7e             	mov    %dl,0x7e(%eax)
80107c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6f:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c76:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107c7d:	ff ff 
80107c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c82:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107c89:	00 00 
80107c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8e:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c98:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107c9f:	83 e2 f0             	and    $0xfffffff0,%edx
80107ca2:	83 ca 02             	or     $0x2,%edx
80107ca5:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cae:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107cb5:	83 ca 10             	or     $0x10,%edx
80107cb8:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc1:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107cc8:	83 e2 9f             	and    $0xffffff9f,%edx
80107ccb:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107cdb:	83 ca 80             	or     $0xffffff80,%edx
80107cde:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107cee:	83 ca 0f             	or     $0xf,%edx
80107cf1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfa:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d01:	83 e2 ef             	and    $0xffffffef,%edx
80107d04:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d14:	83 e2 df             	and    $0xffffffdf,%edx
80107d17:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d20:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d27:	83 ca 40             	or     $0x40,%edx
80107d2a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d33:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d3a:	83 ca 80             	or     $0xffffff80,%edx
80107d3d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d46:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d50:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107d57:	ff ff 
80107d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5c:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107d63:	00 00 
80107d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d68:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d72:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107d79:	83 e2 f0             	and    $0xfffffff0,%edx
80107d7c:	83 ca 0a             	or     $0xa,%edx
80107d7f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d88:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107d8f:	83 ca 10             	or     $0x10,%edx
80107d92:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107da2:	83 ca 60             	or     $0x60,%edx
80107da5:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dae:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107db5:	83 ca 80             	or     $0xffffff80,%edx
80107db8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107dc8:	83 ca 0f             	or     $0xf,%edx
80107dcb:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ddb:	83 e2 ef             	and    $0xffffffef,%edx
80107dde:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107de4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de7:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107dee:	83 e2 df             	and    $0xffffffdf,%edx
80107df1:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfa:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e01:	83 ca 40             	or     $0x40,%edx
80107e04:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e14:	83 ca 80             	or     $0xffffff80,%edx
80107e17:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e20:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2a:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107e31:	ff ff 
80107e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e36:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107e3d:	00 00 
80107e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e42:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107e53:	83 e2 f0             	and    $0xfffffff0,%edx
80107e56:	83 ca 02             	or     $0x2,%edx
80107e59:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107e5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e62:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107e69:	83 ca 10             	or     $0x10,%edx
80107e6c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e75:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107e7c:	83 ca 60             	or     $0x60,%edx
80107e7f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e88:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107e8f:	83 ca 80             	or     $0xffffff80,%edx
80107e92:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107ea2:	83 ca 0f             	or     $0xf,%edx
80107ea5:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eae:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107eb5:	83 e2 ef             	and    $0xffffffef,%edx
80107eb8:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec1:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107ec8:	83 e2 df             	and    $0xffffffdf,%edx
80107ecb:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed4:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107edb:	83 ca 40             	or     $0x40,%edx
80107ede:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee7:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107eee:	83 ca 80             	or     $0xffffff80,%edx
80107ef1:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107efa:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f04:	05 b4 00 00 00       	add    $0xb4,%eax
80107f09:	89 c3                	mov    %eax,%ebx
80107f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0e:	05 b4 00 00 00       	add    $0xb4,%eax
80107f13:	c1 e8 10             	shr    $0x10,%eax
80107f16:	89 c1                	mov    %eax,%ecx
80107f18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1b:	05 b4 00 00 00       	add    $0xb4,%eax
80107f20:	c1 e8 18             	shr    $0x18,%eax
80107f23:	89 c2                	mov    %eax,%edx
80107f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f28:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107f2f:	00 00 
80107f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f34:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f3e:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f47:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107f4e:	83 e1 f0             	and    $0xfffffff0,%ecx
80107f51:	83 c9 02             	or     $0x2,%ecx
80107f54:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5d:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107f64:	83 c9 10             	or     $0x10,%ecx
80107f67:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f70:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107f77:	83 e1 9f             	and    $0xffffff9f,%ecx
80107f7a:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f83:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107f8a:	83 c9 80             	or     $0xffffff80,%ecx
80107f8d:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f96:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107f9d:	83 e1 f0             	and    $0xfffffff0,%ecx
80107fa0:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa9:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107fb0:	83 e1 ef             	and    $0xffffffef,%ecx
80107fb3:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107fb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fbc:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107fc3:	83 e1 df             	and    $0xffffffdf,%ecx
80107fc6:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fcf:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107fd6:	83 c9 40             	or     $0x40,%ecx
80107fd9:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe2:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107fe9:	83 c9 80             	or     $0xffffff80,%ecx
80107fec:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff5:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ffe:	83 c0 70             	add    $0x70,%eax
80108001:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80108008:	00 
80108009:	89 04 24             	mov    %eax,(%esp)
8010800c:	e8 37 fb ff ff       	call   80107b48 <lgdt>
  loadgs(SEG_KCPU << 3);
80108011:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80108018:	e8 6a fb ff ff       	call   80107b87 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
8010801d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108020:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108026:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010802d:	00 00 00 00 
}
80108031:	83 c4 24             	add    $0x24,%esp
80108034:	5b                   	pop    %ebx
80108035:	5d                   	pop    %ebp
80108036:	c3                   	ret    

80108037 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108037:	55                   	push   %ebp
80108038:	89 e5                	mov    %esp,%ebp
8010803a:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010803d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108040:	c1 e8 16             	shr    $0x16,%eax
80108043:	c1 e0 02             	shl    $0x2,%eax
80108046:	03 45 08             	add    0x8(%ebp),%eax
80108049:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010804c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010804f:	8b 00                	mov    (%eax),%eax
80108051:	83 e0 01             	and    $0x1,%eax
80108054:	84 c0                	test   %al,%al
80108056:	74 17                	je     8010806f <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108058:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010805b:	8b 00                	mov    (%eax),%eax
8010805d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108062:	89 04 24             	mov    %eax,(%esp)
80108065:	e8 4a fb ff ff       	call   80107bb4 <p2v>
8010806a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010806d:	eb 4b                	jmp    801080ba <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010806f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108073:	74 0e                	je     80108083 <walkpgdir+0x4c>
80108075:	e8 cd aa ff ff       	call   80102b47 <kalloc>
8010807a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010807d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108081:	75 07                	jne    8010808a <walkpgdir+0x53>
      return 0;
80108083:	b8 00 00 00 00       	mov    $0x0,%eax
80108088:	eb 41                	jmp    801080cb <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
8010808a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108091:	00 
80108092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108099:	00 
8010809a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010809d:	89 04 24             	mov    %eax,(%esp)
801080a0:	e8 81 d4 ff ff       	call   80105526 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
801080a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a8:	89 04 24             	mov    %eax,(%esp)
801080ab:	e8 f7 fa ff ff       	call   80107ba7 <v2p>
801080b0:	89 c2                	mov    %eax,%edx
801080b2:	83 ca 07             	or     $0x7,%edx
801080b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080b8:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801080ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801080bd:	c1 e8 0c             	shr    $0xc,%eax
801080c0:	25 ff 03 00 00       	and    $0x3ff,%eax
801080c5:	c1 e0 02             	shl    $0x2,%eax
801080c8:	03 45 f4             	add    -0xc(%ebp),%eax
}
801080cb:	c9                   	leave  
801080cc:	c3                   	ret    

801080cd <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801080cd:	55                   	push   %ebp
801080ce:	89 e5                	mov    %esp,%ebp
801080d0:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
801080d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801080d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801080de:	8b 45 0c             	mov    0xc(%ebp),%eax
801080e1:	03 45 10             	add    0x10(%ebp),%eax
801080e4:	83 e8 01             	sub    $0x1,%eax
801080e7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801080ef:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801080f6:	00 
801080f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801080fe:	8b 45 08             	mov    0x8(%ebp),%eax
80108101:	89 04 24             	mov    %eax,(%esp)
80108104:	e8 2e ff ff ff       	call   80108037 <walkpgdir>
80108109:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010810c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108110:	75 07                	jne    80108119 <mappages+0x4c>
      return -1;
80108112:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108117:	eb 46                	jmp    8010815f <mappages+0x92>
    if(*pte & PTE_P)
80108119:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010811c:	8b 00                	mov    (%eax),%eax
8010811e:	83 e0 01             	and    $0x1,%eax
80108121:	84 c0                	test   %al,%al
80108123:	74 0c                	je     80108131 <mappages+0x64>
      panic("remap");
80108125:	c7 04 24 f4 8f 10 80 	movl   $0x80108ff4,(%esp)
8010812c:	e8 0c 84 ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80108131:	8b 45 18             	mov    0x18(%ebp),%eax
80108134:	0b 45 14             	or     0x14(%ebp),%eax
80108137:	89 c2                	mov    %eax,%edx
80108139:	83 ca 01             	or     $0x1,%edx
8010813c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010813f:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108141:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108144:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108147:	74 10                	je     80108159 <mappages+0x8c>
      break;
    a += PGSIZE;
80108149:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108150:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108157:	eb 96                	jmp    801080ef <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108159:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
8010815a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010815f:	c9                   	leave  
80108160:	c3                   	ret    

80108161 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108161:	55                   	push   %ebp
80108162:	89 e5                	mov    %esp,%ebp
80108164:	53                   	push   %ebx
80108165:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108168:	e8 da a9 ff ff       	call   80102b47 <kalloc>
8010816d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108170:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108174:	75 0a                	jne    80108180 <setupkvm+0x1f>
    return 0;
80108176:	b8 00 00 00 00       	mov    $0x0,%eax
8010817b:	e9 98 00 00 00       	jmp    80108218 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80108180:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108187:	00 
80108188:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010818f:	00 
80108190:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108193:	89 04 24             	mov    %eax,(%esp)
80108196:	e8 8b d3 ff ff       	call   80105526 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
8010819b:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
801081a2:	e8 0d fa ff ff       	call   80107bb4 <p2v>
801081a7:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
801081ac:	76 0c                	jbe    801081ba <setupkvm+0x59>
    panic("PHYSTOP too high");
801081ae:	c7 04 24 fa 8f 10 80 	movl   $0x80108ffa,(%esp)
801081b5:	e8 83 83 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801081ba:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
801081c1:	eb 49                	jmp    8010820c <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
801081c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801081c6:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
801081c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801081cc:	8b 50 04             	mov    0x4(%eax),%edx
801081cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d2:	8b 58 08             	mov    0x8(%eax),%ebx
801081d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081d8:	8b 40 04             	mov    0x4(%eax),%eax
801081db:	29 c3                	sub    %eax,%ebx
801081dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e0:	8b 00                	mov    (%eax),%eax
801081e2:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801081e6:	89 54 24 0c          	mov    %edx,0xc(%esp)
801081ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801081ee:	89 44 24 04          	mov    %eax,0x4(%esp)
801081f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081f5:	89 04 24             	mov    %eax,(%esp)
801081f8:	e8 d0 fe ff ff       	call   801080cd <mappages>
801081fd:	85 c0                	test   %eax,%eax
801081ff:	79 07                	jns    80108208 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108201:	b8 00 00 00 00       	mov    $0x0,%eax
80108206:	eb 10                	jmp    80108218 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108208:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010820c:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108213:	72 ae                	jb     801081c3 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108215:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108218:	83 c4 34             	add    $0x34,%esp
8010821b:	5b                   	pop    %ebx
8010821c:	5d                   	pop    %ebp
8010821d:	c3                   	ret    

8010821e <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010821e:	55                   	push   %ebp
8010821f:	89 e5                	mov    %esp,%ebp
80108221:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108224:	e8 38 ff ff ff       	call   80108161 <setupkvm>
80108229:	a3 78 66 11 80       	mov    %eax,0x80116678
  switchkvm();
8010822e:	e8 02 00 00 00       	call   80108235 <switchkvm>
}
80108233:	c9                   	leave  
80108234:	c3                   	ret    

80108235 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108235:	55                   	push   %ebp
80108236:	89 e5                	mov    %esp,%ebp
80108238:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
8010823b:	a1 78 66 11 80       	mov    0x80116678,%eax
80108240:	89 04 24             	mov    %eax,(%esp)
80108243:	e8 5f f9 ff ff       	call   80107ba7 <v2p>
80108248:	89 04 24             	mov    %eax,(%esp)
8010824b:	e8 4c f9 ff ff       	call   80107b9c <lcr3>
}
80108250:	c9                   	leave  
80108251:	c3                   	ret    

80108252 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108252:	55                   	push   %ebp
80108253:	89 e5                	mov    %esp,%ebp
80108255:	53                   	push   %ebx
80108256:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80108259:	e8 c1 d1 ff ff       	call   8010541f <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
8010825e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108264:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010826b:	83 c2 08             	add    $0x8,%edx
8010826e:	89 d3                	mov    %edx,%ebx
80108270:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108277:	83 c2 08             	add    $0x8,%edx
8010827a:	c1 ea 10             	shr    $0x10,%edx
8010827d:	89 d1                	mov    %edx,%ecx
8010827f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108286:	83 c2 08             	add    $0x8,%edx
80108289:	c1 ea 18             	shr    $0x18,%edx
8010828c:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108293:	67 00 
80108295:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
8010829c:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
801082a2:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801082a9:	83 e1 f0             	and    $0xfffffff0,%ecx
801082ac:	83 c9 09             	or     $0x9,%ecx
801082af:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801082b5:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801082bc:	83 c9 10             	or     $0x10,%ecx
801082bf:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801082c5:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801082cc:	83 e1 9f             	and    $0xffffff9f,%ecx
801082cf:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801082d5:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801082dc:	83 c9 80             	or     $0xffffff80,%ecx
801082df:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801082e5:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801082ec:	83 e1 f0             	and    $0xfffffff0,%ecx
801082ef:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801082f5:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801082fc:	83 e1 ef             	and    $0xffffffef,%ecx
801082ff:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108305:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010830c:	83 e1 df             	and    $0xffffffdf,%ecx
8010830f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108315:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010831c:	83 c9 40             	or     $0x40,%ecx
8010831f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108325:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010832c:	83 e1 7f             	and    $0x7f,%ecx
8010832f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108335:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
8010833b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108341:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108348:	83 e2 ef             	and    $0xffffffef,%edx
8010834b:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108351:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108357:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
8010835d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108363:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010836a:	8b 52 08             	mov    0x8(%edx),%edx
8010836d:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108373:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108376:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
8010837d:	e8 ef f7 ff ff       	call   80107b71 <ltr>
  if(p->pgdir == 0)
80108382:	8b 45 08             	mov    0x8(%ebp),%eax
80108385:	8b 40 04             	mov    0x4(%eax),%eax
80108388:	85 c0                	test   %eax,%eax
8010838a:	75 0c                	jne    80108398 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
8010838c:	c7 04 24 0b 90 10 80 	movl   $0x8010900b,(%esp)
80108393:	e8 a5 81 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108398:	8b 45 08             	mov    0x8(%ebp),%eax
8010839b:	8b 40 04             	mov    0x4(%eax),%eax
8010839e:	89 04 24             	mov    %eax,(%esp)
801083a1:	e8 01 f8 ff ff       	call   80107ba7 <v2p>
801083a6:	89 04 24             	mov    %eax,(%esp)
801083a9:	e8 ee f7 ff ff       	call   80107b9c <lcr3>
  popcli();
801083ae:	e8 b4 d0 ff ff       	call   80105467 <popcli>
}
801083b3:	83 c4 14             	add    $0x14,%esp
801083b6:	5b                   	pop    %ebx
801083b7:	5d                   	pop    %ebp
801083b8:	c3                   	ret    

801083b9 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801083b9:	55                   	push   %ebp
801083ba:	89 e5                	mov    %esp,%ebp
801083bc:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
801083bf:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801083c6:	76 0c                	jbe    801083d4 <inituvm+0x1b>
    panic("inituvm: more than a page");
801083c8:	c7 04 24 1f 90 10 80 	movl   $0x8010901f,(%esp)
801083cf:	e8 69 81 ff ff       	call   8010053d <panic>
  mem = kalloc();
801083d4:	e8 6e a7 ff ff       	call   80102b47 <kalloc>
801083d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801083dc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801083e3:	00 
801083e4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801083eb:	00 
801083ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ef:	89 04 24             	mov    %eax,(%esp)
801083f2:	e8 2f d1 ff ff       	call   80105526 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
801083f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083fa:	89 04 24             	mov    %eax,(%esp)
801083fd:	e8 a5 f7 ff ff       	call   80107ba7 <v2p>
80108402:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108409:	00 
8010840a:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010840e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108415:	00 
80108416:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010841d:	00 
8010841e:	8b 45 08             	mov    0x8(%ebp),%eax
80108421:	89 04 24             	mov    %eax,(%esp)
80108424:	e8 a4 fc ff ff       	call   801080cd <mappages>
  memmove(mem, init, sz);
80108429:	8b 45 10             	mov    0x10(%ebp),%eax
8010842c:	89 44 24 08          	mov    %eax,0x8(%esp)
80108430:	8b 45 0c             	mov    0xc(%ebp),%eax
80108433:	89 44 24 04          	mov    %eax,0x4(%esp)
80108437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010843a:	89 04 24             	mov    %eax,(%esp)
8010843d:	e8 b7 d1 ff ff       	call   801055f9 <memmove>
}
80108442:	c9                   	leave  
80108443:	c3                   	ret    

80108444 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108444:	55                   	push   %ebp
80108445:	89 e5                	mov    %esp,%ebp
80108447:	53                   	push   %ebx
80108448:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010844b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010844e:	25 ff 0f 00 00       	and    $0xfff,%eax
80108453:	85 c0                	test   %eax,%eax
80108455:	74 0c                	je     80108463 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108457:	c7 04 24 3c 90 10 80 	movl   $0x8010903c,(%esp)
8010845e:	e8 da 80 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108463:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010846a:	e9 ad 00 00 00       	jmp    8010851c <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010846f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108472:	8b 55 0c             	mov    0xc(%ebp),%edx
80108475:	01 d0                	add    %edx,%eax
80108477:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010847e:	00 
8010847f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108483:	8b 45 08             	mov    0x8(%ebp),%eax
80108486:	89 04 24             	mov    %eax,(%esp)
80108489:	e8 a9 fb ff ff       	call   80108037 <walkpgdir>
8010848e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108491:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108495:	75 0c                	jne    801084a3 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80108497:	c7 04 24 5f 90 10 80 	movl   $0x8010905f,(%esp)
8010849e:	e8 9a 80 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
801084a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084a6:	8b 00                	mov    (%eax),%eax
801084a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084ad:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801084b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b3:	8b 55 18             	mov    0x18(%ebp),%edx
801084b6:	89 d1                	mov    %edx,%ecx
801084b8:	29 c1                	sub    %eax,%ecx
801084ba:	89 c8                	mov    %ecx,%eax
801084bc:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801084c1:	77 11                	ja     801084d4 <loaduvm+0x90>
      n = sz - i;
801084c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c6:	8b 55 18             	mov    0x18(%ebp),%edx
801084c9:	89 d1                	mov    %edx,%ecx
801084cb:	29 c1                	sub    %eax,%ecx
801084cd:	89 c8                	mov    %ecx,%eax
801084cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
801084d2:	eb 07                	jmp    801084db <loaduvm+0x97>
    else
      n = PGSIZE;
801084d4:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
801084db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084de:	8b 55 14             	mov    0x14(%ebp),%edx
801084e1:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801084e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801084e7:	89 04 24             	mov    %eax,(%esp)
801084ea:	e8 c5 f6 ff ff       	call   80107bb4 <p2v>
801084ef:	8b 55 f0             	mov    -0x10(%ebp),%edx
801084f2:	89 54 24 0c          	mov    %edx,0xc(%esp)
801084f6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801084fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801084fe:	8b 45 10             	mov    0x10(%ebp),%eax
80108501:	89 04 24             	mov    %eax,(%esp)
80108504:	e8 9d 98 ff ff       	call   80101da6 <readi>
80108509:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010850c:	74 07                	je     80108515 <loaduvm+0xd1>
      return -1;
8010850e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108513:	eb 18                	jmp    8010852d <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108515:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010851c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851f:	3b 45 18             	cmp    0x18(%ebp),%eax
80108522:	0f 82 47 ff ff ff    	jb     8010846f <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108528:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010852d:	83 c4 24             	add    $0x24,%esp
80108530:	5b                   	pop    %ebx
80108531:	5d                   	pop    %ebp
80108532:	c3                   	ret    

80108533 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108533:	55                   	push   %ebp
80108534:	89 e5                	mov    %esp,%ebp
80108536:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108539:	8b 45 10             	mov    0x10(%ebp),%eax
8010853c:	85 c0                	test   %eax,%eax
8010853e:	79 0a                	jns    8010854a <allocuvm+0x17>
    return 0;
80108540:	b8 00 00 00 00       	mov    $0x0,%eax
80108545:	e9 c1 00 00 00       	jmp    8010860b <allocuvm+0xd8>
  if(newsz < oldsz)
8010854a:	8b 45 10             	mov    0x10(%ebp),%eax
8010854d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108550:	73 08                	jae    8010855a <allocuvm+0x27>
    return oldsz;
80108552:	8b 45 0c             	mov    0xc(%ebp),%eax
80108555:	e9 b1 00 00 00       	jmp    8010860b <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
8010855a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010855d:	05 ff 0f 00 00       	add    $0xfff,%eax
80108562:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108567:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010856a:	e9 8d 00 00 00       	jmp    801085fc <allocuvm+0xc9>
    mem = kalloc();
8010856f:	e8 d3 a5 ff ff       	call   80102b47 <kalloc>
80108574:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108577:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010857b:	75 2c                	jne    801085a9 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
8010857d:	c7 04 24 7d 90 10 80 	movl   $0x8010907d,(%esp)
80108584:	e8 18 7e ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108589:	8b 45 0c             	mov    0xc(%ebp),%eax
8010858c:	89 44 24 08          	mov    %eax,0x8(%esp)
80108590:	8b 45 10             	mov    0x10(%ebp),%eax
80108593:	89 44 24 04          	mov    %eax,0x4(%esp)
80108597:	8b 45 08             	mov    0x8(%ebp),%eax
8010859a:	89 04 24             	mov    %eax,(%esp)
8010859d:	e8 6b 00 00 00       	call   8010860d <deallocuvm>
      return 0;
801085a2:	b8 00 00 00 00       	mov    $0x0,%eax
801085a7:	eb 62                	jmp    8010860b <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
801085a9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801085b0:	00 
801085b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801085b8:	00 
801085b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085bc:	89 04 24             	mov    %eax,(%esp)
801085bf:	e8 62 cf ff ff       	call   80105526 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801085c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085c7:	89 04 24             	mov    %eax,(%esp)
801085ca:	e8 d8 f5 ff ff       	call   80107ba7 <v2p>
801085cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801085d2:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801085d9:	00 
801085da:	89 44 24 0c          	mov    %eax,0xc(%esp)
801085de:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801085e5:	00 
801085e6:	89 54 24 04          	mov    %edx,0x4(%esp)
801085ea:	8b 45 08             	mov    0x8(%ebp),%eax
801085ed:	89 04 24             	mov    %eax,(%esp)
801085f0:	e8 d8 fa ff ff       	call   801080cd <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801085f5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801085fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ff:	3b 45 10             	cmp    0x10(%ebp),%eax
80108602:	0f 82 67 ff ff ff    	jb     8010856f <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108608:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010860b:	c9                   	leave  
8010860c:	c3                   	ret    

8010860d <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010860d:	55                   	push   %ebp
8010860e:	89 e5                	mov    %esp,%ebp
80108610:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108613:	8b 45 10             	mov    0x10(%ebp),%eax
80108616:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108619:	72 08                	jb     80108623 <deallocuvm+0x16>
    return oldsz;
8010861b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010861e:	e9 a4 00 00 00       	jmp    801086c7 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80108623:	8b 45 10             	mov    0x10(%ebp),%eax
80108626:	05 ff 0f 00 00       	add    $0xfff,%eax
8010862b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108630:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108633:	e9 80 00 00 00       	jmp    801086b8 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108642:	00 
80108643:	89 44 24 04          	mov    %eax,0x4(%esp)
80108647:	8b 45 08             	mov    0x8(%ebp),%eax
8010864a:	89 04 24             	mov    %eax,(%esp)
8010864d:	e8 e5 f9 ff ff       	call   80108037 <walkpgdir>
80108652:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108655:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108659:	75 09                	jne    80108664 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
8010865b:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108662:	eb 4d                	jmp    801086b1 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108664:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108667:	8b 00                	mov    (%eax),%eax
80108669:	83 e0 01             	and    $0x1,%eax
8010866c:	84 c0                	test   %al,%al
8010866e:	74 41                	je     801086b1 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80108670:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108673:	8b 00                	mov    (%eax),%eax
80108675:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010867a:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010867d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108681:	75 0c                	jne    8010868f <deallocuvm+0x82>
        panic("kfree");
80108683:	c7 04 24 95 90 10 80 	movl   $0x80109095,(%esp)
8010868a:	e8 ae 7e ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
8010868f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108692:	89 04 24             	mov    %eax,(%esp)
80108695:	e8 1a f5 ff ff       	call   80107bb4 <p2v>
8010869a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010869d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801086a0:	89 04 24             	mov    %eax,(%esp)
801086a3:	e8 06 a4 ff ff       	call   80102aae <kfree>
      *pte = 0;
801086a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801086b1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801086b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086bb:	3b 45 0c             	cmp    0xc(%ebp),%eax
801086be:	0f 82 74 ff ff ff    	jb     80108638 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801086c4:	8b 45 10             	mov    0x10(%ebp),%eax
}
801086c7:	c9                   	leave  
801086c8:	c3                   	ret    

801086c9 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801086c9:	55                   	push   %ebp
801086ca:	89 e5                	mov    %esp,%ebp
801086cc:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
801086cf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801086d3:	75 0c                	jne    801086e1 <freevm+0x18>
    panic("freevm: no pgdir");
801086d5:	c7 04 24 9b 90 10 80 	movl   $0x8010909b,(%esp)
801086dc:	e8 5c 7e ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801086e1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801086e8:	00 
801086e9:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
801086f0:	80 
801086f1:	8b 45 08             	mov    0x8(%ebp),%eax
801086f4:	89 04 24             	mov    %eax,(%esp)
801086f7:	e8 11 ff ff ff       	call   8010860d <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801086fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108703:	eb 3c                	jmp    80108741 <freevm+0x78>
    if(pgdir[i] & PTE_P){
80108705:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108708:	c1 e0 02             	shl    $0x2,%eax
8010870b:	03 45 08             	add    0x8(%ebp),%eax
8010870e:	8b 00                	mov    (%eax),%eax
80108710:	83 e0 01             	and    $0x1,%eax
80108713:	84 c0                	test   %al,%al
80108715:	74 26                	je     8010873d <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108717:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010871a:	c1 e0 02             	shl    $0x2,%eax
8010871d:	03 45 08             	add    0x8(%ebp),%eax
80108720:	8b 00                	mov    (%eax),%eax
80108722:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108727:	89 04 24             	mov    %eax,(%esp)
8010872a:	e8 85 f4 ff ff       	call   80107bb4 <p2v>
8010872f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108732:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108735:	89 04 24             	mov    %eax,(%esp)
80108738:	e8 71 a3 ff ff       	call   80102aae <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010873d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108741:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108748:	76 bb                	jbe    80108705 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010874a:	8b 45 08             	mov    0x8(%ebp),%eax
8010874d:	89 04 24             	mov    %eax,(%esp)
80108750:	e8 59 a3 ff ff       	call   80102aae <kfree>
}
80108755:	c9                   	leave  
80108756:	c3                   	ret    

80108757 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108757:	55                   	push   %ebp
80108758:	89 e5                	mov    %esp,%ebp
8010875a:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010875d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108764:	00 
80108765:	8b 45 0c             	mov    0xc(%ebp),%eax
80108768:	89 44 24 04          	mov    %eax,0x4(%esp)
8010876c:	8b 45 08             	mov    0x8(%ebp),%eax
8010876f:	89 04 24             	mov    %eax,(%esp)
80108772:	e8 c0 f8 ff ff       	call   80108037 <walkpgdir>
80108777:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010877a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010877e:	75 0c                	jne    8010878c <clearpteu+0x35>
    panic("clearpteu");
80108780:	c7 04 24 ac 90 10 80 	movl   $0x801090ac,(%esp)
80108787:	e8 b1 7d ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
8010878c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010878f:	8b 00                	mov    (%eax),%eax
80108791:	89 c2                	mov    %eax,%edx
80108793:	83 e2 fb             	and    $0xfffffffb,%edx
80108796:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108799:	89 10                	mov    %edx,(%eax)
}
8010879b:	c9                   	leave  
8010879c:	c3                   	ret    

8010879d <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010879d:	55                   	push   %ebp
8010879e:	89 e5                	mov    %esp,%ebp
801087a0:	53                   	push   %ebx
801087a1:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801087a4:	e8 b8 f9 ff ff       	call   80108161 <setupkvm>
801087a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801087ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801087b0:	75 0a                	jne    801087bc <copyuvm+0x1f>
    return 0;
801087b2:	b8 00 00 00 00       	mov    $0x0,%eax
801087b7:	e9 fd 00 00 00       	jmp    801088b9 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
801087bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801087c3:	e9 cc 00 00 00       	jmp    80108894 <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801087c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801087d2:	00 
801087d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801087d7:	8b 45 08             	mov    0x8(%ebp),%eax
801087da:	89 04 24             	mov    %eax,(%esp)
801087dd:	e8 55 f8 ff ff       	call   80108037 <walkpgdir>
801087e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
801087e5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801087e9:	75 0c                	jne    801087f7 <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
801087eb:	c7 04 24 b6 90 10 80 	movl   $0x801090b6,(%esp)
801087f2:	e8 46 7d ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
801087f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087fa:	8b 00                	mov    (%eax),%eax
801087fc:	83 e0 01             	and    $0x1,%eax
801087ff:	85 c0                	test   %eax,%eax
80108801:	75 0c                	jne    8010880f <copyuvm+0x72>
      panic("copyuvm: page not present");
80108803:	c7 04 24 d0 90 10 80 	movl   $0x801090d0,(%esp)
8010880a:	e8 2e 7d ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
8010880f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108812:	8b 00                	mov    (%eax),%eax
80108814:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108819:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010881c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010881f:	8b 00                	mov    (%eax),%eax
80108821:	25 ff 0f 00 00       	and    $0xfff,%eax
80108826:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108829:	e8 19 a3 ff ff       	call   80102b47 <kalloc>
8010882e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108831:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108835:	74 6e                	je     801088a5 <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108837:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010883a:	89 04 24             	mov    %eax,(%esp)
8010883d:	e8 72 f3 ff ff       	call   80107bb4 <p2v>
80108842:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108849:	00 
8010884a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010884e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108851:	89 04 24             	mov    %eax,(%esp)
80108854:	e8 a0 cd ff ff       	call   801055f9 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108859:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010885c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010885f:	89 04 24             	mov    %eax,(%esp)
80108862:	e8 40 f3 ff ff       	call   80107ba7 <v2p>
80108867:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010886a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010886e:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108872:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108879:	00 
8010887a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010887e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108881:	89 04 24             	mov    %eax,(%esp)
80108884:	e8 44 f8 ff ff       	call   801080cd <mappages>
80108889:	85 c0                	test   %eax,%eax
8010888b:	78 1b                	js     801088a8 <copyuvm+0x10b>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010888d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108894:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108897:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010889a:	0f 82 28 ff ff ff    	jb     801087c8 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801088a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088a3:	eb 14                	jmp    801088b9 <copyuvm+0x11c>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801088a5:	90                   	nop
801088a6:	eb 01                	jmp    801088a9 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
801088a8:	90                   	nop
  }
  return d;

bad:
  freevm(d);
801088a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088ac:	89 04 24             	mov    %eax,(%esp)
801088af:	e8 15 fe ff ff       	call   801086c9 <freevm>
  return 0;
801088b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801088b9:	83 c4 44             	add    $0x44,%esp
801088bc:	5b                   	pop    %ebx
801088bd:	5d                   	pop    %ebp
801088be:	c3                   	ret    

801088bf <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801088bf:	55                   	push   %ebp
801088c0:	89 e5                	mov    %esp,%ebp
801088c2:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801088c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801088cc:	00 
801088cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801088d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801088d4:	8b 45 08             	mov    0x8(%ebp),%eax
801088d7:	89 04 24             	mov    %eax,(%esp)
801088da:	e8 58 f7 ff ff       	call   80108037 <walkpgdir>
801088df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801088e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e5:	8b 00                	mov    (%eax),%eax
801088e7:	83 e0 01             	and    $0x1,%eax
801088ea:	85 c0                	test   %eax,%eax
801088ec:	75 07                	jne    801088f5 <uva2ka+0x36>
    return 0;
801088ee:	b8 00 00 00 00       	mov    $0x0,%eax
801088f3:	eb 25                	jmp    8010891a <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
801088f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f8:	8b 00                	mov    (%eax),%eax
801088fa:	83 e0 04             	and    $0x4,%eax
801088fd:	85 c0                	test   %eax,%eax
801088ff:	75 07                	jne    80108908 <uva2ka+0x49>
    return 0;
80108901:	b8 00 00 00 00       	mov    $0x0,%eax
80108906:	eb 12                	jmp    8010891a <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010890b:	8b 00                	mov    (%eax),%eax
8010890d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108912:	89 04 24             	mov    %eax,(%esp)
80108915:	e8 9a f2 ff ff       	call   80107bb4 <p2v>
}
8010891a:	c9                   	leave  
8010891b:	c3                   	ret    

8010891c <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010891c:	55                   	push   %ebp
8010891d:	89 e5                	mov    %esp,%ebp
8010891f:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108922:	8b 45 10             	mov    0x10(%ebp),%eax
80108925:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108928:	e9 8b 00 00 00       	jmp    801089b8 <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
8010892d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108930:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108935:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108938:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010893b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010893f:	8b 45 08             	mov    0x8(%ebp),%eax
80108942:	89 04 24             	mov    %eax,(%esp)
80108945:	e8 75 ff ff ff       	call   801088bf <uva2ka>
8010894a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010894d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108951:	75 07                	jne    8010895a <copyout+0x3e>
      return -1;
80108953:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108958:	eb 6d                	jmp    801089c7 <copyout+0xab>
    n = PGSIZE - (va - va0);
8010895a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010895d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108960:	89 d1                	mov    %edx,%ecx
80108962:	29 c1                	sub    %eax,%ecx
80108964:	89 c8                	mov    %ecx,%eax
80108966:	05 00 10 00 00       	add    $0x1000,%eax
8010896b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010896e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108971:	3b 45 14             	cmp    0x14(%ebp),%eax
80108974:	76 06                	jbe    8010897c <copyout+0x60>
      n = len;
80108976:	8b 45 14             	mov    0x14(%ebp),%eax
80108979:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010897c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010897f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108982:	89 d1                	mov    %edx,%ecx
80108984:	29 c1                	sub    %eax,%ecx
80108986:	89 c8                	mov    %ecx,%eax
80108988:	03 45 e8             	add    -0x18(%ebp),%eax
8010898b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010898e:	89 54 24 08          	mov    %edx,0x8(%esp)
80108992:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108995:	89 54 24 04          	mov    %edx,0x4(%esp)
80108999:	89 04 24             	mov    %eax,(%esp)
8010899c:	e8 58 cc ff ff       	call   801055f9 <memmove>
    len -= n;
801089a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089a4:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801089a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089aa:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801089ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089b0:	05 00 10 00 00       	add    $0x1000,%eax
801089b5:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801089b8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801089bc:	0f 85 6b ff ff ff    	jne    8010892d <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801089c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801089c7:	c9                   	leave  
801089c8:	c3                   	ret    
801089c9:	00 00                	add    %al,(%eax)
	...

801089cc <EXEC_COPY_EXIT>:
#include "syscall.h"
#include "traps.h"

.globl EXEC_COPY_EXIT
EXEC_COPY_EXIT:
  pushl %eax
801089cc:	50                   	push   %eax
  pushl %eax
801089cd:	50                   	push   %eax
  movl $SYS_exit, %eax
801089ce:	b8 02 00 00 00       	mov    $0x2,%eax
  int $T_SYSCALL
801089d3:	cd 40                	int    $0x40
  ret
801089d5:	c3                   	ret    
