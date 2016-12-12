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
	;call pushed

	mov 	bx, [currentTask]
	mov		[bx + 2], sp

	mov		bx, [nextTask]
	mov 	sp, [bx + 2]
	pop		ds
	pop 	es
	pop 	di
	pop 	si
 	pop 	dx
	pop 	cx
  pop 	bx
  pop 	ax
	pop 	bp
	;call popped
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

YKDispatcherNoSave:
	mov 	bx, [currentTask]
	add		sp, 14
	mov		[bx + 2], sp

	mov		bx, [nextTask]
	mov 	sp, [bx + 2]
	pop		ds
	pop 	es
	pop 	di
	pop 	si
	pop 	dx
	pop 	cx
	pop 	bx
	pop 	ax
	pop 	bp
	;call popped
	iret
