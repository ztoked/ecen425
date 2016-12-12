///////////////////////////////////////////////////////////////////////////////
// Name: 8086.h
// Author: Wade S. Fife
// Last Modified: July 10, 2003
// Description: This file contains common defenitions and types specific to the
//   real mode x86 architecture.
//
///////////////////////////////////////////////////////////////////////////////

#ifndef H_8086_H
#define H_8086_H

// CUSTOM TYPES //

typedef unsigned char BYTE;
typedef unsigned int WORD;
typedef unsigned long DWORD;
typedef void interrupt (*ISRP)();		// Interrupt table vector entry
typedef int BOOL;


// MACROS //

#define SetVect(inum, addr)	*((ISRP far *) ((inum) * 4)) = ((ISRP) addr)
#define GetVect(inum)			(ISRP) (*((ISRP far *) ((inum) * 4)))

#define dRead(SEG, OFF) (*(unsigned long far *)(((DWORD)SEG << 16) | (DWORD)OFF))
#define wRead(SEG, OFF) (*(unsigned int far *)(((DWORD)SEG << 16) | (DWORD)OFF))
#define bRead(SEG, OFF) (*(unsigned char far *)(((DWORD)SEG << 16) | (DWORD)OFF))

#define dWrite(SEG, OFF, VAL) (*(unsigned long far *)(((DWORD)SEG << 16) | (DWORD)OFF)) = VAL
#define wWrite(SEG, OFF, VAL) (*(unsigned int far *)(((DWORD)SEG << 16) | (DWORD)OFF)) = VAL
#define bWrite(SEG, OFF, VAL) (*(unsigned char far *)(((DWORD)SEG << 16) | (DWORD)OFF)) = VAL

#define LogicalToPhysical(X)	(((DWORD)(X) >> 12) + (WORD)(X))
#define PhysicalToLogical(X)	(void far *)((((DWORD)(X) & 0xFFFF0ul) << 12) | ((DWORD)(X) & 0xFul))

#define OUTW(PORT, VAL)	asm mov dx, (PORT); asm mov ax, (VAL); asm out dx,ax;
#define OUTB(PORT, VAL) asm mov dx, (PORT); asm mov al, (VAL); asm out dx,al;

// Be careful with INW and INB. Dest should be a variable of the proper size.
#define INW(DEST, PORT) asm mov dx, (PORT); asm in ax,dx; asm mov word ptr DEST, ax;
#define INB(DEST, PORT) asm mov dx, (PORT); asm in al,dx; asm mov byte ptr DEST, al;

#define MAKEWORD(a, b)      ((WORD)(((BYTE)(a)) | ((WORD)((BYTE)(b))) << 8))
#define MAKELONG(a, b)      ((LONG)(((WORD)(a)) | ((DWORD)((WORD)(b))) << 16))
#define LOWORD(l)           ((WORD)(l))
#define HIWORD(l)           (*(((WORD *)(&(l)))+1))
//#define HIWORD(l)           ((WORD)(((DWORD)(l) >> 16) & 0xFFFF))
#define LOBYTE(w)           ((BYTE)(w))
#define HIBYTE(w)           ((BYTE)((WORD)(w) >> 8))


#endif	// #ifndef H_8086_H

