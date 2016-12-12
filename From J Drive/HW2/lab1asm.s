; Modify AsmFunction to perform the calculation gvar+(a*(b+c))/(d-e).
; Keep in mind the C declaration:
; int AsmFunction(int a, char b, char c, int d, int e);

	CPU	8086
	align	2

AsmFunction:
	push    bp
	mov     bp, sp	
	push bx
	push cx
	push dx

	mov ax, 0
	mov bx, 2
	mov cx, 0
	mov sp, 0xFFFE

	mov	ax, [bx+2]
	dec	word [bx+2]
	mov	bh, [bx+3]
	mov	cx, [bp+si-3]
	mov	dx, [es:bp+2]
	

    pop bp
	ret
