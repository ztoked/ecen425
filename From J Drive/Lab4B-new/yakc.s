; Generated by c86 (BYU-NASM) 5.1 (beta) from yakc.i
	CPU	8086
	ALIGN	2
	jmp	main	; Jump to program start
	ALIGN	2
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
	; >>>>> Line:	29
	; >>>>> { 
	jmp	L_yakc_1
L_yakc_2:
	; >>>>> Line:	32
	; >>>>> for (i = 0; i < 3; ++i) 
	mov	word [bp-2], 0
	jmp	L_yakc_4
L_yakc_3:
	; >>>>> Line:	34
	; >>>>> YKTCBArray[i].priority = 100; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 6
	mov	byte [si], 100
	; >>>>> Line:	35
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
	; >>>>> Line:	38
	; >>>>> YKNewTask(YKIdleTask, (void *)&IdleStk[256], 99); 
	mov	al, 99
	push	ax
	mov	ax, (IdleStk+512)
	push	ax
	mov	ax, YKIdleTask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	39
	; >>>>> ed) 
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
	; >>>>> Line:	43
	; >>>>> { 
	jmp	L_yakc_8
L_yakc_9:
	; >>>>> Line:	44
	; >>>>> while(1) 
	jmp	L_yakc_11
L_yakc_10:
	; >>>>> Line:	46
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	47
	; >>>>> ++YKIdleCount; 
	inc	word [YKIdleCount]
	; >>>>> Line:	48
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
	; >>>>> Line:	53
	; >>>>> { 
	jmp	L_yakc_14
L_yakc_15:
	; >>>>> Line:	59
	; >>>>> for (i = 0; i < 3; ++i) 
	mov	word [bp-2], 0
	jmp	L_yakc_17
L_yakc_16:
	; >>>>> Line:	61
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
	; >>>>> Line:	62
	; >>>>> break; 
	jmp	L_yakc_18
L_yakc_20:
L_yakc_19:
	inc	word [bp-2]
L_yakc_17:
	cmp	word [bp-2], 3
	jl	L_yakc_16
L_yakc_18:
	; >>>>> Line:	65
	; >>>>> YKTCBArray[i].ip = (unsigned int) task; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	mov	si, ax
	add	si, YKTCBArray
	mov	ax, word [bp+4]
	mov	word [si], ax
	; >>>>> Line:	66
	; >>>>> YKTCBArray[i].stackptr = taskStack; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 2
	mov	ax, word [bp+6]
	mov	word [si], ax
	; >>>>> Line:	67
	; >>>>> YKTCBArray[i].state = RUNNING; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 4
	mov	word [si], 0
	; >>>>> Line:	68
	; >>>>> YKTCBArray[i].delay = 0; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 8
	mov	word [si], 0
	; >>>>> Line:	69
	; >>>>> YKTCBArray[i].inUse = 1; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 10
	mov	byte [si], 1
	; >>>>> Line:	70
	; >>>>> YKTCBArray[i].priority = priority; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 6
	mov	al, byte [bp+8]
	mov	byte [si], al
	; >>>>> Line:	71
	; >>>>> readyToStart = 1; 
	mov	byte [readyToStart], 1
	; >>>>> Line:	73
	; >>>>> if(kernelStarted) 
	mov	ax, word [kernelStarted]
	test	ax, ax
	je	L_yakc_21
	; >>>>> Line:	75
	; >>>>> Y 
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
	; >>>>> Line:	80
	; >>>>> { 
	jmp	L_yakc_23
L_yakc_24:
	; >>>>> Line:	81
	; >>>>> if (kernelStarted || !readyToStart) 
	mov	ax, word [kernelStarted]
	test	ax, ax
	jne	L_yakc_26
	mov	al, byte [readyToStart]
	test	al, al
	jne	L_yakc_25
L_yakc_26:
	; >>>>> Line:	82
	; >>>>> return; 
	jmp	L_yakc_27
L_yakc_25:
	; >>>>> Line:	84
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	85
	; >>>>> kernelStarted = 1; 
	mov	word [kernelStarted], 1
	; >>>>> Line:	86
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	; >>>>> Line:	88
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
	; >>>>> Line:	92
	; >>>>> { 
	jmp	L_yakc_29
L_yakc_30:
	; >>>>> Line:	97
	; >>>>> YKEnterMutex(); 
	mov	al, byte [runningTask]
	xor	ah, ah
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 6
	mov	al, byte [si]
	mov	byte [bp-3], al
	mov	al, byte [runningTask]
	mov	byte [bp-4], al
	; >>>>> Line:	97
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	99
	; >>>>> for (i = 0; i <= 3; ++i) 
	mov	word [bp-2], 0
	jmp	L_yakc_32
L_yakc_31:
	; >>>>> Line:	101
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
	; >>>>> Line:	102
	; >>>>> break; 
	jmp	L_yakc_33
L_yakc_35:
	; >>>>> Line:	103
	; >>>>> if (YKTCBArray[i].priority < YKTCBArray[runningTask].priority) 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 6
	mov	al, byte [runningTask]
	xor	ah, ah
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	di, ax
	add	di, 6
	mov	al, byte [di]
	cmp	al, byte [si]
	jle	L_yakc_36
	; >>>>> Line:	105
	; >>>>> maxPriority = YKTCBArray[i].priority; 
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	add	ax, YKTCBArray
	mov	si, ax
	add	si, 6
	mov	al, byte [si]
	mov	byte [bp-3], al
	; >>>>> Line:	106
	; >>>>> toRun = i; 
	mov	al, byte [bp-2]
	mov	byte [bp-4], al
	; >>>>> Line:	107
	; >>>>> nextTask =  
	mov	ax, word [bp-2]
	mov	cx, 12
	imul	cx
	mov	si, ax
	add	si, YKTCBArray
	mov	ax, word [si]
	mov	word [nextTask], ax
L_yakc_36:
L_yakc_34:
	inc	word [bp-2]
L_yakc_32:
	cmp	word [bp-2], 3
	jle	L_yakc_31
L_yakc_33:
	; >>>>> Line:	111
	; >>>>> if (runningTask == toRun && !firstTime) 
	mov	al, byte [bp-4]
	cmp	al, byte [runningTask]
	jne	L_yakc_37
	mov	al, byte [firstTime]
	test	al, al
	jne	L_yakc_37
	; >>>>> Line:	112
	; >>>>> return; 
	jmp	L_yakc_38
L_yakc_37:
	; >>>>> Line:	114
	; >>>>> if (kernelStarted) 
	mov	ax, word [kernelStarted]
	test	ax, ax
	je	L_yakc_39
	; >>>>> Line:	116
	; >>>>> firstTime = 0; 
	mov	byte [firstTime], 0
	; >>>>> Line:	117
	; >>>>> ++YKCtxSwCount; 
	inc	word [YKCtxSwCount]
	; >>>>> Line:	118
	; >>>>> runningTask = toRun; 
	mov	al, byte [bp-4]
	mov	byte [runningTask], al
	; >>>>> Line:	119
	; >>>>> YKDispatcher(); 
	call	YKDispatcher
L_yakc_39:
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
YKCtxSwCount:
	TIMES	2 db 0
YKIdleCount:
	TIMES	2 db 0
IdleStk:
	TIMES	512 db 0
nextTask:
	TIMES	2 db 0
YKTCBArray:
	TIMES	48 db 0
