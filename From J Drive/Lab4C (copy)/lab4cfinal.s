        CPU     8086
        ORG     0h
InterruptVectorTable:
        ; Internal x86 Interrupts:
        dd      0 ; Reserved (Div err)  ; Int 00h
        dd      0 ; Reserved (Step)     ; Int 01h
        dd      0 ; Reserved (NMI)      ; Int 02h
        dd      0 ; Reserved (Break)    ; Int 03h
        dd      0 ; Reserved (Overflow) ; Int 04h
        dd      0                       ; Int 05h
        dd      0                       ; Int 06h
        dd      0                       ; Int 07h
        ; Hardware Interrupts:
        dd      reset ; Reset               ; Int 08h (IRQ 0)
        dd      tick ; Tick                ; Int 09h (IRQ 1)
        dd      keyboard ; Keyboard            ; Int 0Ah (IRQ 2)
        dd      0 ; Simptris Game Over  ; Int 0Bh (IRQ 3)
        dd      0 ; Simptris New Piece  ; Int 0Ch (IRQ 4)
        dd      0 ; Simptris Received   ; Int 0Dh (IRQ 5)
        dd      0 ; Simptris Touchdown  ; Int 0Eh (IRQ 6)
        dd      0 ; Simptris Clear      ; Int 0Fh (IRQ 7)
        ; Software Interrupts:
        dd      0 ; Reserved (PC BIOS)  ; Int 10h
        dd      0                       ; Int 11h
        dd      0                       ; Int 12h
        dd      0                       ; Int 13h
        dd      0                       ; Int 14h
        dd      0                       ; Int 15h
        dd      0                       ; Int 16h
        dd      0                       ; Int 17h
        dd      0                       ; Int 18h
        dd      0                       ; Int 19h
        dd      0                       ; Int 1Ah
        dd      0                       ; Int 1Bh
        dd      0                       ; Int 1Ch
        dd      0                       ; Int 1Dh
        dd      0                       ; Int 1Eh
        dd      0                       ; Int 1Fh
        dd      0                       ; Int 20h
        dd      0 ; Reserved (DOS)      ; Int 21h
        dd      0 ; Simptris Services   ; Int 22h
        dd      0                       ; Int 23h
        dd      0                       ; Int 24h
        dd      0                       ; Int 25h
        dd      0                       ; Int 26h
        dd      0                       ; Int 27h
        dd      0                       ; Int 28h
        dd      0                       ; Int 29h
        dd      0                       ; Int 2Ah
        dd      0                       ; Int 2Bh
        dd      0                       ; Int 2Ch
        dd      0                       ; Int 2Dh
        dd      0                       ; Int 2Eh
        dd      0                       ; Int 2Fh
KeyBuffer:                              ; Address 0xC0
        dw      0
NewPieceType:                           ; Address 0xC2
        dw      0
NewPieceID:                             ; Address 0xC4
        dw      0
NewPieceOrientation:                    ; Address 0xC6
        dw      0
NewPieceColumn:                         ; Address 0xC8
        dw      0
TouchdownID:                            ; Address 0xCA
	dw	0
ScreenBitMap0:                          ; Address 0xCC
        dw      0
ScreenBitMap1:
        dw      0
ScreenBitMap2:
        dw      0
ScreenBitMap3:
        dw      0
ScreenBitMap4:
        dw      0
ScreenBitMap5:
        dw      0
TIMES   100h-($-$$) db  0               ; Fill up to (but not including) address 100h with 0
	jmp	main
; This file contains support routines for 32-bit on the 8086.
; It is intended for use code generated by the C86 compiler.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SR_asldiv:			; l1 /= l2
	push	bp
	mov	bp,sp
	push	bx
	mov	bx,[bp+4]	; Get address of l1	(was push3)
	push	word [bp+8]	; Push hi l2		(was push1)
	push	word [bp+6]	; Push lo l2		(was push2)
	push	word [bx+2]	; Push hi l1
	push	word [bx]	; Push lo l1
	call	SR_ldiv
	mov	bx,[bp+4]	; Restore l1 address
	mov	[bx+2],dx	; Store result
	mov	[bx],ax
	pop	bx
	pop	bp
	ret
SR_aslmod:			; l1 %= l2
	push	bp
	mov	bp,sp
	push	bx
	mov	bx,[bp+4]	; Get address of l1	(was push3)
	push	word [bp+8]	; Push hi l2		(was push1)
	push	word [bp+6]	; Push lo l2		(was push2)
	push	word [bx+2]	; Push hi l1
	push	word [bx]	; Push lo l1
	call	SR_lmod
	mov	bx,[bp+4]	; Restore l1 address
	mov	[bx+2],dx	; Store result
	mov	[bx],ax
	pop	bx
	pop	bp
	ret
SR_aslmul:			; l1 *= l2
	push	bp
	mov	bp,sp
	push	bx
	mov	bx,[bp+4]	; Get address of l1	(was push3)
	push	word [bp+8]	; Push hi l2		(was push1)
	push	word [bp+6]	; Push lo l2		(was push2)
	push	word [bx+2]	; Push hi l1
	push	word [bx]	; Push lo l1
	call	SR_lmul
	add	sp,8
	mov	bx,[bp+4]	; Restore l1 address
	mov	[bx+2],dx	; Store result
	mov	[bx],ax
	pop	bx
	pop	bp
	ret
SR_aslshl:			; l1 <<= l2
	push	bp
	mov	bp,sp
	push	bx
	mov	bx,[bp+4]	; Get address of l1	(was push3)
	push	word [bp+8]	; Push hi l2		(was push1)
	push	word [bp+6]	; Push lo l2		(was push2)
	push	word [bx+2]	; Push hi l1
	push	word [bx]	; Push lo l1
	call	SR_lshl
	add	sp,8
	mov	bx,[bp+4]	; Restore l1 address
	mov	[bx+2],dx	; Store result
	mov	[bx],ax
	pop	bx
	pop	bp
	ret
SR_aslshr:			; l1 >>= l2
	push	bp
	mov	bp,sp
	push	bx
	mov	bx,[bp+4]	; Get address of l1	(was push3)
	push	word [bp+8]	; Push hi l2		(was push1)
	push	word [bp+6]	; Push lo l2		(was push2)
	push	word [bx+2]	; Push hi l1
	push	word [bx]	; Push lo l1
	call	SR_lshr
	add	sp,8
	mov	bx,[bp+4]	; Restore l1 address
	mov	[bx+2],dx	; Store result
	mov	[bx],ax
	pop	bx
	pop	bp
	ret


SR_asuldiv:			; u1 /= u2
	push	bp
	mov	bp,sp
	push	bx
	mov	bx,[bp+4]	; Get address of u1	(was push3)
	push	word [bp+8]	; Push hi u2		(was push1)
	push	word [bp+6]	; Push lo u2		(was push2)
	push	word [bx+2]	; Push hi u1
	push	word [bx]	; Push lo u1
	call	SR_uldiv
	mov	bx,[bp+4]	; Restore u1 address
	mov	[bx+2],dx	; Store result
	mov	[bx],ax
	pop	bx
	pop	bp
	ret
SR_asilmod:			; u1 %= u2
	push	bp
	mov	bp,sp
	push	bx
	mov	bx,[bp+4]	; Get address of u1	(was push3)
	push	word [bp+8]	; Push hi u2		(was push1)
	push	word [bp+6]	; Push lo u2		(was push2)
	push	word [bx+2]	; Push hi u1
	push	word [bx]	; Push lo u1
	call	SR_ilmod
	mov	bx,[bp+4]	; Restore u1 address
	mov	[bx+2],dx	; Store result
	mov	[bx],ax
	pop	bx
	pop	bp
	ret
SR_asulmul:			; u1 *= u2
	push	bp
	mov	bp,sp
	push	bx
	mov	bx,[bp+4]	; Get address of u1	(was push3)
	push	word [bp+8]	; Push hi u2		(was push1)
	push	word [bp+6]	; Push lo u2		(was push2)
	push	word [bx+2]	; Push hi u1
	push	word [bx]	; Push lo u1
	call	SR_ulmul
	add	sp,8
	mov	bx,[bp+4]	; Restore u1 address
	mov	[bx+2],dx	; Store result
	mov	[bx],ax
	pop	bx
	pop	bp
	ret
SR_asulshl:			; u1 << u2
	push	bp
	mov	bp,sp
	push	bx
	mov	bx,[bp+4]	; Get address of u1	(was push3)
	push	word [bp+8]	; Push hi u2		(was push1)
	push	word [bp+6]	; Push lo u2		(was push2)
	push	word [bx+2]	; Push hi u1
	push	word [bx]	; Push lo u1
	call	SR_ulshl
	add	sp,8
	mov	bx,[bp+4]	; Restore u1 address
	mov	[bx+2],dx	; Store result
	mov	[bx],ax
	pop	bx
	pop	bp
	ret
SR_asulshr:			; u1 >> u2
	push	bp
	mov	bp,sp
	push	bx
	mov	bx,[bp+4]	; Get address of u1	(was push3)
	push	word [bp+8]	; Push hi u2		(was push1)
	push	word [bp+6]	; Push lo u2		(was push2)
	push	word [bx+2]	; Push hi u1
	push	word [bx]	; Push lo u1
	call	SR_ulshr
	add	sp,8
	mov	bx,[bp+4]	; Restore u1 address
	mov	[bx+2],dx	; Store result
	mov	[bx],ax
	pop	bx
	pop	bp
	ret


; Main 32-bit routines begin here:

SR_ldiv:	; N_LDIV@
	pop    cx
	push   cs
	push   cx
	; LDIV@
	xor    cx,cx
	jmp    LSR_01
SR_uldiv:	; N_LUDIV@
	pop    cx
	push   cs
	push   cx
	; F_LUDIV@
	mov    cx,0001
	jmp    LSR_01
SR_lmod:	; N_LMOD@
	pop    cx
	push   cs
	push   cx
	; F_LMOD@
	mov    cx,0002
	jmp    LSR_01
SR_ilmod:	; N_LUMOD@
	pop    cx
	push   cs
	push   cx
	; LUMOD@
	mov    cx,0003
LSR_01:
	push   bp
	push   si
	push   di
	mov    bp,sp
	mov    di,cx
	mov    ax,[bp+0Ah]
	mov    dx,[bp+0Ch]
	mov    bx,[bp+0Eh]
	mov    cx,[bp+10h]
	or     cx,cx
	jne    LSR_02
	or     dx,dx
	je     LSR_10
	or     bx,bx
	je     LSR_10
LSR_02:
	test   di,0001
	jne    LSR_04
	or     dx,dx
	jns    LSR_03
	neg    dx
	neg    ax
	sbb    dx,0000
	or     di,000Ch
LSR_03:
	or     cx,cx
	jns    LSR_04
	neg    cx
	neg    bx
	sbb    cx,0000
	xor    di,0004
LSR_04:
	mov    bp,cx
	mov    cx,0020h
	push   di
	xor    di,di
	xor    si,si
LSR_05:
	shl    ax,1
	rcl    dx,1
	rcl    si,1
	rcl    di,1
	cmp    di,bp
	jb     LSR_07
	ja     LSR_06
	cmp    si,bx
	jb     LSR_07
LSR_06:
	sub    si,bx
	sbb    di,bp
	inc    ax
LSR_07:
	loop   LSR_05
	pop    bx
	test   bx,0002
	je     LSR_08
	mov    ax,si
	mov    dx,di
	shr    bx,1
LSR_08:
	test   bx,0004h
	je     LSR_09
	neg    dx
	neg    ax
	sbb    dx,0000
LSR_09:
	pop    di
	pop    si
	pop    bp
	retf   0008
LSR_10:
	div    bx
	test   di,0002
	je     LSR_11
	xchg   dx,ax
LSR_11:
	xor    dx,dx
	jmp    LSR_09
SR_lshl:	; N_LXLSH@
SR_ulshl:
	; r = a << b
	pop    bx
	push   cs
	push   bx

	push   bp
	mov    bp,sp

	push   cx	; C86 doesn't expect use of cx or bx

	mov    ax, [bp+6]	; pop loword(a)
	mov    dx, [bp+8]	; pop hiword(a)
	mov    cx, [bp+10]	; pop word(b)
	
	; LXLSH@
	cmp    cl,10h
	jnb    LSR_12
	mov    bx,ax
	shl    ax,cl
	shl    dx,cl
	neg    cl
	add    cl,10h
	shr    bx,cl
	or     dx,bx
	pop    cx
	pop    bp
	retf
LSR_12:
	sub    cl,10h
	xchg   dx,ax
	xor    ax,ax
	shl    dx,cl
	pop    cx
	pop    bp
	retf
SR_lshr:	; N_LXRSH@
	; r = a >> b
	pop    bx
	push   cs
	push   bx

	push   bp
	mov    bp,sp

	push   cx	; C86 doesn't expect use of cx or bx

        mov    ax, [bp+6]	; pop loword(a)
	mov    dx, [bp+8]	; pop hiword(a)
	mov    cx, [bp+10]	; pop word(b)
	
	; LXRSH@
	cmp    cl,10h
	jnb    LSR_13
	mov    bx,dx
	shr    ax,cl
	sar    dx,cl
	neg    cl
	add    cl,10h
	shl    bx,cl
	or     ax,bx
	pop    cx
	pop    bp
	retf
LSR_13:
	sub    cl,10h
	xchg   dx,ax
	cwd
	sar    ax,cl
	pop    cx
	pop    bp
	retf
SR_ulshr:	; N_LXURSH@
	; r = a >> b
	pop    bx
	push   cs
	push   bx

	push   bp
	mov    bp,sp

	push   cx	; C86 doesn't expect use of cx or bx

        mov    ax, [bp+6]	; pop loword(a)
	mov    dx, [bp+8]	; pop hiword(a)
	mov    cx, [bp+10]	; pop word(b)
	
	; LXURSH@
	cmp    cl,10h
	jnb    LSR_14
	mov    bx,dx
	shr    ax,cl
	shr    dx,cl
	neg    cl
	add    cl,10h
	shl    bx,cl
	or     ax,bx
	pop    cx
	pop    bp
	retf
LSR_14:
	sub    cl,10h
	xchg   dx,ax
	xor    dx,dx
	shr    ax,cl
	pop    cx
	pop    bp
	retf
SR_lmul:	; N_LXMUL@
SR_ulmul:
	; r = a * b
	push   bp
	push   si
	mov    bp,sp

	push   cx	; C86 doesn't expect use of cx or bx
	push   bx

        mov    bx, [bp+6]	; pop loword(a)
	mov    cx, [bp+8]	; pop hiword(a)
	mov    ax, [bp+10]	; pop loword(b)
	mov    dx, [bp+12]	; pop hiword(b)
	
	xchg   si,ax
	xchg   dx,ax
	test   ax,ax
	je     LSR_15
	mul    bx
LSR_15:
	jcxz   LSR_16
	xchg   cx,ax
	mul    si
	add    ax,cx
LSR_16:
	xchg   si,ax
	mul    bx
	add    dx,si
	pop    bx
	pop    cx
	pop    si
	pop    bp
	ret

; Generated by c86 (BYU-NASM) 5.1 (beta) from clib.c
	CPU	8086
	ALIGN	2
	jmp	main	; Jump to program start
new_line:
	db	13,10,36
	ALIGN	2
signalEOI:
	jmp	L_clib_1
L_clib_2:
	mov	al, 0x20
	out	0x20, al
	mov	sp, bp
	pop	bp
	ret
L_clib_1:
	push	bp
	mov	bp, sp
	jmp	L_clib_2
	ALIGN	2
exit:
	jmp	L_clib_4
L_clib_5:
	mov	ah, 4Ch
	mov	al, [bp+4]
	int	21h
	mov	sp, bp
	pop	bp
	ret
L_clib_4:
	push	bp
	mov	bp, sp
	jmp	L_clib_5
	ALIGN	2
print:
	jmp	L_clib_7
L_clib_8:
	mov	ah, 40h
	mov	bx, 1
	mov	cx, [bp+6]
	mov	dx, [bp+4]
	int	21h
	mov	sp, bp
	pop	bp
	ret
L_clib_7:
	push	bp
	mov	bp, sp
	jmp	L_clib_8
	ALIGN	2
printChar:
	jmp	L_clib_10
L_clib_11:
	mov	ah, 2
	mov	dl, [bp+4]
	int	21h
	mov	sp, bp
	pop	bp
	ret
L_clib_10:
	push	bp
	mov	bp, sp
	jmp	L_clib_11
	ALIGN	2
printNewLine:
	jmp	L_clib_13
L_clib_14:
	mov	ah, 9
	mov	dx, new_line
	int	21h
	mov	sp, bp
	pop	bp
	ret
L_clib_13:
	push	bp
	mov	bp, sp
	jmp	L_clib_14
	ALIGN	2
printString:
	jmp	L_clib_16
L_clib_17:
	xor	si,si
	mov	bx, [bp+4]
	jmp	printString2
	printString1:
	inc	si
	printString2:
	cmp	byte [bx+si],0
	jne	printString1
	mov	dx, bx
	mov	cx, si
	mov	ah, 40h
	mov	bx, 1
	int	21h
	mov	sp, bp
	pop	bp
	ret
L_clib_16:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_clib_17
	ALIGN	2
printInt:
	jmp	L_clib_19
L_clib_20:
	mov	word [bp-2], 0
	mov	word [bp-4], 10000
	cmp	word [bp+4], 0
	jge	L_clib_21
	mov	byte [bp-10], 45
	inc	word [bp-2]
	mov	ax, word [bp+4]
	neg	ax
	mov	word [bp+4], ax
L_clib_21:
	mov	ax, word [bp+4]
	test	ax, ax
	jne	L_clib_22
	mov	word [bp-4], 1
	jmp	L_clib_23
L_clib_22:
	jmp	L_clib_25
L_clib_24:
	mov	ax, word [bp-4]
	cwd
	mov	cx, 10
	idiv	cx
	mov	word [bp-4], ax
L_clib_25:
	mov	ax, word [bp+4]
	cwd
	idiv	word [bp-4]
	test	ax, ax
	je	L_clib_24
L_clib_26:
L_clib_23:
	jmp	L_clib_28
L_clib_27:
	mov	ax, word [bp+4]
	xor	dx, dx
	div	word [bp-4]
	add	al, 48
	mov	si, word [bp-2]
	lea	dx, [bp-10]
	add	si, dx
	mov	byte [si], al
	inc	word [bp-2]
	mov	ax, word [bp+4]
	xor	dx, dx
	div	word [bp-4]
	mov	ax, dx
	mov	word [bp+4], ax
	mov	ax, word [bp-4]
	cwd
	mov	cx, 10
	idiv	cx
	mov	word [bp-4], ax
	mov	ax, word [bp-4]
	mov	word [bp-4], ax
L_clib_28:
	cmp	word [bp-4], 0
	jg	L_clib_27
L_clib_29:
	push	word [bp-2]
	lea	ax, [bp-10]
	push	ax
	call	print
	add	sp, 4
	mov	sp, bp
	pop	bp
	ret
L_clib_19:
	push	bp
	mov	bp, sp
	sub	sp, 10
	jmp	L_clib_20
	ALIGN	2
printLong:
	jmp	L_clib_31
L_clib_32:
	mov	word [bp-2], 0
	mov	word [bp-6], 51712
	mov	word [bp-4], 15258
	cmp	word [bp+6], 0
	jg	L_clib_33
	jl	L_clib_34
	cmp	word [bp+4], 0
	jae	L_clib_33
L_clib_34:
	mov	byte [bp-17], 45
	inc	word [bp-2]
	mov	ax, word [bp+4]
	mov	dx, word [bp+6]
	neg	ax
	adc	dx, 0
	neg	dx
	mov	word [bp+4], ax
	mov	word [bp+6], dx
L_clib_33:
	mov	ax, word [bp+4]
	mov	dx, word [bp+6]
	or	dx, ax
	jne	L_clib_35
	mov	word [bp-6], 1
	mov	word [bp-4], 0
	jmp	L_clib_36
L_clib_35:
	jmp	L_clib_38
L_clib_37:
	mov	ax, 10
	xor	dx, dx
	push	dx
	push	ax
	lea	ax, [bp-6]
	push	ax
	call	SR_asldiv
L_clib_38:
	push	word [bp-4]
	push	word [bp-6]
	push	word [bp+6]
	push	word [bp+4]
	call	SR_ldiv
	or	dx, ax
	je	L_clib_37
L_clib_39:
L_clib_36:
	jmp	L_clib_41
L_clib_40:
	push	word [bp-4]
	push	word [bp-6]
	push	word [bp+6]
	push	word [bp+4]
	call	SR_uldiv
	add	al, 48
	mov	si, word [bp-2]
	lea	dx, [bp-17]
	add	si, dx
	mov	byte [si], al
	inc	word [bp-2]
	push	word [bp-4]
	push	word [bp-6]
	push	word [bp+6]
	push	word [bp+4]
	call	SR_lmod
	mov	word [bp+4], ax
	mov	word [bp+6], dx
	mov	ax, 10
	xor	dx, dx
	push	dx
	push	ax
	lea	ax, [bp-6]
	push	ax
	call	SR_asldiv
L_clib_41:
	cmp	word [bp-4], 0
	jg	L_clib_40
	jne	L_clib_43
	cmp	word [bp-6], 0
	ja	L_clib_40
L_clib_43:
L_clib_42:
	push	word [bp-2]
	lea	ax, [bp-17]
	push	ax
	call	print
	add	sp, 4
	mov	sp, bp
	pop	bp
	ret
L_clib_31:
	push	bp
	mov	bp, sp
	sub	sp, 18
	jmp	L_clib_32
	ALIGN	2
printUInt:
	jmp	L_clib_45
L_clib_46:
	mov	word [bp-2], 0
	mov	word [bp-4], 10000
	mov	ax, word [bp+4]
	test	ax, ax
	jne	L_clib_47
	mov	word [bp-4], 1
	jmp	L_clib_48
L_clib_47:
	jmp	L_clib_50
L_clib_49:
	mov	ax, word [bp-4]
	xor	dx, dx
	mov	cx, 10
	div	cx
	mov	word [bp-4], ax
L_clib_50:
	mov	ax, word [bp+4]
	xor	dx, dx
	div	word [bp-4]
	test	ax, ax
	je	L_clib_49
L_clib_51:
L_clib_48:
	jmp	L_clib_53
L_clib_52:
	mov	ax, word [bp+4]
	xor	dx, dx
	div	word [bp-4]
	add	al, 48
	mov	si, word [bp-2]
	lea	dx, [bp-10]
	add	si, dx
	mov	byte [si], al
	inc	word [bp-2]
	mov	ax, word [bp+4]
	xor	dx, dx
	div	word [bp-4]
	mov	word [bp+4], dx
	mov	ax, word [bp-4]
	xor	dx, dx
	mov	cx, 10
	div	cx
	mov	word [bp-4], ax
L_clib_53:
	mov	ax, word [bp-4]
	test	ax, ax
	jne	L_clib_52
L_clib_54:
	push	word [bp-2]
	lea	ax, [bp-10]
	push	ax
	call	print
	add	sp, 4
	mov	sp, bp
	pop	bp
	ret
L_clib_45:
	push	bp
	mov	bp, sp
	sub	sp, 10
	jmp	L_clib_46
	ALIGN	2
printULong:
	jmp	L_clib_56
L_clib_57:
	mov	word [bp-2], 0
	mov	word [bp-6], 51712
	mov	word [bp-4], 15258
	mov	ax, word [bp+4]
	mov	dx, word [bp+6]
	or	dx, ax
	jne	L_clib_58
	mov	word [bp-6], 1
	mov	word [bp-4], 0
	jmp	L_clib_59
L_clib_58:
	jmp	L_clib_61
L_clib_60:
	mov	ax, 10
	xor	dx, dx
	push	dx
	push	ax
	lea	ax, [bp-6]
	push	ax
	call	SR_asuldiv
L_clib_61:
	push	word [bp-4]
	push	word [bp-6]
	push	word [bp+6]
	push	word [bp+4]
	call	SR_uldiv
	or	dx, ax
	je	L_clib_60
L_clib_62:
L_clib_59:
	jmp	L_clib_64
L_clib_63:
	push	word [bp-4]
	push	word [bp-6]
	push	word [bp+6]
	push	word [bp+4]
	call	SR_uldiv
	add	al, 48
	mov	si, word [bp-2]
	lea	dx, [bp-17]
	add	si, dx
	mov	byte [si], al
	inc	word [bp-2]
	push	word [bp-4]
	push	word [bp-6]
	lea	ax, [bp+4]
	push	ax
	call	SR_asilmod
	mov	ax, 10
	xor	dx, dx
	push	dx
	push	ax
	lea	ax, [bp-6]
	push	ax
	call	SR_asuldiv
L_clib_64:
	mov	ax, word [bp-6]
	mov	dx, word [bp-4]
	or	dx, ax
	jne	L_clib_63
L_clib_65:
	push	word [bp-2]
	lea	ax, [bp-17]
	push	ax
	call	print
	add	sp, 4
	mov	sp, bp
	pop	bp
	ret
L_clib_56:
	push	bp
	mov	bp, sp
	sub	sp, 18
	jmp	L_clib_57
	ALIGN	2
printByte:
	jmp	L_clib_67
L_clib_68:
	mov	al, byte [bp+4]
	cbw
	mov	cx, 4
	sar	ax, cl
	and	ax, 15
	mov	byte [bp-1], al
	cmp	byte [bp-1], 9
	jle	L_clib_69
	mov	al, byte [bp-1]
	cbw
	sub	ax, 10
	add	ax, 65
	jmp	L_clib_70
L_clib_69:
	mov	al, byte [bp-1]
	cbw
	add	ax, 48
L_clib_70:
	mov	byte [bp-3], al
	mov	al, byte [bp+4]
	and	al, 15
	mov	byte [bp-1], al
	cmp	byte [bp-1], 9
	jle	L_clib_71
	mov	al, byte [bp-1]
	cbw
	sub	ax, 10
	add	ax, 65
	jmp	L_clib_72
L_clib_71:
	mov	al, byte [bp-1]
	cbw
	add	ax, 48
L_clib_72:
	mov	byte [bp-2], al
	mov	ax, 2
	push	ax
	lea	ax, [bp-3]
	push	ax
	call	print
	add	sp, 4
	mov	sp, bp
	pop	bp
	ret
L_clib_67:
	push	bp
	mov	bp, sp
	sub	sp, 4
	jmp	L_clib_68
	ALIGN	2
printWord:
	jmp	L_clib_74
L_clib_75:
	mov	word [bp-2], 3
	jmp	L_clib_77
L_clib_76:
	mov	ax, word [bp+4]
	and	ax, 15
	mov	byte [bp-3], al
	cmp	byte [bp-3], 9
	jle	L_clib_80
	mov	al, byte [bp-3]
	cbw
	sub	ax, 10
	add	ax, 65
	jmp	L_clib_81
L_clib_80:
	mov	al, byte [bp-3]
	cbw
	add	ax, 48
L_clib_81:
	mov	si, word [bp-2]
	lea	dx, [bp-7]
	add	si, dx
	mov	byte [si], al
	mov	ax, word [bp+4]
	mov	cx, 4
	sar	ax, cl
	mov	word [bp+4], ax
L_clib_79:
	dec	word [bp-2]
L_clib_77:
	cmp	word [bp-2], 0
	jge	L_clib_76
L_clib_78:
	mov	ax, 4
	push	ax
	lea	ax, [bp-7]
	push	ax
	call	print
	add	sp, 4
	mov	sp, bp
	pop	bp
	ret
L_clib_74:
	push	bp
	mov	bp, sp
	sub	sp, 8
	jmp	L_clib_75
	ALIGN	2
printDWord:
	jmp	L_clib_83
L_clib_84:
	lea	ax, [bp+4]
	mov	si, ax
	mov	ax, word [si]
	mov	word [bp-6], ax
	lea	ax, [bp+4]
	mov	si, ax
	add	si, 2
	mov	ax, word [si]
	mov	word [bp-8], ax
	mov	word [bp-2], 3
	jmp	L_clib_86
L_clib_85:
	mov	ax, word [bp-6]
	and	ax, 15
	mov	byte [bp-3], al
	cmp	byte [bp-3], 9
	jle	L_clib_89
	mov	al, byte [bp-3]
	cbw
	sub	ax, 10
	add	ax, 65
	jmp	L_clib_90
L_clib_89:
	mov	al, byte [bp-3]
	cbw
	add	ax, 48
L_clib_90:
	mov	dx, word [bp-2]
	add	dx, 4
	mov	si, dx
	lea	dx, [bp-16]
	add	si, dx
	mov	byte [si], al
	mov	ax, word [bp-6]
	mov	cx, 4
	sar	ax, cl
	mov	word [bp-6], ax
	mov	ax, word [bp-8]
	and	ax, 15
	mov	byte [bp-3], al
	cmp	byte [bp-3], 9
	jle	L_clib_91
	mov	al, byte [bp-3]
	cbw
	sub	ax, 10
	add	ax, 65
	jmp	L_clib_92
L_clib_91:
	mov	al, byte [bp-3]
	cbw
	add	ax, 48
L_clib_92:
	mov	si, word [bp-2]
	lea	dx, [bp-16]
	add	si, dx
	mov	byte [si], al
	mov	ax, word [bp-8]
	mov	cx, 4
	sar	ax, cl
	mov	word [bp-8], ax
L_clib_88:
	dec	word [bp-2]
L_clib_86:
	cmp	word [bp-2], 0
	jge	L_clib_85
L_clib_87:
	mov	ax, 8
	push	ax
	lea	ax, [bp-16]
	push	ax
	call	print
	add	sp, 4
	mov	sp, bp
	pop	bp
	ret
L_clib_83:
	push	bp
	mov	bp, sp
	sub	sp, 16
	jmp	L_clib_84

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
	push bp
	mov bp, sp

	;Step 2
	sti

	;Step 3
	call keyboardHandler

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
; Generated by c86 (BYU-NASM) 5.1 (beta) from myinth.i
	CPU	8086
	ALIGN	2
	jmp	main	; Jump to program start
	ALIGN	2
ticks:
	DW	0
L_myinth_1:
	DB	0xA,"TICK ",0
	ALIGN	2
tickHandler:
	; >>>>> Line:	7
	; >>>>> { 
	jmp	L_myinth_2
L_myinth_3:
	; >>>>> Line:	8
	; >>>>> ++ticks; 
	inc	word [ticks]
	; >>>>> Line:	9
	; >>>>> printString("\nTICK "); 
	mov	ax, L_myinth_1
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	10
	; >>>>> printInt(ticks); 
	push	word [ticks]
	call	printInt
	add	sp, 2
	; >>>>> Line:	11
	; >>>>> printNewLine(); 
	call	printNewLine
	mov	sp, bp
	pop	bp
	ret
L_myinth_2:
	push	bp
	mov	bp, sp
	jmp	L_myinth_3
L_myinth_8:
	DB	") IGNORED",0xA,0
L_myinth_7:
	DB	0xA,"KEYPRESS (",0
L_myinth_6:
	DB	"DELAY COMPLETE",0xA,0
L_myinth_5:
	DB	0xA,"DELAY KEY PRESSED",0xA,0
	ALIGN	2
keyboardHandler:
	; >>>>> Line:	15
	; >>>>> { 
	jmp	L_myinth_9
L_myinth_10:
	; >>>>> Line:	16
	; >>>>> if(KeyBuffer == 'd') 
	cmp	word [KeyBuffer], 100
	jne	L_myinth_11
	; >>>>> Line:	19
	; >>>>> printString("\nDELAY KEY PRESSED\n"); 
	mov	word [bp-2], 0
	; >>>>> Line:	19
	; >>>>> printString("\nDELAY KEY PRESSED\n"); 
	mov	ax, L_myinth_5
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	20
	; >>>>> while(i < 5000) 
	jmp	L_myinth_13
L_myinth_12:
	; >>>>> Line:	22
	; >>>>> ++i; 
	inc	word [bp-2]
L_myinth_13:
	cmp	word [bp-2], 5000
	jl	L_myinth_12
L_myinth_14:
	; >>>>> Line:	24
	; >>>>> printString("DELAY COMPLETE\n"); 
	mov	ax, L_myinth_6
	push	ax
	call	printString
	add	sp, 2
	jmp	L_myinth_15
L_myinth_11:
	; >>>>> Line:	28
	; >>>>> printString("\nKEYPRESS ("); 
	mov	ax, L_myinth_7
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	29
	; >>>>> printChar(KeyBuffer); 
	push	word [KeyBuffer]
	call	printChar
	add	sp, 2
	; >>>>> Line:	30
	; >>>>> printString(") IGNORED\n"); 
	mov	ax, L_myinth_8
	push	ax
	call	printString
	add	sp, 2
L_myinth_15:
	mov	sp, bp
	pop	bp
	ret
L_myinth_9:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_myinth_10
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
; Generated by c86 (BYU-NASM) 5.1 (beta) from lab4c_app.i
	CPU	8086
	ALIGN	2
	jmp	main	; Jump to program start
L_lab4c_app_2:
	DB	"Starting kernel...",0xA,0
L_lab4c_app_1:
	DB	"Creating task...",0xA,0
	ALIGN	2
main:
	; >>>>> Line:	17
	; >>>>> { 
	jmp	L_lab4c_app_3
L_lab4c_app_4:
	; >>>>> Line:	18
	; >>>>> YKInitialize(); 
	call	YKInitialize
	; >>>>> Line:	20
	; >>>>> printString("Creating task...\n"); 
	mov	ax, L_lab4c_app_1
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	21
	; >>>>> YKNewTask(Task, (void  
	xor	al, al
	push	ax
	mov	ax, (TaskStack+512)
	push	ax
	mov	ax, Task
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	23
	; >>>>> printString("Starting kernel...\n"); 
	mov	ax, L_lab4c_app_2
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	24
	; >>>>> YKRun(); 
	call	YKRun
	mov	sp, bp
	pop	bp
	ret
L_lab4c_app_3:
	push	bp
	mov	bp, sp
	jmp	L_lab4c_app_4
L_lab4c_app_9:
	DB	" context switches! YKIdleCount is ",0
L_lab4c_app_8:
	DB	"Task running after ",0
L_lab4c_app_7:
	DB	"Delaying task...",0xA,0
L_lab4c_app_6:
	DB	"Task started.",0xA,0
	ALIGN	2
Task:
	; >>>>> Line:	28
	; >>>>> { 
	jmp	L_lab4c_app_10
L_lab4c_app_11:
	; >>>>> Line:	32
	; >>>>> printString("Task started.\n"); 
	mov	ax, L_lab4c_app_6
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	33
	; >>>>> while (1) 
	jmp	L_lab4c_app_13
L_lab4c_app_12:
	; >>>>> Line:	35
	; >>>>> printString("Delaying task...\n"); 
	mov	ax, L_lab4c_app_7
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	37
	; >>>>> YKDelayTask(2); 
	mov	ax, 2
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	39
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	40
	; >>>>> numCtxSwitches = YKCtxSwCount; 
	mov	ax, word [YKCtxSwCount]
	mov	word [bp-4], ax
	; >>>>> Line:	41
	; >>>>> idleCount = YKIdleCount; 
	mov	ax, word [YKIdleCount]
	mov	word [bp-2], ax
	; >>>>> Line:	42
	; >>>>> YKIdleCount = 0; 
	mov	word [YKIdleCount], 0
	; >>>>> Line:	43
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	; >>>>> Line:	45
	; >>>>> printString("Task running after "); 
	mov	ax, L_lab4c_app_8
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	46
	; >>>>> printUInt(numCtxSwitches); 
	push	word [bp-4]
	call	printUInt
	add	sp, 2
	; >>>>> Line:	47
	; >>>>> p 
	mov	ax, L_lab4c_app_9
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	48
	; >>>>> printUInt(idleCount); 
	push	word [bp-2]
	call	printUInt
	add	sp, 2
	; >>>>> Line:	49
	; >>>>> printString(".\n"); 
	mov	ax, (L_lab4c_app_1+15)
	push	ax
	call	printString
	add	sp, 2
L_lab4c_app_13:
	jmp	L_lab4c_app_12
L_lab4c_app_14:
	mov	sp, bp
	pop	bp
	ret
L_lab4c_app_10:
	push	bp
	mov	bp, sp
	sub	sp, 4
	jmp	L_lab4c_app_11
	ALIGN	2
TaskStack:
	TIMES	512 db 0
