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
	DB	0
firstTime:
	DB	1
	ALIGN	2
YKInitialize:
	; >>>>> Line:	33
	; >>>>> { 
	jmp	L_yakc_1
L_yakc_2:
	; >>>>> Line:	35
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
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
	; >>>>> Line:	49
	; >>>>> { 
	jmp	L_yakc_8
L_yakc_9:
	; >>>>> Line:	50
	; >>>>> while(1) 
	jmp	L_yakc_11
L_yakc_10:
	; >>>>> Line:	52
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	53
	; >>>>> ++YKIdleCount; 
	inc	word [YKIdleCount]
	; >>>>> Line:	54
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
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
	; >>>>> Line:	59
	; >>>>> { 
	jmp	L_yakc_14
L_yakc_15:
	; >>>>> Line:	64
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	66
	; >>>>> for (i = 0; i <= 3; ++i) 
	mov	word [bp-2], 0
	jmp	L_yakc_17
L_yakc_16:
	; >>>>> Line:	68
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
	; >>>>> Line:	69
	; >>>>> break; 
	jmp	L_yakc_18
L_yakc_20:
L_yakc_19:
	inc	word [bp-2]
L_yakc_17:
	cmp	word [bp-2], 3
	jle	L_yakc_16
L_yakc_18:
	; >>>>> Line:	72
	; >>>>> YKTCBArray[i].ip = (unsigned int) task; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	mov	si, ax
	add	si, YKTCBArray
	mov	ax, word [bp+4]
	mov	word [si], ax
	; >>>>> Line:	73
	; >>>>> YKTCBArray[i].stackptr = taskStack; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 2
	mov	ax, word [bp+6]
	mov	word [si], ax
	; >>>>> Line:	74
	; >>>>> YKTCBArray[i].state = READY; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 4
	mov	word [si], 3
	; >>>>> Line:	75
	; >>>>> YKTCBArray[i].delay = 0; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 8
	mov	word [si], 0
	; >>>>> Line:	76
	; >>>>> YKTCBArray[i].inUse = 1; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 10
	mov	byte [si], 1
	; >>>>> Line:	77
	; >>>>> YKTCBArray[i].priority = priority; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 6
	mov	al, byte [bp+8]
	mov	byte [si], al
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
	; >>>>> if(kernelStarted) 
	mov	ax, word [kernelStarted]
	test	ax, ax
	je	L_yakc_21
	; >>>>> Line:	84
	; >>>>> currentTask = &YKTC 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	word [currentTask], ax
	; >>>>> Line:	85
	; >>>>> YKScheduler(); 
	call	YKScheduler
L_yakc_21:
	; >>>>> Line:	87
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
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
	; >>>>> Line:	91
	; >>>>> { 
	jmp	L_yakc_23
L_yakc_24:
	; >>>>> Line:	92
	; >>>>> if (kernelStarted || !readyToStart) 
	mov	ax, word [kernelStarted]
	test	ax, ax
	jne	L_yakc_26
	mov	al, byte [readyToStart]
	test	al, al
	jne	L_yakc_25
L_yakc_26:
	; >>>>> Line:	93
	; >>>>> return; 
	jmp	L_yakc_27
L_yakc_25:
	; >>>>> Line:	95
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	96
	; >>>>> kernelStarted = 1; 
	mov	word [kernelStarted], 1
	; >>>>> Line:	97
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	; >>>>> Line:	99
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
	; >>>>> Line:	103
	; >>>>> { 
	jmp	L_yakc_29
L_yakc_30:
	; >>>>> Line:	108
	; >>>>> YKEnterMutex(); 
	mov	byte [bp-3], 100
	mov	byte [bp-4], 0
	; >>>>> Line:	108
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	110
	; >>>>> for (i = 0; i <= 3; ++i) 
	mov	word [bp-2], 0
	jmp	L_yakc_32
L_yakc_31:
	; >>>>> Line:	112
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
	; >>>>> Line:	113
	; >>>>> break; 
	jmp	L_yakc_33
L_yakc_35:
	; >>>>> Line:	114
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
	; >>>>> Line:	116
	; >>>>> maxPriority = YKTCBArray[i].priority; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 6
	mov	al, byte [si]
	mov	byte [bp-3], al
	; >>>>> Line:	117
	; >>>>> toRun = i; 
	mov	al, byte [bp-2]
	mov	byte [bp-4], al
L_yakc_36:
L_yakc_34:
	inc	word [bp-2]
L_yakc_32:
	cmp	word [bp-2], 3
	jle	L_yakc_31
L_yakc_33:
	; >>>>> Line:	120
	; >>>>>  
	mov	al, byte [bp-4]
	xor	ah, ah
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	word [nextTask], ax
	; >>>>> Line:	122
	; >>>>> if (!kernelStarted) 
	mov	ax, word [kernelStarted]
	test	ax, ax
	jne	L_yakc_37
	; >>>>> Line:	123
	; >>>>> return; 
	jmp	L_yakc_38
L_yakc_37:
	; >>>>> Line:	125
	; >>>>> if (runningTask == toRun && !firstTime) 
	mov	al, byte [bp-4]
	cmp	al, byte [runningTask]
	jne	L_yakc_39
	mov	al, byte [firstTime]
	test	al, al
	jne	L_yakc_39
	; >>>>> Line:	127
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	; >>>>> Line:	128
	; >>>>> return; 
	jmp	L_yakc_38
L_yakc_39:
	; >>>>> Line:	130
	; >>>>> if(firstTime) { 
	mov	al, byte [firstTime]
	test	al, al
	je	L_yakc_40
	; >>>>> Line:	131
	; >>>>> firstTime = 0; 
	mov	byte [firstTime], 0
	; >>>>> Line:	132
	; >>>>> currentTask = &YKTCBArray[toRun]; 
	mov	al, byte [bp-4]
	xor	ah, ah
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	word [currentTask], ax
	; >>>>> Line:	133
	; >>>>> runningTask = toRun; 
	mov	al, byte [bp-4]
	mov	byte [runningTask], al
	; >>>>> Line:	134
	; >>>>> YKDispatcherFirst(); 
	call	YKDispatcherFirst
L_yakc_40:
	; >>>>> Line:	136
	; >>>>> ++YKCtxSwCount; 
	inc	word [YKCtxSwCount]
	; >>>>> Line:	137
	; >>>>> currentTask = &YKTCBArray[runningTask]; 
	mov	al, byte [runningTask]
	xor	ah, ah
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	word [currentTask], ax
	; >>>>> Line:	138
	; >>>>> runningTask = toRun; 
	mov	al, byte [bp-4]
	mov	byte [runningTask], al
	; >>>>> Line:	139
	; >>>>> YKDispatcher(); 
	call	YKDispatcher
L_yakc_38:
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
	; >>>>> Line:	144
	; >>>>> { 
	jmp	L_yakc_42
L_yakc_43:
	; >>>>> Line:	145
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	147
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
	; >>>>> Line:	148
	; >>>>> YKTCBArray[runningTask].state = DELAYED; 
	mov	al, byte [runningTask]
	xor	ah, ah
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 4
	mov	word [si], 1
	; >>>>> Line:	149
	; >>>>> YKScheduler(); 
	call	YKScheduler
	; >>>>> Line:	151
	; >>>>>  
	call	YKExitMutex
	mov	sp, bp
	pop	bp
	ret
L_yakc_42:
	push	bp
	mov	bp, sp
	jmp	L_yakc_43
	ALIGN	2
YKEnterISR:
	; >>>>> Line:	155
	; >>>>> { 
	jmp	L_yakc_45
L_yakc_46:
	; >>>>> Line:	156
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	157
	; >>>>> ++YKInterruptDepth; 
	inc	word [YKInterruptDepth]
	; >>>>> Line:	158
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	mov	sp, bp
	pop	bp
	ret
L_yakc_45:
	push	bp
	mov	bp, sp
	jmp	L_yakc_46
	ALIGN	2
YKExitISR:
	; >>>>> Line:	162
	; >>>>> { 
	jmp	L_yakc_48
L_yakc_49:
	; >>>>> Line:	163
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	164
	; >>>>> --YKInterruptDepth; 
	dec	word [YKInterruptDepth]
	; >>>>> Line:	165
	; >>>>> if(YKInterruptDepth == 0 && kernelStarted && readyToStart) { 
	mov	ax, word [YKInterruptDepth]
	test	ax, ax
	jne	L_yakc_50
	mov	ax, word [kernelStarted]
	test	ax, ax
	je	L_yakc_50
	mov	al, byte [readyToStart]
	test	al, al
	je	L_yakc_50
	; >>>>> Line:	166
	; >>>>> YKScheduler(); 
	call	YKScheduler
L_yakc_50:
	; >>>>> Line:	168
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	mov	sp, bp
	pop	bp
	ret
L_yakc_48:
	push	bp
	mov	bp, sp
	jmp	L_yakc_49
	ALIGN	2
YKTickHandler:
	; >>>>> Line:	172
	; >>>>> { 
	jmp	L_yakc_52
L_yakc_53:
	; >>>>> Line:	174
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	175
	; >>>>> ++YKTickNum; 
	inc	word [YKTickNum]
	; >>>>> Line:	176
	; >>>>> for (i = 1; i <= 3; ++i) 
	mov	word [bp-2], 1
	jmp	L_yakc_55
L_yakc_54:
	; >>>>> Line:	178
	; >>>>> if(YKTCBArray[i].state == DELAYED) { 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 4
	cmp	word [si], 1
	jne	L_yakc_58
	; >>>>> Line:	179
	; >>>>> if(YKTCBArray[i].delay == 1) { 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 8
	cmp	word [si], 1
	jne	L_yakc_59
	; >>>>> Line:	180
	; >>>>> YKTCBArray[i].state = READY; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 4
	mov	word [si], 3
L_yakc_59:
	; >>>>> Line:	182
	; >>>>> --YKTCBArray[i].delay; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 8
	dec	word [si]
L_yakc_58:
L_yakc_57:
	inc	word [bp-2]
L_yakc_55:
	cmp	word [bp-2], 3
	jle	L_yakc_54
L_yakc_56:
	; >>>>> Line:	185
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	mov	sp, bp
	pop	bp
	ret
L_yakc_52:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_yakc_53
	ALIGN	2
YKCtxSwCount:
	TIMES	2 db 0
YKIdleCount:
	TIMES	2 db 0
YKTickNum:
	TIMES	2 db 0
IdleStk:
	TIMES	512 db 0
currentTask:
	TIMES	2 db 0
nextTask:
	TIMES	2 db 0
YKTCBArray:
	TIMES	48 db 0
