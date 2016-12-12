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
