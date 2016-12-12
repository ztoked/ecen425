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
	; >>>>> Line:	9
	; >>>>> { 
	jmp	L_myinth_2
L_myinth_3:
	; >>>>> Line:	11
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	12
	; >>>>> val = ++ticks; 
	mov	ax, word [ticks]
	inc	ax
	mov	word [ticks], ax
	mov	word [bp-2], ax
	; >>>>> Line:	13
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	; >>>>> Line:	14
	; >>>>> printString("\nTICK "); 
	mov	ax, L_myinth_1
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	15
	; >>>>> printInt(val); 
	push	word [bp-2]
	call	printInt
	add	sp, 2
	; >>>>> Line:	16
	; >>>>> printNewLine(); 
	call	printNewLine
	mov	sp, bp
	pop	bp
	ret
L_myinth_2:
	push	bp
	mov	bp, sp
	push	cx
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
	; >>>>> Line:	20
	; >>>>> { 
	jmp	L_myinth_9
L_myinth_10:
	; >>>>> Line:	23
	; >>>>> YKEnterMutex(); 
	mov	word [bp-2], 0
	; >>>>> Line:	23
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	24
	; >>>>> value = KeyBuffer; 
	mov	ax, word [KeyBuffer]
	mov	word [bp-4], ax
	; >>>>> Line:	25
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	; >>>>> Line:	27
	; >>>>> if(value == 'd') 
	cmp	word [bp-4], 100
	jne	L_myinth_11
	; >>>>> Line:	29
	; >>>>> printString("\nDELAY KEY PRESSED\n"); 
	mov	ax, L_myinth_5
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	30
	; >>>>> while(i < 5000) 
	jmp	L_myinth_13
L_myinth_12:
	; >>>>> Line:	32
	; >>>>> ++i; 
	inc	word [bp-2]
L_myinth_13:
	cmp	word [bp-2], 5000
	jl	L_myinth_12
L_myinth_14:
	; >>>>> Line:	34
	; >>>>> printString("DELAY COMPLETE\n"); 
	mov	ax, L_myinth_6
	push	ax
	call	printString
	add	sp, 2
	jmp	L_myinth_15
L_myinth_11:
	; >>>>> Line:	36
	; >>>>> else i 
	cmp	word [bp-4], 112
	jne	L_myinth_16
	; >>>>> Line:	38
	; >>>>> YKSemPost(NSemPtr); 
	push	word [NSemPtr]
	call	YKSemPost
	add	sp, 2
	jmp	L_myinth_17
L_myinth_16:
	; >>>>> Line:	42
	; >>>>> printString("\nKEYPRESS ("); 
	mov	ax, L_myinth_7
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	43
	; >>>>> printChar(value); 
	push	word [bp-4]
	call	printChar
	add	sp, 2
	; >>>>> Line:	44
	; >>>>> printString(") IGNORED\n"); 
	mov	ax, L_myinth_8
	push	ax
	call	printString
	add	sp, 2
L_myinth_17:
L_myinth_15:
	mov	sp, bp
	pop	bp
	ret
L_myinth_9:
	push	bp
	mov	bp, sp
	sub	sp, 4
	jmp	L_myinth_10