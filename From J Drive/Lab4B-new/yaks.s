;Kernel routines written in assembly

YKEnterMutex:
	cli
	ret

YKExitMutex:
	sti
	ret

YKDispatcher:
	mov		ax, [nextTask]
	push 	ax
	ret
