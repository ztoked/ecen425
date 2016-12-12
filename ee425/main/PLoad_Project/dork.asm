	IDEAL
	MODEL	small

	DATASEG

	EXTRN	_ser1


	CODESEG

	PUBLIC	_TestAsm

PROC 	_TestAsm
		mov		bx, offset _ser1
		xor		ax, ax
		mov		ax, 1
		ret

ENDP	_TestAsm

END