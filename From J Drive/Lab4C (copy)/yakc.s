; Generated by c86 (BYU-NASM) 5.1 (beta) from yakc.i
	CPU	8086
	ALIGN	2
	jmp	main	; Jump to program start
	ALIGN	2
FLAGS_MASK:
	DW	512
YKInterruptDepth:
	DW	0
kernelStarted:
	DW	0
readyToStart:
	DB	0
runningTask:
	DB	1
firstTime:
	DB	1
	ALIGN	2
YKInitialize:
	; >>>>> Line:	34
	; >>>>> { 
	jmp	L_yakc_1
L_yakc_2:
	; >>>>> Line:	37
	; >>>>> for (i = 0; i < 3; ++i) 
	mov	word [bp-2], 0
	jmp	L_yakc_4
L_yakc_3:
	; >>>>> Line:	39
	; >>>>> YKTCBArray[i].priority = 100; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 6
	mov	byte [si], 100
	; >>>>> Line:	40
	; >>>>> YKTCBArray[i].inUse = 0; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 10
	mov	byte [si], 0
L_yakc_6:
	inc	word [bp-2]
L_yakc_4:
	cmp	word [bp-2], 3
	jl	L_yakc_3
L_yakc_5:
	; >>>>> Line:	43
	; >>>>> YKNewTask(YKIdleTask, (void *)&IdleStk[256], 99); 
	mov	al, 99
	push	ax
	mov	ax, (IdleStk+512)
	push	ax
	mov	ax, YKIdleTask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	44
	; >>>>> readyToStart = 0; 
	mov	byte [readyToStart], 0
	mov	sp, bp
	pop	bp
	ret
L_yakc_1:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_yakc_2
	ALIGN	2
YKIdleTask:
	; >>>>> Line:	48
	; >>>>> { 
	jmp	L_yakc_8
L_yakc_9:
	; >>>>> Line:	49
	; >>>>> while(1) 
	jmp	L_yakc_11
L_yakc_10:
	; >>>>> Line:	52
	; >>>>> ++YKIdleCount; 
	inc	word [YKIdleCount]
L_yakc_11:
	jmp	L_yakc_10
L_yakc_12:
	mov	sp, bp
	pop	bp
	ret
L_yakc_8:
	push	bp
	mov	bp, sp
	jmp	L_yakc_9
	ALIGN	2
YKNewTask:
	; >>>>> Line:	58
	; >>>>> { 
	jmp	L_yakc_14
L_yakc_15:
	; >>>>> Line:	63
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	65
	; >>>>> for (i = 0; i <= 3; ++i) 
	mov	word [bp-2], 0
	jmp	L_yakc_17
L_yakc_16:
	; >>>>> Line:	67
	; >>>>> if (!YKTCBArray[i].inUse) 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 10
	mov	al, byte [si]
	test	al, al
	jne	L_yakc_20
	; >>>>> Line:	68
	; >>>>> break; 
	jmp	L_yakc_18
L_yakc_20:
L_yakc_19:
	inc	word [bp-2]
L_yakc_17:
	cmp	word [bp-2], 3
	jle	L_yakc_16
L_yakc_18:
	; >>>>> Line:	71
	; >>>>> YKTCBArray[i].ip = (unsigned int) task; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	mov	si, ax
	add	si, YKTCBArray
	mov	ax, word [bp+4]
	mov	word [si], ax
	; >>>>> Line:	72
	; >>>>> YKTCBArray[i].stackptr = taskStack; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 2
	mov	ax, word [bp+6]
	mov	word [si], ax
	; >>>>> Line:	73
	; >>>>> YKTCBArray[i].state = READY; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 4
	mov	word [si], 3
	; >>>>> Line:	74
	; >>>>> YKTCBArray[i].delay = 0; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 8
	mov	word [si], 0
	; >>>>> Line:	75
	; >>>>> YKTCBArray[i].inUse = 1; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 10
	mov	byte [si], 1
	; >>>>> Line:	76
	; >>>>> YKTCBArray[i].priority = priority; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 6
	mov	al, byte [bp+8]
	mov	byte [si], al
	; >>>>> Line:	77
	; >>>>> YKTCBArray[i].hasRun = 0; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 11
	mov	byte [si], 0
	; >>>>> Line:	78
	; >>>>> YKCreateContext(YKTCBArray[i].stackptr, YKTCBArray[i].ip); 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	mov	si, ax
	add	si, YKTCBArray
	push	word [si]
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 2
	push	word [si]
	call	YKCreateContext
	add	sp, 4
	; >>>>> Line:	79
	; >>>>> YKTCBArray[i].stackptr += 24; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 2
	add	word [si], -24
	; >>>>> Line:	80
	; >>>>> readyToStart = 1; 
	mov	byte [readyToStart], 1
	; >>>>> Line:	82
	; >>>>> if(kernelStart 
	mov	ax, word [kernelStarted]
	test	ax, ax
	je	L_yakc_21
	; >>>>> Line:	84
	; >>>>> currentTask = &YKTCBArray[i]; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	word [currentTask], ax
	; >>>>> Line:	85
	; >>>>> YKScheduler(); 
	call	YKScheduler
L_yakc_21:
	mov	sp, bp
	pop	bp
	ret
L_yakc_14:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_yakc_15
	ALIGN	2
YKRun:
	; >>>>> Line:	90
	; >>>>> { 
	jmp	L_yakc_23
L_yakc_24:
	; >>>>> Line:	91
	; >>>>> if (kernelStarted || !readyToStart) 
	mov	ax, word [kernelStarted]
	test	ax, ax
	jne	L_yakc_26
	mov	al, byte [readyToStart]
	test	al, al
	jne	L_yakc_25
L_yakc_26:
	; >>>>> Line:	92
	; >>>>> return; 
	jmp	L_yakc_27
L_yakc_25:
	; >>>>> Line:	94
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	95
	; >>>>> kernelStarted = 1; 
	mov	word [kernelStarted], 1
	; >>>>> Line:	96
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	; >>>>> Line:	98
	; >>>>> YKScheduler(); 
	call	YKScheduler
L_yakc_27:
	mov	sp, bp
	pop	bp
	ret
L_yakc_23:
	push	bp
	mov	bp, sp
	jmp	L_yakc_24
	ALIGN	2
YKScheduler:
	; >>>>> Line:	102
	; >>>>> { 
	jmp	L_yakc_29
L_yakc_30:
	; >>>>> Line:	107
	; >>>>> YKEnterMutex(); 
	mov	byte [bp-3], 100
	mov	byte [bp-4], 0
	; >>>>> Line:	107
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	109
	; >>>>> for (i = 0; i <= 3; ++i) 
	mov	word [bp-2], 0
	jmp	L_yakc_32
L_yakc_31:
	; >>>>> Line:	111
	; >>>>> if (!YKTCBArray[i].inUse) 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 10
	mov	al, byte [si]
	test	al, al
	jne	L_yakc_35
	; >>>>> Line:	112
	; >>>>> break; 
	jmp	L_yakc_33
L_yakc_35:
	; >>>>> Line:	113
	; >>>>> if (YKTCBArray[i].priority < maxPriority && YKTCBArray[i].state == READY) 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 6
	mov	al, byte [si]
	cbw
	mov	dl, byte [bp-3]
	xor	dh, dh
	cmp	dx, ax
	jle	L_yakc_36
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 4
	cmp	word [si], 3
	jne	L_yakc_36
	; >>>>> Line:	115
	; >>>>> maxPriority = YKTCBArray[i].priority; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 6
	mov	al, byte [si]
	mov	byte [bp-3], al
	; >>>>> Line:	116
	; >>>>> toRun = i 
	mov	al, byte [bp-2]
	mov	byte [bp-4], al
	; >>>>> Line:	117
	; >>>>> nextTask = &YKTCBArray[i]; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	word [nextTask], ax
L_yakc_36:
L_yakc_34:
	inc	word [bp-2]
L_yakc_32:
	cmp	word [bp-2], 3
	jle	L_yakc_31
L_yakc_33:
	; >>>>> Line:	121
	; >>>>> if (!kernelStarted || (runningTask == toRun && !firstTime)) 
	mov	ax, word [kernelStarted]
	test	ax, ax
	je	L_yakc_38
	mov	al, byte [bp-4]
	cmp	al, byte [runningTask]
	jne	L_yakc_37
	mov	al, byte [firstTime]
	test	al, al
	jne	L_yakc_37
L_yakc_38:
	; >>>>> Line:	123
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	; >>>>> Line:	124
	; >>>>> return; 
	jmp	L_yakc_39
L_yakc_37:
	; >>>>> Line:	126
	; >>>>> if(firstTime) { 
	mov	al, byte [firstTime]
	test	al, al
	je	L_yakc_40
	; >>>>> Line:	127
	; >>>>> firstTime = 0; 
	mov	byte [firstTime], 0
	; >>>>> Line:	128
	; >>>>> currentTaskIp = YKTCBArray[toRun].ip; 
	mov	al, byte [bp-4]
	xor	ah, ah
	mov	cx, 12
	imul	cx
	mov	si, ax
	add	si, YKTCBArray
	mov	ax, word [si]
	mov	word [currentTaskIp], ax
	; >>>>> Line:	129
	; >>>>> currentTask = &YKTCBArray[toRun]; 
	mov	al, byte [bp-4]
	xor	ah, ah
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	word [currentTask], ax
	; >>>>> Line:	130
	; >>>>> runningTask = toRun; 
	mov	al, byte [bp-4]
	mov	byte [runningTask], al
	; >>>>> Line:	131
	; >>>>> YKDispatcherFirst(); 
	call	YKDispatcherFirst
L_yakc_40:
	; >>>>> Line:	133
	; >>>>> ++YKCtxSwCount; 
	inc	word [YKCtxSwCount]
	; >>>>> Line:	134
	; >>>>> currentTask = &YKTCBArray[runningTask]; 
	mov	al, byte [runningTask]
	xor	ah, ah
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	word [currentTask], ax
	; >>>>> Line:	135
	; >>>>> runningTask = toRun; 
	mov	al, byte [bp-4]
	mov	byte [runningTask], al
	; >>>>> Line:	136
	; >>>>> YKDispatcher(); 
	call	YKDispatcher
L_yakc_39:
	mov	sp, bp
	pop	bp
	ret
L_yakc_29:
	push	bp
	mov	bp, sp
	sub	sp, 4
	jmp	L_yakc_30
	ALIGN	2
YKDelayTask:
	; >>>>> Line:	141
	; >>>>> { 
	jmp	L_yakc_42
L_yakc_43:
	; >>>>> Line:	142
	; >>>>> if(count > 0) { 
	mov	ax, word [bp+4]
	test	ax, ax
	je	L_yakc_44
	; >>>>> Line:	143
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	144
	; >>>>> YKTCBArray[runningTask].delay = count; 
	mov	al, byte [runningTask]
	xor	ah, ah
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 8
	mov	ax, word [bp+4]
	mov	word [si], ax
	; >>>>> Line:	145
	; >>>>> ); 
	mov	al, byte [runningTask]
	xor	ah, ah
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 4
	mov	word [si], 1
	; >>>>> Line:	146
	; >>>>> YKScheduler(); 
	call	YKScheduler
L_yakc_44:
	mov	sp, bp
	pop	bp
	ret
L_yakc_42:
	push	bp
	mov	bp, sp
	jmp	L_yakc_43
	ALIGN	2
YKEnterISR:
	; >>>>> Line:	151
	; >>>>> { 
	jmp	L_yakc_46
L_yakc_47:
	; >>>>> Line:	152
	; >>>>> ++YKInterruptDepth; 
	inc	word [YKInterruptDepth]
	mov	sp, bp
	pop	bp
	ret
L_yakc_46:
	push	bp
	mov	bp, sp
	jmp	L_yakc_47
	ALIGN	2
YKExitISR:
	; >>>>> Line:	156
	; >>>>> { 
	jmp	L_yakc_49
L_yakc_50:
	; >>>>> Line:	157
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	158
	; >>>>> --YKInterruptDepth; 
	dec	word [YKInterruptDepth]
	; >>>>> Line:	159
	; >>>>> if(YKInterruptDepth == 0 && kernelStarted && readyToStart) { 
	mov	ax, word [YKInterruptDepth]
	test	ax, ax
	jne	L_yakc_51
	mov	ax, word [kernelStarted]
	test	ax, ax
	je	L_yakc_51
	mov	al, byte [readyToStart]
	test	al, al
	je	L_yakc_51
	; >>>>> Line:	160
	; >>>>> YKScheduler(); 
	call	YKScheduler
L_yakc_51:
	; >>>>> Line:	162
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	mov	sp, bp
	pop	bp
	ret
L_yakc_49:
	push	bp
	mov	bp, sp
	jmp	L_yakc_50
	ALIGN	2
YKTickHandler:
	; >>>>> Line:	166
	; >>>>> { 
	jmp	L_yakc_53
L_yakc_54:
	; >>>>> Line:	168
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	169
	; >>>>> ++YKTickNum; 
	inc	word [YKTickNum]
	; >>>>> Line:	170
	; >>>>> for (i = 0; i <= 3; ++i) 
	mov	word [bp-2], 0
	jmp	L_yakc_56
L_yakc_55:
	; >>>>> Line:	172
	; >>>>> if(YKTCBArray[i].delay > 0) { 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 8
	cmp	word [si], 0
	jle	L_yakc_59
	; >>>>> Line:	173
	; >>>>> --YKTCBArray[i].delay; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 8
	dec	word [si]
	; >>>>> Line:	174
	; >>>>> if(YKTCBArray[i].delay == 0) { 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 8
	mov	ax, word [si]
	test	ax, ax
	jne	L_yakc_60
	; >>>>> Line:	175
	; >>>>> YKTCBArray[i].state = READY; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 4
	mov	word [si], 3
L_yakc_60:
L_yakc_59:
L_yakc_58:
	inc	word [bp-2]
L_yakc_56:
	cmp	word [bp-2], 3
	jle	L_yakc_55
L_yakc_57:
	; >>>>> Line:	179
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	mov	sp, bp
	pop	bp
	ret
L_yakc_53:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_yakc_54
	ALIGN	2
YKCtxSwCount:
	TIMES	2 db 0
YKIdleCount:
	TIMES	2 db 0
YKTickNum:
	TIMES	2 db 0
IdleStk:
	TIMES	512 db 0
currentTaskIp:
	TIMES	2 db 0
currentTask:
	TIMES	2 db 0
nextTask:
	TIMES	2 db 0
YKTCBArray:
	TIMES	48 db 0
