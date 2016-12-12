; Modify AsmFunction to perform the calculation gvar+(a*(b+c))/(d-e).
; Keep in mind the C declaration:
; int AsmFunction(int a, char b, char c, int d, int e);

	CPU	8086
	align	2

AsmFunction:
	push    bp
	mov     bp, sp
	;[bp+4] -> a
	;[bp+6] -> b
	;[bp+8] -> c
	;[bp+10] -> d
	;[bp+12] -> e
	
	mov ax, [bp+6]
	cbw
	push bx
	mov bx, ax
	mov ax, [bp+8]
	cbw
	add ax, bx
	mov bx, [bp+4]
	imul bx

	mov bx, [bp+10]
	sub bx, [bp+12]
	idiv bx

	add ax, [gvar]

	pop bx
    pop bp
	ret
