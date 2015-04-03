
_sh:     file format elf32-i386


Disassembly of section .text:

00000000 <runcmd>:
struct cmd *parsecmd(char*);

// Execute cmd.  Never returns.
void
runcmd(struct cmd *cmd)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
       6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
       a:	75 0c                	jne    18 <runcmd+0x18>
    exit(EXIT_STATUS_OK);
       c:	c7 04 24 6f 00 00 00 	movl   $0x6f,(%esp)
      13:	e8 c4 0f 00 00       	call   fdc <exit>
  
  switch(cmd->type){
      18:	8b 45 08             	mov    0x8(%ebp),%eax
      1b:	8b 00                	mov    (%eax),%eax
      1d:	83 f8 05             	cmp    $0x5,%eax
      20:	77 09                	ja     2b <runcmd+0x2b>
      22:	8b 04 85 70 15 00 00 	mov    0x1570(,%eax,4),%eax
      29:	ff e0                	jmp    *%eax
  default:
    panic("runcmd");
      2b:	c7 04 24 20 15 00 00 	movl   $0x1520,(%esp)
      32:	e8 96 03 00 00       	call   3cd <panic>

  case EXEC:
    ecmd = (struct execcmd*)cmd;
      37:	8b 45 08             	mov    0x8(%ebp),%eax
      3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ecmd->argv[0] == 0)
      3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
      40:	8b 40 04             	mov    0x4(%eax),%eax
      43:	85 c0                	test   %eax,%eax
      45:	75 0c                	jne    53 <runcmd+0x53>
      exit(EXIT_STATUS_ERR);
      47:	c7 04 24 4d 01 00 00 	movl   $0x14d,(%esp)
      4e:	e8 89 0f 00 00       	call   fdc <exit>
    exec(ecmd->argv[0], ecmd->argv);
      53:	8b 45 f4             	mov    -0xc(%ebp),%eax
      56:	8d 50 04             	lea    0x4(%eax),%edx
      59:	8b 45 f4             	mov    -0xc(%ebp),%eax
      5c:	8b 40 04             	mov    0x4(%eax),%eax
      5f:	89 54 24 04          	mov    %edx,0x4(%esp)
      63:	89 04 24             	mov    %eax,(%esp)
      66:	e8 a9 0f 00 00       	call   1014 <exec>
    printf(2, "exec %s failed\n", ecmd->argv[0]);
      6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
      6e:	8b 40 04             	mov    0x4(%eax),%eax
      71:	89 44 24 08          	mov    %eax,0x8(%esp)
      75:	c7 44 24 04 27 15 00 	movl   $0x1527,0x4(%esp)
      7c:	00 
      7d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      84:	e8 d2 10 00 00       	call   115b <printf>
    break;
      89:	e9 9d 01 00 00       	jmp    22b <runcmd+0x22b>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
      8e:	8b 45 08             	mov    0x8(%ebp),%eax
      91:	89 45 f0             	mov    %eax,-0x10(%ebp)
    close(rcmd->fd);
      94:	8b 45 f0             	mov    -0x10(%ebp),%eax
      97:	8b 40 14             	mov    0x14(%eax),%eax
      9a:	89 04 24             	mov    %eax,(%esp)
      9d:	e8 62 0f 00 00       	call   1004 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
      a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
      a5:	8b 50 10             	mov    0x10(%eax),%edx
      a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
      ab:	8b 40 08             	mov    0x8(%eax),%eax
      ae:	89 54 24 04          	mov    %edx,0x4(%esp)
      b2:	89 04 24             	mov    %eax,(%esp)
      b5:	e8 62 0f 00 00       	call   101c <open>
      ba:	85 c0                	test   %eax,%eax
      bc:	79 2a                	jns    e8 <runcmd+0xe8>
      printf(2, "open %s failed\n", rcmd->file);
      be:	8b 45 f0             	mov    -0x10(%ebp),%eax
      c1:	8b 40 08             	mov    0x8(%eax),%eax
      c4:	89 44 24 08          	mov    %eax,0x8(%esp)
      c8:	c7 44 24 04 37 15 00 	movl   $0x1537,0x4(%esp)
      cf:	00 
      d0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      d7:	e8 7f 10 00 00       	call   115b <printf>
      exit(EXIT_STATUS_ERR);
      dc:	c7 04 24 4d 01 00 00 	movl   $0x14d,(%esp)
      e3:	e8 f4 0e 00 00       	call   fdc <exit>
    }
    runcmd(rcmd->cmd);
      e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
      eb:	8b 40 04             	mov    0x4(%eax),%eax
      ee:	89 04 24             	mov    %eax,(%esp)
      f1:	e8 0a ff ff ff       	call   0 <runcmd>
    break;
      f6:	e9 30 01 00 00       	jmp    22b <runcmd+0x22b>

  case LIST:
    lcmd = (struct listcmd*)cmd;
      fb:	8b 45 08             	mov    0x8(%ebp),%eax
      fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fork1() == 0)
     101:	e8 f4 02 00 00       	call   3fa <fork1>
     106:	85 c0                	test   %eax,%eax
     108:	75 0e                	jne    118 <runcmd+0x118>
      runcmd(lcmd->left);
     10a:	8b 45 ec             	mov    -0x14(%ebp),%eax
     10d:	8b 40 04             	mov    0x4(%eax),%eax
     110:	89 04 24             	mov    %eax,(%esp)
     113:	e8 e8 fe ff ff       	call   0 <runcmd>
    wait(&status);
     118:	8d 45 d8             	lea    -0x28(%ebp),%eax
     11b:	89 04 24             	mov    %eax,(%esp)
     11e:	e8 c1 0e 00 00       	call   fe4 <wait>
    runcmd(lcmd->right);
     123:	8b 45 ec             	mov    -0x14(%ebp),%eax
     126:	8b 40 08             	mov    0x8(%eax),%eax
     129:	89 04 24             	mov    %eax,(%esp)
     12c:	e8 cf fe ff ff       	call   0 <runcmd>
    break;
     131:	e9 f5 00 00 00       	jmp    22b <runcmd+0x22b>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     136:	8b 45 08             	mov    0x8(%ebp),%eax
     139:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pipe(p) < 0)
     13c:	8d 45 dc             	lea    -0x24(%ebp),%eax
     13f:	89 04 24             	mov    %eax,(%esp)
     142:	e8 a5 0e 00 00       	call   fec <pipe>
     147:	85 c0                	test   %eax,%eax
     149:	79 0c                	jns    157 <runcmd+0x157>
      panic("pipe");
     14b:	c7 04 24 47 15 00 00 	movl   $0x1547,(%esp)
     152:	e8 76 02 00 00       	call   3cd <panic>
    if(fork1() == 0){
     157:	e8 9e 02 00 00       	call   3fa <fork1>
     15c:	85 c0                	test   %eax,%eax
     15e:	75 3b                	jne    19b <runcmd+0x19b>
      close(1);
     160:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     167:	e8 98 0e 00 00       	call   1004 <close>
      dup(p[1]);
     16c:	8b 45 e0             	mov    -0x20(%ebp),%eax
     16f:	89 04 24             	mov    %eax,(%esp)
     172:	e8 dd 0e 00 00       	call   1054 <dup>
      close(p[0]);
     177:	8b 45 dc             	mov    -0x24(%ebp),%eax
     17a:	89 04 24             	mov    %eax,(%esp)
     17d:	e8 82 0e 00 00       	call   1004 <close>
      close(p[1]);
     182:	8b 45 e0             	mov    -0x20(%ebp),%eax
     185:	89 04 24             	mov    %eax,(%esp)
     188:	e8 77 0e 00 00       	call   1004 <close>
      runcmd(pcmd->left);
     18d:	8b 45 e8             	mov    -0x18(%ebp),%eax
     190:	8b 40 04             	mov    0x4(%eax),%eax
     193:	89 04 24             	mov    %eax,(%esp)
     196:	e8 65 fe ff ff       	call   0 <runcmd>
    }
    if(fork1() == 0){
     19b:	e8 5a 02 00 00       	call   3fa <fork1>
     1a0:	85 c0                	test   %eax,%eax
     1a2:	75 3b                	jne    1df <runcmd+0x1df>
      close(0);
     1a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     1ab:	e8 54 0e 00 00       	call   1004 <close>
      dup(p[0]);
     1b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1b3:	89 04 24             	mov    %eax,(%esp)
     1b6:	e8 99 0e 00 00       	call   1054 <dup>
      close(p[0]);
     1bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1be:	89 04 24             	mov    %eax,(%esp)
     1c1:	e8 3e 0e 00 00       	call   1004 <close>
      close(p[1]);
     1c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1c9:	89 04 24             	mov    %eax,(%esp)
     1cc:	e8 33 0e 00 00       	call   1004 <close>
      runcmd(pcmd->right);
     1d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
     1d4:	8b 40 08             	mov    0x8(%eax),%eax
     1d7:	89 04 24             	mov    %eax,(%esp)
     1da:	e8 21 fe ff ff       	call   0 <runcmd>
    }
    close(p[0]);
     1df:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1e2:	89 04 24             	mov    %eax,(%esp)
     1e5:	e8 1a 0e 00 00       	call   1004 <close>
    close(p[1]);
     1ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1ed:	89 04 24             	mov    %eax,(%esp)
     1f0:	e8 0f 0e 00 00       	call   1004 <close>
    wait(&status);
     1f5:	8d 45 d8             	lea    -0x28(%ebp),%eax
     1f8:	89 04 24             	mov    %eax,(%esp)
     1fb:	e8 e4 0d 00 00       	call   fe4 <wait>
    wait(&status);
     200:	8d 45 d8             	lea    -0x28(%ebp),%eax
     203:	89 04 24             	mov    %eax,(%esp)
     206:	e8 d9 0d 00 00       	call   fe4 <wait>
    break;
     20b:	eb 1e                	jmp    22b <runcmd+0x22b>
    
  case BACK:
    bcmd = (struct backcmd*)cmd;
     20d:	8b 45 08             	mov    0x8(%ebp),%eax
     210:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(fork1() == 0)
     213:	e8 e2 01 00 00       	call   3fa <fork1>
     218:	85 c0                	test   %eax,%eax
     21a:	75 0e                	jne    22a <runcmd+0x22a>
      runcmd(bcmd->cmd);
     21c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     21f:	8b 40 04             	mov    0x4(%eax),%eax
     222:	89 04 24             	mov    %eax,(%esp)
     225:	e8 d6 fd ff ff       	call   0 <runcmd>
    break;
     22a:	90                   	nop
  }
  
  printf(2, "Process completed with status - %d\n", status);
     22b:	8b 45 d8             	mov    -0x28(%ebp),%eax
     22e:	89 44 24 08          	mov    %eax,0x8(%esp)
     232:	c7 44 24 04 4c 15 00 	movl   $0x154c,0x4(%esp)
     239:	00 
     23a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     241:	e8 15 0f 00 00       	call   115b <printf>
  exit(EXIT_STATUS_OK);
     246:	c7 04 24 6f 00 00 00 	movl   $0x6f,(%esp)
     24d:	e8 8a 0d 00 00       	call   fdc <exit>

00000252 <getcmd>:
}

int
getcmd(char *buf, int nbuf)
{
     252:	55                   	push   %ebp
     253:	89 e5                	mov    %esp,%ebp
     255:	83 ec 18             	sub    $0x18,%esp
  printf(2, "$ ");
     258:	c7 44 24 04 88 15 00 	movl   $0x1588,0x4(%esp)
     25f:	00 
     260:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     267:	e8 ef 0e 00 00       	call   115b <printf>
  memset(buf, 0, nbuf);
     26c:	8b 45 0c             	mov    0xc(%ebp),%eax
     26f:	89 44 24 08          	mov    %eax,0x8(%esp)
     273:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     27a:	00 
     27b:	8b 45 08             	mov    0x8(%ebp),%eax
     27e:	89 04 24             	mov    %eax,(%esp)
     281:	e8 b1 0b 00 00       	call   e37 <memset>
  gets(buf, nbuf);
     286:	8b 45 0c             	mov    0xc(%ebp),%eax
     289:	89 44 24 04          	mov    %eax,0x4(%esp)
     28d:	8b 45 08             	mov    0x8(%ebp),%eax
     290:	89 04 24             	mov    %eax,(%esp)
     293:	e8 f6 0b 00 00       	call   e8e <gets>
  if(buf[0] == 0) // EOF
     298:	8b 45 08             	mov    0x8(%ebp),%eax
     29b:	0f b6 00             	movzbl (%eax),%eax
     29e:	84 c0                	test   %al,%al
     2a0:	75 07                	jne    2a9 <getcmd+0x57>
    return -1;
     2a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     2a7:	eb 05                	jmp    2ae <getcmd+0x5c>
  return 0;
     2a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
     2ae:	c9                   	leave  
     2af:	c3                   	ret    

000002b0 <main>:

int
main(void)
{
     2b0:	55                   	push   %ebp
     2b1:	89 e5                	mov    %esp,%ebp
     2b3:	83 e4 f0             	and    $0xfffffff0,%esp
     2b6:	83 ec 20             	sub    $0x20,%esp
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     2b9:	eb 19                	jmp    2d4 <main+0x24>
    if(fd >= 3){
     2bb:	83 7c 24 1c 02       	cmpl   $0x2,0x1c(%esp)
     2c0:	7e 12                	jle    2d4 <main+0x24>
      close(fd);
     2c2:	8b 44 24 1c          	mov    0x1c(%esp),%eax
     2c6:	89 04 24             	mov    %eax,(%esp)
     2c9:	e8 36 0d 00 00       	call   1004 <close>
      break;
     2ce:	90                   	nop
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     2cf:	e9 d1 00 00 00       	jmp    3a5 <main+0xf5>
{
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     2d4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     2db:	00 
     2dc:	c7 04 24 8b 15 00 00 	movl   $0x158b,(%esp)
     2e3:	e8 34 0d 00 00       	call   101c <open>
     2e8:	89 44 24 1c          	mov    %eax,0x1c(%esp)
     2ec:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
     2f1:	79 c8                	jns    2bb <main+0xb>
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     2f3:	e9 ad 00 00 00       	jmp    3a5 <main+0xf5>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     2f8:	0f b6 05 00 1b 00 00 	movzbl 0x1b00,%eax
     2ff:	3c 63                	cmp    $0x63,%al
     301:	75 5a                	jne    35d <main+0xad>
     303:	0f b6 05 01 1b 00 00 	movzbl 0x1b01,%eax
     30a:	3c 64                	cmp    $0x64,%al
     30c:	75 4f                	jne    35d <main+0xad>
     30e:	0f b6 05 02 1b 00 00 	movzbl 0x1b02,%eax
     315:	3c 20                	cmp    $0x20,%al
     317:	75 44                	jne    35d <main+0xad>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
     319:	c7 04 24 00 1b 00 00 	movl   $0x1b00,(%esp)
     320:	e8 ed 0a 00 00       	call   e12 <strlen>
     325:	83 e8 01             	sub    $0x1,%eax
     328:	c6 80 00 1b 00 00 00 	movb   $0x0,0x1b00(%eax)
      if(chdir(buf+3) < 0)
     32f:	c7 04 24 03 1b 00 00 	movl   $0x1b03,(%esp)
     336:	e8 11 0d 00 00       	call   104c <chdir>
     33b:	85 c0                	test   %eax,%eax
     33d:	79 65                	jns    3a4 <main+0xf4>
        printf(2, "cannot cd %s\n", buf+3);
     33f:	c7 44 24 08 03 1b 00 	movl   $0x1b03,0x8(%esp)
     346:	00 
     347:	c7 44 24 04 93 15 00 	movl   $0x1593,0x4(%esp)
     34e:	00 
     34f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     356:	e8 00 0e 00 00       	call   115b <printf>
      continue;
     35b:	eb 47                	jmp    3a4 <main+0xf4>
    }
    if(fork1() == 0)
     35d:	e8 98 00 00 00       	call   3fa <fork1>
     362:	85 c0                	test   %eax,%eax
     364:	75 14                	jne    37a <main+0xca>
      runcmd(parsecmd(buf));
     366:	c7 04 24 00 1b 00 00 	movl   $0x1b00,(%esp)
     36d:	e8 fa 03 00 00       	call   76c <parsecmd>
     372:	89 04 24             	mov    %eax,(%esp)
     375:	e8 86 fc ff ff       	call   0 <runcmd>
    int status;
    wait(&status);
     37a:	8d 44 24 18          	lea    0x18(%esp),%eax
     37e:	89 04 24             	mov    %eax,(%esp)
     381:	e8 5e 0c 00 00       	call   fe4 <wait>
    
    printf(2, "Program exited with %d\n", status);
     386:	8b 44 24 18          	mov    0x18(%esp),%eax
     38a:	89 44 24 08          	mov    %eax,0x8(%esp)
     38e:	c7 44 24 04 a1 15 00 	movl   $0x15a1,0x4(%esp)
     395:	00 
     396:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     39d:	e8 b9 0d 00 00       	call   115b <printf>
     3a2:	eb 01                	jmp    3a5 <main+0xf5>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
      if(chdir(buf+3) < 0)
        printf(2, "cannot cd %s\n", buf+3);
      continue;
     3a4:	90                   	nop
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     3a5:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
     3ac:	00 
     3ad:	c7 04 24 00 1b 00 00 	movl   $0x1b00,(%esp)
     3b4:	e8 99 fe ff ff       	call   252 <getcmd>
     3b9:	85 c0                	test   %eax,%eax
     3bb:	0f 89 37 ff ff ff    	jns    2f8 <main+0x48>
    int status;
    wait(&status);
    
    printf(2, "Program exited with %d\n", status);
  }
  exit(EXIT_STATUS_OK);
     3c1:	c7 04 24 6f 00 00 00 	movl   $0x6f,(%esp)
     3c8:	e8 0f 0c 00 00       	call   fdc <exit>

000003cd <panic>:
}

void
panic(char *s)
{
     3cd:	55                   	push   %ebp
     3ce:	89 e5                	mov    %esp,%ebp
     3d0:	83 ec 18             	sub    $0x18,%esp
  printf(2, "%s\n", s);
     3d3:	8b 45 08             	mov    0x8(%ebp),%eax
     3d6:	89 44 24 08          	mov    %eax,0x8(%esp)
     3da:	c7 44 24 04 b9 15 00 	movl   $0x15b9,0x4(%esp)
     3e1:	00 
     3e2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     3e9:	e8 6d 0d 00 00       	call   115b <printf>
  exit(EXIT_STATUS_ERR);
     3ee:	c7 04 24 4d 01 00 00 	movl   $0x14d,(%esp)
     3f5:	e8 e2 0b 00 00       	call   fdc <exit>

000003fa <fork1>:
}

int
fork1(void)
{
     3fa:	55                   	push   %ebp
     3fb:	89 e5                	mov    %esp,%ebp
     3fd:	83 ec 28             	sub    $0x28,%esp
  int pid;
  
  pid = fork();
     400:	e8 cf 0b 00 00       	call   fd4 <fork>
     405:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
     408:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     40c:	75 0c                	jne    41a <fork1+0x20>
    panic("fork");
     40e:	c7 04 24 bd 15 00 00 	movl   $0x15bd,(%esp)
     415:	e8 b3 ff ff ff       	call   3cd <panic>
  return pid;
     41a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     41d:	c9                   	leave  
     41e:	c3                   	ret    

0000041f <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     41f:	55                   	push   %ebp
     420:	89 e5                	mov    %esp,%ebp
     422:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     425:	c7 04 24 54 00 00 00 	movl   $0x54,(%esp)
     42c:	e8 0e 10 00 00       	call   143f <malloc>
     431:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     434:	c7 44 24 08 54 00 00 	movl   $0x54,0x8(%esp)
     43b:	00 
     43c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     443:	00 
     444:	8b 45 f4             	mov    -0xc(%ebp),%eax
     447:	89 04 24             	mov    %eax,(%esp)
     44a:	e8 e8 09 00 00       	call   e37 <memset>
  cmd->type = EXEC;
     44f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     452:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  return (struct cmd*)cmd;
     458:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     45b:	c9                   	leave  
     45c:	c3                   	ret    

0000045d <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     45d:	55                   	push   %ebp
     45e:	89 e5                	mov    %esp,%ebp
     460:	83 ec 28             	sub    $0x28,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     463:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
     46a:	e8 d0 0f 00 00       	call   143f <malloc>
     46f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     472:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
     479:	00 
     47a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     481:	00 
     482:	8b 45 f4             	mov    -0xc(%ebp),%eax
     485:	89 04 24             	mov    %eax,(%esp)
     488:	e8 aa 09 00 00       	call   e37 <memset>
  cmd->type = REDIR;
     48d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     490:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  cmd->cmd = subcmd;
     496:	8b 45 f4             	mov    -0xc(%ebp),%eax
     499:	8b 55 08             	mov    0x8(%ebp),%edx
     49c:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->file = file;
     49f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4a2:	8b 55 0c             	mov    0xc(%ebp),%edx
     4a5:	89 50 08             	mov    %edx,0x8(%eax)
  cmd->efile = efile;
     4a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4ab:	8b 55 10             	mov    0x10(%ebp),%edx
     4ae:	89 50 0c             	mov    %edx,0xc(%eax)
  cmd->mode = mode;
     4b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4b4:	8b 55 14             	mov    0x14(%ebp),%edx
     4b7:	89 50 10             	mov    %edx,0x10(%eax)
  cmd->fd = fd;
     4ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4bd:	8b 55 18             	mov    0x18(%ebp),%edx
     4c0:	89 50 14             	mov    %edx,0x14(%eax)
  return (struct cmd*)cmd;
     4c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     4c6:	c9                   	leave  
     4c7:	c3                   	ret    

000004c8 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     4c8:	55                   	push   %ebp
     4c9:	89 e5                	mov    %esp,%ebp
     4cb:	83 ec 28             	sub    $0x28,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     4ce:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     4d5:	e8 65 0f 00 00       	call   143f <malloc>
     4da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     4dd:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     4e4:	00 
     4e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     4ec:	00 
     4ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4f0:	89 04 24             	mov    %eax,(%esp)
     4f3:	e8 3f 09 00 00       	call   e37 <memset>
  cmd->type = PIPE;
     4f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4fb:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
  cmd->left = left;
     501:	8b 45 f4             	mov    -0xc(%ebp),%eax
     504:	8b 55 08             	mov    0x8(%ebp),%edx
     507:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     50a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     50d:	8b 55 0c             	mov    0xc(%ebp),%edx
     510:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     513:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     516:	c9                   	leave  
     517:	c3                   	ret    

00000518 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     518:	55                   	push   %ebp
     519:	89 e5                	mov    %esp,%ebp
     51b:	83 ec 28             	sub    $0x28,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     51e:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     525:	e8 15 0f 00 00       	call   143f <malloc>
     52a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     52d:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     534:	00 
     535:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     53c:	00 
     53d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     540:	89 04 24             	mov    %eax,(%esp)
     543:	e8 ef 08 00 00       	call   e37 <memset>
  cmd->type = LIST;
     548:	8b 45 f4             	mov    -0xc(%ebp),%eax
     54b:	c7 00 04 00 00 00    	movl   $0x4,(%eax)
  cmd->left = left;
     551:	8b 45 f4             	mov    -0xc(%ebp),%eax
     554:	8b 55 08             	mov    0x8(%ebp),%edx
     557:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     55a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     55d:	8b 55 0c             	mov    0xc(%ebp),%edx
     560:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     563:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     566:	c9                   	leave  
     567:	c3                   	ret    

00000568 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     568:	55                   	push   %ebp
     569:	89 e5                	mov    %esp,%ebp
     56b:	83 ec 28             	sub    $0x28,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     56e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
     575:	e8 c5 0e 00 00       	call   143f <malloc>
     57a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     57d:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
     584:	00 
     585:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     58c:	00 
     58d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     590:	89 04 24             	mov    %eax,(%esp)
     593:	e8 9f 08 00 00       	call   e37 <memset>
  cmd->type = BACK;
     598:	8b 45 f4             	mov    -0xc(%ebp),%eax
     59b:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
  cmd->cmd = subcmd;
     5a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5a4:	8b 55 08             	mov    0x8(%ebp),%edx
     5a7:	89 50 04             	mov    %edx,0x4(%eax)
  return (struct cmd*)cmd;
     5aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     5ad:	c9                   	leave  
     5ae:	c3                   	ret    

000005af <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     5af:	55                   	push   %ebp
     5b0:	89 e5                	mov    %esp,%ebp
     5b2:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int ret;
  
  s = *ps;
     5b5:	8b 45 08             	mov    0x8(%ebp),%eax
     5b8:	8b 00                	mov    (%eax),%eax
     5ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     5bd:	eb 04                	jmp    5c3 <gettoken+0x14>
    s++;
     5bf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
{
  char *s;
  int ret;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     5c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5c6:	3b 45 0c             	cmp    0xc(%ebp),%eax
     5c9:	73 1d                	jae    5e8 <gettoken+0x39>
     5cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5ce:	0f b6 00             	movzbl (%eax),%eax
     5d1:	0f be c0             	movsbl %al,%eax
     5d4:	89 44 24 04          	mov    %eax,0x4(%esp)
     5d8:	c7 04 24 cc 1a 00 00 	movl   $0x1acc,(%esp)
     5df:	e8 77 08 00 00       	call   e5b <strchr>
     5e4:	85 c0                	test   %eax,%eax
     5e6:	75 d7                	jne    5bf <gettoken+0x10>
    s++;
  if(q)
     5e8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     5ec:	74 08                	je     5f6 <gettoken+0x47>
    *q = s;
     5ee:	8b 45 10             	mov    0x10(%ebp),%eax
     5f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
     5f4:	89 10                	mov    %edx,(%eax)
  ret = *s;
     5f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5f9:	0f b6 00             	movzbl (%eax),%eax
     5fc:	0f be c0             	movsbl %al,%eax
     5ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  switch(*s){
     602:	8b 45 f4             	mov    -0xc(%ebp),%eax
     605:	0f b6 00             	movzbl (%eax),%eax
     608:	0f be c0             	movsbl %al,%eax
     60b:	83 f8 3c             	cmp    $0x3c,%eax
     60e:	7f 1e                	jg     62e <gettoken+0x7f>
     610:	83 f8 3b             	cmp    $0x3b,%eax
     613:	7d 23                	jge    638 <gettoken+0x89>
     615:	83 f8 29             	cmp    $0x29,%eax
     618:	7f 3f                	jg     659 <gettoken+0xaa>
     61a:	83 f8 28             	cmp    $0x28,%eax
     61d:	7d 19                	jge    638 <gettoken+0x89>
     61f:	85 c0                	test   %eax,%eax
     621:	0f 84 83 00 00 00    	je     6aa <gettoken+0xfb>
     627:	83 f8 26             	cmp    $0x26,%eax
     62a:	74 0c                	je     638 <gettoken+0x89>
     62c:	eb 2b                	jmp    659 <gettoken+0xaa>
     62e:	83 f8 3e             	cmp    $0x3e,%eax
     631:	74 0b                	je     63e <gettoken+0x8f>
     633:	83 f8 7c             	cmp    $0x7c,%eax
     636:	75 21                	jne    659 <gettoken+0xaa>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     638:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
     63c:	eb 73                	jmp    6b1 <gettoken+0x102>
  case '>':
    s++;
     63e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(*s == '>'){
     642:	8b 45 f4             	mov    -0xc(%ebp),%eax
     645:	0f b6 00             	movzbl (%eax),%eax
     648:	3c 3e                	cmp    $0x3e,%al
     64a:	75 61                	jne    6ad <gettoken+0xfe>
      ret = '+';
     64c:	c7 45 f0 2b 00 00 00 	movl   $0x2b,-0x10(%ebp)
      s++;
     653:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    break;
     657:	eb 54                	jmp    6ad <gettoken+0xfe>
  default:
    ret = 'a';
     659:	c7 45 f0 61 00 00 00 	movl   $0x61,-0x10(%ebp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     660:	eb 04                	jmp    666 <gettoken+0xb7>
      s++;
     662:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     666:	8b 45 f4             	mov    -0xc(%ebp),%eax
     669:	3b 45 0c             	cmp    0xc(%ebp),%eax
     66c:	73 42                	jae    6b0 <gettoken+0x101>
     66e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     671:	0f b6 00             	movzbl (%eax),%eax
     674:	0f be c0             	movsbl %al,%eax
     677:	89 44 24 04          	mov    %eax,0x4(%esp)
     67b:	c7 04 24 cc 1a 00 00 	movl   $0x1acc,(%esp)
     682:	e8 d4 07 00 00       	call   e5b <strchr>
     687:	85 c0                	test   %eax,%eax
     689:	75 25                	jne    6b0 <gettoken+0x101>
     68b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     68e:	0f b6 00             	movzbl (%eax),%eax
     691:	0f be c0             	movsbl %al,%eax
     694:	89 44 24 04          	mov    %eax,0x4(%esp)
     698:	c7 04 24 d2 1a 00 00 	movl   $0x1ad2,(%esp)
     69f:	e8 b7 07 00 00       	call   e5b <strchr>
     6a4:	85 c0                	test   %eax,%eax
     6a6:	74 ba                	je     662 <gettoken+0xb3>
      s++;
    break;
     6a8:	eb 06                	jmp    6b0 <gettoken+0x101>
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
  case 0:
    break;
     6aa:	90                   	nop
     6ab:	eb 04                	jmp    6b1 <gettoken+0x102>
    s++;
    if(*s == '>'){
      ret = '+';
      s++;
    }
    break;
     6ad:	90                   	nop
     6ae:	eb 01                	jmp    6b1 <gettoken+0x102>
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
     6b0:	90                   	nop
  }
  if(eq)
     6b1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     6b5:	74 0e                	je     6c5 <gettoken+0x116>
    *eq = s;
     6b7:	8b 45 14             	mov    0x14(%ebp),%eax
     6ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
     6bd:	89 10                	mov    %edx,(%eax)
  
  while(s < es && strchr(whitespace, *s))
     6bf:	eb 04                	jmp    6c5 <gettoken+0x116>
    s++;
     6c1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
  }
  if(eq)
    *eq = s;
  
  while(s < es && strchr(whitespace, *s))
     6c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6c8:	3b 45 0c             	cmp    0xc(%ebp),%eax
     6cb:	73 1d                	jae    6ea <gettoken+0x13b>
     6cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6d0:	0f b6 00             	movzbl (%eax),%eax
     6d3:	0f be c0             	movsbl %al,%eax
     6d6:	89 44 24 04          	mov    %eax,0x4(%esp)
     6da:	c7 04 24 cc 1a 00 00 	movl   $0x1acc,(%esp)
     6e1:	e8 75 07 00 00       	call   e5b <strchr>
     6e6:	85 c0                	test   %eax,%eax
     6e8:	75 d7                	jne    6c1 <gettoken+0x112>
    s++;
  *ps = s;
     6ea:	8b 45 08             	mov    0x8(%ebp),%eax
     6ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
     6f0:	89 10                	mov    %edx,(%eax)
  return ret;
     6f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     6f5:	c9                   	leave  
     6f6:	c3                   	ret    

000006f7 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     6f7:	55                   	push   %ebp
     6f8:	89 e5                	mov    %esp,%ebp
     6fa:	83 ec 28             	sub    $0x28,%esp
  char *s;
  
  s = *ps;
     6fd:	8b 45 08             	mov    0x8(%ebp),%eax
     700:	8b 00                	mov    (%eax),%eax
     702:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     705:	eb 04                	jmp    70b <peek+0x14>
    s++;
     707:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
peek(char **ps, char *es, char *toks)
{
  char *s;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     70b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     70e:	3b 45 0c             	cmp    0xc(%ebp),%eax
     711:	73 1d                	jae    730 <peek+0x39>
     713:	8b 45 f4             	mov    -0xc(%ebp),%eax
     716:	0f b6 00             	movzbl (%eax),%eax
     719:	0f be c0             	movsbl %al,%eax
     71c:	89 44 24 04          	mov    %eax,0x4(%esp)
     720:	c7 04 24 cc 1a 00 00 	movl   $0x1acc,(%esp)
     727:	e8 2f 07 00 00       	call   e5b <strchr>
     72c:	85 c0                	test   %eax,%eax
     72e:	75 d7                	jne    707 <peek+0x10>
    s++;
  *ps = s;
     730:	8b 45 08             	mov    0x8(%ebp),%eax
     733:	8b 55 f4             	mov    -0xc(%ebp),%edx
     736:	89 10                	mov    %edx,(%eax)
  return *s && strchr(toks, *s);
     738:	8b 45 f4             	mov    -0xc(%ebp),%eax
     73b:	0f b6 00             	movzbl (%eax),%eax
     73e:	84 c0                	test   %al,%al
     740:	74 23                	je     765 <peek+0x6e>
     742:	8b 45 f4             	mov    -0xc(%ebp),%eax
     745:	0f b6 00             	movzbl (%eax),%eax
     748:	0f be c0             	movsbl %al,%eax
     74b:	89 44 24 04          	mov    %eax,0x4(%esp)
     74f:	8b 45 10             	mov    0x10(%ebp),%eax
     752:	89 04 24             	mov    %eax,(%esp)
     755:	e8 01 07 00 00       	call   e5b <strchr>
     75a:	85 c0                	test   %eax,%eax
     75c:	74 07                	je     765 <peek+0x6e>
     75e:	b8 01 00 00 00       	mov    $0x1,%eax
     763:	eb 05                	jmp    76a <peek+0x73>
     765:	b8 00 00 00 00       	mov    $0x0,%eax
}
     76a:	c9                   	leave  
     76b:	c3                   	ret    

0000076c <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
     76c:	55                   	push   %ebp
     76d:	89 e5                	mov    %esp,%ebp
     76f:	53                   	push   %ebx
     770:	83 ec 24             	sub    $0x24,%esp
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
     773:	8b 5d 08             	mov    0x8(%ebp),%ebx
     776:	8b 45 08             	mov    0x8(%ebp),%eax
     779:	89 04 24             	mov    %eax,(%esp)
     77c:	e8 91 06 00 00       	call   e12 <strlen>
     781:	01 d8                	add    %ebx,%eax
     783:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cmd = parseline(&s, es);
     786:	8b 45 f4             	mov    -0xc(%ebp),%eax
     789:	89 44 24 04          	mov    %eax,0x4(%esp)
     78d:	8d 45 08             	lea    0x8(%ebp),%eax
     790:	89 04 24             	mov    %eax,(%esp)
     793:	e8 60 00 00 00       	call   7f8 <parseline>
     798:	89 45 f0             	mov    %eax,-0x10(%ebp)
  peek(&s, es, "");
     79b:	c7 44 24 08 c2 15 00 	movl   $0x15c2,0x8(%esp)
     7a2:	00 
     7a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7a6:	89 44 24 04          	mov    %eax,0x4(%esp)
     7aa:	8d 45 08             	lea    0x8(%ebp),%eax
     7ad:	89 04 24             	mov    %eax,(%esp)
     7b0:	e8 42 ff ff ff       	call   6f7 <peek>
  if(s != es){
     7b5:	8b 45 08             	mov    0x8(%ebp),%eax
     7b8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     7bb:	74 27                	je     7e4 <parsecmd+0x78>
    printf(2, "leftovers: %s\n", s);
     7bd:	8b 45 08             	mov    0x8(%ebp),%eax
     7c0:	89 44 24 08          	mov    %eax,0x8(%esp)
     7c4:	c7 44 24 04 c3 15 00 	movl   $0x15c3,0x4(%esp)
     7cb:	00 
     7cc:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     7d3:	e8 83 09 00 00       	call   115b <printf>
    panic("syntax");
     7d8:	c7 04 24 d2 15 00 00 	movl   $0x15d2,(%esp)
     7df:	e8 e9 fb ff ff       	call   3cd <panic>
  }
  nulterminate(cmd);
     7e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
     7e7:	89 04 24             	mov    %eax,(%esp)
     7ea:	e8 a5 04 00 00       	call   c94 <nulterminate>
  return cmd;
     7ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     7f2:	83 c4 24             	add    $0x24,%esp
     7f5:	5b                   	pop    %ebx
     7f6:	5d                   	pop    %ebp
     7f7:	c3                   	ret    

000007f8 <parseline>:

struct cmd*
parseline(char **ps, char *es)
{
     7f8:	55                   	push   %ebp
     7f9:	89 e5                	mov    %esp,%ebp
     7fb:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
     7fe:	8b 45 0c             	mov    0xc(%ebp),%eax
     801:	89 44 24 04          	mov    %eax,0x4(%esp)
     805:	8b 45 08             	mov    0x8(%ebp),%eax
     808:	89 04 24             	mov    %eax,(%esp)
     80b:	e8 bc 00 00 00       	call   8cc <parsepipe>
     810:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(peek(ps, es, "&")){
     813:	eb 30                	jmp    845 <parseline+0x4d>
    gettoken(ps, es, 0, 0);
     815:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     81c:	00 
     81d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     824:	00 
     825:	8b 45 0c             	mov    0xc(%ebp),%eax
     828:	89 44 24 04          	mov    %eax,0x4(%esp)
     82c:	8b 45 08             	mov    0x8(%ebp),%eax
     82f:	89 04 24             	mov    %eax,(%esp)
     832:	e8 78 fd ff ff       	call   5af <gettoken>
    cmd = backcmd(cmd);
     837:	8b 45 f4             	mov    -0xc(%ebp),%eax
     83a:	89 04 24             	mov    %eax,(%esp)
     83d:	e8 26 fd ff ff       	call   568 <backcmd>
     842:	89 45 f4             	mov    %eax,-0xc(%ebp)
parseline(char **ps, char *es)
{
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
  while(peek(ps, es, "&")){
     845:	c7 44 24 08 d9 15 00 	movl   $0x15d9,0x8(%esp)
     84c:	00 
     84d:	8b 45 0c             	mov    0xc(%ebp),%eax
     850:	89 44 24 04          	mov    %eax,0x4(%esp)
     854:	8b 45 08             	mov    0x8(%ebp),%eax
     857:	89 04 24             	mov    %eax,(%esp)
     85a:	e8 98 fe ff ff       	call   6f7 <peek>
     85f:	85 c0                	test   %eax,%eax
     861:	75 b2                	jne    815 <parseline+0x1d>
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
  if(peek(ps, es, ";")){
     863:	c7 44 24 08 db 15 00 	movl   $0x15db,0x8(%esp)
     86a:	00 
     86b:	8b 45 0c             	mov    0xc(%ebp),%eax
     86e:	89 44 24 04          	mov    %eax,0x4(%esp)
     872:	8b 45 08             	mov    0x8(%ebp),%eax
     875:	89 04 24             	mov    %eax,(%esp)
     878:	e8 7a fe ff ff       	call   6f7 <peek>
     87d:	85 c0                	test   %eax,%eax
     87f:	74 46                	je     8c7 <parseline+0xcf>
    gettoken(ps, es, 0, 0);
     881:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     888:	00 
     889:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     890:	00 
     891:	8b 45 0c             	mov    0xc(%ebp),%eax
     894:	89 44 24 04          	mov    %eax,0x4(%esp)
     898:	8b 45 08             	mov    0x8(%ebp),%eax
     89b:	89 04 24             	mov    %eax,(%esp)
     89e:	e8 0c fd ff ff       	call   5af <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     8a3:	8b 45 0c             	mov    0xc(%ebp),%eax
     8a6:	89 44 24 04          	mov    %eax,0x4(%esp)
     8aa:	8b 45 08             	mov    0x8(%ebp),%eax
     8ad:	89 04 24             	mov    %eax,(%esp)
     8b0:	e8 43 ff ff ff       	call   7f8 <parseline>
     8b5:	89 44 24 04          	mov    %eax,0x4(%esp)
     8b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8bc:	89 04 24             	mov    %eax,(%esp)
     8bf:	e8 54 fc ff ff       	call   518 <listcmd>
     8c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     8c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     8ca:	c9                   	leave  
     8cb:	c3                   	ret    

000008cc <parsepipe>:

struct cmd*
parsepipe(char **ps, char *es)
{
     8cc:	55                   	push   %ebp
     8cd:	89 e5                	mov    %esp,%ebp
     8cf:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parseexec(ps, es);
     8d2:	8b 45 0c             	mov    0xc(%ebp),%eax
     8d5:	89 44 24 04          	mov    %eax,0x4(%esp)
     8d9:	8b 45 08             	mov    0x8(%ebp),%eax
     8dc:	89 04 24             	mov    %eax,(%esp)
     8df:	e8 68 02 00 00       	call   b4c <parseexec>
     8e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(peek(ps, es, "|")){
     8e7:	c7 44 24 08 dd 15 00 	movl   $0x15dd,0x8(%esp)
     8ee:	00 
     8ef:	8b 45 0c             	mov    0xc(%ebp),%eax
     8f2:	89 44 24 04          	mov    %eax,0x4(%esp)
     8f6:	8b 45 08             	mov    0x8(%ebp),%eax
     8f9:	89 04 24             	mov    %eax,(%esp)
     8fc:	e8 f6 fd ff ff       	call   6f7 <peek>
     901:	85 c0                	test   %eax,%eax
     903:	74 46                	je     94b <parsepipe+0x7f>
    gettoken(ps, es, 0, 0);
     905:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     90c:	00 
     90d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     914:	00 
     915:	8b 45 0c             	mov    0xc(%ebp),%eax
     918:	89 44 24 04          	mov    %eax,0x4(%esp)
     91c:	8b 45 08             	mov    0x8(%ebp),%eax
     91f:	89 04 24             	mov    %eax,(%esp)
     922:	e8 88 fc ff ff       	call   5af <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     927:	8b 45 0c             	mov    0xc(%ebp),%eax
     92a:	89 44 24 04          	mov    %eax,0x4(%esp)
     92e:	8b 45 08             	mov    0x8(%ebp),%eax
     931:	89 04 24             	mov    %eax,(%esp)
     934:	e8 93 ff ff ff       	call   8cc <parsepipe>
     939:	89 44 24 04          	mov    %eax,0x4(%esp)
     93d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     940:	89 04 24             	mov    %eax,(%esp)
     943:	e8 80 fb ff ff       	call   4c8 <pipecmd>
     948:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     94b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     94e:	c9                   	leave  
     94f:	c3                   	ret    

00000950 <parseredirs>:

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     950:	55                   	push   %ebp
     951:	89 e5                	mov    %esp,%ebp
     953:	83 ec 38             	sub    $0x38,%esp
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     956:	e9 f6 00 00 00       	jmp    a51 <parseredirs+0x101>
    tok = gettoken(ps, es, 0, 0);
     95b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     962:	00 
     963:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     96a:	00 
     96b:	8b 45 10             	mov    0x10(%ebp),%eax
     96e:	89 44 24 04          	mov    %eax,0x4(%esp)
     972:	8b 45 0c             	mov    0xc(%ebp),%eax
     975:	89 04 24             	mov    %eax,(%esp)
     978:	e8 32 fc ff ff       	call   5af <gettoken>
     97d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(gettoken(ps, es, &q, &eq) != 'a')
     980:	8d 45 ec             	lea    -0x14(%ebp),%eax
     983:	89 44 24 0c          	mov    %eax,0xc(%esp)
     987:	8d 45 f0             	lea    -0x10(%ebp),%eax
     98a:	89 44 24 08          	mov    %eax,0x8(%esp)
     98e:	8b 45 10             	mov    0x10(%ebp),%eax
     991:	89 44 24 04          	mov    %eax,0x4(%esp)
     995:	8b 45 0c             	mov    0xc(%ebp),%eax
     998:	89 04 24             	mov    %eax,(%esp)
     99b:	e8 0f fc ff ff       	call   5af <gettoken>
     9a0:	83 f8 61             	cmp    $0x61,%eax
     9a3:	74 0c                	je     9b1 <parseredirs+0x61>
      panic("missing file for redirection");
     9a5:	c7 04 24 df 15 00 00 	movl   $0x15df,(%esp)
     9ac:	e8 1c fa ff ff       	call   3cd <panic>
    switch(tok){
     9b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9b4:	83 f8 3c             	cmp    $0x3c,%eax
     9b7:	74 0f                	je     9c8 <parseredirs+0x78>
     9b9:	83 f8 3e             	cmp    $0x3e,%eax
     9bc:	74 38                	je     9f6 <parseredirs+0xa6>
     9be:	83 f8 2b             	cmp    $0x2b,%eax
     9c1:	74 61                	je     a24 <parseredirs+0xd4>
     9c3:	e9 89 00 00 00       	jmp    a51 <parseredirs+0x101>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     9c8:	8b 55 ec             	mov    -0x14(%ebp),%edx
     9cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
     9ce:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
     9d5:	00 
     9d6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     9dd:	00 
     9de:	89 54 24 08          	mov    %edx,0x8(%esp)
     9e2:	89 44 24 04          	mov    %eax,0x4(%esp)
     9e6:	8b 45 08             	mov    0x8(%ebp),%eax
     9e9:	89 04 24             	mov    %eax,(%esp)
     9ec:	e8 6c fa ff ff       	call   45d <redircmd>
     9f1:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     9f4:	eb 5b                	jmp    a51 <parseredirs+0x101>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     9f6:	8b 55 ec             	mov    -0x14(%ebp),%edx
     9f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
     9fc:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     a03:	00 
     a04:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     a0b:	00 
     a0c:	89 54 24 08          	mov    %edx,0x8(%esp)
     a10:	89 44 24 04          	mov    %eax,0x4(%esp)
     a14:	8b 45 08             	mov    0x8(%ebp),%eax
     a17:	89 04 24             	mov    %eax,(%esp)
     a1a:	e8 3e fa ff ff       	call   45d <redircmd>
     a1f:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     a22:	eb 2d                	jmp    a51 <parseredirs+0x101>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     a24:	8b 55 ec             	mov    -0x14(%ebp),%edx
     a27:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a2a:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     a31:	00 
     a32:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     a39:	00 
     a3a:	89 54 24 08          	mov    %edx,0x8(%esp)
     a3e:	89 44 24 04          	mov    %eax,0x4(%esp)
     a42:	8b 45 08             	mov    0x8(%ebp),%eax
     a45:	89 04 24             	mov    %eax,(%esp)
     a48:	e8 10 fa ff ff       	call   45d <redircmd>
     a4d:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     a50:	90                   	nop
parseredirs(struct cmd *cmd, char **ps, char *es)
{
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     a51:	c7 44 24 08 fc 15 00 	movl   $0x15fc,0x8(%esp)
     a58:	00 
     a59:	8b 45 10             	mov    0x10(%ebp),%eax
     a5c:	89 44 24 04          	mov    %eax,0x4(%esp)
     a60:	8b 45 0c             	mov    0xc(%ebp),%eax
     a63:	89 04 24             	mov    %eax,(%esp)
     a66:	e8 8c fc ff ff       	call   6f7 <peek>
     a6b:	85 c0                	test   %eax,%eax
     a6d:	0f 85 e8 fe ff ff    	jne    95b <parseredirs+0xb>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    }
  }
  return cmd;
     a73:	8b 45 08             	mov    0x8(%ebp),%eax
}
     a76:	c9                   	leave  
     a77:	c3                   	ret    

00000a78 <parseblock>:

struct cmd*
parseblock(char **ps, char *es)
{
     a78:	55                   	push   %ebp
     a79:	89 e5                	mov    %esp,%ebp
     a7b:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  if(!peek(ps, es, "("))
     a7e:	c7 44 24 08 ff 15 00 	movl   $0x15ff,0x8(%esp)
     a85:	00 
     a86:	8b 45 0c             	mov    0xc(%ebp),%eax
     a89:	89 44 24 04          	mov    %eax,0x4(%esp)
     a8d:	8b 45 08             	mov    0x8(%ebp),%eax
     a90:	89 04 24             	mov    %eax,(%esp)
     a93:	e8 5f fc ff ff       	call   6f7 <peek>
     a98:	85 c0                	test   %eax,%eax
     a9a:	75 0c                	jne    aa8 <parseblock+0x30>
    panic("parseblock");
     a9c:	c7 04 24 01 16 00 00 	movl   $0x1601,(%esp)
     aa3:	e8 25 f9 ff ff       	call   3cd <panic>
  gettoken(ps, es, 0, 0);
     aa8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     aaf:	00 
     ab0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     ab7:	00 
     ab8:	8b 45 0c             	mov    0xc(%ebp),%eax
     abb:	89 44 24 04          	mov    %eax,0x4(%esp)
     abf:	8b 45 08             	mov    0x8(%ebp),%eax
     ac2:	89 04 24             	mov    %eax,(%esp)
     ac5:	e8 e5 fa ff ff       	call   5af <gettoken>
  cmd = parseline(ps, es);
     aca:	8b 45 0c             	mov    0xc(%ebp),%eax
     acd:	89 44 24 04          	mov    %eax,0x4(%esp)
     ad1:	8b 45 08             	mov    0x8(%ebp),%eax
     ad4:	89 04 24             	mov    %eax,(%esp)
     ad7:	e8 1c fd ff ff       	call   7f8 <parseline>
     adc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!peek(ps, es, ")"))
     adf:	c7 44 24 08 0c 16 00 	movl   $0x160c,0x8(%esp)
     ae6:	00 
     ae7:	8b 45 0c             	mov    0xc(%ebp),%eax
     aea:	89 44 24 04          	mov    %eax,0x4(%esp)
     aee:	8b 45 08             	mov    0x8(%ebp),%eax
     af1:	89 04 24             	mov    %eax,(%esp)
     af4:	e8 fe fb ff ff       	call   6f7 <peek>
     af9:	85 c0                	test   %eax,%eax
     afb:	75 0c                	jne    b09 <parseblock+0x91>
    panic("syntax - missing )");
     afd:	c7 04 24 0e 16 00 00 	movl   $0x160e,(%esp)
     b04:	e8 c4 f8 ff ff       	call   3cd <panic>
  gettoken(ps, es, 0, 0);
     b09:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     b10:	00 
     b11:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     b18:	00 
     b19:	8b 45 0c             	mov    0xc(%ebp),%eax
     b1c:	89 44 24 04          	mov    %eax,0x4(%esp)
     b20:	8b 45 08             	mov    0x8(%ebp),%eax
     b23:	89 04 24             	mov    %eax,(%esp)
     b26:	e8 84 fa ff ff       	call   5af <gettoken>
  cmd = parseredirs(cmd, ps, es);
     b2b:	8b 45 0c             	mov    0xc(%ebp),%eax
     b2e:	89 44 24 08          	mov    %eax,0x8(%esp)
     b32:	8b 45 08             	mov    0x8(%ebp),%eax
     b35:	89 44 24 04          	mov    %eax,0x4(%esp)
     b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b3c:	89 04 24             	mov    %eax,(%esp)
     b3f:	e8 0c fe ff ff       	call   950 <parseredirs>
     b44:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return cmd;
     b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     b4a:	c9                   	leave  
     b4b:	c3                   	ret    

00000b4c <parseexec>:

struct cmd*
parseexec(char **ps, char *es)
{
     b4c:	55                   	push   %ebp
     b4d:	89 e5                	mov    %esp,%ebp
     b4f:	83 ec 38             	sub    $0x38,%esp
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;
  
  if(peek(ps, es, "("))
     b52:	c7 44 24 08 ff 15 00 	movl   $0x15ff,0x8(%esp)
     b59:	00 
     b5a:	8b 45 0c             	mov    0xc(%ebp),%eax
     b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
     b61:	8b 45 08             	mov    0x8(%ebp),%eax
     b64:	89 04 24             	mov    %eax,(%esp)
     b67:	e8 8b fb ff ff       	call   6f7 <peek>
     b6c:	85 c0                	test   %eax,%eax
     b6e:	74 17                	je     b87 <parseexec+0x3b>
    return parseblock(ps, es);
     b70:	8b 45 0c             	mov    0xc(%ebp),%eax
     b73:	89 44 24 04          	mov    %eax,0x4(%esp)
     b77:	8b 45 08             	mov    0x8(%ebp),%eax
     b7a:	89 04 24             	mov    %eax,(%esp)
     b7d:	e8 f6 fe ff ff       	call   a78 <parseblock>
     b82:	e9 0b 01 00 00       	jmp    c92 <parseexec+0x146>

  ret = execcmd();
     b87:	e8 93 f8 ff ff       	call   41f <execcmd>
     b8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cmd = (struct execcmd*)ret;
     b8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b92:	89 45 ec             	mov    %eax,-0x14(%ebp)

  argc = 0;
     b95:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ret = parseredirs(ret, ps, es);
     b9c:	8b 45 0c             	mov    0xc(%ebp),%eax
     b9f:	89 44 24 08          	mov    %eax,0x8(%esp)
     ba3:	8b 45 08             	mov    0x8(%ebp),%eax
     ba6:	89 44 24 04          	mov    %eax,0x4(%esp)
     baa:	8b 45 f0             	mov    -0x10(%ebp),%eax
     bad:	89 04 24             	mov    %eax,(%esp)
     bb0:	e8 9b fd ff ff       	call   950 <parseredirs>
     bb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while(!peek(ps, es, "|)&;")){
     bb8:	e9 8e 00 00 00       	jmp    c4b <parseexec+0xff>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     bbd:	8d 45 e0             	lea    -0x20(%ebp),%eax
     bc0:	89 44 24 0c          	mov    %eax,0xc(%esp)
     bc4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     bc7:	89 44 24 08          	mov    %eax,0x8(%esp)
     bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
     bce:	89 44 24 04          	mov    %eax,0x4(%esp)
     bd2:	8b 45 08             	mov    0x8(%ebp),%eax
     bd5:	89 04 24             	mov    %eax,(%esp)
     bd8:	e8 d2 f9 ff ff       	call   5af <gettoken>
     bdd:	89 45 e8             	mov    %eax,-0x18(%ebp)
     be0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     be4:	0f 84 85 00 00 00    	je     c6f <parseexec+0x123>
      break;
    if(tok != 'a')
     bea:	83 7d e8 61          	cmpl   $0x61,-0x18(%ebp)
     bee:	74 0c                	je     bfc <parseexec+0xb0>
      panic("syntax");
     bf0:	c7 04 24 d2 15 00 00 	movl   $0x15d2,(%esp)
     bf7:	e8 d1 f7 ff ff       	call   3cd <panic>
    cmd->argv[argc] = q;
     bfc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
     bff:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c02:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c05:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
    cmd->eargv[argc] = eq;
     c09:	8b 55 e0             	mov    -0x20(%ebp),%edx
     c0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c0f:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     c12:	83 c1 08             	add    $0x8,%ecx
     c15:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    argc++;
     c19:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(argc >= MAXARGS)
     c1d:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     c21:	7e 0c                	jle    c2f <parseexec+0xe3>
      panic("too many args");
     c23:	c7 04 24 21 16 00 00 	movl   $0x1621,(%esp)
     c2a:	e8 9e f7 ff ff       	call   3cd <panic>
    ret = parseredirs(ret, ps, es);
     c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
     c32:	89 44 24 08          	mov    %eax,0x8(%esp)
     c36:	8b 45 08             	mov    0x8(%ebp),%eax
     c39:	89 44 24 04          	mov    %eax,0x4(%esp)
     c3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c40:	89 04 24             	mov    %eax,(%esp)
     c43:	e8 08 fd ff ff       	call   950 <parseredirs>
     c48:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
     c4b:	c7 44 24 08 2f 16 00 	movl   $0x162f,0x8(%esp)
     c52:	00 
     c53:	8b 45 0c             	mov    0xc(%ebp),%eax
     c56:	89 44 24 04          	mov    %eax,0x4(%esp)
     c5a:	8b 45 08             	mov    0x8(%ebp),%eax
     c5d:	89 04 24             	mov    %eax,(%esp)
     c60:	e8 92 fa ff ff       	call   6f7 <peek>
     c65:	85 c0                	test   %eax,%eax
     c67:	0f 84 50 ff ff ff    	je     bbd <parseexec+0x71>
     c6d:	eb 01                	jmp    c70 <parseexec+0x124>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
     c6f:	90                   	nop
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
     c70:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c73:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c76:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
     c7d:	00 
  cmd->eargv[argc] = 0;
     c7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c81:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c84:	83 c2 08             	add    $0x8,%edx
     c87:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
     c8e:	00 
  return ret;
     c8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     c92:	c9                   	leave  
     c93:	c3                   	ret    

00000c94 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     c94:	55                   	push   %ebp
     c95:	89 e5                	mov    %esp,%ebp
     c97:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     c9a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     c9e:	75 0a                	jne    caa <nulterminate+0x16>
    return 0;
     ca0:	b8 00 00 00 00       	mov    $0x0,%eax
     ca5:	e9 c9 00 00 00       	jmp    d73 <nulterminate+0xdf>
  
  switch(cmd->type){
     caa:	8b 45 08             	mov    0x8(%ebp),%eax
     cad:	8b 00                	mov    (%eax),%eax
     caf:	83 f8 05             	cmp    $0x5,%eax
     cb2:	0f 87 b8 00 00 00    	ja     d70 <nulterminate+0xdc>
     cb8:	8b 04 85 34 16 00 00 	mov    0x1634(,%eax,4),%eax
     cbf:	ff e0                	jmp    *%eax
  case EXEC:
    ecmd = (struct execcmd*)cmd;
     cc1:	8b 45 08             	mov    0x8(%ebp),%eax
     cc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(i=0; ecmd->argv[i]; i++)
     cc7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     cce:	eb 14                	jmp    ce4 <nulterminate+0x50>
      *ecmd->eargv[i] = 0;
     cd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
     cd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
     cd6:	83 c2 08             	add    $0x8,%edx
     cd9:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
     cdd:	c6 00 00             	movb   $0x0,(%eax)
    return 0;
  
  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     ce0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     ce4:	8b 45 f0             	mov    -0x10(%ebp),%eax
     ce7:	8b 55 f4             	mov    -0xc(%ebp),%edx
     cea:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
     cee:	85 c0                	test   %eax,%eax
     cf0:	75 de                	jne    cd0 <nulterminate+0x3c>
      *ecmd->eargv[i] = 0;
    break;
     cf2:	eb 7c                	jmp    d70 <nulterminate+0xdc>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
     cf4:	8b 45 08             	mov    0x8(%ebp),%eax
     cf7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    nulterminate(rcmd->cmd);
     cfa:	8b 45 ec             	mov    -0x14(%ebp),%eax
     cfd:	8b 40 04             	mov    0x4(%eax),%eax
     d00:	89 04 24             	mov    %eax,(%esp)
     d03:	e8 8c ff ff ff       	call   c94 <nulterminate>
    *rcmd->efile = 0;
     d08:	8b 45 ec             	mov    -0x14(%ebp),%eax
     d0b:	8b 40 0c             	mov    0xc(%eax),%eax
     d0e:	c6 00 00             	movb   $0x0,(%eax)
    break;
     d11:	eb 5d                	jmp    d70 <nulterminate+0xdc>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     d13:	8b 45 08             	mov    0x8(%ebp),%eax
     d16:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nulterminate(pcmd->left);
     d19:	8b 45 e8             	mov    -0x18(%ebp),%eax
     d1c:	8b 40 04             	mov    0x4(%eax),%eax
     d1f:	89 04 24             	mov    %eax,(%esp)
     d22:	e8 6d ff ff ff       	call   c94 <nulterminate>
    nulterminate(pcmd->right);
     d27:	8b 45 e8             	mov    -0x18(%ebp),%eax
     d2a:	8b 40 08             	mov    0x8(%eax),%eax
     d2d:	89 04 24             	mov    %eax,(%esp)
     d30:	e8 5f ff ff ff       	call   c94 <nulterminate>
    break;
     d35:	eb 39                	jmp    d70 <nulterminate+0xdc>
    
  case LIST:
    lcmd = (struct listcmd*)cmd;
     d37:	8b 45 08             	mov    0x8(%ebp),%eax
     d3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nulterminate(lcmd->left);
     d3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     d40:	8b 40 04             	mov    0x4(%eax),%eax
     d43:	89 04 24             	mov    %eax,(%esp)
     d46:	e8 49 ff ff ff       	call   c94 <nulterminate>
    nulterminate(lcmd->right);
     d4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     d4e:	8b 40 08             	mov    0x8(%eax),%eax
     d51:	89 04 24             	mov    %eax,(%esp)
     d54:	e8 3b ff ff ff       	call   c94 <nulterminate>
    break;
     d59:	eb 15                	jmp    d70 <nulterminate+0xdc>

  case BACK:
    bcmd = (struct backcmd*)cmd;
     d5b:	8b 45 08             	mov    0x8(%ebp),%eax
     d5e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nulterminate(bcmd->cmd);
     d61:	8b 45 e0             	mov    -0x20(%ebp),%eax
     d64:	8b 40 04             	mov    0x4(%eax),%eax
     d67:	89 04 24             	mov    %eax,(%esp)
     d6a:	e8 25 ff ff ff       	call   c94 <nulterminate>
    break;
     d6f:	90                   	nop
  }
  return cmd;
     d70:	8b 45 08             	mov    0x8(%ebp),%eax
}
     d73:	c9                   	leave  
     d74:	c3                   	ret    
     d75:	90                   	nop
     d76:	90                   	nop
     d77:	90                   	nop

00000d78 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     d78:	55                   	push   %ebp
     d79:	89 e5                	mov    %esp,%ebp
     d7b:	57                   	push   %edi
     d7c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     d7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
     d80:	8b 55 10             	mov    0x10(%ebp),%edx
     d83:	8b 45 0c             	mov    0xc(%ebp),%eax
     d86:	89 cb                	mov    %ecx,%ebx
     d88:	89 df                	mov    %ebx,%edi
     d8a:	89 d1                	mov    %edx,%ecx
     d8c:	fc                   	cld    
     d8d:	f3 aa                	rep stos %al,%es:(%edi)
     d8f:	89 ca                	mov    %ecx,%edx
     d91:	89 fb                	mov    %edi,%ebx
     d93:	89 5d 08             	mov    %ebx,0x8(%ebp)
     d96:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     d99:	5b                   	pop    %ebx
     d9a:	5f                   	pop    %edi
     d9b:	5d                   	pop    %ebp
     d9c:	c3                   	ret    

00000d9d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     d9d:	55                   	push   %ebp
     d9e:	89 e5                	mov    %esp,%ebp
     da0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     da3:	8b 45 08             	mov    0x8(%ebp),%eax
     da6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     da9:	90                   	nop
     daa:	8b 45 0c             	mov    0xc(%ebp),%eax
     dad:	0f b6 10             	movzbl (%eax),%edx
     db0:	8b 45 08             	mov    0x8(%ebp),%eax
     db3:	88 10                	mov    %dl,(%eax)
     db5:	8b 45 08             	mov    0x8(%ebp),%eax
     db8:	0f b6 00             	movzbl (%eax),%eax
     dbb:	84 c0                	test   %al,%al
     dbd:	0f 95 c0             	setne  %al
     dc0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     dc4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
     dc8:	84 c0                	test   %al,%al
     dca:	75 de                	jne    daa <strcpy+0xd>
    ;
  return os;
     dcc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     dcf:	c9                   	leave  
     dd0:	c3                   	ret    

00000dd1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     dd1:	55                   	push   %ebp
     dd2:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     dd4:	eb 08                	jmp    dde <strcmp+0xd>
    p++, q++;
     dd6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     dda:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     dde:	8b 45 08             	mov    0x8(%ebp),%eax
     de1:	0f b6 00             	movzbl (%eax),%eax
     de4:	84 c0                	test   %al,%al
     de6:	74 10                	je     df8 <strcmp+0x27>
     de8:	8b 45 08             	mov    0x8(%ebp),%eax
     deb:	0f b6 10             	movzbl (%eax),%edx
     dee:	8b 45 0c             	mov    0xc(%ebp),%eax
     df1:	0f b6 00             	movzbl (%eax),%eax
     df4:	38 c2                	cmp    %al,%dl
     df6:	74 de                	je     dd6 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     df8:	8b 45 08             	mov    0x8(%ebp),%eax
     dfb:	0f b6 00             	movzbl (%eax),%eax
     dfe:	0f b6 d0             	movzbl %al,%edx
     e01:	8b 45 0c             	mov    0xc(%ebp),%eax
     e04:	0f b6 00             	movzbl (%eax),%eax
     e07:	0f b6 c0             	movzbl %al,%eax
     e0a:	89 d1                	mov    %edx,%ecx
     e0c:	29 c1                	sub    %eax,%ecx
     e0e:	89 c8                	mov    %ecx,%eax
}
     e10:	5d                   	pop    %ebp
     e11:	c3                   	ret    

00000e12 <strlen>:

uint
strlen(char *s)
{
     e12:	55                   	push   %ebp
     e13:	89 e5                	mov    %esp,%ebp
     e15:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     e18:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     e1f:	eb 04                	jmp    e25 <strlen+0x13>
     e21:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     e25:	8b 45 fc             	mov    -0x4(%ebp),%eax
     e28:	03 45 08             	add    0x8(%ebp),%eax
     e2b:	0f b6 00             	movzbl (%eax),%eax
     e2e:	84 c0                	test   %al,%al
     e30:	75 ef                	jne    e21 <strlen+0xf>
    ;
  return n;
     e32:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     e35:	c9                   	leave  
     e36:	c3                   	ret    

00000e37 <memset>:

void*
memset(void *dst, int c, uint n)
{
     e37:	55                   	push   %ebp
     e38:	89 e5                	mov    %esp,%ebp
     e3a:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
     e3d:	8b 45 10             	mov    0x10(%ebp),%eax
     e40:	89 44 24 08          	mov    %eax,0x8(%esp)
     e44:	8b 45 0c             	mov    0xc(%ebp),%eax
     e47:	89 44 24 04          	mov    %eax,0x4(%esp)
     e4b:	8b 45 08             	mov    0x8(%ebp),%eax
     e4e:	89 04 24             	mov    %eax,(%esp)
     e51:	e8 22 ff ff ff       	call   d78 <stosb>
  return dst;
     e56:	8b 45 08             	mov    0x8(%ebp),%eax
}
     e59:	c9                   	leave  
     e5a:	c3                   	ret    

00000e5b <strchr>:

char*
strchr(const char *s, char c)
{
     e5b:	55                   	push   %ebp
     e5c:	89 e5                	mov    %esp,%ebp
     e5e:	83 ec 04             	sub    $0x4,%esp
     e61:	8b 45 0c             	mov    0xc(%ebp),%eax
     e64:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     e67:	eb 14                	jmp    e7d <strchr+0x22>
    if(*s == c)
     e69:	8b 45 08             	mov    0x8(%ebp),%eax
     e6c:	0f b6 00             	movzbl (%eax),%eax
     e6f:	3a 45 fc             	cmp    -0x4(%ebp),%al
     e72:	75 05                	jne    e79 <strchr+0x1e>
      return (char*)s;
     e74:	8b 45 08             	mov    0x8(%ebp),%eax
     e77:	eb 13                	jmp    e8c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     e79:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     e7d:	8b 45 08             	mov    0x8(%ebp),%eax
     e80:	0f b6 00             	movzbl (%eax),%eax
     e83:	84 c0                	test   %al,%al
     e85:	75 e2                	jne    e69 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     e87:	b8 00 00 00 00       	mov    $0x0,%eax
}
     e8c:	c9                   	leave  
     e8d:	c3                   	ret    

00000e8e <gets>:

char*
gets(char *buf, int max)
{
     e8e:	55                   	push   %ebp
     e8f:	89 e5                	mov    %esp,%ebp
     e91:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     e94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     e9b:	eb 44                	jmp    ee1 <gets+0x53>
    cc = read(0, &c, 1);
     e9d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     ea4:	00 
     ea5:	8d 45 ef             	lea    -0x11(%ebp),%eax
     ea8:	89 44 24 04          	mov    %eax,0x4(%esp)
     eac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     eb3:	e8 3c 01 00 00       	call   ff4 <read>
     eb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     ebb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     ebf:	7e 2d                	jle    eee <gets+0x60>
      break;
    buf[i++] = c;
     ec1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ec4:	03 45 08             	add    0x8(%ebp),%eax
     ec7:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
     ecb:	88 10                	mov    %dl,(%eax)
     ecd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
     ed1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     ed5:	3c 0a                	cmp    $0xa,%al
     ed7:	74 16                	je     eef <gets+0x61>
     ed9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     edd:	3c 0d                	cmp    $0xd,%al
     edf:	74 0e                	je     eef <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ee4:	83 c0 01             	add    $0x1,%eax
     ee7:	3b 45 0c             	cmp    0xc(%ebp),%eax
     eea:	7c b1                	jl     e9d <gets+0xf>
     eec:	eb 01                	jmp    eef <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
     eee:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ef2:	03 45 08             	add    0x8(%ebp),%eax
     ef5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
     ef8:	8b 45 08             	mov    0x8(%ebp),%eax
}
     efb:	c9                   	leave  
     efc:	c3                   	ret    

00000efd <stat>:

int
stat(char *n, struct stat *st)
{
     efd:	55                   	push   %ebp
     efe:	89 e5                	mov    %esp,%ebp
     f00:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     f03:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     f0a:	00 
     f0b:	8b 45 08             	mov    0x8(%ebp),%eax
     f0e:	89 04 24             	mov    %eax,(%esp)
     f11:	e8 06 01 00 00       	call   101c <open>
     f16:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
     f19:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     f1d:	79 07                	jns    f26 <stat+0x29>
    return -1;
     f1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     f24:	eb 23                	jmp    f49 <stat+0x4c>
  r = fstat(fd, st);
     f26:	8b 45 0c             	mov    0xc(%ebp),%eax
     f29:	89 44 24 04          	mov    %eax,0x4(%esp)
     f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f30:	89 04 24             	mov    %eax,(%esp)
     f33:	e8 fc 00 00 00       	call   1034 <fstat>
     f38:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f3e:	89 04 24             	mov    %eax,(%esp)
     f41:	e8 be 00 00 00       	call   1004 <close>
  return r;
     f46:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     f49:	c9                   	leave  
     f4a:	c3                   	ret    

00000f4b <atoi>:

int
atoi(const char *s)
{
     f4b:	55                   	push   %ebp
     f4c:	89 e5                	mov    %esp,%ebp
     f4e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
     f51:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
     f58:	eb 23                	jmp    f7d <atoi+0x32>
    n = n*10 + *s++ - '0';
     f5a:	8b 55 fc             	mov    -0x4(%ebp),%edx
     f5d:	89 d0                	mov    %edx,%eax
     f5f:	c1 e0 02             	shl    $0x2,%eax
     f62:	01 d0                	add    %edx,%eax
     f64:	01 c0                	add    %eax,%eax
     f66:	89 c2                	mov    %eax,%edx
     f68:	8b 45 08             	mov    0x8(%ebp),%eax
     f6b:	0f b6 00             	movzbl (%eax),%eax
     f6e:	0f be c0             	movsbl %al,%eax
     f71:	01 d0                	add    %edx,%eax
     f73:	83 e8 30             	sub    $0x30,%eax
     f76:	89 45 fc             	mov    %eax,-0x4(%ebp)
     f79:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     f7d:	8b 45 08             	mov    0x8(%ebp),%eax
     f80:	0f b6 00             	movzbl (%eax),%eax
     f83:	3c 2f                	cmp    $0x2f,%al
     f85:	7e 0a                	jle    f91 <atoi+0x46>
     f87:	8b 45 08             	mov    0x8(%ebp),%eax
     f8a:	0f b6 00             	movzbl (%eax),%eax
     f8d:	3c 39                	cmp    $0x39,%al
     f8f:	7e c9                	jle    f5a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
     f91:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     f94:	c9                   	leave  
     f95:	c3                   	ret    

00000f96 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
     f96:	55                   	push   %ebp
     f97:	89 e5                	mov    %esp,%ebp
     f99:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
     f9c:	8b 45 08             	mov    0x8(%ebp),%eax
     f9f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
     fa2:	8b 45 0c             	mov    0xc(%ebp),%eax
     fa5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
     fa8:	eb 13                	jmp    fbd <memmove+0x27>
    *dst++ = *src++;
     faa:	8b 45 f8             	mov    -0x8(%ebp),%eax
     fad:	0f b6 10             	movzbl (%eax),%edx
     fb0:	8b 45 fc             	mov    -0x4(%ebp),%eax
     fb3:	88 10                	mov    %dl,(%eax)
     fb5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     fb9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
     fbd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     fc1:	0f 9f c0             	setg   %al
     fc4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
     fc8:	84 c0                	test   %al,%al
     fca:	75 de                	jne    faa <memmove+0x14>
    *dst++ = *src++;
  return vdst;
     fcc:	8b 45 08             	mov    0x8(%ebp),%eax
}
     fcf:	c9                   	leave  
     fd0:	c3                   	ret    
     fd1:	90                   	nop
     fd2:	90                   	nop
     fd3:	90                   	nop

00000fd4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     fd4:	b8 01 00 00 00       	mov    $0x1,%eax
     fd9:	cd 40                	int    $0x40
     fdb:	c3                   	ret    

00000fdc <exit>:
SYSCALL(exit)
     fdc:	b8 02 00 00 00       	mov    $0x2,%eax
     fe1:	cd 40                	int    $0x40
     fe3:	c3                   	ret    

00000fe4 <wait>:
SYSCALL(wait)
     fe4:	b8 03 00 00 00       	mov    $0x3,%eax
     fe9:	cd 40                	int    $0x40
     feb:	c3                   	ret    

00000fec <pipe>:
SYSCALL(pipe)
     fec:	b8 04 00 00 00       	mov    $0x4,%eax
     ff1:	cd 40                	int    $0x40
     ff3:	c3                   	ret    

00000ff4 <read>:
SYSCALL(read)
     ff4:	b8 05 00 00 00       	mov    $0x5,%eax
     ff9:	cd 40                	int    $0x40
     ffb:	c3                   	ret    

00000ffc <write>:
SYSCALL(write)
     ffc:	b8 10 00 00 00       	mov    $0x10,%eax
    1001:	cd 40                	int    $0x40
    1003:	c3                   	ret    

00001004 <close>:
SYSCALL(close)
    1004:	b8 15 00 00 00       	mov    $0x15,%eax
    1009:	cd 40                	int    $0x40
    100b:	c3                   	ret    

0000100c <kill>:
SYSCALL(kill)
    100c:	b8 06 00 00 00       	mov    $0x6,%eax
    1011:	cd 40                	int    $0x40
    1013:	c3                   	ret    

00001014 <exec>:
SYSCALL(exec)
    1014:	b8 07 00 00 00       	mov    $0x7,%eax
    1019:	cd 40                	int    $0x40
    101b:	c3                   	ret    

0000101c <open>:
SYSCALL(open)
    101c:	b8 0f 00 00 00       	mov    $0xf,%eax
    1021:	cd 40                	int    $0x40
    1023:	c3                   	ret    

00001024 <mknod>:
SYSCALL(mknod)
    1024:	b8 11 00 00 00       	mov    $0x11,%eax
    1029:	cd 40                	int    $0x40
    102b:	c3                   	ret    

0000102c <unlink>:
SYSCALL(unlink)
    102c:	b8 12 00 00 00       	mov    $0x12,%eax
    1031:	cd 40                	int    $0x40
    1033:	c3                   	ret    

00001034 <fstat>:
SYSCALL(fstat)
    1034:	b8 08 00 00 00       	mov    $0x8,%eax
    1039:	cd 40                	int    $0x40
    103b:	c3                   	ret    

0000103c <link>:
SYSCALL(link)
    103c:	b8 13 00 00 00       	mov    $0x13,%eax
    1041:	cd 40                	int    $0x40
    1043:	c3                   	ret    

00001044 <mkdir>:
SYSCALL(mkdir)
    1044:	b8 14 00 00 00       	mov    $0x14,%eax
    1049:	cd 40                	int    $0x40
    104b:	c3                   	ret    

0000104c <chdir>:
SYSCALL(chdir)
    104c:	b8 09 00 00 00       	mov    $0x9,%eax
    1051:	cd 40                	int    $0x40
    1053:	c3                   	ret    

00001054 <dup>:
SYSCALL(dup)
    1054:	b8 0a 00 00 00       	mov    $0xa,%eax
    1059:	cd 40                	int    $0x40
    105b:	c3                   	ret    

0000105c <getpid>:
SYSCALL(getpid)
    105c:	b8 0b 00 00 00       	mov    $0xb,%eax
    1061:	cd 40                	int    $0x40
    1063:	c3                   	ret    

00001064 <sbrk>:
SYSCALL(sbrk)
    1064:	b8 0c 00 00 00       	mov    $0xc,%eax
    1069:	cd 40                	int    $0x40
    106b:	c3                   	ret    

0000106c <sleep>:
SYSCALL(sleep)
    106c:	b8 0d 00 00 00       	mov    $0xd,%eax
    1071:	cd 40                	int    $0x40
    1073:	c3                   	ret    

00001074 <uptime>:
SYSCALL(uptime)
    1074:	b8 0e 00 00 00       	mov    $0xe,%eax
    1079:	cd 40                	int    $0x40
    107b:	c3                   	ret    

0000107c <waitpid>:
    107c:	b8 16 00 00 00       	mov    $0x16,%eax
    1081:	cd 40                	int    $0x40
    1083:	c3                   	ret    

00001084 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    1084:	55                   	push   %ebp
    1085:	89 e5                	mov    %esp,%ebp
    1087:	83 ec 28             	sub    $0x28,%esp
    108a:	8b 45 0c             	mov    0xc(%ebp),%eax
    108d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    1090:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1097:	00 
    1098:	8d 45 f4             	lea    -0xc(%ebp),%eax
    109b:	89 44 24 04          	mov    %eax,0x4(%esp)
    109f:	8b 45 08             	mov    0x8(%ebp),%eax
    10a2:	89 04 24             	mov    %eax,(%esp)
    10a5:	e8 52 ff ff ff       	call   ffc <write>
}
    10aa:	c9                   	leave  
    10ab:	c3                   	ret    

000010ac <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    10ac:	55                   	push   %ebp
    10ad:	89 e5                	mov    %esp,%ebp
    10af:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    10b2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    10b9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    10bd:	74 17                	je     10d6 <printint+0x2a>
    10bf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    10c3:	79 11                	jns    10d6 <printint+0x2a>
    neg = 1;
    10c5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    10cc:	8b 45 0c             	mov    0xc(%ebp),%eax
    10cf:	f7 d8                	neg    %eax
    10d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    10d4:	eb 06                	jmp    10dc <printint+0x30>
  } else {
    x = xx;
    10d6:	8b 45 0c             	mov    0xc(%ebp),%eax
    10d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    10dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    10e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
    10e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
    10e9:	ba 00 00 00 00       	mov    $0x0,%edx
    10ee:	f7 f1                	div    %ecx
    10f0:	89 d0                	mov    %edx,%eax
    10f2:	0f b6 90 dc 1a 00 00 	movzbl 0x1adc(%eax),%edx
    10f9:	8d 45 dc             	lea    -0x24(%ebp),%eax
    10fc:	03 45 f4             	add    -0xc(%ebp),%eax
    10ff:	88 10                	mov    %dl,(%eax)
    1101:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
    1105:	8b 55 10             	mov    0x10(%ebp),%edx
    1108:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    110b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    110e:	ba 00 00 00 00       	mov    $0x0,%edx
    1113:	f7 75 d4             	divl   -0x2c(%ebp)
    1116:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1119:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    111d:	75 c4                	jne    10e3 <printint+0x37>
  if(neg)
    111f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1123:	74 2a                	je     114f <printint+0xa3>
    buf[i++] = '-';
    1125:	8d 45 dc             	lea    -0x24(%ebp),%eax
    1128:	03 45 f4             	add    -0xc(%ebp),%eax
    112b:	c6 00 2d             	movb   $0x2d,(%eax)
    112e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
    1132:	eb 1b                	jmp    114f <printint+0xa3>
    putc(fd, buf[i]);
    1134:	8d 45 dc             	lea    -0x24(%ebp),%eax
    1137:	03 45 f4             	add    -0xc(%ebp),%eax
    113a:	0f b6 00             	movzbl (%eax),%eax
    113d:	0f be c0             	movsbl %al,%eax
    1140:	89 44 24 04          	mov    %eax,0x4(%esp)
    1144:	8b 45 08             	mov    0x8(%ebp),%eax
    1147:	89 04 24             	mov    %eax,(%esp)
    114a:	e8 35 ff ff ff       	call   1084 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    114f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    1153:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1157:	79 db                	jns    1134 <printint+0x88>
    putc(fd, buf[i]);
}
    1159:	c9                   	leave  
    115a:	c3                   	ret    

0000115b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    115b:	55                   	push   %ebp
    115c:	89 e5                	mov    %esp,%ebp
    115e:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1161:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    1168:	8d 45 0c             	lea    0xc(%ebp),%eax
    116b:	83 c0 04             	add    $0x4,%eax
    116e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    1171:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1178:	e9 7d 01 00 00       	jmp    12fa <printf+0x19f>
    c = fmt[i] & 0xff;
    117d:	8b 55 0c             	mov    0xc(%ebp),%edx
    1180:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1183:	01 d0                	add    %edx,%eax
    1185:	0f b6 00             	movzbl (%eax),%eax
    1188:	0f be c0             	movsbl %al,%eax
    118b:	25 ff 00 00 00       	and    $0xff,%eax
    1190:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    1193:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1197:	75 2c                	jne    11c5 <printf+0x6a>
      if(c == '%'){
    1199:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    119d:	75 0c                	jne    11ab <printf+0x50>
        state = '%';
    119f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    11a6:	e9 4b 01 00 00       	jmp    12f6 <printf+0x19b>
      } else {
        putc(fd, c);
    11ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    11ae:	0f be c0             	movsbl %al,%eax
    11b1:	89 44 24 04          	mov    %eax,0x4(%esp)
    11b5:	8b 45 08             	mov    0x8(%ebp),%eax
    11b8:	89 04 24             	mov    %eax,(%esp)
    11bb:	e8 c4 fe ff ff       	call   1084 <putc>
    11c0:	e9 31 01 00 00       	jmp    12f6 <printf+0x19b>
      }
    } else if(state == '%'){
    11c5:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    11c9:	0f 85 27 01 00 00    	jne    12f6 <printf+0x19b>
      if(c == 'd'){
    11cf:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    11d3:	75 2d                	jne    1202 <printf+0xa7>
        printint(fd, *ap, 10, 1);
    11d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
    11d8:	8b 00                	mov    (%eax),%eax
    11da:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    11e1:	00 
    11e2:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    11e9:	00 
    11ea:	89 44 24 04          	mov    %eax,0x4(%esp)
    11ee:	8b 45 08             	mov    0x8(%ebp),%eax
    11f1:	89 04 24             	mov    %eax,(%esp)
    11f4:	e8 b3 fe ff ff       	call   10ac <printint>
        ap++;
    11f9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    11fd:	e9 ed 00 00 00       	jmp    12ef <printf+0x194>
      } else if(c == 'x' || c == 'p'){
    1202:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    1206:	74 06                	je     120e <printf+0xb3>
    1208:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    120c:	75 2d                	jne    123b <printf+0xe0>
        printint(fd, *ap, 16, 0);
    120e:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1211:	8b 00                	mov    (%eax),%eax
    1213:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    121a:	00 
    121b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    1222:	00 
    1223:	89 44 24 04          	mov    %eax,0x4(%esp)
    1227:	8b 45 08             	mov    0x8(%ebp),%eax
    122a:	89 04 24             	mov    %eax,(%esp)
    122d:	e8 7a fe ff ff       	call   10ac <printint>
        ap++;
    1232:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1236:	e9 b4 00 00 00       	jmp    12ef <printf+0x194>
      } else if(c == 's'){
    123b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    123f:	75 46                	jne    1287 <printf+0x12c>
        s = (char*)*ap;
    1241:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1244:	8b 00                	mov    (%eax),%eax
    1246:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1249:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    124d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1251:	75 27                	jne    127a <printf+0x11f>
          s = "(null)";
    1253:	c7 45 f4 4c 16 00 00 	movl   $0x164c,-0xc(%ebp)
        while(*s != 0){
    125a:	eb 1e                	jmp    127a <printf+0x11f>
          putc(fd, *s);
    125c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    125f:	0f b6 00             	movzbl (%eax),%eax
    1262:	0f be c0             	movsbl %al,%eax
    1265:	89 44 24 04          	mov    %eax,0x4(%esp)
    1269:	8b 45 08             	mov    0x8(%ebp),%eax
    126c:	89 04 24             	mov    %eax,(%esp)
    126f:	e8 10 fe ff ff       	call   1084 <putc>
          s++;
    1274:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1278:	eb 01                	jmp    127b <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    127a:	90                   	nop
    127b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    127e:	0f b6 00             	movzbl (%eax),%eax
    1281:	84 c0                	test   %al,%al
    1283:	75 d7                	jne    125c <printf+0x101>
    1285:	eb 68                	jmp    12ef <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1287:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    128b:	75 1d                	jne    12aa <printf+0x14f>
        putc(fd, *ap);
    128d:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1290:	8b 00                	mov    (%eax),%eax
    1292:	0f be c0             	movsbl %al,%eax
    1295:	89 44 24 04          	mov    %eax,0x4(%esp)
    1299:	8b 45 08             	mov    0x8(%ebp),%eax
    129c:	89 04 24             	mov    %eax,(%esp)
    129f:	e8 e0 fd ff ff       	call   1084 <putc>
        ap++;
    12a4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    12a8:	eb 45                	jmp    12ef <printf+0x194>
      } else if(c == '%'){
    12aa:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    12ae:	75 17                	jne    12c7 <printf+0x16c>
        putc(fd, c);
    12b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    12b3:	0f be c0             	movsbl %al,%eax
    12b6:	89 44 24 04          	mov    %eax,0x4(%esp)
    12ba:	8b 45 08             	mov    0x8(%ebp),%eax
    12bd:	89 04 24             	mov    %eax,(%esp)
    12c0:	e8 bf fd ff ff       	call   1084 <putc>
    12c5:	eb 28                	jmp    12ef <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    12c7:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    12ce:	00 
    12cf:	8b 45 08             	mov    0x8(%ebp),%eax
    12d2:	89 04 24             	mov    %eax,(%esp)
    12d5:	e8 aa fd ff ff       	call   1084 <putc>
        putc(fd, c);
    12da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    12dd:	0f be c0             	movsbl %al,%eax
    12e0:	89 44 24 04          	mov    %eax,0x4(%esp)
    12e4:	8b 45 08             	mov    0x8(%ebp),%eax
    12e7:	89 04 24             	mov    %eax,(%esp)
    12ea:	e8 95 fd ff ff       	call   1084 <putc>
      }
      state = 0;
    12ef:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    12f6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    12fa:	8b 55 0c             	mov    0xc(%ebp),%edx
    12fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1300:	01 d0                	add    %edx,%eax
    1302:	0f b6 00             	movzbl (%eax),%eax
    1305:	84 c0                	test   %al,%al
    1307:	0f 85 70 fe ff ff    	jne    117d <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    130d:	c9                   	leave  
    130e:	c3                   	ret    
    130f:	90                   	nop

00001310 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1310:	55                   	push   %ebp
    1311:	89 e5                	mov    %esp,%ebp
    1313:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1316:	8b 45 08             	mov    0x8(%ebp),%eax
    1319:	83 e8 08             	sub    $0x8,%eax
    131c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    131f:	a1 6c 1b 00 00       	mov    0x1b6c,%eax
    1324:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1327:	eb 24                	jmp    134d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1329:	8b 45 fc             	mov    -0x4(%ebp),%eax
    132c:	8b 00                	mov    (%eax),%eax
    132e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1331:	77 12                	ja     1345 <free+0x35>
    1333:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1336:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1339:	77 24                	ja     135f <free+0x4f>
    133b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    133e:	8b 00                	mov    (%eax),%eax
    1340:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1343:	77 1a                	ja     135f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1345:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1348:	8b 00                	mov    (%eax),%eax
    134a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    134d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1350:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1353:	76 d4                	jbe    1329 <free+0x19>
    1355:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1358:	8b 00                	mov    (%eax),%eax
    135a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    135d:	76 ca                	jbe    1329 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    135f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1362:	8b 40 04             	mov    0x4(%eax),%eax
    1365:	c1 e0 03             	shl    $0x3,%eax
    1368:	89 c2                	mov    %eax,%edx
    136a:	03 55 f8             	add    -0x8(%ebp),%edx
    136d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1370:	8b 00                	mov    (%eax),%eax
    1372:	39 c2                	cmp    %eax,%edx
    1374:	75 24                	jne    139a <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
    1376:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1379:	8b 50 04             	mov    0x4(%eax),%edx
    137c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    137f:	8b 00                	mov    (%eax),%eax
    1381:	8b 40 04             	mov    0x4(%eax),%eax
    1384:	01 c2                	add    %eax,%edx
    1386:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1389:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    138c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    138f:	8b 00                	mov    (%eax),%eax
    1391:	8b 10                	mov    (%eax),%edx
    1393:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1396:	89 10                	mov    %edx,(%eax)
    1398:	eb 0a                	jmp    13a4 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
    139a:	8b 45 fc             	mov    -0x4(%ebp),%eax
    139d:	8b 10                	mov    (%eax),%edx
    139f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    13a2:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    13a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13a7:	8b 40 04             	mov    0x4(%eax),%eax
    13aa:	c1 e0 03             	shl    $0x3,%eax
    13ad:	03 45 fc             	add    -0x4(%ebp),%eax
    13b0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    13b3:	75 20                	jne    13d5 <free+0xc5>
    p->s.size += bp->s.size;
    13b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13b8:	8b 50 04             	mov    0x4(%eax),%edx
    13bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
    13be:	8b 40 04             	mov    0x4(%eax),%eax
    13c1:	01 c2                	add    %eax,%edx
    13c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13c6:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    13c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
    13cc:	8b 10                	mov    (%eax),%edx
    13ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13d1:	89 10                	mov    %edx,(%eax)
    13d3:	eb 08                	jmp    13dd <free+0xcd>
  } else
    p->s.ptr = bp;
    13d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13d8:	8b 55 f8             	mov    -0x8(%ebp),%edx
    13db:	89 10                	mov    %edx,(%eax)
  freep = p;
    13dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13e0:	a3 6c 1b 00 00       	mov    %eax,0x1b6c
}
    13e5:	c9                   	leave  
    13e6:	c3                   	ret    

000013e7 <morecore>:

static Header*
morecore(uint nu)
{
    13e7:	55                   	push   %ebp
    13e8:	89 e5                	mov    %esp,%ebp
    13ea:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    13ed:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    13f4:	77 07                	ja     13fd <morecore+0x16>
    nu = 4096;
    13f6:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    13fd:	8b 45 08             	mov    0x8(%ebp),%eax
    1400:	c1 e0 03             	shl    $0x3,%eax
    1403:	89 04 24             	mov    %eax,(%esp)
    1406:	e8 59 fc ff ff       	call   1064 <sbrk>
    140b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    140e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    1412:	75 07                	jne    141b <morecore+0x34>
    return 0;
    1414:	b8 00 00 00 00       	mov    $0x0,%eax
    1419:	eb 22                	jmp    143d <morecore+0x56>
  hp = (Header*)p;
    141b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    141e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1421:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1424:	8b 55 08             	mov    0x8(%ebp),%edx
    1427:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    142a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    142d:	83 c0 08             	add    $0x8,%eax
    1430:	89 04 24             	mov    %eax,(%esp)
    1433:	e8 d8 fe ff ff       	call   1310 <free>
  return freep;
    1438:	a1 6c 1b 00 00       	mov    0x1b6c,%eax
}
    143d:	c9                   	leave  
    143e:	c3                   	ret    

0000143f <malloc>:

void*
malloc(uint nbytes)
{
    143f:	55                   	push   %ebp
    1440:	89 e5                	mov    %esp,%ebp
    1442:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1445:	8b 45 08             	mov    0x8(%ebp),%eax
    1448:	83 c0 07             	add    $0x7,%eax
    144b:	c1 e8 03             	shr    $0x3,%eax
    144e:	83 c0 01             	add    $0x1,%eax
    1451:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    1454:	a1 6c 1b 00 00       	mov    0x1b6c,%eax
    1459:	89 45 f0             	mov    %eax,-0x10(%ebp)
    145c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1460:	75 23                	jne    1485 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    1462:	c7 45 f0 64 1b 00 00 	movl   $0x1b64,-0x10(%ebp)
    1469:	8b 45 f0             	mov    -0x10(%ebp),%eax
    146c:	a3 6c 1b 00 00       	mov    %eax,0x1b6c
    1471:	a1 6c 1b 00 00       	mov    0x1b6c,%eax
    1476:	a3 64 1b 00 00       	mov    %eax,0x1b64
    base.s.size = 0;
    147b:	c7 05 68 1b 00 00 00 	movl   $0x0,0x1b68
    1482:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1485:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1488:	8b 00                	mov    (%eax),%eax
    148a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    148d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1490:	8b 40 04             	mov    0x4(%eax),%eax
    1493:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1496:	72 4d                	jb     14e5 <malloc+0xa6>
      if(p->s.size == nunits)
    1498:	8b 45 f4             	mov    -0xc(%ebp),%eax
    149b:	8b 40 04             	mov    0x4(%eax),%eax
    149e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    14a1:	75 0c                	jne    14af <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    14a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14a6:	8b 10                	mov    (%eax),%edx
    14a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
    14ab:	89 10                	mov    %edx,(%eax)
    14ad:	eb 26                	jmp    14d5 <malloc+0x96>
      else {
        p->s.size -= nunits;
    14af:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14b2:	8b 40 04             	mov    0x4(%eax),%eax
    14b5:	89 c2                	mov    %eax,%edx
    14b7:	2b 55 ec             	sub    -0x14(%ebp),%edx
    14ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14bd:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    14c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14c3:	8b 40 04             	mov    0x4(%eax),%eax
    14c6:	c1 e0 03             	shl    $0x3,%eax
    14c9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    14cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14cf:	8b 55 ec             	mov    -0x14(%ebp),%edx
    14d2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    14d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
    14d8:	a3 6c 1b 00 00       	mov    %eax,0x1b6c
      return (void*)(p + 1);
    14dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14e0:	83 c0 08             	add    $0x8,%eax
    14e3:	eb 38                	jmp    151d <malloc+0xde>
    }
    if(p == freep)
    14e5:	a1 6c 1b 00 00       	mov    0x1b6c,%eax
    14ea:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    14ed:	75 1b                	jne    150a <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    14ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
    14f2:	89 04 24             	mov    %eax,(%esp)
    14f5:	e8 ed fe ff ff       	call   13e7 <morecore>
    14fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    14fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1501:	75 07                	jne    150a <malloc+0xcb>
        return 0;
    1503:	b8 00 00 00 00       	mov    $0x0,%eax
    1508:	eb 13                	jmp    151d <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    150a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    150d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1510:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1513:	8b 00                	mov    (%eax),%eax
    1515:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1518:	e9 70 ff ff ff       	jmp    148d <malloc+0x4e>
}
    151d:	c9                   	leave  
    151e:	c3                   	ret    
