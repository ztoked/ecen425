; Generated by c86 (BYU-NASM) 5.1 (beta) from lab7app.i
	CPU	8086
	ALIGN	2
	jmp	main	; Jump to program start
L_lab7app_5:
	DB	"CharTask     (C)",0xA,0
L_lab7app_4:
	DB	"CharTask     (B)",0xA,0
L_lab7app_3:
	DB	"CharTask     (A)",0xA,0
L_lab7app_2:
	DB	"Oops! At least one event should be set in return value!",0xA,0
L_lab7app_1:
	DB	"Started CharTask     (2)",0xA,0
	ALIGN	2
CharTask:
	; >>>>> Line:	26
	; >>>>> { 
	jmp	L_lab7app_6
L_lab7app_7:
	; >>>>> Line:	29
	; >>>>> printString("Started CharTask     (2)\n"); 
	mov	ax, L_lab7app_1
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	31
	; >>>>> while(1) { 
	jmp	L_lab7app_9
L_lab7app_8:
	; >>>>> Line:	32
	; >>>>> events = YKEventPend(charEvent, 
	xor	ax, ax
	push	ax
	mov	ax, 7
	push	ax
	push	word [charEvent]
	call	YKEventPend
	add	sp, 6
	mov	word [bp-2], ax
	; >>>>> Line:	36
	; >>>>> if(events == 0) { 
	mov	ax, word [bp-2]
	test	ax, ax
	jne	L_lab7app_11
	; >>>>> Line:	37
	; >>>>> printString("Oops! At least one event should be set " 
	mov	ax, L_lab7app_2
	push	ax
	call	printString
	add	sp, 2
L_lab7app_11:
	; >>>>> Line:	41
	; >>>>> if(events & 0x1) { 
	mov	ax, word [bp-2]
	and	ax, 1
	je	L_lab7app_12
	; >>>>> Line:	42
	; >>>>> printString("CharTask     (A)\n"); 
	mov	ax, L_lab7app_3
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	43
	; >>>>> YKEventReset(charEvent, 0x1 
	mov	ax, 1
	push	ax
	push	word [charEvent]
	call	YKEventReset
	add	sp, 4
L_lab7app_12:
	; >>>>> Line:	46
	; >>>>> if(events & 0x2) { 
	mov	ax, word [bp-2]
	and	ax, 2
	je	L_lab7app_13
	; >>>>> Line:	47
	; >>>>> printString("CharTask     (B)\n"); 
	mov	ax, L_lab7app_4
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	48
	; >>>>> YKEventReset(charEvent, 0x2); 
	mov	ax, 2
	push	ax
	push	word [charEvent]
	call	YKEventReset
	add	sp, 4
L_lab7app_13:
	; >>>>> Line:	51
	; >>>>> if(events & 0x4) { 
	mov	ax, word [bp-2]
	and	ax, 4
	je	L_lab7app_14
	; >>>>> Line:	52
	; >>>>> printString("CharTask     (C)\n"); 
	mov	ax, L_lab7app_5
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	53
	; >>>>> YKEventReset(charEvent, 0x4); 
	mov	ax, 4
	push	ax
	push	word [charEvent]
	call	YKEventReset
	add	sp, 4
L_lab7app_14:
L_lab7app_9:
	jmp	L_lab7app_8
L_lab7app_10:
	mov	sp, bp
	pop	bp
	ret
L_lab7app_6:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_lab7app_7
L_lab7app_18:
	DB	"AllCharsTask (D)",0xA,0
L_lab7app_17:
	DB	"Oops! Char events weren't reset by CharTask!",0xA,0
L_lab7app_16:
	DB	"Started AllCharsTask (3)",0xA,0
	ALIGN	2
AllCharsTask:
	; >>>>> Line:	60
	; >>>>> { 
	jmp	L_lab7app_19
L_lab7app_20:
	; >>>>> Line:	63
	; >>>>> printString("Started AllCharsTask (3)\n"); 
	mov	ax, L_lab7app_16
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	65
	; >>>>> while(1) { 
	jmp	L_lab7app_22
L_lab7app_21:
	; >>>>> Line:	66
	; >>>>> events = YKEventPend(charEvent, 
	mov	ax, 1
	push	ax
	mov	ax, 7
	push	ax
	push	word [charEvent]
	call	YKEventPend
	add	sp, 6
	mov	word [bp-2], ax
	; >>>>> Line:	71
	; >>>>>  
	mov	ax, word [bp-2]
	test	ax, ax
	je	L_lab7app_24
	; >>>>> Line:	72
	; >>>>> printString("Oops! Char events weren't reset by CharTask!\n"); 
	mov	ax, L_lab7app_17
	push	ax
	call	printString
	add	sp, 2
L_lab7app_24:
	; >>>>> Line:	75
	; >>>>> printString("AllCharsTask (D)\n"); 
	mov	ax, L_lab7app_18
	push	ax
	call	printString
	add	sp, 2
L_lab7app_22:
	jmp	L_lab7app_21
L_lab7app_23:
	mov	sp, bp
	pop	bp
	ret
L_lab7app_19:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_lab7app_20
L_lab7app_28:
	DB	"AllNumsTask  (123)",0xA,0
L_lab7app_27:
	DB	"Oops! All events should be set in return value!",0xA,0
L_lab7app_26:
	DB	"Started AllNumsTask  (1)",0xA,0
	ALIGN	2
AllNumsTask:
	; >>>>> Line:	81
	; >>>>> { 
	jmp	L_lab7app_29
L_lab7app_30:
	; >>>>> Line:	84
	; >>>>> printString("Started AllNumsTask  (1)\n"); 
	mov	ax, L_lab7app_26
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	86
	; >>>>> while(1) { 
	jmp	L_lab7app_32
L_lab7app_31:
	; >>>>> Line:	87
	; >>>>> events = YKEventPend(numEvent, 
	mov	ax, 1
	push	ax
	mov	ax, 7
	push	ax
	push	word [numEvent]
	call	YKEventPend
	add	sp, 6
	mov	word [bp-2], ax
	; >>>>> Line:	91
	; >>>>> if(events != (0x1 | 0x2 | 0x4)) { 
	cmp	word [bp-2], 7
	je	L_lab7app_34
	; >>>>> Line:	92
	; >>>>> printString("Oops! All events should be set in return value!\n"); 
	mov	ax, L_lab7app_27
	push	ax
	call	printString
	add	sp, 2
L_lab7app_34:
	; >>>>> Line:	95
	; >>>>> printString("AllNumsTask  (123)\n"); 
	mov	ax, L_lab7app_28
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	97
	; >>>>> YKEventReset(numEvent, 0x1 | 0x2 | 0x4); 
	mov	ax, 7
	push	ax
	push	word [numEvent]
	call	YKEventReset
	add	sp, 4
L_lab7app_32:
	jmp	L_lab7app_31
L_lab7app_33:
	mov	sp, bp
	pop	bp
	ret
L_lab7app_29:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_lab7app_30
L_lab7app_40:
	DB	"% >>>>>",0xD,0xA,0
L_lab7app_39:
	DB	", CPU usage: ",0
L_lab7app_38:
	DB	"<<<<< Context switches: ",0
L_lab7app_37:
	DB	"Determining CPU capacity",0xD,0xA,0
L_lab7app_36:
	DB	"Welcome to the YAK kernel",0xD,0xA,0
	ALIGN	2
STask:
	; >>>>> Line:	103
	; >>>>> { 
	jmp	L_lab7app_41
L_lab7app_42:
	; >>>>> Line:	107
	; >>>>> YKDelayTask(1); 
	mov	ax, 1
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	108
	; >>>>> printString("Welcome to the YAK kernel\r\n"); 
	mov	ax, L_lab7app_36
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	109
	; >>>>> printString("Determining CPU capacity\r\n"); 
	mov	ax, L_lab7app_37
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	110
	; >>>>> YKDelayTask(1); 
	mov	ax, 1
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	111
	; >>>>> YKIdleCount = 0; 
	mov	word [YKIdleCount], 0
	; >>>>> Line:	112
	; >>>>> YKDelayTask(5); 
	mov	ax, 5
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	113
	; >>>>> max = YKIdleCount / 25; 
	mov	ax, word [YKIdleCount]
	xor	dx, dx
	mov	cx, 25
	div	cx
	mov	word [bp-2], ax
	; >>>>> Line:	114
	; >>>>> YKIdleCount = 0; 
	mov	word [YKIdleCount], 0
	; >>>>> Line:	116
	; >>>>> YKNewTask(CharTask, (void *) &CharTaskStk[512], 2); 
	mov	al, 2
	push	ax
	mov	ax, (CharTaskStk+1024)
	push	ax
	mov	ax, CharTask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	117
	; >>>>> YKNewTask(AllNumsTask, (void *)  
	mov	al, 1
	push	ax
	mov	ax, (AllNumsTaskStk+1024)
	push	ax
	mov	ax, AllNumsTask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	118
	; >>>>> YKNewTask(AllCharsTask, (void *) &AllCharsTaskStk[512], 3); 
	mov	al, 3
	push	ax
	mov	ax, (AllCharsTaskStk+1024)
	push	ax
	mov	ax, AllCharsTask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	120
	; >>>>> while (1) 
	jmp	L_lab7app_44
L_lab7app_43:
	; >>>>> Line:	122
	; >>>>> YKDelayTask(20); 
	mov	ax, 20
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	124
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	125
	; >>>>> switchCount = YKCtxSwCount; 
	mov	ax, word [YKCtxSwCount]
	mov	word [bp-4], ax
	; >>>>> Line:	126
	; >>>>> idleCount = YKIdleCount; 
	mov	ax, word [YKIdleCount]
	mov	word [bp-6], ax
	; >>>>> Line:	127
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	; >>>>> Line:	129
	; >>>>> printString("<<<<< Context switches: "); 
	mov	ax, L_lab7app_38
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	130
	; >>>>> printInt((int)switchCount); 
	push	word [bp-4]
	call	printInt
	add	sp, 2
	; >>>>> Line:	131
	; >>>>> printString(", CPU usage: "); 
	mov	ax, L_lab7app_39
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	132
	; >>>>> tmp = (int) (idleCount/max); 
	mov	ax, word [bp-6]
	xor	dx, dx
	div	word [bp-2]
	mov	word [bp-8], ax
	; >>>>> Line:	133
	; >>>>> printInt(100-tmp); 
	mov	ax, 100
	sub	ax, word [bp-8]
	push	ax
	call	printInt
	add	sp, 2
	; >>>>> Line:	134
	; >>>>> printString("% >>>>>\r\n"); 
	mov	ax, L_lab7app_40
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	136
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	137
	; >>>>> YK 
	mov	word [YKCtxSwCount], 0
	; >>>>> Line:	138
	; >>>>> YKIdleCount = 0; 
	mov	word [YKIdleCount], 0
	; >>>>> Line:	139
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
L_lab7app_44:
	jmp	L_lab7app_43
L_lab7app_45:
	mov	sp, bp
	pop	bp
	ret
L_lab7app_41:
	push	bp
	mov	bp, sp
	sub	sp, 8
	jmp	L_lab7app_42
L_lab7app_48:
	DB	"numEvent: ",0
L_lab7app_47:
	DB	"charEvent: ",0
	ALIGN	2
main:
	; >>>>> Line:	145
	; >>>>> { 
	jmp	L_lab7app_49
L_lab7app_50:
	; >>>>> Line:	146
	; >>>>> YKInitialize(); 
	call	YKInitialize
	; >>>>> Line:	148
	; >>>>> charEvent = YKEventCreate(0); 
	xor	ax, ax
	push	ax
	call	YKEventCreate
	add	sp, 2
	mov	word [charEvent], ax
	; >>>>> Line:	149
	; >>>>> printString("charEvent: "); 
	mov	ax, L_lab7app_47
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	150
	; >>>>> printWord(charEvent); 
	push	word [charEvent]
	call	printWord
	add	sp, 2
	; >>>>> Line:	151
	; >>>>> printNewLine(); 
	call	printNewLine
	; >>>>> Line:	152
	; >>>>> numEvent = YKEventCreate(0); 
	xor	ax, ax
	push	ax
	call	YKEventCreate
	add	sp, 2
	mov	word [numEvent], ax
	; >>>>> Line:	153
	; >>>>> printString("numEvent: "); 
	mov	ax, L_lab7app_48
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	154
	; >>>>> printWord(numEvent); 
	push	word [numEvent]
	call	printWord
	add	sp, 2
	; >>>>> Line:	155
	; >>>>> printNewLine(); 
	call	printNewLine
	; >>>>> Line:	156
	; >>>>> YKNewTask(STask, (void *) &STaskStk[512], 0); 
	xor	al, al
	push	ax
	mov	ax, (STaskStk+1024)
	push	ax
	mov	ax, STask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	158
	; >>>>> YKRun(); 
	call	YKRun
	mov	sp, bp
	pop	bp
	ret
L_lab7app_49:
	push	bp
	mov	bp, sp
	jmp	L_lab7app_50
	ALIGN	2
charEvent:
	TIMES	2 db 0
numEvent:
	TIMES	2 db 0
CharTaskStk:
	TIMES	1024 db 0
AllCharsTaskStk:
	TIMES	1024 db 0
AllNumsTaskStk:
	TIMES	1024 db 0
STaskStk:
	TIMES	1024 db 0
