
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
      13:	e8 f4 0f 00 00       	call   100c <exit>
  
  switch(cmd->type){
      18:	8b 45 08             	mov    0x8(%ebp),%eax
      1b:	8b 00                	mov    (%eax),%eax
      1d:	83 f8 05             	cmp    $0x5,%eax
      20:	77 09                	ja     2b <runcmd+0x2b>
      22:	8b 04 85 a8 15 00 00 	mov    0x15a8(,%eax,4),%eax
      29:	ff e0                	jmp    *%eax
  default:
    panic("runcmd");
      2b:	c7 04 24 58 15 00 00 	movl   $0x1558,(%esp)
      32:	e8 9d 03 00 00       	call   3d4 <panic>

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
      4e:	e8 b9 0f 00 00       	call   100c <exit>
    exec(ecmd->argv[0], ecmd->argv);
      53:	8b 45 f4             	mov    -0xc(%ebp),%eax
      56:	8d 50 04             	lea    0x4(%eax),%edx
      59:	8b 45 f4             	mov    -0xc(%ebp),%eax
      5c:	8b 40 04             	mov    0x4(%eax),%eax
      5f:	89 54 24 04          	mov    %edx,0x4(%esp)
      63:	89 04 24             	mov    %eax,(%esp)
      66:	e8 d9 0f 00 00       	call   1044 <exec>
    printf(2, "exec %s failed\n", ecmd->argv[0]);
      6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
      6e:	8b 40 04             	mov    0x4(%eax),%eax
      71:	89 44 24 08          	mov    %eax,0x8(%esp)
      75:	c7 44 24 04 5f 15 00 	movl   $0x155f,0x4(%esp)
      7c:	00 
      7d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      84:	e8 0a 11 00 00       	call   1193 <printf>
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
      9d:	e8 92 0f 00 00       	call   1034 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
      a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
      a5:	8b 50 10             	mov    0x10(%eax),%edx
      a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
      ab:	8b 40 08             	mov    0x8(%eax),%eax
      ae:	89 54 24 04          	mov    %edx,0x4(%esp)
      b2:	89 04 24             	mov    %eax,(%esp)
      b5:	e8 92 0f 00 00       	call   104c <open>
      ba:	85 c0                	test   %eax,%eax
      bc:	79 2a                	jns    e8 <runcmd+0xe8>
      printf(2, "open %s failed\n", rcmd->file);
      be:	8b 45 f0             	mov    -0x10(%ebp),%eax
      c1:	8b 40 08             	mov    0x8(%eax),%eax
      c4:	89 44 24 08          	mov    %eax,0x8(%esp)
      c8:	c7 44 24 04 6f 15 00 	movl   $0x156f,0x4(%esp)
      cf:	00 
      d0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      d7:	e8 b7 10 00 00       	call   1193 <printf>
      exit(EXIT_STATUS_ERR);
      dc:	c7 04 24 4d 01 00 00 	movl   $0x14d,(%esp)
      e3:	e8 24 0f 00 00       	call   100c <exit>
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
     101:	e8 fb 02 00 00       	call   401 <fork1>
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
     11e:	e8 f1 0e 00 00       	call   1014 <wait>
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
     142:	e8 d5 0e 00 00       	call   101c <pipe>
     147:	85 c0                	test   %eax,%eax
     149:	79 0c                	jns    157 <runcmd+0x157>
      panic("pipe");
     14b:	c7 04 24 7f 15 00 00 	movl   $0x157f,(%esp)
     152:	e8 7d 02 00 00       	call   3d4 <panic>
    if(fork1() == 0){
     157:	e8 a5 02 00 00       	call   401 <fork1>
     15c:	85 c0                	test   %eax,%eax
     15e:	75 3b                	jne    19b <runcmd+0x19b>
      close(1);
     160:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     167:	e8 c8 0e 00 00       	call   1034 <close>
      dup(p[1]);
     16c:	8b 45 e0             	mov    -0x20(%ebp),%eax
     16f:	89 04 24             	mov    %eax,(%esp)
     172:	e8 0d 0f 00 00       	call   1084 <dup>
      close(p[0]);
     177:	8b 45 dc             	mov    -0x24(%ebp),%eax
     17a:	89 04 24             	mov    %eax,(%esp)
     17d:	e8 b2 0e 00 00       	call   1034 <close>
      close(p[1]);
     182:	8b 45 e0             	mov    -0x20(%ebp),%eax
     185:	89 04 24             	mov    %eax,(%esp)
     188:	e8 a7 0e 00 00       	call   1034 <close>
      runcmd(pcmd->left);
     18d:	8b 45 e8             	mov    -0x18(%ebp),%eax
     190:	8b 40 04             	mov    0x4(%eax),%eax
     193:	89 04 24             	mov    %eax,(%esp)
     196:	e8 65 fe ff ff       	call   0 <runcmd>
    }
    if(fork1() == 0){
     19b:	e8 61 02 00 00       	call   401 <fork1>
     1a0:	85 c0                	test   %eax,%eax
     1a2:	75 3b                	jne    1df <runcmd+0x1df>
      close(0);
     1a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     1ab:	e8 84 0e 00 00       	call   1034 <close>
      dup(p[0]);
     1b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1b3:	89 04 24             	mov    %eax,(%esp)
     1b6:	e8 c9 0e 00 00       	call   1084 <dup>
      close(p[0]);
     1bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1be:	89 04 24             	mov    %eax,(%esp)
     1c1:	e8 6e 0e 00 00       	call   1034 <close>
      close(p[1]);
     1c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1c9:	89 04 24             	mov    %eax,(%esp)
     1cc:	e8 63 0e 00 00       	call   1034 <close>
      runcmd(pcmd->right);
     1d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
     1d4:	8b 40 08             	mov    0x8(%eax),%eax
     1d7:	89 04 24             	mov    %eax,(%esp)
     1da:	e8 21 fe ff ff       	call   0 <runcmd>
    }
    close(p[0]);
     1df:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1e2:	89 04 24             	mov    %eax,(%esp)
     1e5:	e8 4a 0e 00 00       	call   1034 <close>
    close(p[1]);
     1ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1ed:	89 04 24             	mov    %eax,(%esp)
     1f0:	e8 3f 0e 00 00       	call   1034 <close>
    wait(&status);
     1f5:	8d 45 d8             	lea    -0x28(%ebp),%eax
     1f8:	89 04 24             	mov    %eax,(%esp)
     1fb:	e8 14 0e 00 00       	call   1014 <wait>
    wait(&status);
     200:	8d 45 d8             	lea    -0x28(%ebp),%eax
     203:	89 04 24             	mov    %eax,(%esp)
     206:	e8 09 0e 00 00       	call   1014 <wait>
    break;
     20b:	eb 1e                	jmp    22b <runcmd+0x22b>
    
  case BACK:
    bcmd = (struct backcmd*)cmd;
     20d:	8b 45 08             	mov    0x8(%ebp),%eax
     210:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(fork1() == 0)
     213:	e8 e9 01 00 00       	call   401 <fork1>
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
     232:	c7 44 24 04 84 15 00 	movl   $0x1584,0x4(%esp)
     239:	00 
     23a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     241:	e8 4d 0f 00 00       	call   1193 <printf>
  exit(EXIT_STATUS_OK);
     246:	c7 04 24 6f 00 00 00 	movl   $0x6f,(%esp)
     24d:	e8 ba 0d 00 00       	call   100c <exit>

00000252 <getcmd>:
}

int
getcmd(char *buf, int nbuf)
{
     252:	55                   	push   %ebp
     253:	89 e5                	mov    %esp,%ebp
     255:	83 ec 18             	sub    $0x18,%esp
  printf(2, "$ ");
     258:	c7 44 24 04 c0 15 00 	movl   $0x15c0,0x4(%esp)
     25f:	00 
     260:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     267:	e8 27 0f 00 00       	call   1193 <printf>
  memset(buf, 0, nbuf);
     26c:	8b 45 0c             	mov    0xc(%ebp),%eax
     26f:	89 44 24 08          	mov    %eax,0x8(%esp)
     273:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     27a:	00 
     27b:	8b 45 08             	mov    0x8(%ebp),%eax
     27e:	89 04 24             	mov    %eax,(%esp)
     281:	e8 e1 0b 00 00       	call   e67 <memset>
  gets(buf, nbuf);
     286:	8b 45 0c             	mov    0xc(%ebp),%eax
     289:	89 44 24 04          	mov    %eax,0x4(%esp)
     28d:	8b 45 08             	mov    0x8(%ebp),%eax
     290:	89 04 24             	mov    %eax,(%esp)
     293:	e8 26 0c 00 00       	call   ebe <gets>
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
     2c9:	e8 66 0d 00 00       	call   1034 <close>
      break;
     2ce:	90                   	nop
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     2cf:	e9 d8 00 00 00       	jmp    3ac <main+0xfc>
{
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     2d4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     2db:	00 
     2dc:	c7 04 24 c3 15 00 00 	movl   $0x15c3,(%esp)
     2e3:	e8 64 0d 00 00       	call   104c <open>
     2e8:	89 44 24 1c          	mov    %eax,0x1c(%esp)
     2ec:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
     2f1:	79 c8                	jns    2bb <main+0xb>
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     2f3:	e9 b4 00 00 00       	jmp    3ac <main+0xfc>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     2f8:	0f b6 05 60 1b 00 00 	movzbl 0x1b60,%eax
     2ff:	3c 63                	cmp    $0x63,%al
     301:	75 5a                	jne    35d <main+0xad>
     303:	0f b6 05 61 1b 00 00 	movzbl 0x1b61,%eax
     30a:	3c 64                	cmp    $0x64,%al
     30c:	75 4f                	jne    35d <main+0xad>
     30e:	0f b6 05 62 1b 00 00 	movzbl 0x1b62,%eax
     315:	3c 20                	cmp    $0x20,%al
     317:	75 44                	jne    35d <main+0xad>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
     319:	c7 04 24 60 1b 00 00 	movl   $0x1b60,(%esp)
     320:	e8 1d 0b 00 00       	call   e42 <strlen>
     325:	83 e8 01             	sub    $0x1,%eax
     328:	c6 80 60 1b 00 00 00 	movb   $0x0,0x1b60(%eax)
      if(chdir(buf+3) < 0)
     32f:	c7 04 24 63 1b 00 00 	movl   $0x1b63,(%esp)
     336:	e8 41 0d 00 00       	call   107c <chdir>
     33b:	85 c0                	test   %eax,%eax
     33d:	79 6c                	jns    3ab <main+0xfb>
        printf(2, "cannot cd %s\n", buf+3);
     33f:	c7 44 24 08 63 1b 00 	movl   $0x1b63,0x8(%esp)
     346:	00 
     347:	c7 44 24 04 cb 15 00 	movl   $0x15cb,0x4(%esp)
     34e:	00 
     34f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     356:	e8 38 0e 00 00       	call   1193 <printf>
      continue;
     35b:	eb 4e                	jmp    3ab <main+0xfb>
    }
    if(fork1CreateJob(buf) == 0) {
     35d:	c7 04 24 60 1b 00 00 	movl   $0x1b60,(%esp)
     364:	e8 bd 00 00 00       	call   426 <fork1CreateJob>
     369:	85 c0                	test   %eax,%eax
     36b:	75 14                	jne    381 <main+0xd1>
      runcmd(parsecmd(buf));
     36d:	c7 04 24 60 1b 00 00 	movl   $0x1b60,(%esp)
     374:	e8 25 04 00 00       	call   79e <parsecmd>
     379:	89 04 24             	mov    %eax,(%esp)
     37c:	e8 7f fc ff ff       	call   0 <runcmd>
    }
    int status;
    wait(&status);
     381:	8d 44 24 18          	lea    0x18(%esp),%eax
     385:	89 04 24             	mov    %eax,(%esp)
     388:	e8 87 0c 00 00       	call   1014 <wait>
    
    printf(2, "Program exited with %d\n", status);
     38d:	8b 44 24 18          	mov    0x18(%esp),%eax
     391:	89 44 24 08          	mov    %eax,0x8(%esp)
     395:	c7 44 24 04 d9 15 00 	movl   $0x15d9,0x4(%esp)
     39c:	00 
     39d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     3a4:	e8 ea 0d 00 00       	call   1193 <printf>
     3a9:	eb 01                	jmp    3ac <main+0xfc>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
      if(chdir(buf+3) < 0)
        printf(2, "cannot cd %s\n", buf+3);
      continue;
     3ab:	90                   	nop
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     3ac:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
     3b3:	00 
     3b4:	c7 04 24 60 1b 00 00 	movl   $0x1b60,(%esp)
     3bb:	e8 92 fe ff ff       	call   252 <getcmd>
     3c0:	85 c0                	test   %eax,%eax
     3c2:	0f 89 30 ff ff ff    	jns    2f8 <main+0x48>
    int status;
    wait(&status);
    
    printf(2, "Program exited with %d\n", status);
  }
  exit(EXIT_STATUS_OK);
     3c8:	c7 04 24 6f 00 00 00 	movl   $0x6f,(%esp)
     3cf:	e8 38 0c 00 00       	call   100c <exit>

000003d4 <panic>:
}

void
panic(char *s)
{
     3d4:	55                   	push   %ebp
     3d5:	89 e5                	mov    %esp,%ebp
     3d7:	83 ec 18             	sub    $0x18,%esp
  printf(2, "%s\n", s);
     3da:	8b 45 08             	mov    0x8(%ebp),%eax
     3dd:	89 44 24 08          	mov    %eax,0x8(%esp)
     3e1:	c7 44 24 04 f1 15 00 	movl   $0x15f1,0x4(%esp)
     3e8:	00 
     3e9:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     3f0:	e8 9e 0d 00 00       	call   1193 <printf>
  exit(EXIT_STATUS_ERR);
     3f5:	c7 04 24 4d 01 00 00 	movl   $0x14d,(%esp)
     3fc:	e8 0b 0c 00 00       	call   100c <exit>

00000401 <fork1>:
}

int
fork1()
{
     401:	55                   	push   %ebp
     402:	89 e5                	mov    %esp,%ebp
     404:	83 ec 28             	sub    $0x28,%esp
  int pid;
  
  pid = fork();
     407:	e8 f8 0b 00 00       	call   1004 <fork>
     40c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
     40f:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     413:	75 0c                	jne    421 <fork1+0x20>
    panic("fork");
     415:	c7 04 24 f5 15 00 00 	movl   $0x15f5,(%esp)
     41c:	e8 b3 ff ff ff       	call   3d4 <panic>
  return pid;
     421:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     424:	c9                   	leave  
     425:	c3                   	ret    

00000426 <fork1CreateJob>:


int
fork1CreateJob(char *commandName)
{
     426:	55                   	push   %ebp
     427:	89 e5                	mov    %esp,%ebp
     429:	83 ec 28             	sub    $0x28,%esp
  int pid;
  
  pid = forkjob(commandName);
     42c:	8b 45 08             	mov    0x8(%ebp),%eax
     42f:	89 04 24             	mov    %eax,(%esp)
     432:	e8 7d 0c 00 00       	call   10b4 <forkjob>
     437:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
     43a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     43e:	75 0c                	jne    44c <fork1CreateJob+0x26>
    panic("fork");
     440:	c7 04 24 f5 15 00 00 	movl   $0x15f5,(%esp)
     447:	e8 88 ff ff ff       	call   3d4 <panic>
  return pid;
     44c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     44f:	c9                   	leave  
     450:	c3                   	ret    

00000451 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     451:	55                   	push   %ebp
     452:	89 e5                	mov    %esp,%ebp
     454:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     457:	c7 04 24 54 00 00 00 	movl   $0x54,(%esp)
     45e:	e8 14 10 00 00       	call   1477 <malloc>
     463:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     466:	c7 44 24 08 54 00 00 	movl   $0x54,0x8(%esp)
     46d:	00 
     46e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     475:	00 
     476:	8b 45 f4             	mov    -0xc(%ebp),%eax
     479:	89 04 24             	mov    %eax,(%esp)
     47c:	e8 e6 09 00 00       	call   e67 <memset>
  cmd->type = EXEC;
     481:	8b 45 f4             	mov    -0xc(%ebp),%eax
     484:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  return (struct cmd*)cmd;
     48a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     48d:	c9                   	leave  
     48e:	c3                   	ret    

0000048f <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     48f:	55                   	push   %ebp
     490:	89 e5                	mov    %esp,%ebp
     492:	83 ec 28             	sub    $0x28,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     495:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
     49c:	e8 d6 0f 00 00       	call   1477 <malloc>
     4a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     4a4:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
     4ab:	00 
     4ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     4b3:	00 
     4b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4b7:	89 04 24             	mov    %eax,(%esp)
     4ba:	e8 a8 09 00 00       	call   e67 <memset>
  cmd->type = REDIR;
     4bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4c2:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  cmd->cmd = subcmd;
     4c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4cb:	8b 55 08             	mov    0x8(%ebp),%edx
     4ce:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->file = file;
     4d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4d4:	8b 55 0c             	mov    0xc(%ebp),%edx
     4d7:	89 50 08             	mov    %edx,0x8(%eax)
  cmd->efile = efile;
     4da:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4dd:	8b 55 10             	mov    0x10(%ebp),%edx
     4e0:	89 50 0c             	mov    %edx,0xc(%eax)
  cmd->mode = mode;
     4e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4e6:	8b 55 14             	mov    0x14(%ebp),%edx
     4e9:	89 50 10             	mov    %edx,0x10(%eax)
  cmd->fd = fd;
     4ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4ef:	8b 55 18             	mov    0x18(%ebp),%edx
     4f2:	89 50 14             	mov    %edx,0x14(%eax)
  return (struct cmd*)cmd;
     4f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     4f8:	c9                   	leave  
     4f9:	c3                   	ret    

000004fa <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     4fa:	55                   	push   %ebp
     4fb:	89 e5                	mov    %esp,%ebp
     4fd:	83 ec 28             	sub    $0x28,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     500:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     507:	e8 6b 0f 00 00       	call   1477 <malloc>
     50c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     50f:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     516:	00 
     517:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     51e:	00 
     51f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     522:	89 04 24             	mov    %eax,(%esp)
     525:	e8 3d 09 00 00       	call   e67 <memset>
  cmd->type = PIPE;
     52a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     52d:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
  cmd->left = left;
     533:	8b 45 f4             	mov    -0xc(%ebp),%eax
     536:	8b 55 08             	mov    0x8(%ebp),%edx
     539:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     53c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     53f:	8b 55 0c             	mov    0xc(%ebp),%edx
     542:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     545:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     548:	c9                   	leave  
     549:	c3                   	ret    

0000054a <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     54a:	55                   	push   %ebp
     54b:	89 e5                	mov    %esp,%ebp
     54d:	83 ec 28             	sub    $0x28,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     550:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     557:	e8 1b 0f 00 00       	call   1477 <malloc>
     55c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     55f:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     566:	00 
     567:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     56e:	00 
     56f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     572:	89 04 24             	mov    %eax,(%esp)
     575:	e8 ed 08 00 00       	call   e67 <memset>
  cmd->type = LIST;
     57a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     57d:	c7 00 04 00 00 00    	movl   $0x4,(%eax)
  cmd->left = left;
     583:	8b 45 f4             	mov    -0xc(%ebp),%eax
     586:	8b 55 08             	mov    0x8(%ebp),%edx
     589:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     58c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     58f:	8b 55 0c             	mov    0xc(%ebp),%edx
     592:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     595:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     598:	c9                   	leave  
     599:	c3                   	ret    

0000059a <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     59a:	55                   	push   %ebp
     59b:	89 e5                	mov    %esp,%ebp
     59d:	83 ec 28             	sub    $0x28,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     5a0:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
     5a7:	e8 cb 0e 00 00       	call   1477 <malloc>
     5ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     5af:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
     5b6:	00 
     5b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     5be:	00 
     5bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5c2:	89 04 24             	mov    %eax,(%esp)
     5c5:	e8 9d 08 00 00       	call   e67 <memset>
  cmd->type = BACK;
     5ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5cd:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
  cmd->cmd = subcmd;
     5d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5d6:	8b 55 08             	mov    0x8(%ebp),%edx
     5d9:	89 50 04             	mov    %edx,0x4(%eax)
  return (struct cmd*)cmd;
     5dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     5df:	c9                   	leave  
     5e0:	c3                   	ret    

000005e1 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     5e1:	55                   	push   %ebp
     5e2:	89 e5                	mov    %esp,%ebp
     5e4:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int ret;
  
  s = *ps;
     5e7:	8b 45 08             	mov    0x8(%ebp),%eax
     5ea:	8b 00                	mov    (%eax),%eax
     5ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     5ef:	eb 04                	jmp    5f5 <gettoken+0x14>
    s++;
     5f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
{
  char *s;
  int ret;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     5f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5f8:	3b 45 0c             	cmp    0xc(%ebp),%eax
     5fb:	73 1d                	jae    61a <gettoken+0x39>
     5fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
     600:	0f b6 00             	movzbl (%eax),%eax
     603:	0f be c0             	movsbl %al,%eax
     606:	89 44 24 04          	mov    %eax,0x4(%esp)
     60a:	c7 04 24 24 1b 00 00 	movl   $0x1b24,(%esp)
     611:	e8 75 08 00 00       	call   e8b <strchr>
     616:	85 c0                	test   %eax,%eax
     618:	75 d7                	jne    5f1 <gettoken+0x10>
    s++;
  if(q)
     61a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     61e:	74 08                	je     628 <gettoken+0x47>
    *q = s;
     620:	8b 45 10             	mov    0x10(%ebp),%eax
     623:	8b 55 f4             	mov    -0xc(%ebp),%edx
     626:	89 10                	mov    %edx,(%eax)
  ret = *s;
     628:	8b 45 f4             	mov    -0xc(%ebp),%eax
     62b:	0f b6 00             	movzbl (%eax),%eax
     62e:	0f be c0             	movsbl %al,%eax
     631:	89 45 f0             	mov    %eax,-0x10(%ebp)
  switch(*s){
     634:	8b 45 f4             	mov    -0xc(%ebp),%eax
     637:	0f b6 00             	movzbl (%eax),%eax
     63a:	0f be c0             	movsbl %al,%eax
     63d:	83 f8 3c             	cmp    $0x3c,%eax
     640:	7f 1e                	jg     660 <gettoken+0x7f>
     642:	83 f8 3b             	cmp    $0x3b,%eax
     645:	7d 23                	jge    66a <gettoken+0x89>
     647:	83 f8 29             	cmp    $0x29,%eax
     64a:	7f 3f                	jg     68b <gettoken+0xaa>
     64c:	83 f8 28             	cmp    $0x28,%eax
     64f:	7d 19                	jge    66a <gettoken+0x89>
     651:	85 c0                	test   %eax,%eax
     653:	0f 84 83 00 00 00    	je     6dc <gettoken+0xfb>
     659:	83 f8 26             	cmp    $0x26,%eax
     65c:	74 0c                	je     66a <gettoken+0x89>
     65e:	eb 2b                	jmp    68b <gettoken+0xaa>
     660:	83 f8 3e             	cmp    $0x3e,%eax
     663:	74 0b                	je     670 <gettoken+0x8f>
     665:	83 f8 7c             	cmp    $0x7c,%eax
     668:	75 21                	jne    68b <gettoken+0xaa>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     66a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
     66e:	eb 73                	jmp    6e3 <gettoken+0x102>
  case '>':
    s++;
     670:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(*s == '>'){
     674:	8b 45 f4             	mov    -0xc(%ebp),%eax
     677:	0f b6 00             	movzbl (%eax),%eax
     67a:	3c 3e                	cmp    $0x3e,%al
     67c:	75 61                	jne    6df <gettoken+0xfe>
      ret = '+';
     67e:	c7 45 f0 2b 00 00 00 	movl   $0x2b,-0x10(%ebp)
      s++;
     685:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    break;
     689:	eb 54                	jmp    6df <gettoken+0xfe>
  default:
    ret = 'a';
     68b:	c7 45 f0 61 00 00 00 	movl   $0x61,-0x10(%ebp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     692:	eb 04                	jmp    698 <gettoken+0xb7>
      s++;
     694:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     698:	8b 45 f4             	mov    -0xc(%ebp),%eax
     69b:	3b 45 0c             	cmp    0xc(%ebp),%eax
     69e:	73 42                	jae    6e2 <gettoken+0x101>
     6a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6a3:	0f b6 00             	movzbl (%eax),%eax
     6a6:	0f be c0             	movsbl %al,%eax
     6a9:	89 44 24 04          	mov    %eax,0x4(%esp)
     6ad:	c7 04 24 24 1b 00 00 	movl   $0x1b24,(%esp)
     6b4:	e8 d2 07 00 00       	call   e8b <strchr>
     6b9:	85 c0                	test   %eax,%eax
     6bb:	75 25                	jne    6e2 <gettoken+0x101>
     6bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6c0:	0f b6 00             	movzbl (%eax),%eax
     6c3:	0f be c0             	movsbl %al,%eax
     6c6:	89 44 24 04          	mov    %eax,0x4(%esp)
     6ca:	c7 04 24 2a 1b 00 00 	movl   $0x1b2a,(%esp)
     6d1:	e8 b5 07 00 00       	call   e8b <strchr>
     6d6:	85 c0                	test   %eax,%eax
     6d8:	74 ba                	je     694 <gettoken+0xb3>
      s++;
    break;
     6da:	eb 06                	jmp    6e2 <gettoken+0x101>
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
  case 0:
    break;
     6dc:	90                   	nop
     6dd:	eb 04                	jmp    6e3 <gettoken+0x102>
    s++;
    if(*s == '>'){
      ret = '+';
      s++;
    }
    break;
     6df:	90                   	nop
     6e0:	eb 01                	jmp    6e3 <gettoken+0x102>
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
     6e2:	90                   	nop
  }
  if(eq)
     6e3:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     6e7:	74 0e                	je     6f7 <gettoken+0x116>
    *eq = s;
     6e9:	8b 45 14             	mov    0x14(%ebp),%eax
     6ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
     6ef:	89 10                	mov    %edx,(%eax)
  
  while(s < es && strchr(whitespace, *s))
     6f1:	eb 04                	jmp    6f7 <gettoken+0x116>
    s++;
     6f3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
  }
  if(eq)
    *eq = s;
  
  while(s < es && strchr(whitespace, *s))
     6f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6fa:	3b 45 0c             	cmp    0xc(%ebp),%eax
     6fd:	73 1d                	jae    71c <gettoken+0x13b>
     6ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
     702:	0f b6 00             	movzbl (%eax),%eax
     705:	0f be c0             	movsbl %al,%eax
     708:	89 44 24 04          	mov    %eax,0x4(%esp)
     70c:	c7 04 24 24 1b 00 00 	movl   $0x1b24,(%esp)
     713:	e8 73 07 00 00       	call   e8b <strchr>
     718:	85 c0                	test   %eax,%eax
     71a:	75 d7                	jne    6f3 <gettoken+0x112>
    s++;
  *ps = s;
     71c:	8b 45 08             	mov    0x8(%ebp),%eax
     71f:	8b 55 f4             	mov    -0xc(%ebp),%edx
     722:	89 10                	mov    %edx,(%eax)
  return ret;
     724:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     727:	c9                   	leave  
     728:	c3                   	ret    

00000729 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     729:	55                   	push   %ebp
     72a:	89 e5                	mov    %esp,%ebp
     72c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  
  s = *ps;
     72f:	8b 45 08             	mov    0x8(%ebp),%eax
     732:	8b 00                	mov    (%eax),%eax
     734:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     737:	eb 04                	jmp    73d <peek+0x14>
    s++;
     739:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
peek(char **ps, char *es, char *toks)
{
  char *s;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     73d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     740:	3b 45 0c             	cmp    0xc(%ebp),%eax
     743:	73 1d                	jae    762 <peek+0x39>
     745:	8b 45 f4             	mov    -0xc(%ebp),%eax
     748:	0f b6 00             	movzbl (%eax),%eax
     74b:	0f be c0             	movsbl %al,%eax
     74e:	89 44 24 04          	mov    %eax,0x4(%esp)
     752:	c7 04 24 24 1b 00 00 	movl   $0x1b24,(%esp)
     759:	e8 2d 07 00 00       	call   e8b <strchr>
     75e:	85 c0                	test   %eax,%eax
     760:	75 d7                	jne    739 <peek+0x10>
    s++;
  *ps = s;
     762:	8b 45 08             	mov    0x8(%ebp),%eax
     765:	8b 55 f4             	mov    -0xc(%ebp),%edx
     768:	89 10                	mov    %edx,(%eax)
  return *s && strchr(toks, *s);
     76a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     76d:	0f b6 00             	movzbl (%eax),%eax
     770:	84 c0                	test   %al,%al
     772:	74 23                	je     797 <peek+0x6e>
     774:	8b 45 f4             	mov    -0xc(%ebp),%eax
     777:	0f b6 00             	movzbl (%eax),%eax
     77a:	0f be c0             	movsbl %al,%eax
     77d:	89 44 24 04          	mov    %eax,0x4(%esp)
     781:	8b 45 10             	mov    0x10(%ebp),%eax
     784:	89 04 24             	mov    %eax,(%esp)
     787:	e8 ff 06 00 00       	call   e8b <strchr>
     78c:	85 c0                	test   %eax,%eax
     78e:	74 07                	je     797 <peek+0x6e>
     790:	b8 01 00 00 00       	mov    $0x1,%eax
     795:	eb 05                	jmp    79c <peek+0x73>
     797:	b8 00 00 00 00       	mov    $0x0,%eax
}
     79c:	c9                   	leave  
     79d:	c3                   	ret    

0000079e <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
     79e:	55                   	push   %ebp
     79f:	89 e5                	mov    %esp,%ebp
     7a1:	53                   	push   %ebx
     7a2:	83 ec 24             	sub    $0x24,%esp
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
     7a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
     7a8:	8b 45 08             	mov    0x8(%ebp),%eax
     7ab:	89 04 24             	mov    %eax,(%esp)
     7ae:	e8 8f 06 00 00       	call   e42 <strlen>
     7b3:	01 d8                	add    %ebx,%eax
     7b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cmd = parseline(&s, es);
     7b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7bb:	89 44 24 04          	mov    %eax,0x4(%esp)
     7bf:	8d 45 08             	lea    0x8(%ebp),%eax
     7c2:	89 04 24             	mov    %eax,(%esp)
     7c5:	e8 60 00 00 00       	call   82a <parseline>
     7ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  peek(&s, es, "");
     7cd:	c7 44 24 08 fa 15 00 	movl   $0x15fa,0x8(%esp)
     7d4:	00 
     7d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7d8:	89 44 24 04          	mov    %eax,0x4(%esp)
     7dc:	8d 45 08             	lea    0x8(%ebp),%eax
     7df:	89 04 24             	mov    %eax,(%esp)
     7e2:	e8 42 ff ff ff       	call   729 <peek>
  if(s != es){
     7e7:	8b 45 08             	mov    0x8(%ebp),%eax
     7ea:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     7ed:	74 27                	je     816 <parsecmd+0x78>
    printf(2, "leftovers: %s\n", s);
     7ef:	8b 45 08             	mov    0x8(%ebp),%eax
     7f2:	89 44 24 08          	mov    %eax,0x8(%esp)
     7f6:	c7 44 24 04 fb 15 00 	movl   $0x15fb,0x4(%esp)
     7fd:	00 
     7fe:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     805:	e8 89 09 00 00       	call   1193 <printf>
    panic("syntax");
     80a:	c7 04 24 0a 16 00 00 	movl   $0x160a,(%esp)
     811:	e8 be fb ff ff       	call   3d4 <panic>
  }
  nulterminate(cmd);
     816:	8b 45 f0             	mov    -0x10(%ebp),%eax
     819:	89 04 24             	mov    %eax,(%esp)
     81c:	e8 a5 04 00 00       	call   cc6 <nulterminate>
  return cmd;
     821:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     824:	83 c4 24             	add    $0x24,%esp
     827:	5b                   	pop    %ebx
     828:	5d                   	pop    %ebp
     829:	c3                   	ret    

0000082a <parseline>:

struct cmd*
parseline(char **ps, char *es)
{
     82a:	55                   	push   %ebp
     82b:	89 e5                	mov    %esp,%ebp
     82d:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
     830:	8b 45 0c             	mov    0xc(%ebp),%eax
     833:	89 44 24 04          	mov    %eax,0x4(%esp)
     837:	8b 45 08             	mov    0x8(%ebp),%eax
     83a:	89 04 24             	mov    %eax,(%esp)
     83d:	e8 bc 00 00 00       	call   8fe <parsepipe>
     842:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(peek(ps, es, "&")){
     845:	eb 30                	jmp    877 <parseline+0x4d>
    gettoken(ps, es, 0, 0);
     847:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     84e:	00 
     84f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     856:	00 
     857:	8b 45 0c             	mov    0xc(%ebp),%eax
     85a:	89 44 24 04          	mov    %eax,0x4(%esp)
     85e:	8b 45 08             	mov    0x8(%ebp),%eax
     861:	89 04 24             	mov    %eax,(%esp)
     864:	e8 78 fd ff ff       	call   5e1 <gettoken>
    cmd = backcmd(cmd);
     869:	8b 45 f4             	mov    -0xc(%ebp),%eax
     86c:	89 04 24             	mov    %eax,(%esp)
     86f:	e8 26 fd ff ff       	call   59a <backcmd>
     874:	89 45 f4             	mov    %eax,-0xc(%ebp)
parseline(char **ps, char *es)
{
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
  while(peek(ps, es, "&")){
     877:	c7 44 24 08 11 16 00 	movl   $0x1611,0x8(%esp)
     87e:	00 
     87f:	8b 45 0c             	mov    0xc(%ebp),%eax
     882:	89 44 24 04          	mov    %eax,0x4(%esp)
     886:	8b 45 08             	mov    0x8(%ebp),%eax
     889:	89 04 24             	mov    %eax,(%esp)
     88c:	e8 98 fe ff ff       	call   729 <peek>
     891:	85 c0                	test   %eax,%eax
     893:	75 b2                	jne    847 <parseline+0x1d>
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
  if(peek(ps, es, ";")){
     895:	c7 44 24 08 13 16 00 	movl   $0x1613,0x8(%esp)
     89c:	00 
     89d:	8b 45 0c             	mov    0xc(%ebp),%eax
     8a0:	89 44 24 04          	mov    %eax,0x4(%esp)
     8a4:	8b 45 08             	mov    0x8(%ebp),%eax
     8a7:	89 04 24             	mov    %eax,(%esp)
     8aa:	e8 7a fe ff ff       	call   729 <peek>
     8af:	85 c0                	test   %eax,%eax
     8b1:	74 46                	je     8f9 <parseline+0xcf>
    gettoken(ps, es, 0, 0);
     8b3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     8ba:	00 
     8bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     8c2:	00 
     8c3:	8b 45 0c             	mov    0xc(%ebp),%eax
     8c6:	89 44 24 04          	mov    %eax,0x4(%esp)
     8ca:	8b 45 08             	mov    0x8(%ebp),%eax
     8cd:	89 04 24             	mov    %eax,(%esp)
     8d0:	e8 0c fd ff ff       	call   5e1 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     8d5:	8b 45 0c             	mov    0xc(%ebp),%eax
     8d8:	89 44 24 04          	mov    %eax,0x4(%esp)
     8dc:	8b 45 08             	mov    0x8(%ebp),%eax
     8df:	89 04 24             	mov    %eax,(%esp)
     8e2:	e8 43 ff ff ff       	call   82a <parseline>
     8e7:	89 44 24 04          	mov    %eax,0x4(%esp)
     8eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8ee:	89 04 24             	mov    %eax,(%esp)
     8f1:	e8 54 fc ff ff       	call   54a <listcmd>
     8f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     8f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     8fc:	c9                   	leave  
     8fd:	c3                   	ret    

000008fe <parsepipe>:

struct cmd*
parsepipe(char **ps, char *es)
{
     8fe:	55                   	push   %ebp
     8ff:	89 e5                	mov    %esp,%ebp
     901:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parseexec(ps, es);
     904:	8b 45 0c             	mov    0xc(%ebp),%eax
     907:	89 44 24 04          	mov    %eax,0x4(%esp)
     90b:	8b 45 08             	mov    0x8(%ebp),%eax
     90e:	89 04 24             	mov    %eax,(%esp)
     911:	e8 68 02 00 00       	call   b7e <parseexec>
     916:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(peek(ps, es, "|")){
     919:	c7 44 24 08 15 16 00 	movl   $0x1615,0x8(%esp)
     920:	00 
     921:	8b 45 0c             	mov    0xc(%ebp),%eax
     924:	89 44 24 04          	mov    %eax,0x4(%esp)
     928:	8b 45 08             	mov    0x8(%ebp),%eax
     92b:	89 04 24             	mov    %eax,(%esp)
     92e:	e8 f6 fd ff ff       	call   729 <peek>
     933:	85 c0                	test   %eax,%eax
     935:	74 46                	je     97d <parsepipe+0x7f>
    gettoken(ps, es, 0, 0);
     937:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     93e:	00 
     93f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     946:	00 
     947:	8b 45 0c             	mov    0xc(%ebp),%eax
     94a:	89 44 24 04          	mov    %eax,0x4(%esp)
     94e:	8b 45 08             	mov    0x8(%ebp),%eax
     951:	89 04 24             	mov    %eax,(%esp)
     954:	e8 88 fc ff ff       	call   5e1 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     959:	8b 45 0c             	mov    0xc(%ebp),%eax
     95c:	89 44 24 04          	mov    %eax,0x4(%esp)
     960:	8b 45 08             	mov    0x8(%ebp),%eax
     963:	89 04 24             	mov    %eax,(%esp)
     966:	e8 93 ff ff ff       	call   8fe <parsepipe>
     96b:	89 44 24 04          	mov    %eax,0x4(%esp)
     96f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     972:	89 04 24             	mov    %eax,(%esp)
     975:	e8 80 fb ff ff       	call   4fa <pipecmd>
     97a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     97d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     980:	c9                   	leave  
     981:	c3                   	ret    

00000982 <parseredirs>:

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     982:	55                   	push   %ebp
     983:	89 e5                	mov    %esp,%ebp
     985:	83 ec 38             	sub    $0x38,%esp
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     988:	e9 f6 00 00 00       	jmp    a83 <parseredirs+0x101>
    tok = gettoken(ps, es, 0, 0);
     98d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     994:	00 
     995:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     99c:	00 
     99d:	8b 45 10             	mov    0x10(%ebp),%eax
     9a0:	89 44 24 04          	mov    %eax,0x4(%esp)
     9a4:	8b 45 0c             	mov    0xc(%ebp),%eax
     9a7:	89 04 24             	mov    %eax,(%esp)
     9aa:	e8 32 fc ff ff       	call   5e1 <gettoken>
     9af:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(gettoken(ps, es, &q, &eq) != 'a')
     9b2:	8d 45 ec             	lea    -0x14(%ebp),%eax
     9b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
     9b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
     9bc:	89 44 24 08          	mov    %eax,0x8(%esp)
     9c0:	8b 45 10             	mov    0x10(%ebp),%eax
     9c3:	89 44 24 04          	mov    %eax,0x4(%esp)
     9c7:	8b 45 0c             	mov    0xc(%ebp),%eax
     9ca:	89 04 24             	mov    %eax,(%esp)
     9cd:	e8 0f fc ff ff       	call   5e1 <gettoken>
     9d2:	83 f8 61             	cmp    $0x61,%eax
     9d5:	74 0c                	je     9e3 <parseredirs+0x61>
      panic("missing file for redirection");
     9d7:	c7 04 24 17 16 00 00 	movl   $0x1617,(%esp)
     9de:	e8 f1 f9 ff ff       	call   3d4 <panic>
    switch(tok){
     9e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9e6:	83 f8 3c             	cmp    $0x3c,%eax
     9e9:	74 0f                	je     9fa <parseredirs+0x78>
     9eb:	83 f8 3e             	cmp    $0x3e,%eax
     9ee:	74 38                	je     a28 <parseredirs+0xa6>
     9f0:	83 f8 2b             	cmp    $0x2b,%eax
     9f3:	74 61                	je     a56 <parseredirs+0xd4>
     9f5:	e9 89 00 00 00       	jmp    a83 <parseredirs+0x101>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     9fa:	8b 55 ec             	mov    -0x14(%ebp),%edx
     9fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a00:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
     a07:	00 
     a08:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     a0f:	00 
     a10:	89 54 24 08          	mov    %edx,0x8(%esp)
     a14:	89 44 24 04          	mov    %eax,0x4(%esp)
     a18:	8b 45 08             	mov    0x8(%ebp),%eax
     a1b:	89 04 24             	mov    %eax,(%esp)
     a1e:	e8 6c fa ff ff       	call   48f <redircmd>
     a23:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     a26:	eb 5b                	jmp    a83 <parseredirs+0x101>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     a28:	8b 55 ec             	mov    -0x14(%ebp),%edx
     a2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a2e:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     a35:	00 
     a36:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     a3d:	00 
     a3e:	89 54 24 08          	mov    %edx,0x8(%esp)
     a42:	89 44 24 04          	mov    %eax,0x4(%esp)
     a46:	8b 45 08             	mov    0x8(%ebp),%eax
     a49:	89 04 24             	mov    %eax,(%esp)
     a4c:	e8 3e fa ff ff       	call   48f <redircmd>
     a51:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     a54:	eb 2d                	jmp    a83 <parseredirs+0x101>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     a56:	8b 55 ec             	mov    -0x14(%ebp),%edx
     a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a5c:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     a63:	00 
     a64:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     a6b:	00 
     a6c:	89 54 24 08          	mov    %edx,0x8(%esp)
     a70:	89 44 24 04          	mov    %eax,0x4(%esp)
     a74:	8b 45 08             	mov    0x8(%ebp),%eax
     a77:	89 04 24             	mov    %eax,(%esp)
     a7a:	e8 10 fa ff ff       	call   48f <redircmd>
     a7f:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     a82:	90                   	nop
parseredirs(struct cmd *cmd, char **ps, char *es)
{
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     a83:	c7 44 24 08 34 16 00 	movl   $0x1634,0x8(%esp)
     a8a:	00 
     a8b:	8b 45 10             	mov    0x10(%ebp),%eax
     a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
     a92:	8b 45 0c             	mov    0xc(%ebp),%eax
     a95:	89 04 24             	mov    %eax,(%esp)
     a98:	e8 8c fc ff ff       	call   729 <peek>
     a9d:	85 c0                	test   %eax,%eax
     a9f:	0f 85 e8 fe ff ff    	jne    98d <parseredirs+0xb>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    }
  }
  return cmd;
     aa5:	8b 45 08             	mov    0x8(%ebp),%eax
}
     aa8:	c9                   	leave  
     aa9:	c3                   	ret    

00000aaa <parseblock>:

struct cmd*
parseblock(char **ps, char *es)
{
     aaa:	55                   	push   %ebp
     aab:	89 e5                	mov    %esp,%ebp
     aad:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  if(!peek(ps, es, "("))
     ab0:	c7 44 24 08 37 16 00 	movl   $0x1637,0x8(%esp)
     ab7:	00 
     ab8:	8b 45 0c             	mov    0xc(%ebp),%eax
     abb:	89 44 24 04          	mov    %eax,0x4(%esp)
     abf:	8b 45 08             	mov    0x8(%ebp),%eax
     ac2:	89 04 24             	mov    %eax,(%esp)
     ac5:	e8 5f fc ff ff       	call   729 <peek>
     aca:	85 c0                	test   %eax,%eax
     acc:	75 0c                	jne    ada <parseblock+0x30>
    panic("parseblock");
     ace:	c7 04 24 39 16 00 00 	movl   $0x1639,(%esp)
     ad5:	e8 fa f8 ff ff       	call   3d4 <panic>
  gettoken(ps, es, 0, 0);
     ada:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     ae1:	00 
     ae2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     ae9:	00 
     aea:	8b 45 0c             	mov    0xc(%ebp),%eax
     aed:	89 44 24 04          	mov    %eax,0x4(%esp)
     af1:	8b 45 08             	mov    0x8(%ebp),%eax
     af4:	89 04 24             	mov    %eax,(%esp)
     af7:	e8 e5 fa ff ff       	call   5e1 <gettoken>
  cmd = parseline(ps, es);
     afc:	8b 45 0c             	mov    0xc(%ebp),%eax
     aff:	89 44 24 04          	mov    %eax,0x4(%esp)
     b03:	8b 45 08             	mov    0x8(%ebp),%eax
     b06:	89 04 24             	mov    %eax,(%esp)
     b09:	e8 1c fd ff ff       	call   82a <parseline>
     b0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!peek(ps, es, ")"))
     b11:	c7 44 24 08 44 16 00 	movl   $0x1644,0x8(%esp)
     b18:	00 
     b19:	8b 45 0c             	mov    0xc(%ebp),%eax
     b1c:	89 44 24 04          	mov    %eax,0x4(%esp)
     b20:	8b 45 08             	mov    0x8(%ebp),%eax
     b23:	89 04 24             	mov    %eax,(%esp)
     b26:	e8 fe fb ff ff       	call   729 <peek>
     b2b:	85 c0                	test   %eax,%eax
     b2d:	75 0c                	jne    b3b <parseblock+0x91>
    panic("syntax - missing )");
     b2f:	c7 04 24 46 16 00 00 	movl   $0x1646,(%esp)
     b36:	e8 99 f8 ff ff       	call   3d4 <panic>
  gettoken(ps, es, 0, 0);
     b3b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     b42:	00 
     b43:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     b4a:	00 
     b4b:	8b 45 0c             	mov    0xc(%ebp),%eax
     b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
     b52:	8b 45 08             	mov    0x8(%ebp),%eax
     b55:	89 04 24             	mov    %eax,(%esp)
     b58:	e8 84 fa ff ff       	call   5e1 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     b5d:	8b 45 0c             	mov    0xc(%ebp),%eax
     b60:	89 44 24 08          	mov    %eax,0x8(%esp)
     b64:	8b 45 08             	mov    0x8(%ebp),%eax
     b67:	89 44 24 04          	mov    %eax,0x4(%esp)
     b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b6e:	89 04 24             	mov    %eax,(%esp)
     b71:	e8 0c fe ff ff       	call   982 <parseredirs>
     b76:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return cmd;
     b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     b7c:	c9                   	leave  
     b7d:	c3                   	ret    

00000b7e <parseexec>:

struct cmd*
parseexec(char **ps, char *es)
{
     b7e:	55                   	push   %ebp
     b7f:	89 e5                	mov    %esp,%ebp
     b81:	83 ec 38             	sub    $0x38,%esp
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;
  
  if(peek(ps, es, "("))
     b84:	c7 44 24 08 37 16 00 	movl   $0x1637,0x8(%esp)
     b8b:	00 
     b8c:	8b 45 0c             	mov    0xc(%ebp),%eax
     b8f:	89 44 24 04          	mov    %eax,0x4(%esp)
     b93:	8b 45 08             	mov    0x8(%ebp),%eax
     b96:	89 04 24             	mov    %eax,(%esp)
     b99:	e8 8b fb ff ff       	call   729 <peek>
     b9e:	85 c0                	test   %eax,%eax
     ba0:	74 17                	je     bb9 <parseexec+0x3b>
    return parseblock(ps, es);
     ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
     ba5:	89 44 24 04          	mov    %eax,0x4(%esp)
     ba9:	8b 45 08             	mov    0x8(%ebp),%eax
     bac:	89 04 24             	mov    %eax,(%esp)
     baf:	e8 f6 fe ff ff       	call   aaa <parseblock>
     bb4:	e9 0b 01 00 00       	jmp    cc4 <parseexec+0x146>

  ret = execcmd();
     bb9:	e8 93 f8 ff ff       	call   451 <execcmd>
     bbe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cmd = (struct execcmd*)ret;
     bc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
     bc4:	89 45 ec             	mov    %eax,-0x14(%ebp)

  argc = 0;
     bc7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ret = parseredirs(ret, ps, es);
     bce:	8b 45 0c             	mov    0xc(%ebp),%eax
     bd1:	89 44 24 08          	mov    %eax,0x8(%esp)
     bd5:	8b 45 08             	mov    0x8(%ebp),%eax
     bd8:	89 44 24 04          	mov    %eax,0x4(%esp)
     bdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
     bdf:	89 04 24             	mov    %eax,(%esp)
     be2:	e8 9b fd ff ff       	call   982 <parseredirs>
     be7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while(!peek(ps, es, "|)&;")){
     bea:	e9 8e 00 00 00       	jmp    c7d <parseexec+0xff>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     bef:	8d 45 e0             	lea    -0x20(%ebp),%eax
     bf2:	89 44 24 0c          	mov    %eax,0xc(%esp)
     bf6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     bf9:	89 44 24 08          	mov    %eax,0x8(%esp)
     bfd:	8b 45 0c             	mov    0xc(%ebp),%eax
     c00:	89 44 24 04          	mov    %eax,0x4(%esp)
     c04:	8b 45 08             	mov    0x8(%ebp),%eax
     c07:	89 04 24             	mov    %eax,(%esp)
     c0a:	e8 d2 f9 ff ff       	call   5e1 <gettoken>
     c0f:	89 45 e8             	mov    %eax,-0x18(%ebp)
     c12:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     c16:	0f 84 85 00 00 00    	je     ca1 <parseexec+0x123>
      break;
    if(tok != 'a')
     c1c:	83 7d e8 61          	cmpl   $0x61,-0x18(%ebp)
     c20:	74 0c                	je     c2e <parseexec+0xb0>
      panic("syntax");
     c22:	c7 04 24 0a 16 00 00 	movl   $0x160a,(%esp)
     c29:	e8 a6 f7 ff ff       	call   3d4 <panic>
    cmd->argv[argc] = q;
     c2e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
     c31:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c34:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c37:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
    cmd->eargv[argc] = eq;
     c3b:	8b 55 e0             	mov    -0x20(%ebp),%edx
     c3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c41:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     c44:	83 c1 08             	add    $0x8,%ecx
     c47:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    argc++;
     c4b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(argc >= MAXARGS)
     c4f:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     c53:	7e 0c                	jle    c61 <parseexec+0xe3>
      panic("too many args");
     c55:	c7 04 24 59 16 00 00 	movl   $0x1659,(%esp)
     c5c:	e8 73 f7 ff ff       	call   3d4 <panic>
    ret = parseredirs(ret, ps, es);
     c61:	8b 45 0c             	mov    0xc(%ebp),%eax
     c64:	89 44 24 08          	mov    %eax,0x8(%esp)
     c68:	8b 45 08             	mov    0x8(%ebp),%eax
     c6b:	89 44 24 04          	mov    %eax,0x4(%esp)
     c6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c72:	89 04 24             	mov    %eax,(%esp)
     c75:	e8 08 fd ff ff       	call   982 <parseredirs>
     c7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
     c7d:	c7 44 24 08 67 16 00 	movl   $0x1667,0x8(%esp)
     c84:	00 
     c85:	8b 45 0c             	mov    0xc(%ebp),%eax
     c88:	89 44 24 04          	mov    %eax,0x4(%esp)
     c8c:	8b 45 08             	mov    0x8(%ebp),%eax
     c8f:	89 04 24             	mov    %eax,(%esp)
     c92:	e8 92 fa ff ff       	call   729 <peek>
     c97:	85 c0                	test   %eax,%eax
     c99:	0f 84 50 ff ff ff    	je     bef <parseexec+0x71>
     c9f:	eb 01                	jmp    ca2 <parseexec+0x124>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
     ca1:	90                   	nop
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
     ca2:	8b 45 ec             	mov    -0x14(%ebp),%eax
     ca5:	8b 55 f4             	mov    -0xc(%ebp),%edx
     ca8:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
     caf:	00 
  cmd->eargv[argc] = 0;
     cb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
     cb3:	8b 55 f4             	mov    -0xc(%ebp),%edx
     cb6:	83 c2 08             	add    $0x8,%edx
     cb9:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
     cc0:	00 
  return ret;
     cc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     cc4:	c9                   	leave  
     cc5:	c3                   	ret    

00000cc6 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     cc6:	55                   	push   %ebp
     cc7:	89 e5                	mov    %esp,%ebp
     cc9:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     ccc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     cd0:	75 0a                	jne    cdc <nulterminate+0x16>
    return 0;
     cd2:	b8 00 00 00 00       	mov    $0x0,%eax
     cd7:	e9 c9 00 00 00       	jmp    da5 <nulterminate+0xdf>
  
  switch(cmd->type){
     cdc:	8b 45 08             	mov    0x8(%ebp),%eax
     cdf:	8b 00                	mov    (%eax),%eax
     ce1:	83 f8 05             	cmp    $0x5,%eax
     ce4:	0f 87 b8 00 00 00    	ja     da2 <nulterminate+0xdc>
     cea:	8b 04 85 6c 16 00 00 	mov    0x166c(,%eax,4),%eax
     cf1:	ff e0                	jmp    *%eax
  case EXEC:
    ecmd = (struct execcmd*)cmd;
     cf3:	8b 45 08             	mov    0x8(%ebp),%eax
     cf6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(i=0; ecmd->argv[i]; i++)
     cf9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     d00:	eb 14                	jmp    d16 <nulterminate+0x50>
      *ecmd->eargv[i] = 0;
     d02:	8b 45 f0             	mov    -0x10(%ebp),%eax
     d05:	8b 55 f4             	mov    -0xc(%ebp),%edx
     d08:	83 c2 08             	add    $0x8,%edx
     d0b:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
     d0f:	c6 00 00             	movb   $0x0,(%eax)
    return 0;
  
  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     d12:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     d16:	8b 45 f0             	mov    -0x10(%ebp),%eax
     d19:	8b 55 f4             	mov    -0xc(%ebp),%edx
     d1c:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
     d20:	85 c0                	test   %eax,%eax
     d22:	75 de                	jne    d02 <nulterminate+0x3c>
      *ecmd->eargv[i] = 0;
    break;
     d24:	eb 7c                	jmp    da2 <nulterminate+0xdc>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
     d26:	8b 45 08             	mov    0x8(%ebp),%eax
     d29:	89 45 ec             	mov    %eax,-0x14(%ebp)
    nulterminate(rcmd->cmd);
     d2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
     d2f:	8b 40 04             	mov    0x4(%eax),%eax
     d32:	89 04 24             	mov    %eax,(%esp)
     d35:	e8 8c ff ff ff       	call   cc6 <nulterminate>
    *rcmd->efile = 0;
     d3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
     d3d:	8b 40 0c             	mov    0xc(%eax),%eax
     d40:	c6 00 00             	movb   $0x0,(%eax)
    break;
     d43:	eb 5d                	jmp    da2 <nulterminate+0xdc>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     d45:	8b 45 08             	mov    0x8(%ebp),%eax
     d48:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nulterminate(pcmd->left);
     d4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
     d4e:	8b 40 04             	mov    0x4(%eax),%eax
     d51:	89 04 24             	mov    %eax,(%esp)
     d54:	e8 6d ff ff ff       	call   cc6 <nulterminate>
    nulterminate(pcmd->right);
     d59:	8b 45 e8             	mov    -0x18(%ebp),%eax
     d5c:	8b 40 08             	mov    0x8(%eax),%eax
     d5f:	89 04 24             	mov    %eax,(%esp)
     d62:	e8 5f ff ff ff       	call   cc6 <nulterminate>
    break;
     d67:	eb 39                	jmp    da2 <nulterminate+0xdc>
    
  case LIST:
    lcmd = (struct listcmd*)cmd;
     d69:	8b 45 08             	mov    0x8(%ebp),%eax
     d6c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nulterminate(lcmd->left);
     d6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     d72:	8b 40 04             	mov    0x4(%eax),%eax
     d75:	89 04 24             	mov    %eax,(%esp)
     d78:	e8 49 ff ff ff       	call   cc6 <nulterminate>
    nulterminate(lcmd->right);
     d7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     d80:	8b 40 08             	mov    0x8(%eax),%eax
     d83:	89 04 24             	mov    %eax,(%esp)
     d86:	e8 3b ff ff ff       	call   cc6 <nulterminate>
    break;
     d8b:	eb 15                	jmp    da2 <nulterminate+0xdc>

  case BACK:
    bcmd = (struct backcmd*)cmd;
     d8d:	8b 45 08             	mov    0x8(%ebp),%eax
     d90:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nulterminate(bcmd->cmd);
     d93:	8b 45 e0             	mov    -0x20(%ebp),%eax
     d96:	8b 40 04             	mov    0x4(%eax),%eax
     d99:	89 04 24             	mov    %eax,(%esp)
     d9c:	e8 25 ff ff ff       	call   cc6 <nulterminate>
    break;
     da1:	90                   	nop
  }
  return cmd;
     da2:	8b 45 08             	mov    0x8(%ebp),%eax
}
     da5:	c9                   	leave  
     da6:	c3                   	ret    
     da7:	90                   	nop

00000da8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     da8:	55                   	push   %ebp
     da9:	89 e5                	mov    %esp,%ebp
     dab:	57                   	push   %edi
     dac:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     dad:	8b 4d 08             	mov    0x8(%ebp),%ecx
     db0:	8b 55 10             	mov    0x10(%ebp),%edx
     db3:	8b 45 0c             	mov    0xc(%ebp),%eax
     db6:	89 cb                	mov    %ecx,%ebx
     db8:	89 df                	mov    %ebx,%edi
     dba:	89 d1                	mov    %edx,%ecx
     dbc:	fc                   	cld    
     dbd:	f3 aa                	rep stos %al,%es:(%edi)
     dbf:	89 ca                	mov    %ecx,%edx
     dc1:	89 fb                	mov    %edi,%ebx
     dc3:	89 5d 08             	mov    %ebx,0x8(%ebp)
     dc6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     dc9:	5b                   	pop    %ebx
     dca:	5f                   	pop    %edi
     dcb:	5d                   	pop    %ebp
     dcc:	c3                   	ret    

00000dcd <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     dcd:	55                   	push   %ebp
     dce:	89 e5                	mov    %esp,%ebp
     dd0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     dd3:	8b 45 08             	mov    0x8(%ebp),%eax
     dd6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     dd9:	90                   	nop
     dda:	8b 45 0c             	mov    0xc(%ebp),%eax
     ddd:	0f b6 10             	movzbl (%eax),%edx
     de0:	8b 45 08             	mov    0x8(%ebp),%eax
     de3:	88 10                	mov    %dl,(%eax)
     de5:	8b 45 08             	mov    0x8(%ebp),%eax
     de8:	0f b6 00             	movzbl (%eax),%eax
     deb:	84 c0                	test   %al,%al
     ded:	0f 95 c0             	setne  %al
     df0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     df4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
     df8:	84 c0                	test   %al,%al
     dfa:	75 de                	jne    dda <strcpy+0xd>
    ;
  return os;
     dfc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     dff:	c9                   	leave  
     e00:	c3                   	ret    

00000e01 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     e01:	55                   	push   %ebp
     e02:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     e04:	eb 08                	jmp    e0e <strcmp+0xd>
    p++, q++;
     e06:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     e0a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     e0e:	8b 45 08             	mov    0x8(%ebp),%eax
     e11:	0f b6 00             	movzbl (%eax),%eax
     e14:	84 c0                	test   %al,%al
     e16:	74 10                	je     e28 <strcmp+0x27>
     e18:	8b 45 08             	mov    0x8(%ebp),%eax
     e1b:	0f b6 10             	movzbl (%eax),%edx
     e1e:	8b 45 0c             	mov    0xc(%ebp),%eax
     e21:	0f b6 00             	movzbl (%eax),%eax
     e24:	38 c2                	cmp    %al,%dl
     e26:	74 de                	je     e06 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     e28:	8b 45 08             	mov    0x8(%ebp),%eax
     e2b:	0f b6 00             	movzbl (%eax),%eax
     e2e:	0f b6 d0             	movzbl %al,%edx
     e31:	8b 45 0c             	mov    0xc(%ebp),%eax
     e34:	0f b6 00             	movzbl (%eax),%eax
     e37:	0f b6 c0             	movzbl %al,%eax
     e3a:	89 d1                	mov    %edx,%ecx
     e3c:	29 c1                	sub    %eax,%ecx
     e3e:	89 c8                	mov    %ecx,%eax
}
     e40:	5d                   	pop    %ebp
     e41:	c3                   	ret    

00000e42 <strlen>:

uint
strlen(char *s)
{
     e42:	55                   	push   %ebp
     e43:	89 e5                	mov    %esp,%ebp
     e45:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     e48:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     e4f:	eb 04                	jmp    e55 <strlen+0x13>
     e51:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     e55:	8b 45 fc             	mov    -0x4(%ebp),%eax
     e58:	03 45 08             	add    0x8(%ebp),%eax
     e5b:	0f b6 00             	movzbl (%eax),%eax
     e5e:	84 c0                	test   %al,%al
     e60:	75 ef                	jne    e51 <strlen+0xf>
    ;
  return n;
     e62:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     e65:	c9                   	leave  
     e66:	c3                   	ret    

00000e67 <memset>:

void*
memset(void *dst, int c, uint n)
{
     e67:	55                   	push   %ebp
     e68:	89 e5                	mov    %esp,%ebp
     e6a:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
     e6d:	8b 45 10             	mov    0x10(%ebp),%eax
     e70:	89 44 24 08          	mov    %eax,0x8(%esp)
     e74:	8b 45 0c             	mov    0xc(%ebp),%eax
     e77:	89 44 24 04          	mov    %eax,0x4(%esp)
     e7b:	8b 45 08             	mov    0x8(%ebp),%eax
     e7e:	89 04 24             	mov    %eax,(%esp)
     e81:	e8 22 ff ff ff       	call   da8 <stosb>
  return dst;
     e86:	8b 45 08             	mov    0x8(%ebp),%eax
}
     e89:	c9                   	leave  
     e8a:	c3                   	ret    

00000e8b <strchr>:

char*
strchr(const char *s, char c)
{
     e8b:	55                   	push   %ebp
     e8c:	89 e5                	mov    %esp,%ebp
     e8e:	83 ec 04             	sub    $0x4,%esp
     e91:	8b 45 0c             	mov    0xc(%ebp),%eax
     e94:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     e97:	eb 14                	jmp    ead <strchr+0x22>
    if(*s == c)
     e99:	8b 45 08             	mov    0x8(%ebp),%eax
     e9c:	0f b6 00             	movzbl (%eax),%eax
     e9f:	3a 45 fc             	cmp    -0x4(%ebp),%al
     ea2:	75 05                	jne    ea9 <strchr+0x1e>
      return (char*)s;
     ea4:	8b 45 08             	mov    0x8(%ebp),%eax
     ea7:	eb 13                	jmp    ebc <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     ea9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     ead:	8b 45 08             	mov    0x8(%ebp),%eax
     eb0:	0f b6 00             	movzbl (%eax),%eax
     eb3:	84 c0                	test   %al,%al
     eb5:	75 e2                	jne    e99 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     eb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
     ebc:	c9                   	leave  
     ebd:	c3                   	ret    

00000ebe <gets>:

char*
gets(char *buf, int max)
{
     ebe:	55                   	push   %ebp
     ebf:	89 e5                	mov    %esp,%ebp
     ec1:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     ec4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     ecb:	eb 44                	jmp    f11 <gets+0x53>
    cc = read(0, &c, 1);
     ecd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     ed4:	00 
     ed5:	8d 45 ef             	lea    -0x11(%ebp),%eax
     ed8:	89 44 24 04          	mov    %eax,0x4(%esp)
     edc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     ee3:	e8 3c 01 00 00       	call   1024 <read>
     ee8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     eeb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     eef:	7e 2d                	jle    f1e <gets+0x60>
      break;
    buf[i++] = c;
     ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ef4:	03 45 08             	add    0x8(%ebp),%eax
     ef7:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
     efb:	88 10                	mov    %dl,(%eax)
     efd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
     f01:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     f05:	3c 0a                	cmp    $0xa,%al
     f07:	74 16                	je     f1f <gets+0x61>
     f09:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
     f0d:	3c 0d                	cmp    $0xd,%al
     f0f:	74 0e                	je     f1f <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f14:	83 c0 01             	add    $0x1,%eax
     f17:	3b 45 0c             	cmp    0xc(%ebp),%eax
     f1a:	7c b1                	jl     ecd <gets+0xf>
     f1c:	eb 01                	jmp    f1f <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
     f1e:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     f1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f22:	03 45 08             	add    0x8(%ebp),%eax
     f25:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
     f28:	8b 45 08             	mov    0x8(%ebp),%eax
}
     f2b:	c9                   	leave  
     f2c:	c3                   	ret    

00000f2d <stat>:

int
stat(char *n, struct stat *st)
{
     f2d:	55                   	push   %ebp
     f2e:	89 e5                	mov    %esp,%ebp
     f30:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     f33:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     f3a:	00 
     f3b:	8b 45 08             	mov    0x8(%ebp),%eax
     f3e:	89 04 24             	mov    %eax,(%esp)
     f41:	e8 06 01 00 00       	call   104c <open>
     f46:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
     f49:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     f4d:	79 07                	jns    f56 <stat+0x29>
    return -1;
     f4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     f54:	eb 23                	jmp    f79 <stat+0x4c>
  r = fstat(fd, st);
     f56:	8b 45 0c             	mov    0xc(%ebp),%eax
     f59:	89 44 24 04          	mov    %eax,0x4(%esp)
     f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f60:	89 04 24             	mov    %eax,(%esp)
     f63:	e8 fc 00 00 00       	call   1064 <fstat>
     f68:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f6e:	89 04 24             	mov    %eax,(%esp)
     f71:	e8 be 00 00 00       	call   1034 <close>
  return r;
     f76:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     f79:	c9                   	leave  
     f7a:	c3                   	ret    

00000f7b <atoi>:

int
atoi(const char *s)
{
     f7b:	55                   	push   %ebp
     f7c:	89 e5                	mov    %esp,%ebp
     f7e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
     f81:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
     f88:	eb 23                	jmp    fad <atoi+0x32>
    n = n*10 + *s++ - '0';
     f8a:	8b 55 fc             	mov    -0x4(%ebp),%edx
     f8d:	89 d0                	mov    %edx,%eax
     f8f:	c1 e0 02             	shl    $0x2,%eax
     f92:	01 d0                	add    %edx,%eax
     f94:	01 c0                	add    %eax,%eax
     f96:	89 c2                	mov    %eax,%edx
     f98:	8b 45 08             	mov    0x8(%ebp),%eax
     f9b:	0f b6 00             	movzbl (%eax),%eax
     f9e:	0f be c0             	movsbl %al,%eax
     fa1:	01 d0                	add    %edx,%eax
     fa3:	83 e8 30             	sub    $0x30,%eax
     fa6:	89 45 fc             	mov    %eax,-0x4(%ebp)
     fa9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     fad:	8b 45 08             	mov    0x8(%ebp),%eax
     fb0:	0f b6 00             	movzbl (%eax),%eax
     fb3:	3c 2f                	cmp    $0x2f,%al
     fb5:	7e 0a                	jle    fc1 <atoi+0x46>
     fb7:	8b 45 08             	mov    0x8(%ebp),%eax
     fba:	0f b6 00             	movzbl (%eax),%eax
     fbd:	3c 39                	cmp    $0x39,%al
     fbf:	7e c9                	jle    f8a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
     fc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     fc4:	c9                   	leave  
     fc5:	c3                   	ret    

00000fc6 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
     fc6:	55                   	push   %ebp
     fc7:	89 e5                	mov    %esp,%ebp
     fc9:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
     fcc:	8b 45 08             	mov    0x8(%ebp),%eax
     fcf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
     fd2:	8b 45 0c             	mov    0xc(%ebp),%eax
     fd5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
     fd8:	eb 13                	jmp    fed <memmove+0x27>
    *dst++ = *src++;
     fda:	8b 45 f8             	mov    -0x8(%ebp),%eax
     fdd:	0f b6 10             	movzbl (%eax),%edx
     fe0:	8b 45 fc             	mov    -0x4(%ebp),%eax
     fe3:	88 10                	mov    %dl,(%eax)
     fe5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     fe9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
     fed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     ff1:	0f 9f c0             	setg   %al
     ff4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
     ff8:	84 c0                	test   %al,%al
     ffa:	75 de                	jne    fda <memmove+0x14>
    *dst++ = *src++;
  return vdst;
     ffc:	8b 45 08             	mov    0x8(%ebp),%eax
}
     fff:	c9                   	leave  
    1000:	c3                   	ret    
    1001:	90                   	nop
    1002:	90                   	nop
    1003:	90                   	nop

00001004 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    1004:	b8 01 00 00 00       	mov    $0x1,%eax
    1009:	cd 40                	int    $0x40
    100b:	c3                   	ret    

0000100c <exit>:
SYSCALL(exit)
    100c:	b8 02 00 00 00       	mov    $0x2,%eax
    1011:	cd 40                	int    $0x40
    1013:	c3                   	ret    

00001014 <wait>:
SYSCALL(wait)
    1014:	b8 03 00 00 00       	mov    $0x3,%eax
    1019:	cd 40                	int    $0x40
    101b:	c3                   	ret    

0000101c <pipe>:
SYSCALL(pipe)
    101c:	b8 04 00 00 00       	mov    $0x4,%eax
    1021:	cd 40                	int    $0x40
    1023:	c3                   	ret    

00001024 <read>:
SYSCALL(read)
    1024:	b8 05 00 00 00       	mov    $0x5,%eax
    1029:	cd 40                	int    $0x40
    102b:	c3                   	ret    

0000102c <write>:
SYSCALL(write)
    102c:	b8 10 00 00 00       	mov    $0x10,%eax
    1031:	cd 40                	int    $0x40
    1033:	c3                   	ret    

00001034 <close>:
SYSCALL(close)
    1034:	b8 15 00 00 00       	mov    $0x15,%eax
    1039:	cd 40                	int    $0x40
    103b:	c3                   	ret    

0000103c <kill>:
SYSCALL(kill)
    103c:	b8 06 00 00 00       	mov    $0x6,%eax
    1041:	cd 40                	int    $0x40
    1043:	c3                   	ret    

00001044 <exec>:
SYSCALL(exec)
    1044:	b8 07 00 00 00       	mov    $0x7,%eax
    1049:	cd 40                	int    $0x40
    104b:	c3                   	ret    

0000104c <open>:
SYSCALL(open)
    104c:	b8 0f 00 00 00       	mov    $0xf,%eax
    1051:	cd 40                	int    $0x40
    1053:	c3                   	ret    

00001054 <mknod>:
SYSCALL(mknod)
    1054:	b8 11 00 00 00       	mov    $0x11,%eax
    1059:	cd 40                	int    $0x40
    105b:	c3                   	ret    

0000105c <unlink>:
SYSCALL(unlink)
    105c:	b8 12 00 00 00       	mov    $0x12,%eax
    1061:	cd 40                	int    $0x40
    1063:	c3                   	ret    

00001064 <fstat>:
SYSCALL(fstat)
    1064:	b8 08 00 00 00       	mov    $0x8,%eax
    1069:	cd 40                	int    $0x40
    106b:	c3                   	ret    

0000106c <link>:
SYSCALL(link)
    106c:	b8 13 00 00 00       	mov    $0x13,%eax
    1071:	cd 40                	int    $0x40
    1073:	c3                   	ret    

00001074 <mkdir>:
SYSCALL(mkdir)
    1074:	b8 14 00 00 00       	mov    $0x14,%eax
    1079:	cd 40                	int    $0x40
    107b:	c3                   	ret    

0000107c <chdir>:
SYSCALL(chdir)
    107c:	b8 09 00 00 00       	mov    $0x9,%eax
    1081:	cd 40                	int    $0x40
    1083:	c3                   	ret    

00001084 <dup>:
SYSCALL(dup)
    1084:	b8 0a 00 00 00       	mov    $0xa,%eax
    1089:	cd 40                	int    $0x40
    108b:	c3                   	ret    

0000108c <getpid>:
SYSCALL(getpid)
    108c:	b8 0b 00 00 00       	mov    $0xb,%eax
    1091:	cd 40                	int    $0x40
    1093:	c3                   	ret    

00001094 <sbrk>:
SYSCALL(sbrk)
    1094:	b8 0c 00 00 00       	mov    $0xc,%eax
    1099:	cd 40                	int    $0x40
    109b:	c3                   	ret    

0000109c <sleep>:
SYSCALL(sleep)
    109c:	b8 0d 00 00 00       	mov    $0xd,%eax
    10a1:	cd 40                	int    $0x40
    10a3:	c3                   	ret    

000010a4 <uptime>:
SYSCALL(uptime)
    10a4:	b8 0e 00 00 00       	mov    $0xe,%eax
    10a9:	cd 40                	int    $0x40
    10ab:	c3                   	ret    

000010ac <waitpid>:
SYSCALL(waitpid)
    10ac:	b8 16 00 00 00       	mov    $0x16,%eax
    10b1:	cd 40                	int    $0x40
    10b3:	c3                   	ret    

000010b4 <forkjob>:
    10b4:	b8 17 00 00 00       	mov    $0x17,%eax
    10b9:	cd 40                	int    $0x40
    10bb:	c3                   	ret    

000010bc <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    10bc:	55                   	push   %ebp
    10bd:	89 e5                	mov    %esp,%ebp
    10bf:	83 ec 28             	sub    $0x28,%esp
    10c2:	8b 45 0c             	mov    0xc(%ebp),%eax
    10c5:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    10c8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    10cf:	00 
    10d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
    10d3:	89 44 24 04          	mov    %eax,0x4(%esp)
    10d7:	8b 45 08             	mov    0x8(%ebp),%eax
    10da:	89 04 24             	mov    %eax,(%esp)
    10dd:	e8 4a ff ff ff       	call   102c <write>
}
    10e2:	c9                   	leave  
    10e3:	c3                   	ret    

000010e4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    10e4:	55                   	push   %ebp
    10e5:	89 e5                	mov    %esp,%ebp
    10e7:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    10ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    10f1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    10f5:	74 17                	je     110e <printint+0x2a>
    10f7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    10fb:	79 11                	jns    110e <printint+0x2a>
    neg = 1;
    10fd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1104:	8b 45 0c             	mov    0xc(%ebp),%eax
    1107:	f7 d8                	neg    %eax
    1109:	89 45 ec             	mov    %eax,-0x14(%ebp)
    110c:	eb 06                	jmp    1114 <printint+0x30>
  } else {
    x = xx;
    110e:	8b 45 0c             	mov    0xc(%ebp),%eax
    1111:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    1114:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    111b:	8b 4d 10             	mov    0x10(%ebp),%ecx
    111e:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1121:	ba 00 00 00 00       	mov    $0x0,%edx
    1126:	f7 f1                	div    %ecx
    1128:	89 d0                	mov    %edx,%eax
    112a:	0f b6 90 34 1b 00 00 	movzbl 0x1b34(%eax),%edx
    1131:	8d 45 dc             	lea    -0x24(%ebp),%eax
    1134:	03 45 f4             	add    -0xc(%ebp),%eax
    1137:	88 10                	mov    %dl,(%eax)
    1139:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
    113d:	8b 55 10             	mov    0x10(%ebp),%edx
    1140:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    1143:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1146:	ba 00 00 00 00       	mov    $0x0,%edx
    114b:	f7 75 d4             	divl   -0x2c(%ebp)
    114e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1151:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1155:	75 c4                	jne    111b <printint+0x37>
  if(neg)
    1157:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    115b:	74 2a                	je     1187 <printint+0xa3>
    buf[i++] = '-';
    115d:	8d 45 dc             	lea    -0x24(%ebp),%eax
    1160:	03 45 f4             	add    -0xc(%ebp),%eax
    1163:	c6 00 2d             	movb   $0x2d,(%eax)
    1166:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
    116a:	eb 1b                	jmp    1187 <printint+0xa3>
    putc(fd, buf[i]);
    116c:	8d 45 dc             	lea    -0x24(%ebp),%eax
    116f:	03 45 f4             	add    -0xc(%ebp),%eax
    1172:	0f b6 00             	movzbl (%eax),%eax
    1175:	0f be c0             	movsbl %al,%eax
    1178:	89 44 24 04          	mov    %eax,0x4(%esp)
    117c:	8b 45 08             	mov    0x8(%ebp),%eax
    117f:	89 04 24             	mov    %eax,(%esp)
    1182:	e8 35 ff ff ff       	call   10bc <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    1187:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    118b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    118f:	79 db                	jns    116c <printint+0x88>
    putc(fd, buf[i]);
}
    1191:	c9                   	leave  
    1192:	c3                   	ret    

00001193 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    1193:	55                   	push   %ebp
    1194:	89 e5                	mov    %esp,%ebp
    1196:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    1199:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    11a0:	8d 45 0c             	lea    0xc(%ebp),%eax
    11a3:	83 c0 04             	add    $0x4,%eax
    11a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    11a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    11b0:	e9 7d 01 00 00       	jmp    1332 <printf+0x19f>
    c = fmt[i] & 0xff;
    11b5:	8b 55 0c             	mov    0xc(%ebp),%edx
    11b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
    11bb:	01 d0                	add    %edx,%eax
    11bd:	0f b6 00             	movzbl (%eax),%eax
    11c0:	0f be c0             	movsbl %al,%eax
    11c3:	25 ff 00 00 00       	and    $0xff,%eax
    11c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    11cb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    11cf:	75 2c                	jne    11fd <printf+0x6a>
      if(c == '%'){
    11d1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    11d5:	75 0c                	jne    11e3 <printf+0x50>
        state = '%';
    11d7:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    11de:	e9 4b 01 00 00       	jmp    132e <printf+0x19b>
      } else {
        putc(fd, c);
    11e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    11e6:	0f be c0             	movsbl %al,%eax
    11e9:	89 44 24 04          	mov    %eax,0x4(%esp)
    11ed:	8b 45 08             	mov    0x8(%ebp),%eax
    11f0:	89 04 24             	mov    %eax,(%esp)
    11f3:	e8 c4 fe ff ff       	call   10bc <putc>
    11f8:	e9 31 01 00 00       	jmp    132e <printf+0x19b>
      }
    } else if(state == '%'){
    11fd:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1201:	0f 85 27 01 00 00    	jne    132e <printf+0x19b>
      if(c == 'd'){
    1207:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    120b:	75 2d                	jne    123a <printf+0xa7>
        printint(fd, *ap, 10, 1);
    120d:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1210:	8b 00                	mov    (%eax),%eax
    1212:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    1219:	00 
    121a:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1221:	00 
    1222:	89 44 24 04          	mov    %eax,0x4(%esp)
    1226:	8b 45 08             	mov    0x8(%ebp),%eax
    1229:	89 04 24             	mov    %eax,(%esp)
    122c:	e8 b3 fe ff ff       	call   10e4 <printint>
        ap++;
    1231:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1235:	e9 ed 00 00 00       	jmp    1327 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
    123a:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    123e:	74 06                	je     1246 <printf+0xb3>
    1240:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    1244:	75 2d                	jne    1273 <printf+0xe0>
        printint(fd, *ap, 16, 0);
    1246:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1249:	8b 00                	mov    (%eax),%eax
    124b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    1252:	00 
    1253:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    125a:	00 
    125b:	89 44 24 04          	mov    %eax,0x4(%esp)
    125f:	8b 45 08             	mov    0x8(%ebp),%eax
    1262:	89 04 24             	mov    %eax,(%esp)
    1265:	e8 7a fe ff ff       	call   10e4 <printint>
        ap++;
    126a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    126e:	e9 b4 00 00 00       	jmp    1327 <printf+0x194>
      } else if(c == 's'){
    1273:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    1277:	75 46                	jne    12bf <printf+0x12c>
        s = (char*)*ap;
    1279:	8b 45 e8             	mov    -0x18(%ebp),%eax
    127c:	8b 00                	mov    (%eax),%eax
    127e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    1281:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    1285:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1289:	75 27                	jne    12b2 <printf+0x11f>
          s = "(null)";
    128b:	c7 45 f4 84 16 00 00 	movl   $0x1684,-0xc(%ebp)
        while(*s != 0){
    1292:	eb 1e                	jmp    12b2 <printf+0x11f>
          putc(fd, *s);
    1294:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1297:	0f b6 00             	movzbl (%eax),%eax
    129a:	0f be c0             	movsbl %al,%eax
    129d:	89 44 24 04          	mov    %eax,0x4(%esp)
    12a1:	8b 45 08             	mov    0x8(%ebp),%eax
    12a4:	89 04 24             	mov    %eax,(%esp)
    12a7:	e8 10 fe ff ff       	call   10bc <putc>
          s++;
    12ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    12b0:	eb 01                	jmp    12b3 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    12b2:	90                   	nop
    12b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12b6:	0f b6 00             	movzbl (%eax),%eax
    12b9:	84 c0                	test   %al,%al
    12bb:	75 d7                	jne    1294 <printf+0x101>
    12bd:	eb 68                	jmp    1327 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    12bf:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    12c3:	75 1d                	jne    12e2 <printf+0x14f>
        putc(fd, *ap);
    12c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
    12c8:	8b 00                	mov    (%eax),%eax
    12ca:	0f be c0             	movsbl %al,%eax
    12cd:	89 44 24 04          	mov    %eax,0x4(%esp)
    12d1:	8b 45 08             	mov    0x8(%ebp),%eax
    12d4:	89 04 24             	mov    %eax,(%esp)
    12d7:	e8 e0 fd ff ff       	call   10bc <putc>
        ap++;
    12dc:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    12e0:	eb 45                	jmp    1327 <printf+0x194>
      } else if(c == '%'){
    12e2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    12e6:	75 17                	jne    12ff <printf+0x16c>
        putc(fd, c);
    12e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    12eb:	0f be c0             	movsbl %al,%eax
    12ee:	89 44 24 04          	mov    %eax,0x4(%esp)
    12f2:	8b 45 08             	mov    0x8(%ebp),%eax
    12f5:	89 04 24             	mov    %eax,(%esp)
    12f8:	e8 bf fd ff ff       	call   10bc <putc>
    12fd:	eb 28                	jmp    1327 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    12ff:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    1306:	00 
    1307:	8b 45 08             	mov    0x8(%ebp),%eax
    130a:	89 04 24             	mov    %eax,(%esp)
    130d:	e8 aa fd ff ff       	call   10bc <putc>
        putc(fd, c);
    1312:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1315:	0f be c0             	movsbl %al,%eax
    1318:	89 44 24 04          	mov    %eax,0x4(%esp)
    131c:	8b 45 08             	mov    0x8(%ebp),%eax
    131f:	89 04 24             	mov    %eax,(%esp)
    1322:	e8 95 fd ff ff       	call   10bc <putc>
      }
      state = 0;
    1327:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    132e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    1332:	8b 55 0c             	mov    0xc(%ebp),%edx
    1335:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1338:	01 d0                	add    %edx,%eax
    133a:	0f b6 00             	movzbl (%eax),%eax
    133d:	84 c0                	test   %al,%al
    133f:	0f 85 70 fe ff ff    	jne    11b5 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    1345:	c9                   	leave  
    1346:	c3                   	ret    
    1347:	90                   	nop

00001348 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1348:	55                   	push   %ebp
    1349:	89 e5                	mov    %esp,%ebp
    134b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    134e:	8b 45 08             	mov    0x8(%ebp),%eax
    1351:	83 e8 08             	sub    $0x8,%eax
    1354:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1357:	a1 cc 1b 00 00       	mov    0x1bcc,%eax
    135c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    135f:	eb 24                	jmp    1385 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1361:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1364:	8b 00                	mov    (%eax),%eax
    1366:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1369:	77 12                	ja     137d <free+0x35>
    136b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    136e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1371:	77 24                	ja     1397 <free+0x4f>
    1373:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1376:	8b 00                	mov    (%eax),%eax
    1378:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    137b:	77 1a                	ja     1397 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    137d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1380:	8b 00                	mov    (%eax),%eax
    1382:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1385:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1388:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    138b:	76 d4                	jbe    1361 <free+0x19>
    138d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1390:	8b 00                	mov    (%eax),%eax
    1392:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1395:	76 ca                	jbe    1361 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    1397:	8b 45 f8             	mov    -0x8(%ebp),%eax
    139a:	8b 40 04             	mov    0x4(%eax),%eax
    139d:	c1 e0 03             	shl    $0x3,%eax
    13a0:	89 c2                	mov    %eax,%edx
    13a2:	03 55 f8             	add    -0x8(%ebp),%edx
    13a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13a8:	8b 00                	mov    (%eax),%eax
    13aa:	39 c2                	cmp    %eax,%edx
    13ac:	75 24                	jne    13d2 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
    13ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
    13b1:	8b 50 04             	mov    0x4(%eax),%edx
    13b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13b7:	8b 00                	mov    (%eax),%eax
    13b9:	8b 40 04             	mov    0x4(%eax),%eax
    13bc:	01 c2                	add    %eax,%edx
    13be:	8b 45 f8             	mov    -0x8(%ebp),%eax
    13c1:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    13c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13c7:	8b 00                	mov    (%eax),%eax
    13c9:	8b 10                	mov    (%eax),%edx
    13cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
    13ce:	89 10                	mov    %edx,(%eax)
    13d0:	eb 0a                	jmp    13dc <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
    13d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13d5:	8b 10                	mov    (%eax),%edx
    13d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
    13da:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    13dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13df:	8b 40 04             	mov    0x4(%eax),%eax
    13e2:	c1 e0 03             	shl    $0x3,%eax
    13e5:	03 45 fc             	add    -0x4(%ebp),%eax
    13e8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    13eb:	75 20                	jne    140d <free+0xc5>
    p->s.size += bp->s.size;
    13ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13f0:	8b 50 04             	mov    0x4(%eax),%edx
    13f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
    13f6:	8b 40 04             	mov    0x4(%eax),%eax
    13f9:	01 c2                	add    %eax,%edx
    13fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
    13fe:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    1401:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1404:	8b 10                	mov    (%eax),%edx
    1406:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1409:	89 10                	mov    %edx,(%eax)
    140b:	eb 08                	jmp    1415 <free+0xcd>
  } else
    p->s.ptr = bp;
    140d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1410:	8b 55 f8             	mov    -0x8(%ebp),%edx
    1413:	89 10                	mov    %edx,(%eax)
  freep = p;
    1415:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1418:	a3 cc 1b 00 00       	mov    %eax,0x1bcc
}
    141d:	c9                   	leave  
    141e:	c3                   	ret    

0000141f <morecore>:

static Header*
morecore(uint nu)
{
    141f:	55                   	push   %ebp
    1420:	89 e5                	mov    %esp,%ebp
    1422:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    1425:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    142c:	77 07                	ja     1435 <morecore+0x16>
    nu = 4096;
    142e:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    1435:	8b 45 08             	mov    0x8(%ebp),%eax
    1438:	c1 e0 03             	shl    $0x3,%eax
    143b:	89 04 24             	mov    %eax,(%esp)
    143e:	e8 51 fc ff ff       	call   1094 <sbrk>
    1443:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    1446:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    144a:	75 07                	jne    1453 <morecore+0x34>
    return 0;
    144c:	b8 00 00 00 00       	mov    $0x0,%eax
    1451:	eb 22                	jmp    1475 <morecore+0x56>
  hp = (Header*)p;
    1453:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1456:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1459:	8b 45 f0             	mov    -0x10(%ebp),%eax
    145c:	8b 55 08             	mov    0x8(%ebp),%edx
    145f:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    1462:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1465:	83 c0 08             	add    $0x8,%eax
    1468:	89 04 24             	mov    %eax,(%esp)
    146b:	e8 d8 fe ff ff       	call   1348 <free>
  return freep;
    1470:	a1 cc 1b 00 00       	mov    0x1bcc,%eax
}
    1475:	c9                   	leave  
    1476:	c3                   	ret    

00001477 <malloc>:

void*
malloc(uint nbytes)
{
    1477:	55                   	push   %ebp
    1478:	89 e5                	mov    %esp,%ebp
    147a:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    147d:	8b 45 08             	mov    0x8(%ebp),%eax
    1480:	83 c0 07             	add    $0x7,%eax
    1483:	c1 e8 03             	shr    $0x3,%eax
    1486:	83 c0 01             	add    $0x1,%eax
    1489:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    148c:	a1 cc 1b 00 00       	mov    0x1bcc,%eax
    1491:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1494:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1498:	75 23                	jne    14bd <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    149a:	c7 45 f0 c4 1b 00 00 	movl   $0x1bc4,-0x10(%ebp)
    14a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    14a4:	a3 cc 1b 00 00       	mov    %eax,0x1bcc
    14a9:	a1 cc 1b 00 00       	mov    0x1bcc,%eax
    14ae:	a3 c4 1b 00 00       	mov    %eax,0x1bc4
    base.s.size = 0;
    14b3:	c7 05 c8 1b 00 00 00 	movl   $0x0,0x1bc8
    14ba:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    14bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
    14c0:	8b 00                	mov    (%eax),%eax
    14c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    14c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14c8:	8b 40 04             	mov    0x4(%eax),%eax
    14cb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    14ce:	72 4d                	jb     151d <malloc+0xa6>
      if(p->s.size == nunits)
    14d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14d3:	8b 40 04             	mov    0x4(%eax),%eax
    14d6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    14d9:	75 0c                	jne    14e7 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    14db:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14de:	8b 10                	mov    (%eax),%edx
    14e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
    14e3:	89 10                	mov    %edx,(%eax)
    14e5:	eb 26                	jmp    150d <malloc+0x96>
      else {
        p->s.size -= nunits;
    14e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14ea:	8b 40 04             	mov    0x4(%eax),%eax
    14ed:	89 c2                	mov    %eax,%edx
    14ef:	2b 55 ec             	sub    -0x14(%ebp),%edx
    14f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14f5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    14f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14fb:	8b 40 04             	mov    0x4(%eax),%eax
    14fe:	c1 e0 03             	shl    $0x3,%eax
    1501:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    1504:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1507:	8b 55 ec             	mov    -0x14(%ebp),%edx
    150a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    150d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1510:	a3 cc 1b 00 00       	mov    %eax,0x1bcc
      return (void*)(p + 1);
    1515:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1518:	83 c0 08             	add    $0x8,%eax
    151b:	eb 38                	jmp    1555 <malloc+0xde>
    }
    if(p == freep)
    151d:	a1 cc 1b 00 00       	mov    0x1bcc,%eax
    1522:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    1525:	75 1b                	jne    1542 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    1527:	8b 45 ec             	mov    -0x14(%ebp),%eax
    152a:	89 04 24             	mov    %eax,(%esp)
    152d:	e8 ed fe ff ff       	call   141f <morecore>
    1532:	89 45 f4             	mov    %eax,-0xc(%ebp)
    1535:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1539:	75 07                	jne    1542 <malloc+0xcb>
        return 0;
    153b:	b8 00 00 00 00       	mov    $0x0,%eax
    1540:	eb 13                	jmp    1555 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1542:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1545:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1548:	8b 45 f4             	mov    -0xc(%ebp),%eax
    154b:	8b 00                	mov    (%eax),%eax
    154d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1550:	e9 70 ff ff ff       	jmp    14c5 <malloc+0x4e>
}
    1555:	c9                   	leave  
    1556:	c3                   	ret    
