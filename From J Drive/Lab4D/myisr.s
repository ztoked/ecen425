reset:
	;Step 1
	push ax
	push bx
	push cx
	push dx
	push bp
	mov bp, sp

	;Step 2
	sti

	;Step 3
	mov ax, 0
	push ax
	call exit

	;Step 4
	cli

	;Step 5
	mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
	out	0x20, al	; Write EOI to PIC (port 0x20)

	;Step 6
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax

	;Step 7
	iret

tick:
	;Step 1
	push ax
	push bx
	push cx
	push dx
	push 	si
	push 	di
	push 	es
	push 	ds
	push bp
	mov bp, sp

	;Step 2
	sti
	call YKEnterISR
	;Step 3
	call tickHandler
	call YKTickHandler

	;Step 4
	cli

	;Step 5
	mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
	out	0x20, al	; Write EOI to PIC (port 0x20)

	call YKExitISR

	;Step 6
	pop bp
	pop		ds
	pop 	es
	pop 	di
	pop 	si
	pop dx
	pop cx
	pop bx
	pop ax

	;Step 7
	iret

keyboard:
;Step 1
push ax
push bx
push cx
push dx
push 	si
push 	di
push 	es
push 	ds
push bp
mov bp, sp

;Step 2
sti
call YKEnterISR
;Step 3
call keyboardHandler

;Step 4
cli

;Step 5
mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
out	0x20, al	; Write EOI to PIC (port 0x20)

call YKExitISR

;Step 6
pop bp
pop		ds
pop 	es
pop 	di
pop 	si
pop dx
pop cx
pop bx
pop ax

;Step 7
iret
