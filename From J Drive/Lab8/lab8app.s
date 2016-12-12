; Generated by c86 (BYU-NASM) 5.1 (beta) from lab8app.i
	CPU	8086
	ALIGN	2
	jmp	main	; Jump to program start
L_lab8app_1:
	DB	0
L_lab8app_2:
	DB	"Simptris Started",0xA,0
	ALIGN	2
SimTask:
	; >>>>> Line:	28
	; >>>>> { 
	jmp	L_lab8app_3
L_lab8app_4:
	; >>>>> Line:	31
	; >>>>> SeedSimptris((long)87245); 
	mov	ax, 21709
	mov	dx, 1
	push	dx
	push	ax
	call	SeedSimptris
	add	sp, 4
	; >>>>> Line:	32
	; >>>>> StartSimptris(); 
	call	StartSimptris
	; >>>>> Line:	33
	; >>>>> printString("Simptris Started\n"); 
	mov	ax, L_lab8app_2
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	35
	; >>>>> while(1) 
	jmp	L_lab8app_6
L_lab8app_5:
	; >>>>> Line:	37
	; >>>>> curPiece = (struct piece *) YKQPend(PieceQPtr); 
	push	word [PieceQPtr]
	call	YKQPend
	add	sp, 2
	mov	word [bp-2], ax
	; >>>>> Line:	38
	; >>>>> if(curPiece->type = 
	mov	si, word [bp-2]
	add	si, 2
	cmp	word [si], 1
	jne	L_lab8app_8
	; >>>>> Line:	39
	; >>>>> while(curPiece->column != 4) 
	jmp	L_lab8app_10
L_lab8app_9:
	; >>>>> Line:	41
	; >>>>> if(curPiece->column < 4) { 
	mov	si, word [bp-2]
	add	si, 6
	cmp	word [si], 4
	jge	L_lab8app_12
	; >>>>> Line:	42
	; >>>>> SlidePiece(curPiece->id, 1); 
	mov	ax, 1
	push	ax
	mov	si, word [bp-2]
	push	word [si]
	call	SlidePiece
	add	sp, 4
	; >>>>> Line:	43
	; >>>>> curPiece->column = curPiece->column + 1; 
	mov	si, word [bp-2]
	add	si, 6
	mov	ax, word [si]
	inc	ax
	mov	si, word [bp-2]
	add	si, 6
	mov	word [si], ax
	; >>>>> Line:	44
	; >>>>> YKSemPend(commandSem); 
	push	word [commandSem]
	call	YKSemPend
	add	sp, 2
	jmp	L_lab8app_13
L_lab8app_12:
	; >>>>> Line:	47
	; >>>>> SlidePiece(curPiece->id, 0); 
	xor	ax, ax
	push	ax
	mov	si, word [bp-2]
	push	word [si]
	call	SlidePiece
	add	sp, 4
	; >>>>> Line:	48
	; >>>>> curPiece->column = curPiece->column - 1; 
	mov	si, word [bp-2]
	add	si, 6
	mov	ax, word [si]
	dec	ax
	mov	si, word [bp-2]
	add	si, 6
	mov	word [si], ax
	; >>>>> Line:	49
	; >>>>> YKSemPend(commandSem); 
	push	word [commandSem]
	call	YKSemPend
	add	sp, 2
L_lab8app_13:
L_lab8app_10:
	mov	si, word [bp-2]
	add	si, 6
	cmp	word [si], 4
	jne	L_lab8app_9
L_lab8app_11:
	; >>>>> Line:	52
	; >>>>> if(curPiece->orientation == 1) { 
	mov	si, word [bp-2]
	add	si, 4
	cmp	word [si], 1
	jne	L_lab8app_14
	; >>>>> Line:	53
	; >>>>> RotatePiece(curPiece->id, 1); 
	mov	ax, 1
	push	ax
	mov	si, word [bp-2]
	push	word [si]
	call	RotatePiece
	add	sp, 4
	; >>>>> Line:	54
	; >>>>> YKSemPend(commandSem); 
	push	word [commandSem]
	call	YKSemPend
	add	sp, 2
L_lab8app_14:
	jmp	L_lab8app_15
L_lab8app_8:
	; >>>>> Line:	58
	; >>>>> mand 
	mov	si, word [bp-2]
	add	si, 6
	mov	ax, word [si]
	test	ax, ax
	jne	L_lab8app_16
	; >>>>> Line:	59
	; >>>>> SlidePiece(curPiece->id, 1); 
	mov	ax, 1
	push	ax
	mov	si, word [bp-2]
	push	word [si]
	call	SlidePiece
	add	sp, 4
	; >>>>> Line:	60
	; >>>>> curPiece->column = curPiece->column + 1; 
	mov	si, word [bp-2]
	add	si, 6
	mov	ax, word [si]
	inc	ax
	mov	si, word [bp-2]
	add	si, 6
	mov	word [si], ax
	; >>>>> Line:	61
	; >>>>> YKSemPend(commandSem); 
	push	word [commandSem]
	call	YKSemPend
	add	sp, 2
	jmp	L_lab8app_17
L_lab8app_16:
	; >>>>> Line:	63
	; >>>>> else if(curPiece->column == 5) { 
	mov	si, word [bp-2]
	add	si, 6
	cmp	word [si], 5
	jne	L_lab8app_18
	; >>>>> Line:	64
	; >>>>> SlidePiece(curPiece->id, 0); 
	xor	ax, ax
	push	ax
	mov	si, word [bp-2]
	push	word [si]
	call	SlidePiece
	add	sp, 4
	; >>>>> Line:	65
	; >>>>> curPiece->column = curPiece->column - 1; 
	mov	si, word [bp-2]
	add	si, 6
	mov	ax, word [si]
	dec	ax
	mov	si, word [bp-2]
	add	si, 6
	mov	word [si], ax
	; >>>>> Line:	66
	; >>>>> YKSemPend(commandSem); 
	push	word [commandSem]
	call	YKSemPend
	add	sp, 2
L_lab8app_18:
L_lab8app_17:
	; >>>>> Line:	68
	; >>>>> if(cornerType == 0) { 
	mov	al, byte [L_lab8app_1]
	test	al, al
	jne	L_lab8app_19
	; >>>>> Line:	69
	; >>>>> switch (curPiece->orientation){ 
	mov	si, word [bp-2]
	add	si, 4
	mov	ax, word [si]
	sub	ax, 0
	je	L_lab8app_21
	dec	ax
	je	L_lab8app_22
	dec	ax
	je	L_lab8app_23
	dec	ax
	je	L_lab8app_24
	jmp	L_lab8app_20
L_lab8app_21:
	; >>>>> Line:	71
	; >>>>> break; 
	jmp	L_lab8app_20
L_lab8app_22:
	; >>>>> Line:	73
	; >>>>> RotatePiece(curPiece->id, 1); 
	mov	ax, 1
	push	ax
	mov	si, word [bp-2]
	push	word [si]
	call	RotatePiece
	add	sp, 4
	; >>>>> Line:	74
	; >>>>> YKSemPend(command 
	push	word [commandSem]
	call	YKSemPend
	add	sp, 2
	; >>>>> Line:	75
	; >>>>> break; 
	jmp	L_lab8app_20
L_lab8app_23:
	; >>>>> Line:	77
	; >>>>> RotatePiece(curPiece->id, 1); 
	mov	ax, 1
	push	ax
	mov	si, word [bp-2]
	push	word [si]
	call	RotatePiece
	add	sp, 4
	; >>>>> Line:	78
	; >>>>> YKSemPend(commandSem); 
	push	word [commandSem]
	call	YKSemPend
	add	sp, 2
	; >>>>> Line:	79
	; >>>>> RotatePiece(curPiece->id, 1); 
	mov	ax, 1
	push	ax
	mov	si, word [bp-2]
	push	word [si]
	call	RotatePiece
	add	sp, 4
	; >>>>> Line:	80
	; >>>>> YKSemPend(commandSem); 
	push	word [commandSem]
	call	YKSemPend
	add	sp, 2
	; >>>>> Line:	81
	; >>>>> break; 
	jmp	L_lab8app_20
L_lab8app_24:
	; >>>>> Line:	83
	; >>>>> RotatePiece(curPiece->id, 0); 
	xor	ax, ax
	push	ax
	mov	si, word [bp-2]
	push	word [si]
	call	RotatePiece
	add	sp, 4
	; >>>>> Line:	84
	; >>>>> YKSemPend(commandSem); 
	push	word [commandSem]
	call	YKSemPend
	add	sp, 2
L_lab8app_20:
	; >>>>> Line:	87
	; >>>>> while(curPiece->column > 0) 
	jmp	L_lab8app_26
L_lab8app_25:
	; >>>>> Line:	89
	; >>>>> SlidePiece(curPiece->id, 0); 
	xor	ax, ax
	push	ax
	mov	si, word [bp-2]
	push	word [si]
	call	SlidePiece
	add	sp, 4
	; >>>>> Line:	90
	; >>>>> curPiece->column = curPiece->column - 1; 
	mov	si, word [bp-2]
	add	si, 6
	mov	ax, word [si]
	dec	ax
	mov	si, word [bp-2]
	add	si, 6
	mov	word [si], ax
	; >>>>> Line:	91
	; >>>>> YKSemPend(commandSem); 
	push	word [commandSem]
	call	YKSemPend
	add	sp, 2
L_lab8app_26:
	mov	si, word [bp-2]
	add	si, 6
	cmp	word [si], 0
	jg	L_lab8app_25
L_lab8app_27:
	; >>>>> Line:	93
	; >>>>> cornerType = 1; 
	mov	byte [L_lab8app_1], 1
	jmp	L_lab8app_28
L_lab8app_19:
	; >>>>> Line:	96
	; >>>>> switch (curPiece->orientation){ 
	mov	si, word [bp-2]
	add	si, 4
	mov	ax, word [si]
	sub	ax, 0
	je	L_lab8app_30
	dec	ax
	je	L_lab8app_31
	dec	ax
	je	L_lab8app_32
	dec	ax
	je	L_lab8app_33
	jmp	L_lab8app_29
L_lab8app_30:
	; >>>>> Line:	98
	; >>>>> RotatePiece(curPiece->id, 1); 
	mov	ax, 1
	push	ax
	mov	si, word [bp-2]
	push	word [si]
	call	RotatePiece
	add	sp, 4
	; >>>>> Line:	99
	; >>>>> YKSemPend(commandSem); 
	push	word [commandSem]
	call	YKSemPend
	add	sp, 2
	; >>>>> Line:	100
	; >>>>> RotatePiece(curPiece->id, 1); 
	mov	ax, 1
	push	ax
	mov	si, word [bp-2]
	push	word [si]
	call	RotatePiece
	add	sp, 4
	; >>>>> Line:	101
	; >>>>> YKSemPend(commandSem); 
	push	word [commandSem]
	call	YKSemPend
	add	sp, 2
	; >>>>> Line:	102
	; >>>>> break; 
	jmp	L_lab8app_29
L_lab8app_31:
	; >>>>> Line:	104
	; >>>>> RotatePiece(curPiece->id, 0); 
	xor	ax, ax
	push	ax
	mov	si, word [bp-2]
	push	word [si]
	call	RotatePiece
	add	sp, 4
	; >>>>> Line:	105
	; >>>>> YKSemPend(commandSem); 
	push	word [commandSem]
	call	YKSemPend
	add	sp, 2
	; >>>>> Line:	106
	; >>>>> break; 
	jmp	L_lab8app_29
L_lab8app_32:
	; >>>>> Line:	108
	; >>>>> break; 
	jmp	L_lab8app_29
L_lab8app_33:
	; >>>>> Line:	110
	; >>>>> RotatePiece(curPiece->id, 1); 
	mov	ax, 1
	push	ax
	mov	si, word [bp-2]
	push	word [si]
	call	RotatePiece
	add	sp, 4
	; >>>>> Line:	111
	; >>>>> CPUTask() 
	push	word [commandSem]
	call	YKSemPend
	add	sp, 2
L_lab8app_29:
	; >>>>> Line:	114
	; >>>>> while(curPiece->column != 2) 
	jmp	L_lab8app_35
L_lab8app_34:
	; >>>>> Line:	116
	; >>>>> if(curPiece->column < 2) { 
	mov	si, word [bp-2]
	add	si, 6
	cmp	word [si], 2
	jge	L_lab8app_37
	; >>>>> Line:	117
	; >>>>> SlidePiece(curPiece->id, 1); 
	mov	ax, 1
	push	ax
	mov	si, word [bp-2]
	push	word [si]
	call	SlidePiece
	add	sp, 4
	; >>>>> Line:	118
	; >>>>> curPiece->column = curPiece->column + 1; 
	mov	si, word [bp-2]
	add	si, 6
	mov	ax, word [si]
	inc	ax
	mov	si, word [bp-2]
	add	si, 6
	mov	word [si], ax
	; >>>>> Line:	119
	; >>>>> YKSemPend(commandSem); 
	push	word [commandSem]
	call	YKSemPend
	add	sp, 2
	jmp	L_lab8app_38
L_lab8app_37:
	; >>>>> Line:	122
	; >>>>> SlidePiece(curPiece->id, 0); 
	xor	ax, ax
	push	ax
	mov	si, word [bp-2]
	push	word [si]
	call	SlidePiece
	add	sp, 4
	; >>>>> Line:	123
	; >>>>> curPiece->column = curPiece->column - 1; 
	mov	si, word [bp-2]
	add	si, 6
	mov	ax, word [si]
	dec	ax
	mov	si, word [bp-2]
	add	si, 6
	mov	word [si], ax
	; >>>>> Line:	124
	; >>>>> YKSemPend(commandSem); 
	push	word [commandSem]
	call	YKSemPend
	add	sp, 2
L_lab8app_38:
L_lab8app_35:
	mov	si, word [bp-2]
	add	si, 6
	cmp	word [si], 2
	jne	L_lab8app_34
L_lab8app_36:
	; >>>>> Line:	127
	; >>>>> cornerType = 0; 
	mov	byte [L_lab8app_1], 0
L_lab8app_28:
L_lab8app_15:
L_lab8app_6:
	jmp	L_lab8app_5
L_lab8app_7:
	mov	sp, bp
	pop	bp
	ret
L_lab8app_3:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_lab8app_4
L_lab8app_42:
	DB	">",0xD,0xA,0
L_lab8app_41:
	DB	", CPU: ",0
L_lab8app_40:
	DB	"<CS: ",0
	ALIGN	2
CPUTask:
	; >>>>> Line:	134
	; >>>>> { 
	jmp	L_lab8app_43
L_lab8app_44:
	; >>>>> Line:	138
	; >>>>> YKDelayTask(1); 
	mov	ax, 1
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	139
	; >>>>> YKDelayTask(1); 
	mov	ax, 1
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	140
	; >>>>> YKIdleCount = 0; 
	mov	word [YKIdleCount], 0
	; >>>>> Line:	141
	; >>>>> YKDelayTask(5); 
	mov	ax, 5
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	142
	; >>>>> max = YKIdleCount / 25; 
	mov	ax, word [YKIdleCount]
	xor	dx, dx
	mov	cx, 25
	div	cx
	mov	word [bp-2], ax
	; >>>>> Line:	143
	; >>>>> YKIdleCount = 0; 
	mov	word [YKIdleCount], 0
	; >>>>> Line:	145
	; >>>>> while (1) 
	jmp	L_lab8app_46
L_lab8app_45:
	; >>>>> Line:	147
	; >>>>> YKDelayTask(20); 
	mov	ax, 20
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	149
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	150
	; >>>>> switchCount = YKCtxSwCount; 
	mov	ax, word [YKCtxSwCount]
	mov	word [bp-4], ax
	; >>>>> Line:	151
	; >>>>> idleCount = YKIdleCount; 
	mov	ax, word [YKIdleCount]
	mov	word [bp-6], ax
	; >>>>> Line:	152
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	; >>>>> Line:	155
	; >>>>> printString("<CS: "); 
	mov	ax, L_lab8app_40
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	156
	; >>>>> printInt((int)switchCount); 
	push	word [bp-4]
	call	printInt
	add	sp, 2
	; >>>>> Line:	157
	; >>>>> printString(", CPU: "); 
	mov	ax, L_lab8app_41
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	158
	; >>>>> tmp = (int) (idleCount/max); 
	mov	ax, word [bp-6]
	xor	dx, dx
	div	word [bp-2]
	mov	word [bp-8], ax
	; >>>>> Line:	159
	; >>>>> printInt(100-tmp); 
	mov	ax, 100
	sub	ax, word [bp-8]
	push	ax
	call	printInt
	add	sp, 2
	; >>>>> Line:	160
	; >>>>> printString(">\r\n"); 
	mov	ax, L_lab8app_42
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	162
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	163
	; >>>>> YKCtxSwCount = 0; 
	mov	word [YKCtxSwCount], 0
	; >>>>> Line:	164
	; >>>>> YKIdleCount = 0; 
	mov	word [YKIdleCount], 0
	; >>>>> Line:	165
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
L_lab8app_46:
	jmp	L_lab8app_45
L_lab8app_47:
	mov	sp, bp
	pop	bp
	ret
L_lab8app_43:
	push	bp
	mov	bp, sp
	sub	sp, 8
	jmp	L_lab8app_44
	ALIGN	2
main:
	; >>>>> Line:	170
	; >>>>> { 
	jmp	L_lab8app_49
L_lab8app_50:
	; >>>>> Line:	171
	; >>>>> YKInitialize(); 
	call	YKInitialize
	; >>>>> Line:	172
	; >>>>> YKNewTask(SimTask, (void *) &SimTaskStk[512], 0); 
	xor	al, al
	push	ax
	mov	ax, (SimTaskStk+1024)
	push	ax
	mov	ax, SimTask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	173
	; >>>>> YKNewTask(CPUTask, (void *) &CPUTaskStk[512], 1); 
	mov	al, 1
	push	ax
	mov	ax, (CPUTaskStk+1024)
	push	ax
	mov	ax, CPUTask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	175
	; >>>>> PieceQPtr = YKQCreate(PieceQ, 10); 
	mov	ax, 10
	push	ax
	mov	ax, PieceQ
	push	ax
	call	YKQCreate
	add	sp, 4
	mov	word [PieceQPtr], ax
	; >>>>> Line:	177
	; >>>>> commandSem = YKSemCreate(0); 
	xor	ax, ax
	push	ax
	call	YKSemCreate
	add	sp, 2
	mov	word [commandSem], ax
	; >>>>> Line:	178
	; >>>>> YKRun(); 
	call	YKRun
	mov	sp, bp
	pop	bp
	ret
L_lab8app_49:
	push	bp
	mov	bp, sp
	jmp	L_lab8app_50
	ALIGN	2
CPUTaskStk:
	TIMES	1024 db 0
SimTaskStk:
	TIMES	1024 db 0
pieceArray:
	TIMES	320 db 0
commandSem:
	TIMES	2 db 0
PieceQ:
	TIMES	20 db 0
PieceQPtr:
	TIMES	2 db 0
