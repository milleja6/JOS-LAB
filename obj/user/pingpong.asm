
obj/user/pingpong：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 bd 10 00 00       	call   8010ff <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 0c 0d 00 00       	call   800d5c <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 c0 17 80 00 	movl   $0x8017c0,(%esp)
  80005f:	e8 bf 01 00 00       	call   800223 <cprintf>
		ipc_send(who, 0, 0, 0);
  800064:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007b:	00 
  80007c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 cb 12 00 00       	call   801352 <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 34 24             	mov    %esi,(%esp)
  80009d:	e8 8e 12 00 00       	call   801330 <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000a7:	e8 b0 0c 00 00       	call   800d5c <sys_getenvid>
  8000ac:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 d6 17 80 00 	movl   $0x8017d6,(%esp)
  8000bf:	e8 5f 01 00 00       	call   800223 <cprintf>
		if (i == 10)
  8000c4:	83 fb 0a             	cmp    $0xa,%ebx
  8000c7:	74 27                	je     8000f0 <umain+0xbc>
			return;
		i++;
  8000c9:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d3:	00 
  8000d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000db:	00 
  8000dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e3:	89 04 24             	mov    %eax,(%esp)
  8000e6:	e8 67 12 00 00       	call   801352 <ipc_send>
		if (i == 10)
  8000eb:	83 fb 0a             	cmp    $0xa,%ebx
  8000ee:	75 9a                	jne    80008a <umain+0x56>
			return;
	}

}
  8000f0:	83 c4 2c             	add    $0x2c,%esp
  8000f3:	5b                   	pop    %ebx
  8000f4:	5e                   	pop    %esi
  8000f5:	5f                   	pop    %edi
  8000f6:	5d                   	pop    %ebp
  8000f7:	c3                   	ret    

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	57                   	push   %edi
  8000fc:	56                   	push   %esi
  8000fd:	53                   	push   %ebx
  8000fe:	83 ec 1c             	sub    $0x1c,%esp
  800101:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800104:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t thisid = sys_getenvid();
  800107:	e8 50 0c 00 00       	call   800d5c <sys_getenvid>
	thisenv = envs;
  80010c:	c7 05 04 20 80 00 00 	movl   $0xeec00000,0x802004
  800113:	00 c0 ee 
	for(;thisenv;thisenv++)
		if(thisenv -> env_id == thisid)
  800116:	8b 15 48 00 c0 ee    	mov    0xeec00048,%edx
  80011c:	39 c2                	cmp    %eax,%edx
  80011e:	74 25                	je     800145 <libmain+0x4d>
  800120:	ba 7c 00 c0 ee       	mov    $0xeec0007c,%edx
  800125:	eb 12                	jmp    800139 <libmain+0x41>
  800127:	8b 4a 48             	mov    0x48(%edx),%ecx
  80012a:	83 c2 7c             	add    $0x7c,%edx
  80012d:	39 c1                	cmp    %eax,%ecx
  80012f:	75 08                	jne    800139 <libmain+0x41>
  800131:	89 3d 04 20 80 00    	mov    %edi,0x802004
  800137:	eb 0c                	jmp    800145 <libmain+0x4d>
{
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t thisid = sys_getenvid();
	thisenv = envs;
	for(;thisenv;thisenv++)
  800139:	89 d7                	mov    %edx,%edi
  80013b:	85 d2                	test   %edx,%edx
  80013d:	75 e8                	jne    800127 <libmain+0x2f>
  80013f:	89 15 04 20 80 00    	mov    %edx,0x802004
		if(thisenv -> env_id == thisid)
			break;

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800145:	85 db                	test   %ebx,%ebx
  800147:	7e 07                	jle    800150 <libmain+0x58>
		binaryname = argv[0];
  800149:	8b 06                	mov    (%esi),%eax
  80014b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800150:	89 74 24 04          	mov    %esi,0x4(%esp)
  800154:	89 1c 24             	mov    %ebx,(%esp)
  800157:	e8 d8 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80015c:	e8 0b 00 00 00       	call   80016c <exit>
}
  800161:	83 c4 1c             	add    $0x1c,%esp
  800164:	5b                   	pop    %ebx
  800165:	5e                   	pop    %esi
  800166:	5f                   	pop    %edi
  800167:	5d                   	pop    %ebp
  800168:	c3                   	ret    
  800169:	66 90                	xchg   %ax,%ax
  80016b:	90                   	nop

0080016c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800172:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800179:	e8 81 0b 00 00       	call   800cff <sys_env_destroy>
}
  80017e:	c9                   	leave  
  80017f:	c3                   	ret    

00800180 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	53                   	push   %ebx
  800184:	83 ec 14             	sub    $0x14,%esp
  800187:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018a:	8b 03                	mov    (%ebx),%eax
  80018c:	8b 55 08             	mov    0x8(%ebp),%edx
  80018f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800193:	83 c0 01             	add    $0x1,%eax
  800196:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800198:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019d:	75 19                	jne    8001b8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80019f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001a6:	00 
  8001a7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001aa:	89 04 24             	mov    %eax,(%esp)
  8001ad:	e8 ee 0a 00 00       	call   800ca0 <sys_cputs>
		b->idx = 0;
  8001b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001b8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bc:	83 c4 14             	add    $0x14,%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5d                   	pop    %ebp
  8001c1:	c3                   	ret    

008001c2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c2:	55                   	push   %ebp
  8001c3:	89 e5                	mov    %esp,%ebp
  8001c5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001cb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d2:	00 00 00 
	b.cnt = 0;
  8001d5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001dc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ed:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f7:	c7 04 24 80 01 80 00 	movl   $0x800180,(%esp)
  8001fe:	e8 af 01 00 00       	call   8003b2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800203:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800209:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800213:	89 04 24             	mov    %eax,(%esp)
  800216:	e8 85 0a 00 00       	call   800ca0 <sys_cputs>

	return b.cnt;
}
  80021b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800221:	c9                   	leave  
  800222:	c3                   	ret    

00800223 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800229:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800230:	8b 45 08             	mov    0x8(%ebp),%eax
  800233:	89 04 24             	mov    %eax,(%esp)
  800236:	e8 87 ff ff ff       	call   8001c2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80023b:	c9                   	leave  
  80023c:	c3                   	ret    
  80023d:	66 90                	xchg   %ax,%ax
  80023f:	90                   	nop

00800240 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	83 ec 4c             	sub    $0x4c,%esp
  800249:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80024c:	89 d7                	mov    %edx,%edi
  80024e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800251:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800254:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800257:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025a:	b8 00 00 00 00       	mov    $0x0,%eax
  80025f:	39 d8                	cmp    %ebx,%eax
  800261:	72 17                	jb     80027a <printnum+0x3a>
  800263:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800266:	39 5d 10             	cmp    %ebx,0x10(%ebp)
  800269:	76 0f                	jbe    80027a <printnum+0x3a>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80026b:	8b 75 14             	mov    0x14(%ebp),%esi
  80026e:	83 ee 01             	sub    $0x1,%esi
  800271:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800274:	85 f6                	test   %esi,%esi
  800276:	7f 63                	jg     8002db <printnum+0x9b>
  800278:	eb 75                	jmp    8002ef <printnum+0xaf>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027a:	8b 5d 18             	mov    0x18(%ebp),%ebx
  80027d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800281:	8b 45 14             	mov    0x14(%ebp),%eax
  800284:	83 e8 01             	sub    $0x1,%eax
  800287:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80028b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80028e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800292:	8b 44 24 08          	mov    0x8(%esp),%eax
  800296:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80029a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80029d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8002a0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002a7:	00 
  8002a8:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8002ab:	89 1c 24             	mov    %ebx,(%esp)
  8002ae:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002b5:	e8 16 12 00 00       	call   8014d0 <__udivdi3>
  8002ba:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002bd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002c0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002c4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002c8:	89 04 24             	mov    %eax,(%esp)
  8002cb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002cf:	89 fa                	mov    %edi,%edx
  8002d1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002d4:	e8 67 ff ff ff       	call   800240 <printnum>
  8002d9:	eb 14                	jmp    8002ef <printnum+0xaf>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002df:	8b 45 18             	mov    0x18(%ebp),%eax
  8002e2:	89 04 24             	mov    %eax,(%esp)
  8002e5:	ff d3                	call   *%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e7:	83 ee 01             	sub    $0x1,%esi
  8002ea:	75 ef                	jne    8002db <printnum+0x9b>
  8002ec:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ef:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002fe:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800305:	00 
  800306:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800309:	89 1c 24             	mov    %ebx,(%esp)
  80030c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80030f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800313:	e8 08 13 00 00       	call   801620 <__umoddi3>
  800318:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80031c:	0f be 80 f3 17 80 00 	movsbl 0x8017f3(%eax),%eax
  800323:	89 04 24             	mov    %eax,(%esp)
  800326:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800329:	ff d0                	call   *%eax
}
  80032b:	83 c4 4c             	add    $0x4c,%esp
  80032e:	5b                   	pop    %ebx
  80032f:	5e                   	pop    %esi
  800330:	5f                   	pop    %edi
  800331:	5d                   	pop    %ebp
  800332:	c3                   	ret    

00800333 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800333:	55                   	push   %ebp
  800334:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800336:	83 fa 01             	cmp    $0x1,%edx
  800339:	7e 0e                	jle    800349 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80033b:	8b 10                	mov    (%eax),%edx
  80033d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800340:	89 08                	mov    %ecx,(%eax)
  800342:	8b 02                	mov    (%edx),%eax
  800344:	8b 52 04             	mov    0x4(%edx),%edx
  800347:	eb 22                	jmp    80036b <getuint+0x38>
	else if (lflag)
  800349:	85 d2                	test   %edx,%edx
  80034b:	74 10                	je     80035d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80034d:	8b 10                	mov    (%eax),%edx
  80034f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800352:	89 08                	mov    %ecx,(%eax)
  800354:	8b 02                	mov    (%edx),%eax
  800356:	ba 00 00 00 00       	mov    $0x0,%edx
  80035b:	eb 0e                	jmp    80036b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80035d:	8b 10                	mov    (%eax),%edx
  80035f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800362:	89 08                	mov    %ecx,(%eax)
  800364:	8b 02                	mov    (%edx),%eax
  800366:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800373:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800377:	8b 10                	mov    (%eax),%edx
  800379:	3b 50 04             	cmp    0x4(%eax),%edx
  80037c:	73 0a                	jae    800388 <sprintputch+0x1b>
		*b->buf++ = ch;
  80037e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800381:	88 0a                	mov    %cl,(%edx)
  800383:	83 c2 01             	add    $0x1,%edx
  800386:	89 10                	mov    %edx,(%eax)
}
  800388:	5d                   	pop    %ebp
  800389:	c3                   	ret    

0080038a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
  80038d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800390:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800393:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800397:	8b 45 10             	mov    0x10(%ebp),%eax
  80039a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a8:	89 04 24             	mov    %eax,(%esp)
  8003ab:	e8 02 00 00 00       	call   8003b2 <vprintfmt>
	va_end(ap);
}
  8003b0:	c9                   	leave  
  8003b1:	c3                   	ret    

008003b2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	57                   	push   %edi
  8003b6:	56                   	push   %esi
  8003b7:	53                   	push   %ebx
  8003b8:	83 ec 4c             	sub    $0x4c,%esp
  8003bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8003be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003c1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003c4:	eb 11                	jmp    8003d7 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003c6:	85 c0                	test   %eax,%eax
  8003c8:	0f 84 db 03 00 00    	je     8007a9 <vprintfmt+0x3f7>
				return;
			putch(ch, putdat);
  8003ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003d2:	89 04 24             	mov    %eax,(%esp)
  8003d5:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d7:	0f b6 07             	movzbl (%edi),%eax
  8003da:	83 c7 01             	add    $0x1,%edi
  8003dd:	83 f8 25             	cmp    $0x25,%eax
  8003e0:	75 e4                	jne    8003c6 <vprintfmt+0x14>
  8003e2:	c6 45 e4 20          	movb   $0x20,-0x1c(%ebp)
  8003e6:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8003ed:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003f4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800400:	eb 2b                	jmp    80042d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 7d e0             	mov    -0x20(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800405:	c6 45 e4 2d          	movb   $0x2d,-0x1c(%ebp)
  800409:	eb 22                	jmp    80042d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	8b 7d e0             	mov    -0x20(%ebp),%edi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80040e:	c6 45 e4 30          	movb   $0x30,-0x1c(%ebp)
  800412:	eb 19                	jmp    80042d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 7d e0             	mov    -0x20(%ebp),%edi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800417:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80041e:	eb 0d                	jmp    80042d <vprintfmt+0x7b>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800420:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800423:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800426:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	0f b6 0f             	movzbl (%edi),%ecx
  800430:	8d 47 01             	lea    0x1(%edi),%eax
  800433:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800436:	0f b6 07             	movzbl (%edi),%eax
  800439:	83 e8 23             	sub    $0x23,%eax
  80043c:	3c 55                	cmp    $0x55,%al
  80043e:	0f 87 40 03 00 00    	ja     800784 <vprintfmt+0x3d2>
  800444:	0f b6 c0             	movzbl %al,%eax
  800447:	ff 24 85 c0 18 80 00 	jmp    *0x8018c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80044e:	83 e9 30             	sub    $0x30,%ecx
  800451:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				ch = *fmt;
  800454:	0f be 47 01          	movsbl 0x1(%edi),%eax
				if (ch < '0' || ch > '9')
  800458:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80045b:	83 f9 09             	cmp    $0x9,%ecx
  80045e:	77 57                	ja     8004b7 <vprintfmt+0x105>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800463:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800466:	8b 55 dc             	mov    -0x24(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800469:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80046c:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80046f:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800473:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800476:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800479:	83 f9 09             	cmp    $0x9,%ecx
  80047c:	76 eb                	jbe    800469 <vprintfmt+0xb7>
  80047e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800481:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800484:	eb 34                	jmp    8004ba <vprintfmt+0x108>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800486:	8b 45 14             	mov    0x14(%ebp),%eax
  800489:	8d 48 04             	lea    0x4(%eax),%ecx
  80048c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80048f:	8b 00                	mov    (%eax),%eax
  800491:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800494:	8b 7d e0             	mov    -0x20(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800497:	eb 21                	jmp    8004ba <vprintfmt+0x108>

		case '.':
			if (width < 0)
  800499:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80049d:	0f 88 71 ff ff ff    	js     800414 <vprintfmt+0x62>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004a6:	eb 85                	jmp    80042d <vprintfmt+0x7b>
  8004a8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004ab:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8004b2:	e9 76 ff ff ff       	jmp    80042d <vprintfmt+0x7b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b7:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004ba:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004be:	0f 89 69 ff ff ff    	jns    80042d <vprintfmt+0x7b>
  8004c4:	e9 57 ff ff ff       	jmp    800420 <vprintfmt+0x6e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cc:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004cf:	e9 59 ff ff ff       	jmp    80042d <vprintfmt+0x7b>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d7:	8d 50 04             	lea    0x4(%eax),%edx
  8004da:	89 55 14             	mov    %edx,0x14(%ebp)
  8004dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e1:	8b 00                	mov    (%eax),%eax
  8004e3:	89 04 24             	mov    %eax,(%esp)
  8004e6:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e8:	8b 7d e0             	mov    -0x20(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004eb:	e9 e7 fe ff ff       	jmp    8003d7 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f3:	8d 50 04             	lea    0x4(%eax),%edx
  8004f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f9:	8b 00                	mov    (%eax),%eax
  8004fb:	89 c2                	mov    %eax,%edx
  8004fd:	c1 fa 1f             	sar    $0x1f,%edx
  800500:	31 d0                	xor    %edx,%eax
  800502:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800504:	83 f8 08             	cmp    $0x8,%eax
  800507:	7f 0b                	jg     800514 <vprintfmt+0x162>
  800509:	8b 14 85 20 1a 80 00 	mov    0x801a20(,%eax,4),%edx
  800510:	85 d2                	test   %edx,%edx
  800512:	75 20                	jne    800534 <vprintfmt+0x182>
				printfmt(putch, putdat, "error %d", err);
  800514:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800518:	c7 44 24 08 0b 18 80 	movl   $0x80180b,0x8(%esp)
  80051f:	00 
  800520:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800524:	89 34 24             	mov    %esi,(%esp)
  800527:	e8 5e fe ff ff       	call   80038a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052c:	8b 7d e0             	mov    -0x20(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80052f:	e9 a3 fe ff ff       	jmp    8003d7 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800534:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800538:	c7 44 24 08 14 18 80 	movl   $0x801814,0x8(%esp)
  80053f:	00 
  800540:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800544:	89 34 24             	mov    %esi,(%esp)
  800547:	e8 3e fe ff ff       	call   80038a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80054f:	e9 83 fe ff ff       	jmp    8003d7 <vprintfmt+0x25>
  800554:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800557:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80055a:	89 7d cc             	mov    %edi,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8d 50 04             	lea    0x4(%eax),%edx
  800563:	89 55 14             	mov    %edx,0x14(%ebp)
  800566:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800568:	85 ff                	test   %edi,%edi
  80056a:	b8 04 18 80 00       	mov    $0x801804,%eax
  80056f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800572:	80 7d e4 2d          	cmpb   $0x2d,-0x1c(%ebp)
  800576:	74 06                	je     80057e <vprintfmt+0x1cc>
  800578:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80057c:	7f 16                	jg     800594 <vprintfmt+0x1e2>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057e:	0f b6 17             	movzbl (%edi),%edx
  800581:	0f be c2             	movsbl %dl,%eax
  800584:	83 c7 01             	add    $0x1,%edi
  800587:	85 c0                	test   %eax,%eax
  800589:	0f 85 9f 00 00 00    	jne    80062e <vprintfmt+0x27c>
  80058f:	e9 8b 00 00 00       	jmp    80061f <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800594:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800598:	89 3c 24             	mov    %edi,(%esp)
  80059b:	e8 c2 02 00 00       	call   800862 <strnlen>
  8005a0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005a3:	29 c2                	sub    %eax,%edx
  8005a5:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005a8:	85 d2                	test   %edx,%edx
  8005aa:	7e d2                	jle    80057e <vprintfmt+0x1cc>
					putch(padc, putdat);
  8005ac:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
  8005b0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8005b3:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005b6:	89 d7                	mov    %edx,%edi
  8005b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005bf:	89 04 24             	mov    %eax,(%esp)
  8005c2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c4:	83 ef 01             	sub    $0x1,%edi
  8005c7:	75 ef                	jne    8005b8 <vprintfmt+0x206>
  8005c9:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8005cc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005cf:	eb ad                	jmp    80057e <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005d1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005d5:	74 20                	je     8005f7 <vprintfmt+0x245>
  8005d7:	0f be d2             	movsbl %dl,%edx
  8005da:	83 ea 20             	sub    $0x20,%edx
  8005dd:	83 fa 5e             	cmp    $0x5e,%edx
  8005e0:	76 15                	jbe    8005f7 <vprintfmt+0x245>
					putch('?', putdat);
  8005e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005e9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005f0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005f3:	ff d1                	call   *%ecx
  8005f5:	eb 0f                	jmp    800606 <vprintfmt+0x254>
				else
					putch(ch, putdat);
  8005f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005fe:	89 04 24             	mov    %eax,(%esp)
  800601:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800604:	ff d1                	call   *%ecx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800606:	83 eb 01             	sub    $0x1,%ebx
  800609:	0f b6 17             	movzbl (%edi),%edx
  80060c:	0f be c2             	movsbl %dl,%eax
  80060f:	83 c7 01             	add    $0x1,%edi
  800612:	85 c0                	test   %eax,%eax
  800614:	75 24                	jne    80063a <vprintfmt+0x288>
  800616:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800619:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80061c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061f:	8b 7d e0             	mov    -0x20(%ebp),%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800622:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800626:	0f 8e ab fd ff ff    	jle    8003d7 <vprintfmt+0x25>
  80062c:	eb 20                	jmp    80064e <vprintfmt+0x29c>
  80062e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800631:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800634:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800637:	8b 5d d8             	mov    -0x28(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80063a:	85 f6                	test   %esi,%esi
  80063c:	78 93                	js     8005d1 <vprintfmt+0x21f>
  80063e:	83 ee 01             	sub    $0x1,%esi
  800641:	79 8e                	jns    8005d1 <vprintfmt+0x21f>
  800643:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800646:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800649:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80064c:	eb d1                	jmp    80061f <vprintfmt+0x26d>
  80064e:	8b 7d d8             	mov    -0x28(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800651:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800655:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80065c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065e:	83 ef 01             	sub    $0x1,%edi
  800661:	75 ee                	jne    800651 <vprintfmt+0x29f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800663:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800666:	e9 6c fd ff ff       	jmp    8003d7 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066b:	83 fa 01             	cmp    $0x1,%edx
  80066e:	66 90                	xchg   %ax,%ax
  800670:	7e 16                	jle    800688 <vprintfmt+0x2d6>
		return va_arg(*ap, long long);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8d 50 08             	lea    0x8(%eax),%edx
  800678:	89 55 14             	mov    %edx,0x14(%ebp)
  80067b:	8b 10                	mov    (%eax),%edx
  80067d:	8b 48 04             	mov    0x4(%eax),%ecx
  800680:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800683:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800686:	eb 32                	jmp    8006ba <vprintfmt+0x308>
	else if (lflag)
  800688:	85 d2                	test   %edx,%edx
  80068a:	74 18                	je     8006a4 <vprintfmt+0x2f2>
		return va_arg(*ap, long);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 50 04             	lea    0x4(%eax),%edx
  800692:	89 55 14             	mov    %edx,0x14(%ebp)
  800695:	8b 00                	mov    (%eax),%eax
  800697:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80069a:	89 c1                	mov    %eax,%ecx
  80069c:	c1 f9 1f             	sar    $0x1f,%ecx
  80069f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006a2:	eb 16                	jmp    8006ba <vprintfmt+0x308>
	else
		return va_arg(*ap, int);
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8d 50 04             	lea    0x4(%eax),%edx
  8006aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ad:	8b 00                	mov    (%eax),%eax
  8006af:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006b2:	89 c7                	mov    %eax,%edi
  8006b4:	c1 ff 1f             	sar    $0x1f,%edi
  8006b7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006ba:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006bd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006c5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006c9:	79 7d                	jns    800748 <vprintfmt+0x396>
				putch('-', putdat);
  8006cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006d6:	ff d6                	call   *%esi
				num = -(long long) num;
  8006d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006db:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006de:	f7 d8                	neg    %eax
  8006e0:	83 d2 00             	adc    $0x0,%edx
  8006e3:	f7 da                	neg    %edx
			}
			base = 10;
  8006e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006ea:	eb 5c                	jmp    800748 <vprintfmt+0x396>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ef:	e8 3f fc ff ff       	call   800333 <getuint>
			base = 10;
  8006f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006f9:	eb 4d                	jmp    800748 <vprintfmt+0x396>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fe:	e8 30 fc ff ff       	call   800333 <getuint>
			base = 8;
  800703:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800708:	eb 3e                	jmp    800748 <vprintfmt+0x396>

		// pointer
		case 'p':
			putch('0', putdat);
  80070a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800715:	ff d6                	call   *%esi
			putch('x', putdat);
  800717:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800722:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800724:	8b 45 14             	mov    0x14(%ebp),%eax
  800727:	8d 50 04             	lea    0x4(%eax),%edx
  80072a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80072d:	8b 00                	mov    (%eax),%eax
  80072f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800734:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800739:	eb 0d                	jmp    800748 <vprintfmt+0x396>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80073b:	8d 45 14             	lea    0x14(%ebp),%eax
  80073e:	e8 f0 fb ff ff       	call   800333 <getuint>
			base = 16;
  800743:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800748:	0f be 7d e4          	movsbl -0x1c(%ebp),%edi
  80074c:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800750:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800753:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800757:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80075b:	89 04 24             	mov    %eax,(%esp)
  80075e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800762:	89 da                	mov    %ebx,%edx
  800764:	89 f0                	mov    %esi,%eax
  800766:	e8 d5 fa ff ff       	call   800240 <printnum>
			break;
  80076b:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80076e:	e9 64 fc ff ff       	jmp    8003d7 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800773:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800777:	89 0c 24             	mov    %ecx,(%esp)
  80077a:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077c:	8b 7d e0             	mov    -0x20(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80077f:	e9 53 fc ff ff       	jmp    8003d7 <vprintfmt+0x25>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800784:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800788:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80078f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800791:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800795:	0f 84 3c fc ff ff    	je     8003d7 <vprintfmt+0x25>
  80079b:	83 ef 01             	sub    $0x1,%edi
  80079e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007a2:	75 f7                	jne    80079b <vprintfmt+0x3e9>
  8007a4:	e9 2e fc ff ff       	jmp    8003d7 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007a9:	83 c4 4c             	add    $0x4c,%esp
  8007ac:	5b                   	pop    %ebx
  8007ad:	5e                   	pop    %esi
  8007ae:	5f                   	pop    %edi
  8007af:	5d                   	pop    %ebp
  8007b0:	c3                   	ret    

008007b1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	83 ec 28             	sub    $0x28,%esp
  8007b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ce:	85 d2                	test   %edx,%edx
  8007d0:	7e 30                	jle    800802 <vsnprintf+0x51>
  8007d2:	85 c0                	test   %eax,%eax
  8007d4:	74 2c                	je     800802 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007eb:	c7 04 24 6d 03 80 00 	movl   $0x80036d,(%esp)
  8007f2:	e8 bb fb ff ff       	call   8003b2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007fa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800800:	eb 05                	jmp    800807 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800802:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800807:	c9                   	leave  
  800808:	c3                   	ret    

00800809 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80080f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800812:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800816:	8b 45 10             	mov    0x10(%ebp),%eax
  800819:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800820:	89 44 24 04          	mov    %eax,0x4(%esp)
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	89 04 24             	mov    %eax,(%esp)
  80082a:	e8 82 ff ff ff       	call   8007b1 <vsnprintf>
	va_end(ap);

	return rc;
}
  80082f:	c9                   	leave  
  800830:	c3                   	ret    
  800831:	66 90                	xchg   %ax,%ax
  800833:	66 90                	xchg   %ax,%ax
  800835:	66 90                	xchg   %ax,%ax
  800837:	66 90                	xchg   %ax,%ax
  800839:	66 90                	xchg   %ax,%ax
  80083b:	66 90                	xchg   %ax,%ax
  80083d:	66 90                	xchg   %ax,%ax
  80083f:	90                   	nop

00800840 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800846:	80 3a 00             	cmpb   $0x0,(%edx)
  800849:	74 10                	je     80085b <strlen+0x1b>
  80084b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800850:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800853:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800857:	75 f7                	jne    800850 <strlen+0x10>
  800859:	eb 05                	jmp    800860 <strlen+0x20>
  80085b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	53                   	push   %ebx
  800866:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800869:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086c:	85 c9                	test   %ecx,%ecx
  80086e:	74 1c                	je     80088c <strnlen+0x2a>
  800870:	80 3b 00             	cmpb   $0x0,(%ebx)
  800873:	74 1e                	je     800893 <strnlen+0x31>
  800875:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80087a:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087c:	39 ca                	cmp    %ecx,%edx
  80087e:	74 18                	je     800898 <strnlen+0x36>
  800880:	83 c2 01             	add    $0x1,%edx
  800883:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800888:	75 f0                	jne    80087a <strnlen+0x18>
  80088a:	eb 0c                	jmp    800898 <strnlen+0x36>
  80088c:	b8 00 00 00 00       	mov    $0x0,%eax
  800891:	eb 05                	jmp    800898 <strnlen+0x36>
  800893:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800898:	5b                   	pop    %ebx
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	53                   	push   %ebx
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a5:	89 c2                	mov    %eax,%edx
  8008a7:	0f b6 19             	movzbl (%ecx),%ebx
  8008aa:	88 1a                	mov    %bl,(%edx)
  8008ac:	83 c2 01             	add    $0x1,%edx
  8008af:	83 c1 01             	add    $0x1,%ecx
  8008b2:	84 db                	test   %bl,%bl
  8008b4:	75 f1                	jne    8008a7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b6:	5b                   	pop    %ebx
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	53                   	push   %ebx
  8008bd:	83 ec 08             	sub    $0x8,%esp
  8008c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c3:	89 1c 24             	mov    %ebx,(%esp)
  8008c6:	e8 75 ff ff ff       	call   800840 <strlen>
	strcpy(dst + len, src);
  8008cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008d2:	01 d8                	add    %ebx,%eax
  8008d4:	89 04 24             	mov    %eax,(%esp)
  8008d7:	e8 bf ff ff ff       	call   80089b <strcpy>
	return dst;
}
  8008dc:	89 d8                	mov    %ebx,%eax
  8008de:	83 c4 08             	add    $0x8,%esp
  8008e1:	5b                   	pop    %ebx
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f2:	85 db                	test   %ebx,%ebx
  8008f4:	74 16                	je     80090c <strncpy+0x28>
	strcpy(dst + len, src);
	return dst;
}

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f6:	01 f3                	add    %esi,%ebx
  8008f8:	89 f1                	mov    %esi,%ecx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
		*dst++ = *src;
  8008fa:	0f b6 02             	movzbl (%edx),%eax
  8008fd:	88 01                	mov    %al,(%ecx)
  8008ff:	83 c1 01             	add    $0x1,%ecx
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800902:	80 3a 01             	cmpb   $0x1,(%edx)
  800905:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800908:	39 d9                	cmp    %ebx,%ecx
  80090a:	75 ee                	jne    8008fa <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80090c:	89 f0                	mov    %esi,%eax
  80090e:	5b                   	pop    %ebx
  80090f:	5e                   	pop    %esi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	57                   	push   %edi
  800916:	56                   	push   %esi
  800917:	53                   	push   %ebx
  800918:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80091e:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800921:	89 f8                	mov    %edi,%eax
  800923:	85 f6                	test   %esi,%esi
  800925:	74 33                	je     80095a <strlcpy+0x48>
		while (--size > 0 && *src != '\0')
  800927:	83 fe 01             	cmp    $0x1,%esi
  80092a:	74 25                	je     800951 <strlcpy+0x3f>
  80092c:	0f b6 0b             	movzbl (%ebx),%ecx
  80092f:	84 c9                	test   %cl,%cl
  800931:	74 22                	je     800955 <strlcpy+0x43>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800933:	83 ee 02             	sub    $0x2,%esi
  800936:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80093b:	88 08                	mov    %cl,(%eax)
  80093d:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800940:	39 f2                	cmp    %esi,%edx
  800942:	74 13                	je     800957 <strlcpy+0x45>
  800944:	83 c2 01             	add    $0x1,%edx
  800947:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80094b:	84 c9                	test   %cl,%cl
  80094d:	75 ec                	jne    80093b <strlcpy+0x29>
  80094f:	eb 06                	jmp    800957 <strlcpy+0x45>
  800951:	89 f8                	mov    %edi,%eax
  800953:	eb 02                	jmp    800957 <strlcpy+0x45>
  800955:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800957:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80095a:	29 f8                	sub    %edi,%eax
}
  80095c:	5b                   	pop    %ebx
  80095d:	5e                   	pop    %esi
  80095e:	5f                   	pop    %edi
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800967:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80096a:	0f b6 01             	movzbl (%ecx),%eax
  80096d:	84 c0                	test   %al,%al
  80096f:	74 15                	je     800986 <strcmp+0x25>
  800971:	3a 02                	cmp    (%edx),%al
  800973:	75 11                	jne    800986 <strcmp+0x25>
		p++, q++;
  800975:	83 c1 01             	add    $0x1,%ecx
  800978:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80097b:	0f b6 01             	movzbl (%ecx),%eax
  80097e:	84 c0                	test   %al,%al
  800980:	74 04                	je     800986 <strcmp+0x25>
  800982:	3a 02                	cmp    (%edx),%al
  800984:	74 ef                	je     800975 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800986:	0f b6 c0             	movzbl %al,%eax
  800989:	0f b6 12             	movzbl (%edx),%edx
  80098c:	29 d0                	sub    %edx,%eax
}
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	56                   	push   %esi
  800994:	53                   	push   %ebx
  800995:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800998:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  80099e:	85 f6                	test   %esi,%esi
  8009a0:	74 29                	je     8009cb <strncmp+0x3b>
  8009a2:	0f b6 03             	movzbl (%ebx),%eax
  8009a5:	84 c0                	test   %al,%al
  8009a7:	74 30                	je     8009d9 <strncmp+0x49>
  8009a9:	3a 02                	cmp    (%edx),%al
  8009ab:	75 2c                	jne    8009d9 <strncmp+0x49>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
  8009ad:	8d 43 01             	lea    0x1(%ebx),%eax
  8009b0:	01 de                	add    %ebx,%esi
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
  8009b2:	89 c3                	mov    %eax,%ebx
  8009b4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009b7:	39 f0                	cmp    %esi,%eax
  8009b9:	74 17                	je     8009d2 <strncmp+0x42>
  8009bb:	0f b6 08             	movzbl (%eax),%ecx
  8009be:	84 c9                	test   %cl,%cl
  8009c0:	74 17                	je     8009d9 <strncmp+0x49>
  8009c2:	83 c0 01             	add    $0x1,%eax
  8009c5:	3a 0a                	cmp    (%edx),%cl
  8009c7:	74 e9                	je     8009b2 <strncmp+0x22>
  8009c9:	eb 0e                	jmp    8009d9 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d0:	eb 0f                	jmp    8009e1 <strncmp+0x51>
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d7:	eb 08                	jmp    8009e1 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d9:	0f b6 03             	movzbl (%ebx),%eax
  8009dc:	0f b6 12             	movzbl (%edx),%edx
  8009df:	29 d0                	sub    %edx,%eax
}
  8009e1:	5b                   	pop    %ebx
  8009e2:	5e                   	pop    %esi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	53                   	push   %ebx
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  8009ef:	0f b6 18             	movzbl (%eax),%ebx
  8009f2:	84 db                	test   %bl,%bl
  8009f4:	74 1d                	je     800a13 <strchr+0x2e>
  8009f6:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  8009f8:	38 d3                	cmp    %dl,%bl
  8009fa:	75 06                	jne    800a02 <strchr+0x1d>
  8009fc:	eb 1a                	jmp    800a18 <strchr+0x33>
  8009fe:	38 ca                	cmp    %cl,%dl
  800a00:	74 16                	je     800a18 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	0f b6 10             	movzbl (%eax),%edx
  800a08:	84 d2                	test   %dl,%dl
  800a0a:	75 f2                	jne    8009fe <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800a0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a11:	eb 05                	jmp    800a18 <strchr+0x33>
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a18:	5b                   	pop    %ebx
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	53                   	push   %ebx
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a25:	0f b6 18             	movzbl (%eax),%ebx
  800a28:	84 db                	test   %bl,%bl
  800a2a:	74 16                	je     800a42 <strfind+0x27>
  800a2c:	89 d1                	mov    %edx,%ecx
		if (*s == c)
  800a2e:	38 d3                	cmp    %dl,%bl
  800a30:	75 06                	jne    800a38 <strfind+0x1d>
  800a32:	eb 0e                	jmp    800a42 <strfind+0x27>
  800a34:	38 ca                	cmp    %cl,%dl
  800a36:	74 0a                	je     800a42 <strfind+0x27>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a38:	83 c0 01             	add    $0x1,%eax
  800a3b:	0f b6 10             	movzbl (%eax),%edx
  800a3e:	84 d2                	test   %dl,%dl
  800a40:	75 f2                	jne    800a34 <strfind+0x19>
		if (*s == c)
			break;
	return (char *) s;
}
  800a42:	5b                   	pop    %ebx
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	83 ec 0c             	sub    $0xc,%esp
  800a4b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a4e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a51:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a54:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a57:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a5a:	85 c9                	test   %ecx,%ecx
  800a5c:	74 36                	je     800a94 <memset+0x4f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a5e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a64:	75 28                	jne    800a8e <memset+0x49>
  800a66:	f6 c1 03             	test   $0x3,%cl
  800a69:	75 23                	jne    800a8e <memset+0x49>
		c &= 0xFF;
  800a6b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a6f:	89 d3                	mov    %edx,%ebx
  800a71:	c1 e3 08             	shl    $0x8,%ebx
  800a74:	89 d6                	mov    %edx,%esi
  800a76:	c1 e6 18             	shl    $0x18,%esi
  800a79:	89 d0                	mov    %edx,%eax
  800a7b:	c1 e0 10             	shl    $0x10,%eax
  800a7e:	09 f0                	or     %esi,%eax
  800a80:	09 c2                	or     %eax,%edx
  800a82:	89 d0                	mov    %edx,%eax
  800a84:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a86:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a89:	fc                   	cld    
  800a8a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a8c:	eb 06                	jmp    800a94 <memset+0x4f>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a91:	fc                   	cld    
  800a92:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a94:	89 f8                	mov    %edi,%eax
  800a96:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a99:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a9c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a9f:	89 ec                	mov    %ebp,%esp
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	83 ec 08             	sub    $0x8,%esp
  800aa9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800aac:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab8:	39 c6                	cmp    %eax,%esi
  800aba:	73 36                	jae    800af2 <memmove+0x4f>
  800abc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800abf:	39 d0                	cmp    %edx,%eax
  800ac1:	73 2f                	jae    800af2 <memmove+0x4f>
		s += n;
		d += n;
  800ac3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac6:	f6 c2 03             	test   $0x3,%dl
  800ac9:	75 1b                	jne    800ae6 <memmove+0x43>
  800acb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ad1:	75 13                	jne    800ae6 <memmove+0x43>
  800ad3:	f6 c1 03             	test   $0x3,%cl
  800ad6:	75 0e                	jne    800ae6 <memmove+0x43>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ad8:	83 ef 04             	sub    $0x4,%edi
  800adb:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ade:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ae1:	fd                   	std    
  800ae2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae4:	eb 09                	jmp    800aef <memmove+0x4c>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ae6:	83 ef 01             	sub    $0x1,%edi
  800ae9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aec:	fd                   	std    
  800aed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aef:	fc                   	cld    
  800af0:	eb 20                	jmp    800b12 <memmove+0x6f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af8:	75 13                	jne    800b0d <memmove+0x6a>
  800afa:	a8 03                	test   $0x3,%al
  800afc:	75 0f                	jne    800b0d <memmove+0x6a>
  800afe:	f6 c1 03             	test   $0x3,%cl
  800b01:	75 0a                	jne    800b0d <memmove+0x6a>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b03:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b06:	89 c7                	mov    %eax,%edi
  800b08:	fc                   	cld    
  800b09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b0b:	eb 05                	jmp    800b12 <memmove+0x6f>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b0d:	89 c7                	mov    %eax,%edi
  800b0f:	fc                   	cld    
  800b10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b12:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b15:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b18:	89 ec                	mov    %ebp,%esp
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b22:	8b 45 10             	mov    0x10(%ebp),%eax
  800b25:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b30:	8b 45 08             	mov    0x8(%ebp),%eax
  800b33:	89 04 24             	mov    %eax,(%esp)
  800b36:	e8 68 ff ff ff       	call   800aa3 <memmove>
}
  800b3b:	c9                   	leave  
  800b3c:	c3                   	ret    

00800b3d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
  800b43:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b46:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b49:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b4c:	8d 78 ff             	lea    -0x1(%eax),%edi
  800b4f:	85 c0                	test   %eax,%eax
  800b51:	74 36                	je     800b89 <memcmp+0x4c>
		if (*s1 != *s2)
  800b53:	0f b6 03             	movzbl (%ebx),%eax
  800b56:	0f b6 0e             	movzbl (%esi),%ecx
  800b59:	38 c8                	cmp    %cl,%al
  800b5b:	75 17                	jne    800b74 <memcmp+0x37>
  800b5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b62:	eb 1a                	jmp    800b7e <memcmp+0x41>
  800b64:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b69:	83 c2 01             	add    $0x1,%edx
  800b6c:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b70:	38 c8                	cmp    %cl,%al
  800b72:	74 0a                	je     800b7e <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800b74:	0f b6 c0             	movzbl %al,%eax
  800b77:	0f b6 c9             	movzbl %cl,%ecx
  800b7a:	29 c8                	sub    %ecx,%eax
  800b7c:	eb 10                	jmp    800b8e <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7e:	39 fa                	cmp    %edi,%edx
  800b80:	75 e2                	jne    800b64 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b82:	b8 00 00 00 00       	mov    $0x0,%eax
  800b87:	eb 05                	jmp    800b8e <memcmp+0x51>
  800b89:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b8e:	5b                   	pop    %ebx
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	53                   	push   %ebx
  800b97:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const void *ends = (const char *) s + n;
  800b9d:	89 c2                	mov    %eax,%edx
  800b9f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ba2:	39 d0                	cmp    %edx,%eax
  800ba4:	73 13                	jae    800bb9 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ba6:	89 d9                	mov    %ebx,%ecx
  800ba8:	38 18                	cmp    %bl,(%eax)
  800baa:	75 06                	jne    800bb2 <memfind+0x1f>
  800bac:	eb 0b                	jmp    800bb9 <memfind+0x26>
  800bae:	38 08                	cmp    %cl,(%eax)
  800bb0:	74 07                	je     800bb9 <memfind+0x26>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bb2:	83 c0 01             	add    $0x1,%eax
  800bb5:	39 d0                	cmp    %edx,%eax
  800bb7:	75 f5                	jne    800bae <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bb9:	5b                   	pop    %ebx
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	83 ec 04             	sub    $0x4,%esp
  800bc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bcb:	0f b6 02             	movzbl (%edx),%eax
  800bce:	3c 09                	cmp    $0x9,%al
  800bd0:	74 04                	je     800bd6 <strtol+0x1a>
  800bd2:	3c 20                	cmp    $0x20,%al
  800bd4:	75 0e                	jne    800be4 <strtol+0x28>
		s++;
  800bd6:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd9:	0f b6 02             	movzbl (%edx),%eax
  800bdc:	3c 09                	cmp    $0x9,%al
  800bde:	74 f6                	je     800bd6 <strtol+0x1a>
  800be0:	3c 20                	cmp    $0x20,%al
  800be2:	74 f2                	je     800bd6 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800be4:	3c 2b                	cmp    $0x2b,%al
  800be6:	75 0a                	jne    800bf2 <strtol+0x36>
		s++;
  800be8:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800beb:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf0:	eb 10                	jmp    800c02 <strtol+0x46>
  800bf2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bf7:	3c 2d                	cmp    $0x2d,%al
  800bf9:	75 07                	jne    800c02 <strtol+0x46>
		s++, neg = 1;
  800bfb:	83 c2 01             	add    $0x1,%edx
  800bfe:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c02:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c08:	75 15                	jne    800c1f <strtol+0x63>
  800c0a:	80 3a 30             	cmpb   $0x30,(%edx)
  800c0d:	75 10                	jne    800c1f <strtol+0x63>
  800c0f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c13:	75 0a                	jne    800c1f <strtol+0x63>
		s += 2, base = 16;
  800c15:	83 c2 02             	add    $0x2,%edx
  800c18:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c1d:	eb 10                	jmp    800c2f <strtol+0x73>
	else if (base == 0 && s[0] == '0')
  800c1f:	85 db                	test   %ebx,%ebx
  800c21:	75 0c                	jne    800c2f <strtol+0x73>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c23:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c25:	80 3a 30             	cmpb   $0x30,(%edx)
  800c28:	75 05                	jne    800c2f <strtol+0x73>
		s++, base = 8;
  800c2a:	83 c2 01             	add    $0x1,%edx
  800c2d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800c2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c34:	89 5d f0             	mov    %ebx,-0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c37:	0f b6 0a             	movzbl (%edx),%ecx
  800c3a:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800c3d:	89 f3                	mov    %esi,%ebx
  800c3f:	80 fb 09             	cmp    $0x9,%bl
  800c42:	77 08                	ja     800c4c <strtol+0x90>
			dig = *s - '0';
  800c44:	0f be c9             	movsbl %cl,%ecx
  800c47:	83 e9 30             	sub    $0x30,%ecx
  800c4a:	eb 22                	jmp    800c6e <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
  800c4c:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800c4f:	89 f3                	mov    %esi,%ebx
  800c51:	80 fb 19             	cmp    $0x19,%bl
  800c54:	77 08                	ja     800c5e <strtol+0xa2>
			dig = *s - 'a' + 10;
  800c56:	0f be c9             	movsbl %cl,%ecx
  800c59:	83 e9 57             	sub    $0x57,%ecx
  800c5c:	eb 10                	jmp    800c6e <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
  800c5e:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800c61:	89 f3                	mov    %esi,%ebx
  800c63:	80 fb 19             	cmp    $0x19,%bl
  800c66:	77 16                	ja     800c7e <strtol+0xc2>
			dig = *s - 'A' + 10;
  800c68:	0f be c9             	movsbl %cl,%ecx
  800c6b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c6e:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800c71:	7d 0f                	jge    800c82 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800c73:	83 c2 01             	add    $0x1,%edx
  800c76:	0f af 45 f0          	imul   -0x10(%ebp),%eax
  800c7a:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c7c:	eb b9                	jmp    800c37 <strtol+0x7b>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c7e:	89 c1                	mov    %eax,%ecx
  800c80:	eb 02                	jmp    800c84 <strtol+0xc8>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c82:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c84:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c88:	74 05                	je     800c8f <strtol+0xd3>
		*endptr = (char *) s;
  800c8a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c8d:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c8f:	89 ca                	mov    %ecx,%edx
  800c91:	f7 da                	neg    %edx
  800c93:	85 ff                	test   %edi,%edi
  800c95:	0f 45 c2             	cmovne %edx,%eax
}
  800c98:	83 c4 04             	add    $0x4,%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ca9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cac:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cba:	89 c3                	mov    %eax,%ebx
  800cbc:	89 c7                	mov    %eax,%edi
  800cbe:	89 c6                	mov    %eax,%esi
  800cc0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cc2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cc5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cc8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ccb:	89 ec                	mov    %ebp,%esp
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <sys_cgetc>:

int
sys_cgetc(void)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	83 ec 0c             	sub    $0xc,%esp
  800cd5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cd8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cdb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cde:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce8:	89 d1                	mov    %edx,%ecx
  800cea:	89 d3                	mov    %edx,%ebx
  800cec:	89 d7                	mov    %edx,%edi
  800cee:	89 d6                	mov    %edx,%esi
  800cf0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cf2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cf5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cf8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cfb:	89 ec                	mov    %ebp,%esp
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	83 ec 38             	sub    $0x38,%esp
  800d05:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d08:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d0b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d13:	b8 03 00 00 00       	mov    $0x3,%eax
  800d18:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1b:	89 cb                	mov    %ecx,%ebx
  800d1d:	89 cf                	mov    %ecx,%edi
  800d1f:	89 ce                	mov    %ecx,%esi
  800d21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d23:	85 c0                	test   %eax,%eax
  800d25:	7e 28                	jle    800d4f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d27:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d32:	00 
  800d33:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800d3a:	00 
  800d3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d42:	00 
  800d43:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800d4a:	e8 6d 06 00 00       	call   8013bc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d4f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d52:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d55:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d58:	89 ec                	mov    %ebp,%esp
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	83 ec 0c             	sub    $0xc,%esp
  800d62:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d65:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d68:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d70:	b8 02 00 00 00       	mov    $0x2,%eax
  800d75:	89 d1                	mov    %edx,%ecx
  800d77:	89 d3                	mov    %edx,%ebx
  800d79:	89 d7                	mov    %edx,%edi
  800d7b:	89 d6                	mov    %edx,%esi
  800d7d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d7f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d82:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d85:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d88:	89 ec                	mov    %ebp,%esp
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_yield>:

void
sys_yield(void)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	83 ec 0c             	sub    $0xc,%esp
  800d92:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d95:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d98:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800da0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800da5:	89 d1                	mov    %edx,%ecx
  800da7:	89 d3                	mov    %edx,%ebx
  800da9:	89 d7                	mov    %edx,%edi
  800dab:	89 d6                	mov    %edx,%esi
  800dad:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800daf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800db5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800db8:	89 ec                	mov    %ebp,%esp
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	83 ec 38             	sub    $0x38,%esp
  800dc2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dc5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dc8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcb:	be 00 00 00 00       	mov    $0x0,%esi
  800dd0:	b8 04 00 00 00       	mov    $0x4,%eax
  800dd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dde:	89 f7                	mov    %esi,%edi
  800de0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de2:	85 c0                	test   %eax,%eax
  800de4:	7e 28                	jle    800e0e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dea:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800df1:	00 
  800df2:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800df9:	00 
  800dfa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e01:	00 
  800e02:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800e09:	e8 ae 05 00 00       	call   8013bc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e0e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e11:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e14:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e17:	89 ec                	mov    %ebp,%esp
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	83 ec 38             	sub    $0x38,%esp
  800e21:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e24:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e27:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e32:	8b 55 08             	mov    0x8(%ebp),%edx
  800e35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e38:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e3b:	8b 75 18             	mov    0x18(%ebp),%esi
  800e3e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e40:	85 c0                	test   %eax,%eax
  800e42:	7e 28                	jle    800e6c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e44:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e48:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e4f:	00 
  800e50:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800e57:	00 
  800e58:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e5f:	00 
  800e60:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800e67:	e8 50 05 00 00       	call   8013bc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e6c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e6f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e72:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e75:	89 ec                	mov    %ebp,%esp
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    

00800e79 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	83 ec 38             	sub    $0x38,%esp
  800e7f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e82:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e85:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8d:	b8 06 00 00 00       	mov    $0x6,%eax
  800e92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e95:	8b 55 08             	mov    0x8(%ebp),%edx
  800e98:	89 df                	mov    %ebx,%edi
  800e9a:	89 de                	mov    %ebx,%esi
  800e9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	7e 28                	jle    800eca <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ead:	00 
  800eae:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800eb5:	00 
  800eb6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebd:	00 
  800ebe:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800ec5:	e8 f2 04 00 00       	call   8013bc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ecd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed3:	89 ec                	mov    %ebp,%esp
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    

00800ed7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	83 ec 38             	sub    $0x38,%esp
  800edd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ee3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eeb:	b8 08 00 00 00       	mov    $0x8,%eax
  800ef0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef6:	89 df                	mov    %ebx,%edi
  800ef8:	89 de                	mov    %ebx,%esi
  800efa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800efc:	85 c0                	test   %eax,%eax
  800efe:	7e 28                	jle    800f28 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f00:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f04:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f0b:	00 
  800f0c:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800f13:	00 
  800f14:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1b:	00 
  800f1c:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800f23:	e8 94 04 00 00       	call   8013bc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f28:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f2b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f2e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f31:	89 ec                	mov    %ebp,%esp
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	83 ec 38             	sub    $0x38,%esp
  800f3b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f3e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f41:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f49:	b8 09 00 00 00       	mov    $0x9,%eax
  800f4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f51:	8b 55 08             	mov    0x8(%ebp),%edx
  800f54:	89 df                	mov    %ebx,%edi
  800f56:	89 de                	mov    %ebx,%esi
  800f58:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f5a:	85 c0                	test   %eax,%eax
  800f5c:	7e 28                	jle    800f86 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f62:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f69:	00 
  800f6a:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800f71:	00 
  800f72:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f79:	00 
  800f7a:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800f81:	e8 36 04 00 00       	call   8013bc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f86:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f89:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f8c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f8f:	89 ec                	mov    %ebp,%esp
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	83 ec 0c             	sub    $0xc,%esp
  800f99:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f9c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f9f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa2:	be 00 00 00 00       	mov    $0x0,%esi
  800fa7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800faf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fb5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fb8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fba:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fbd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fc0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc3:	89 ec                	mov    %ebp,%esp
  800fc5:	5d                   	pop    %ebp
  800fc6:	c3                   	ret    

00800fc7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	83 ec 38             	sub    $0x38,%esp
  800fcd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fd0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fd3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fdb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fe0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe3:	89 cb                	mov    %ecx,%ebx
  800fe5:	89 cf                	mov    %ecx,%edi
  800fe7:	89 ce                	mov    %ecx,%esi
  800fe9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800feb:	85 c0                	test   %eax,%eax
  800fed:	7e 28                	jle    801017 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fef:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff3:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ffa:	00 
  800ffb:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  801002:	00 
  801003:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80100a:	00 
  80100b:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  801012:	e8 a5 03 00 00       	call   8013bc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801017:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80101a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80101d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801020:	89 ec                	mov    %ebp,%esp
  801022:	5d                   	pop    %ebp
  801023:	c3                   	ret    

00801024 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	53                   	push   %ebx
  801028:	83 ec 24             	sub    $0x24,%esp
  80102b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80102e:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!((err & FEC_WR) && (vpd[PDX(addr)]&PTE_P) && (vpt[PGNUM(addr)]&PTE_COW) ))
  801030:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801034:	74 21                	je     801057 <pgfault+0x33>
  801036:	89 d8                	mov    %ebx,%eax
  801038:	c1 e8 16             	shr    $0x16,%eax
  80103b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801042:	a8 01                	test   $0x1,%al
  801044:	74 11                	je     801057 <pgfault+0x33>
  801046:	89 d8                	mov    %ebx,%eax
  801048:	c1 e8 0c             	shr    $0xc,%eax
  80104b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801052:	f6 c4 08             	test   $0x8,%ah
  801055:	75 1c                	jne    801073 <pgfault+0x4f>
		panic("Invalid fault address!\n");
  801057:	c7 44 24 08 6f 1a 80 	movl   $0x801a6f,0x8(%esp)
  80105e:	00 
  80105f:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  801066:	00 
  801067:	c7 04 24 87 1a 80 00 	movl   $0x801a87,(%esp)
  80106e:	e8 49 03 00 00       	call   8013bc <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	if((r = sys_page_alloc(0, (void *)PFTEMP, PTE_W|PTE_P|PTE_U)))
  801073:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80107a:	00 
  80107b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801082:	00 
  801083:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80108a:	e8 2d fd ff ff       	call   800dbc <sys_page_alloc>
  80108f:	85 c0                	test   %eax,%eax
  801091:	74 20                	je     8010b3 <pgfault+0x8f>
		panic("Alloc page error: %e", r);
  801093:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801097:	c7 44 24 08 92 1a 80 	movl   $0x801a92,0x8(%esp)
  80109e:	00 
  80109f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8010a6:	00 
  8010a7:	c7 04 24 87 1a 80 00 	movl   $0x801a87,(%esp)
  8010ae:	e8 09 03 00 00       	call   8013bc <_panic>
	addr = ROUNDDOWN(addr, PGSIZE);
  8010b3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove((void *)PFTEMP, addr, PGSIZE);
  8010b9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8010c0:	00 
  8010c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010c5:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8010cc:	e8 d2 f9 ff ff       	call   800aa3 <memmove>
	sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_W|PTE_P|PTE_U);
  8010d1:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010d8:	00 
  8010d9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010dd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010e4:	00 
  8010e5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010ec:	00 
  8010ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f4:	e8 22 fd ff ff       	call   800e1b <sys_page_map>

	//panic("pgfault not implemented");
}
  8010f9:	83 c4 24             	add    $0x24,%esp
  8010fc:	5b                   	pop    %ebx
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    

008010ff <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	57                   	push   %edi
  801103:	56                   	push   %esi
  801104:	53                   	push   %ebx
  801105:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	envid_t ch_id;
	uint32_t cow_pg_ptr;
	int r;

	set_pgfault_handler(pgfault);
  801108:	c7 04 24 24 10 80 00 	movl   $0x801024,(%esp)
  80110f:	e8 18 03 00 00       	call   80142c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801114:	ba 07 00 00 00       	mov    $0x7,%edx
  801119:	89 d0                	mov    %edx,%eax
  80111b:	cd 30                	int    $0x30
  80111d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if((ch_id = sys_exofork()) < 0)
  801120:	85 c0                	test   %eax,%eax
  801122:	79 1c                	jns    801140 <fork+0x41>
		panic("Fork error\n");
  801124:	c7 44 24 08 a7 1a 80 	movl   $0x801aa7,0x8(%esp)
  80112b:	00 
  80112c:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
  801133:	00 
  801134:	c7 04 24 87 1a 80 00 	movl   $0x801a87,(%esp)
  80113b:	e8 7c 02 00 00       	call   8013bc <_panic>
  801140:	89 c7                	mov    %eax,%edi
	if(ch_id == 0){ /* the child process */
  801142:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801147:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80114b:	75 1c                	jne    801169 <fork+0x6a>
		thisenv =  &envs[ENVX(sys_getenvid())];
  80114d:	e8 0a fc ff ff       	call   800d5c <sys_getenvid>
  801152:	25 ff 03 00 00       	and    $0x3ff,%eax
  801157:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80115a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80115f:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  801164:	e9 98 01 00 00       	jmp    801301 <fork+0x202>
	}
	for(cow_pg_ptr = UTEXT; cow_pg_ptr < UXSTACKTOP - PGSIZE; cow_pg_ptr += PGSIZE){
		if ((vpd[PDX(cow_pg_ptr)] & PTE_P) && (vpt[PGNUM(cow_pg_ptr)] & (PTE_P|PTE_U))) 
  801169:	89 d8                	mov    %ebx,%eax
  80116b:	c1 e8 16             	shr    $0x16,%eax
  80116e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801175:	a8 01                	test   $0x1,%al
  801177:	0f 84 0d 01 00 00    	je     80128a <fork+0x18b>
  80117d:	89 d8                	mov    %ebx,%eax
  80117f:	c1 e8 0c             	shr    $0xc,%eax
  801182:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801189:	f6 c2 05             	test   $0x5,%dl
  80118c:	0f 84 f8 00 00 00    	je     80128a <fork+0x18b>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	if((vpd[PDX(pn*PGSIZE)]&PTE_P) && (vpt[pn]&(PTE_COW|PTE_W))){
  801192:	89 c6                	mov    %eax,%esi
  801194:	c1 e6 0c             	shl    $0xc,%esi
  801197:	89 f2                	mov    %esi,%edx
  801199:	c1 ea 16             	shr    $0x16,%edx
  80119c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011a3:	f6 c2 01             	test   $0x1,%dl
  8011a6:	0f 84 9a 00 00 00    	je     801246 <fork+0x147>
  8011ac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b3:	a9 02 08 00 00       	test   $0x802,%eax
  8011b8:	0f 84 88 00 00 00    	je     801246 <fork+0x147>
		if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), PTE_P|PTE_COW|PTE_U)))
  8011be:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8011c5:	00 
  8011c6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011ca:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d9:	e8 3d fc ff ff       	call   800e1b <sys_page_map>
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	74 20                	je     801202 <fork+0x103>
			panic("Map page for child procesee failed: %e\n", r);
  8011e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011e6:	c7 44 24 08 cc 1a 80 	movl   $0x801acc,0x8(%esp)
  8011ed:	00 
  8011ee:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  8011f5:	00 
  8011f6:	c7 04 24 87 1a 80 00 	movl   $0x801a87,(%esp)
  8011fd:	e8 ba 01 00 00       	call   8013bc <_panic>
		if((r = sys_page_map(envid, (void *)(pn*PGSIZE), 0, (void *)(pn*PGSIZE), PTE_P|PTE_COW|PTE_U)))
  801202:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801209:	00 
  80120a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80120e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801215:	00 
  801216:	89 74 24 04          	mov    %esi,0x4(%esp)
  80121a:	89 3c 24             	mov    %edi,(%esp)
  80121d:	e8 f9 fb ff ff       	call   800e1b <sys_page_map>
  801222:	85 c0                	test   %eax,%eax
  801224:	74 64                	je     80128a <fork+0x18b>
			panic("Map page for child procesee failed: %e\n", r);
  801226:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80122a:	c7 44 24 08 cc 1a 80 	movl   $0x801acc,0x8(%esp)
  801231:	00 
  801232:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  801239:	00 
  80123a:	c7 04 24 87 1a 80 00 	movl   $0x801a87,(%esp)
  801241:	e8 76 01 00 00       	call   8013bc <_panic>
	}else
		if((r = sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), PTE_P|PTE_U)))
  801246:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80124d:	00 
  80124e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801252:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801256:	89 74 24 04          	mov    %esi,0x4(%esp)
  80125a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801261:	e8 b5 fb ff ff       	call   800e1b <sys_page_map>
  801266:	85 c0                	test   %eax,%eax
  801268:	74 20                	je     80128a <fork+0x18b>
			panic("Map page for child procesee failed: %e\n", r);
  80126a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80126e:	c7 44 24 08 cc 1a 80 	movl   $0x801acc,0x8(%esp)
  801275:	00 
  801276:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  80127d:	00 
  80127e:	c7 04 24 87 1a 80 00 	movl   $0x801a87,(%esp)
  801285:	e8 32 01 00 00       	call   8013bc <_panic>
		panic("Fork error\n");
	if(ch_id == 0){ /* the child process */
		thisenv =  &envs[ENVX(sys_getenvid())];
		return 0;
	}
	for(cow_pg_ptr = UTEXT; cow_pg_ptr < UXSTACKTOP - PGSIZE; cow_pg_ptr += PGSIZE){
  80128a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801290:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801296:	0f 85 cd fe ff ff    	jne    801169 <fork+0x6a>
		if ((vpd[PDX(cow_pg_ptr)] & PTE_P) && (vpt[PGNUM(cow_pg_ptr)] & (PTE_P|PTE_U))) 
			duppage(ch_id, PGNUM(cow_pg_ptr));
	}

	if((r = sys_page_alloc(ch_id, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)))
  80129c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012a3:	00 
  8012a4:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012ab:	ee 
  8012ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012af:	89 04 24             	mov    %eax,(%esp)
  8012b2:	e8 05 fb ff ff       	call   800dbc <sys_page_alloc>
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	74 20                	je     8012db <fork+0x1dc>
		panic("Alloc exception stack error: %e\n", r);
  8012bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012bf:	c7 44 24 08 f4 1a 80 	movl   $0x801af4,0x8(%esp)
  8012c6:	00 
  8012c7:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
  8012ce:	00 
  8012cf:	c7 04 24 87 1a 80 00 	movl   $0x801a87,(%esp)
  8012d6:	e8 e1 00 00 00       	call   8013bc <_panic>

	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(ch_id, _pgfault_upcall);
  8012db:	c7 44 24 04 9c 14 80 	movl   $0x80149c,0x4(%esp)
  8012e2:	00 
  8012e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012e6:	89 04 24             	mov    %eax,(%esp)
  8012e9:	e8 47 fc ff ff       	call   800f35 <sys_env_set_pgfault_upcall>

	sys_env_set_status(ch_id, ENV_RUNNABLE);
  8012ee:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012f5:	00 
  8012f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012f9:	89 04 24             	mov    %eax,(%esp)
  8012fc:	e8 d6 fb ff ff       	call   800ed7 <sys_env_set_status>
	return ch_id;
	//panic("fork not implemented");
}
  801301:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801304:	83 c4 3c             	add    $0x3c,%esp
  801307:	5b                   	pop    %ebx
  801308:	5e                   	pop    %esi
  801309:	5f                   	pop    %edi
  80130a:	5d                   	pop    %ebp
  80130b:	c3                   	ret    

0080130c <sfork>:

// Challenge!
int
sfork(void)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801312:	c7 44 24 08 b3 1a 80 	movl   $0x801ab3,0x8(%esp)
  801319:	00 
  80131a:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  801321:	00 
  801322:	c7 04 24 87 1a 80 00 	movl   $0x801a87,(%esp)
  801329:	e8 8e 00 00 00       	call   8013bc <_panic>
  80132e:	66 90                	xchg   %ax,%ax

00801330 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  801336:	c7 44 24 08 15 1b 80 	movl   $0x801b15,0x8(%esp)
  80133d:	00 
  80133e:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  801345:	00 
  801346:	c7 04 24 2e 1b 80 00 	movl   $0x801b2e,(%esp)
  80134d:	e8 6a 00 00 00       	call   8013bc <_panic>

00801352 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
  801355:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  801358:	c7 44 24 08 38 1b 80 	movl   $0x801b38,0x8(%esp)
  80135f:	00 
  801360:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  801367:	00 
  801368:	c7 04 24 2e 1b 80 00 	movl   $0x801b2e,(%esp)
  80136f:	e8 48 00 00 00       	call   8013bc <_panic>

00801374 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80137a:	a1 50 00 c0 ee       	mov    0xeec00050,%eax
  80137f:	39 c8                	cmp    %ecx,%eax
  801381:	74 17                	je     80139a <ipc_find_env+0x26>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801383:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801388:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80138b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801391:	8b 52 50             	mov    0x50(%edx),%edx
  801394:	39 ca                	cmp    %ecx,%edx
  801396:	75 14                	jne    8013ac <ipc_find_env+0x38>
  801398:	eb 05                	jmp    80139f <ipc_find_env+0x2b>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80139a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80139f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013a2:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8013a7:	8b 40 40             	mov    0x40(%eax),%eax
  8013aa:	eb 0e                	jmp    8013ba <ipc_find_env+0x46>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013ac:	83 c0 01             	add    $0x1,%eax
  8013af:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013b4:	75 d2                	jne    801388 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013b6:	66 b8 00 00          	mov    $0x0,%ax
}
  8013ba:	5d                   	pop    %ebp
  8013bb:	c3                   	ret    

008013bc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	56                   	push   %esi
  8013c0:	53                   	push   %ebx
  8013c1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8013c4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  8013c7:	a1 08 20 80 00       	mov    0x802008,%eax
  8013cc:	85 c0                	test   %eax,%eax
  8013ce:	74 10                	je     8013e0 <_panic+0x24>
		cprintf("%s: ", argv0);
  8013d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d4:	c7 04 24 51 1b 80 00 	movl   $0x801b51,(%esp)
  8013db:	e8 43 ee ff ff       	call   800223 <cprintf>
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013e0:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8013e6:	e8 71 f9 ff ff       	call   800d5c <sys_getenvid>
  8013eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ee:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8013f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013f9:	89 74 24 08          	mov    %esi,0x8(%esp)
  8013fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801401:	c7 04 24 58 1b 80 00 	movl   $0x801b58,(%esp)
  801408:	e8 16 ee ff ff       	call   800223 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80140d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801411:	8b 45 10             	mov    0x10(%ebp),%eax
  801414:	89 04 24             	mov    %eax,(%esp)
  801417:	e8 a6 ed ff ff       	call   8001c2 <vcprintf>
	cprintf("\n");
  80141c:	c7 04 24 85 1a 80 00 	movl   $0x801a85,(%esp)
  801423:	e8 fb ed ff ff       	call   800223 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801428:	cc                   	int3   
  801429:	eb fd                	jmp    801428 <_panic+0x6c>
  80142b:	90                   	nop

0080142c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801432:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801439:	75 54                	jne    80148f <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)))
  80143b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801442:	00 
  801443:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80144a:	ee 
  80144b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801452:	e8 65 f9 ff ff       	call   800dbc <sys_page_alloc>
  801457:	85 c0                	test   %eax,%eax
  801459:	74 20                	je     80147b <set_pgfault_handler+0x4f>
			panic("Exception stack alloc failed: %e!\n", r);
  80145b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80145f:	c7 44 24 08 7c 1b 80 	movl   $0x801b7c,0x8(%esp)
  801466:	00 
  801467:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80146e:	00 
  80146f:	c7 04 24 a0 1b 80 00 	movl   $0x801ba0,(%esp)
  801476:	e8 41 ff ff ff       	call   8013bc <_panic>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80147b:	c7 44 24 04 9c 14 80 	movl   $0x80149c,0x4(%esp)
  801482:	00 
  801483:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80148a:	e8 a6 fa ff ff       	call   800f35 <sys_env_set_pgfault_upcall>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80148f:	8b 45 08             	mov    0x8(%ebp),%eax
  801492:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  801497:	c9                   	leave  
  801498:	c3                   	ret    
  801499:	66 90                	xchg   %ax,%ax
  80149b:	90                   	nop

0080149c <_pgfault_upcall>:
  80149c:	54                   	push   %esp
  80149d:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8014a2:	ff d0                	call   *%eax
  8014a4:	83 c4 04             	add    $0x4,%esp
  8014a7:	83 c4 08             	add    $0x8,%esp
  8014aa:	8b 4c 24 20          	mov    0x20(%esp),%ecx
  8014ae:	8b 44 24 28          	mov    0x28(%esp),%eax
  8014b2:	83 e8 04             	sub    $0x4,%eax
  8014b5:	89 44 24 28          	mov    %eax,0x28(%esp)
  8014b9:	89 08                	mov    %ecx,(%eax)
  8014bb:	61                   	popa   
  8014bc:	83 c4 04             	add    $0x4,%esp
  8014bf:	9d                   	popf   
  8014c0:	5c                   	pop    %esp
  8014c1:	c3                   	ret    
  8014c2:	66 90                	xchg   %ax,%ax
  8014c4:	66 90                	xchg   %ax,%ax
  8014c6:	66 90                	xchg   %ax,%ax
  8014c8:	66 90                	xchg   %ax,%ax
  8014ca:	66 90                	xchg   %ax,%ax
  8014cc:	66 90                	xchg   %ax,%ax
  8014ce:	66 90                	xchg   %ax,%ax

008014d0 <__udivdi3>:
  8014d0:	83 ec 1c             	sub    $0x1c,%esp
  8014d3:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8014d7:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8014db:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8014df:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8014e3:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8014e7:	8b 6c 24 24          	mov    0x24(%esp),%ebp
  8014eb:	85 c0                	test   %eax,%eax
  8014ed:	89 74 24 10          	mov    %esi,0x10(%esp)
  8014f1:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8014f5:	89 ea                	mov    %ebp,%edx
  8014f7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014fb:	75 33                	jne    801530 <__udivdi3+0x60>
  8014fd:	39 e9                	cmp    %ebp,%ecx
  8014ff:	77 6f                	ja     801570 <__udivdi3+0xa0>
  801501:	85 c9                	test   %ecx,%ecx
  801503:	89 ce                	mov    %ecx,%esi
  801505:	75 0b                	jne    801512 <__udivdi3+0x42>
  801507:	b8 01 00 00 00       	mov    $0x1,%eax
  80150c:	31 d2                	xor    %edx,%edx
  80150e:	f7 f1                	div    %ecx
  801510:	89 c6                	mov    %eax,%esi
  801512:	31 d2                	xor    %edx,%edx
  801514:	89 e8                	mov    %ebp,%eax
  801516:	f7 f6                	div    %esi
  801518:	89 c5                	mov    %eax,%ebp
  80151a:	89 f8                	mov    %edi,%eax
  80151c:	f7 f6                	div    %esi
  80151e:	89 ea                	mov    %ebp,%edx
  801520:	8b 74 24 10          	mov    0x10(%esp),%esi
  801524:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801528:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80152c:	83 c4 1c             	add    $0x1c,%esp
  80152f:	c3                   	ret    
  801530:	39 e8                	cmp    %ebp,%eax
  801532:	77 24                	ja     801558 <__udivdi3+0x88>
  801534:	0f bd c8             	bsr    %eax,%ecx
  801537:	83 f1 1f             	xor    $0x1f,%ecx
  80153a:	89 0c 24             	mov    %ecx,(%esp)
  80153d:	75 49                	jne    801588 <__udivdi3+0xb8>
  80153f:	8b 74 24 08          	mov    0x8(%esp),%esi
  801543:	39 74 24 04          	cmp    %esi,0x4(%esp)
  801547:	0f 86 ab 00 00 00    	jbe    8015f8 <__udivdi3+0x128>
  80154d:	39 e8                	cmp    %ebp,%eax
  80154f:	0f 82 a3 00 00 00    	jb     8015f8 <__udivdi3+0x128>
  801555:	8d 76 00             	lea    0x0(%esi),%esi
  801558:	31 d2                	xor    %edx,%edx
  80155a:	31 c0                	xor    %eax,%eax
  80155c:	8b 74 24 10          	mov    0x10(%esp),%esi
  801560:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801564:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801568:	83 c4 1c             	add    $0x1c,%esp
  80156b:	c3                   	ret    
  80156c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801570:	89 f8                	mov    %edi,%eax
  801572:	f7 f1                	div    %ecx
  801574:	31 d2                	xor    %edx,%edx
  801576:	8b 74 24 10          	mov    0x10(%esp),%esi
  80157a:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80157e:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801582:	83 c4 1c             	add    $0x1c,%esp
  801585:	c3                   	ret    
  801586:	66 90                	xchg   %ax,%ax
  801588:	0f b6 0c 24          	movzbl (%esp),%ecx
  80158c:	89 c6                	mov    %eax,%esi
  80158e:	b8 20 00 00 00       	mov    $0x20,%eax
  801593:	8b 6c 24 04          	mov    0x4(%esp),%ebp
  801597:	2b 04 24             	sub    (%esp),%eax
  80159a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80159e:	d3 e6                	shl    %cl,%esi
  8015a0:	89 c1                	mov    %eax,%ecx
  8015a2:	d3 ed                	shr    %cl,%ebp
  8015a4:	0f b6 0c 24          	movzbl (%esp),%ecx
  8015a8:	09 f5                	or     %esi,%ebp
  8015aa:	8b 74 24 04          	mov    0x4(%esp),%esi
  8015ae:	d3 e6                	shl    %cl,%esi
  8015b0:	89 c1                	mov    %eax,%ecx
  8015b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015b6:	89 d6                	mov    %edx,%esi
  8015b8:	d3 ee                	shr    %cl,%esi
  8015ba:	0f b6 0c 24          	movzbl (%esp),%ecx
  8015be:	d3 e2                	shl    %cl,%edx
  8015c0:	89 c1                	mov    %eax,%ecx
  8015c2:	d3 ef                	shr    %cl,%edi
  8015c4:	09 d7                	or     %edx,%edi
  8015c6:	89 f2                	mov    %esi,%edx
  8015c8:	89 f8                	mov    %edi,%eax
  8015ca:	f7 f5                	div    %ebp
  8015cc:	89 d6                	mov    %edx,%esi
  8015ce:	89 c7                	mov    %eax,%edi
  8015d0:	f7 64 24 04          	mull   0x4(%esp)
  8015d4:	39 d6                	cmp    %edx,%esi
  8015d6:	72 30                	jb     801608 <__udivdi3+0x138>
  8015d8:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8015dc:	0f b6 0c 24          	movzbl (%esp),%ecx
  8015e0:	d3 e5                	shl    %cl,%ebp
  8015e2:	39 c5                	cmp    %eax,%ebp
  8015e4:	73 04                	jae    8015ea <__udivdi3+0x11a>
  8015e6:	39 d6                	cmp    %edx,%esi
  8015e8:	74 1e                	je     801608 <__udivdi3+0x138>
  8015ea:	89 f8                	mov    %edi,%eax
  8015ec:	31 d2                	xor    %edx,%edx
  8015ee:	e9 69 ff ff ff       	jmp    80155c <__udivdi3+0x8c>
  8015f3:	90                   	nop
  8015f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015f8:	31 d2                	xor    %edx,%edx
  8015fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ff:	e9 58 ff ff ff       	jmp    80155c <__udivdi3+0x8c>
  801604:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801608:	8d 47 ff             	lea    -0x1(%edi),%eax
  80160b:	31 d2                	xor    %edx,%edx
  80160d:	8b 74 24 10          	mov    0x10(%esp),%esi
  801611:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801615:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801619:	83 c4 1c             	add    $0x1c,%esp
  80161c:	c3                   	ret    
  80161d:	66 90                	xchg   %ax,%ax
  80161f:	90                   	nop

00801620 <__umoddi3>:
  801620:	83 ec 2c             	sub    $0x2c,%esp
  801623:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801627:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80162b:	89 74 24 20          	mov    %esi,0x20(%esp)
  80162f:	8b 74 24 38          	mov    0x38(%esp),%esi
  801633:	89 7c 24 24          	mov    %edi,0x24(%esp)
  801637:	8b 7c 24 34          	mov    0x34(%esp),%edi
  80163b:	85 c0                	test   %eax,%eax
  80163d:	89 c2                	mov    %eax,%edx
  80163f:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  801643:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801647:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80164b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80164f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801653:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801657:	75 1f                	jne    801678 <__umoddi3+0x58>
  801659:	39 fe                	cmp    %edi,%esi
  80165b:	76 63                	jbe    8016c0 <__umoddi3+0xa0>
  80165d:	89 c8                	mov    %ecx,%eax
  80165f:	89 fa                	mov    %edi,%edx
  801661:	f7 f6                	div    %esi
  801663:	89 d0                	mov    %edx,%eax
  801665:	31 d2                	xor    %edx,%edx
  801667:	8b 74 24 20          	mov    0x20(%esp),%esi
  80166b:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80166f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  801673:	83 c4 2c             	add    $0x2c,%esp
  801676:	c3                   	ret    
  801677:	90                   	nop
  801678:	39 f8                	cmp    %edi,%eax
  80167a:	77 64                	ja     8016e0 <__umoddi3+0xc0>
  80167c:	0f bd e8             	bsr    %eax,%ebp
  80167f:	83 f5 1f             	xor    $0x1f,%ebp
  801682:	75 74                	jne    8016f8 <__umoddi3+0xd8>
  801684:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801688:	39 7c 24 10          	cmp    %edi,0x10(%esp)
  80168c:	0f 87 0e 01 00 00    	ja     8017a0 <__umoddi3+0x180>
  801692:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  801696:	29 f1                	sub    %esi,%ecx
  801698:	19 c7                	sbb    %eax,%edi
  80169a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80169e:	89 7c 24 18          	mov    %edi,0x18(%esp)
  8016a2:	8b 44 24 14          	mov    0x14(%esp),%eax
  8016a6:	8b 54 24 18          	mov    0x18(%esp),%edx
  8016aa:	8b 74 24 20          	mov    0x20(%esp),%esi
  8016ae:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8016b2:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8016b6:	83 c4 2c             	add    $0x2c,%esp
  8016b9:	c3                   	ret    
  8016ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8016c0:	85 f6                	test   %esi,%esi
  8016c2:	89 f5                	mov    %esi,%ebp
  8016c4:	75 0b                	jne    8016d1 <__umoddi3+0xb1>
  8016c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8016cb:	31 d2                	xor    %edx,%edx
  8016cd:	f7 f6                	div    %esi
  8016cf:	89 c5                	mov    %eax,%ebp
  8016d1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8016d5:	31 d2                	xor    %edx,%edx
  8016d7:	f7 f5                	div    %ebp
  8016d9:	89 c8                	mov    %ecx,%eax
  8016db:	f7 f5                	div    %ebp
  8016dd:	eb 84                	jmp    801663 <__umoddi3+0x43>
  8016df:	90                   	nop
  8016e0:	89 c8                	mov    %ecx,%eax
  8016e2:	89 fa                	mov    %edi,%edx
  8016e4:	8b 74 24 20          	mov    0x20(%esp),%esi
  8016e8:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8016ec:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  8016f0:	83 c4 2c             	add    $0x2c,%esp
  8016f3:	c3                   	ret    
  8016f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016f8:	8b 44 24 10          	mov    0x10(%esp),%eax
  8016fc:	be 20 00 00 00       	mov    $0x20,%esi
  801701:	89 e9                	mov    %ebp,%ecx
  801703:	29 ee                	sub    %ebp,%esi
  801705:	d3 e2                	shl    %cl,%edx
  801707:	89 f1                	mov    %esi,%ecx
  801709:	d3 e8                	shr    %cl,%eax
  80170b:	89 e9                	mov    %ebp,%ecx
  80170d:	09 d0                	or     %edx,%eax
  80170f:	89 fa                	mov    %edi,%edx
  801711:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801715:	8b 44 24 10          	mov    0x10(%esp),%eax
  801719:	d3 e0                	shl    %cl,%eax
  80171b:	89 f1                	mov    %esi,%ecx
  80171d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801721:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801725:	d3 ea                	shr    %cl,%edx
  801727:	89 e9                	mov    %ebp,%ecx
  801729:	d3 e7                	shl    %cl,%edi
  80172b:	89 f1                	mov    %esi,%ecx
  80172d:	d3 e8                	shr    %cl,%eax
  80172f:	89 e9                	mov    %ebp,%ecx
  801731:	09 f8                	or     %edi,%eax
  801733:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801737:	f7 74 24 0c          	divl   0xc(%esp)
  80173b:	d3 e7                	shl    %cl,%edi
  80173d:	89 7c 24 18          	mov    %edi,0x18(%esp)
  801741:	89 d7                	mov    %edx,%edi
  801743:	f7 64 24 10          	mull   0x10(%esp)
  801747:	39 d7                	cmp    %edx,%edi
  801749:	89 c1                	mov    %eax,%ecx
  80174b:	89 54 24 14          	mov    %edx,0x14(%esp)
  80174f:	72 3b                	jb     80178c <__umoddi3+0x16c>
  801751:	39 44 24 18          	cmp    %eax,0x18(%esp)
  801755:	72 31                	jb     801788 <__umoddi3+0x168>
  801757:	8b 44 24 18          	mov    0x18(%esp),%eax
  80175b:	29 c8                	sub    %ecx,%eax
  80175d:	19 d7                	sbb    %edx,%edi
  80175f:	89 e9                	mov    %ebp,%ecx
  801761:	89 fa                	mov    %edi,%edx
  801763:	d3 e8                	shr    %cl,%eax
  801765:	89 f1                	mov    %esi,%ecx
  801767:	d3 e2                	shl    %cl,%edx
  801769:	89 e9                	mov    %ebp,%ecx
  80176b:	09 d0                	or     %edx,%eax
  80176d:	89 fa                	mov    %edi,%edx
  80176f:	d3 ea                	shr    %cl,%edx
  801771:	8b 74 24 20          	mov    0x20(%esp),%esi
  801775:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801779:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  80177d:	83 c4 2c             	add    $0x2c,%esp
  801780:	c3                   	ret    
  801781:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801788:	39 d7                	cmp    %edx,%edi
  80178a:	75 cb                	jne    801757 <__umoddi3+0x137>
  80178c:	8b 54 24 14          	mov    0x14(%esp),%edx
  801790:	89 c1                	mov    %eax,%ecx
  801792:	2b 4c 24 10          	sub    0x10(%esp),%ecx
  801796:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80179a:	eb bb                	jmp    801757 <__umoddi3+0x137>
  80179c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8017a0:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8017a4:	0f 82 e8 fe ff ff    	jb     801692 <__umoddi3+0x72>
  8017aa:	e9 f3 fe ff ff       	jmp    8016a2 <__umoddi3+0x82>
