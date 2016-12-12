;Kernel routines written in assembly

YKEnterMutex:
	cli
	ret

YKExitMutex:
	sti
	ret

YKDispatcherFirst:
	mov		bx, [nextTask]
	mov 	sp, [bx + 2]
	;mov sp, [nextTask + 2]
	pop		ds
	pop 	es
	pop 	di
	pop 	si
	pop 	dx
	pop 	cx
	pop 	bx
	pop 	ax
	pop 	bp
	iret



YKDispatcherHelper:
	pushf
	push	cs
	push	word[bp+2]
	push 	bp
	push 	ax
	push 	bx
	push 	cx
	push 	dx
	push 	si
	push 	di
	push 	es
	push 	ds
	mov 	bx, [nextTask]
	mov		[bx + 2], sp
	push  word[bx]
	call	YKExitMutex
	ret


	;push 	bp
	;mov 	bp, sp
	;push 	word[bp+4]
	;call 	YKExitMutex
	;ret


YKDispatcher:
	pushf
	push	cs
	push	word[bp+2]
	push 	bp
	push 	ax
	push 	bx
	push 	cx
	push 	dx
	push 	si
	push 	di
	push 	es
	push 	ds
	mov 	bx, [currentTask]
	mov		[bx + 2], sp
	;mov		[currentTask + 2], sp

	mov		bx, [nextTask]
	mov 	sp, [bx + 2]
	;mov sp, [nextTask + 2]
	pop		ds
	pop 	es
	pop 	di
	pop 	si
 	pop 	dx
	pop 	cx
  pop 	bx
  pop 	ax
	pop 	bp
  iret

YKCreateContext:
	push	bp
	mov		bp, sp
	push  word[bp + 4]
	mov		[bp + 4], sp
	pop 	sp
	push	word[FLAGS_MASK]
	push 	cs
	push	word[bp + 6]
	push 	bp
	push 	ax
	push 	bx
	push 	cx
	push 	dx
	push 	si
	push 	di
	push 	es
	push 	ds

	mov		sp, [bp + 4]
	pop 	bp
	pop		bp
	ret
