///////////////////////////////////////////////////////////////////////////////
// Name: ErrorHandle.c
// Author: Wade S. Fife
// Last modified: July 10, 2003
// Description: Routines to handle processor exceptions (e.g., divide error,
//   unused opcode exception, etc.).
//
// Notes: Call SetupErrorHandlers() to intialize. When an exception occurs,
//   these handlers will send an error message over the serial port along with
//   the register contents when the error occured. The LED will then flash
//   the number of the exception plus 2, pause, then repeat. For example, if
//   the invalide opcode exception occurs (interrupt type 6), the LED will flash
//   8 times (6+2), pause, flash 8 times, pause, etc...
//
///////////////////////////////////////////////////////////////////////////////

#include "ErrorHandle.h"
#include "8086.h"
#include "SerialPort.h"
#include "LED.h"


/* All the ISRs in this file assume that registers were saved by the compiler
   in the following order (bp at [bp], di at [bp+2], etc):
WORD rbp, WORD rdi, WORD rsi, WORD rds, WORD res,
WORD rdx, WORD rcx, WORD rbx, WORD rax,
WORD rip, WORD rcs, WORD rflags
*/

void DisplayRegisters(WORD far *data)
{
	/*
	AX:0000 BX:0000 CX:0000 DX:0000
	SI:0000 DI:0000 BP:0000
	DS:0000 ES:0000
	SS:0000 SP:0000
	CS:0000 IP:0000
	OF:0 DF:0 IF:0 TF:0 SF:0 ZF:0 AF:0 PF:0 CF:0
	*/

	SendStringPoll("AX:");
	SendHexWordPoll(data[8]);
	SendStringPoll(" BX:");
	SendHexWordPoll(data[7]);
	SendStringPoll(" CX:");
	SendHexWordPoll(data[6]);
	SendStringPoll(" DX:");
	SendHexWordPoll(data[5]);

	SendStringPoll("\r\nSI:");
	SendHexWordPoll(data[2]);
	SendStringPoll(" DI:");
	SendHexWordPoll(data[1]);
	SendStringPoll(" BP:");
	SendHexWordPoll(data[0]);

	SendStringPoll("\r\nDS:");
	SendHexWordPoll(data[3]);
	SendStringPoll(" ES:");
	SendHexWordPoll(data[4]);

	SendStringPoll("\r\nSS:");
	SendHexWordPoll((WORD)*((WORD *)&data + 1));
	SendStringPoll(" SP:");
	SendHexWordPoll((WORD)data + 24);

	SendStringPoll("\r\nCS:");
	SendHexWordPoll(data[10]);
	SendStringPoll(" IP:");
	SendHexWordPoll(data[9]);

	SendStringPoll("\r\nFLAGS:");
	SendHexWordPoll(data[11]);
	SendStringPoll(" (");

	SendStringPoll("OF:");
	if((data[11]) & 0x0800) SendBytePoll('1');
	else SendBytePoll('0');
	SendStringPoll(" DF:");
	if((data[11]) & 0x0400) SendBytePoll('1');
	else SendBytePoll('0');
	SendStringPoll(" IF:");
	if((data[11]) & 0x0200) SendBytePoll('1');
	else SendBytePoll('0');
	SendStringPoll(" TF:");
	if((data[11]) & 0x0100) SendBytePoll('1');
	else SendBytePoll('0');
	SendStringPoll(" SF:");
	if((data[11]) & 0x0080) SendBytePoll('1');
	else SendBytePoll('0');
	SendStringPoll(" ZF:");
	if((data[11]) & 0x0040) SendBytePoll('1');
	else SendBytePoll('0');
	SendStringPoll(" AF:");
	if((data[11]) & 0x0010) SendBytePoll('1');
	else SendBytePoll('0');
	SendStringPoll(" PF:");
	if((data[11]) & 0x0004) SendBytePoll('1');
	else SendBytePoll('0');
	SendStringPoll(" CF:");
	if((data[11]) & 0x0001) SendBytePoll('1');
	else SendBytePoll('0');

	SendStringPoll(")\r\n");
}

void interrupt DivideErrorException(void)	// Vector 0
{
	SendStringPoll("\r\nDIVIDE ERROR EXCEPTION (INT 0)\r\n");

	// Display register contents
	asm {
		push	ss
		push	bp
		call	near ptr DisplayRegisters
		add		sp, 2
	}

	FlashError(2);
}

/*
void interrupt TraceInterrupt(void)			// Vector 1
{
}

void interrupt NonmaskableInterrupt(void)	// Vector 2
{
}

void interrupt BreakpointInterrupt(void) 	// Vector 3
{
}
*/

void interrupt OverflowException(void)		// Vector 4
{
	SendStringPoll("\r\nOVERFLOW EXCEPTION (INT 4)\r\n");

	// Display register contents
	asm {
		push	ss
		push	bp
		call	near ptr DisplayRegisters
		add		sp, 2
	}

	FlashError(6);
}

void interrupt ArrayBoundsException(void)	// Vector 5
{
	SendStringPoll("\r\nARRAY BOUNDS EXCEPTION (INT 5)\r\n");

	// Display register contents
	asm {
		push	ss
		push	bp
		call	near ptr DisplayRegisters
		add		sp, 2
	}

	FlashError(7);
}

void interrupt UnusedOpcodeException(void)	// Vector 6
{
	SendStringPoll("\r\nUNUSED OPCODE EXCEPTION (INT 6)\r\n");

	// Display register contents
	asm {
		push	ss
		push	bp
		call	near ptr DisplayRegisters
		add		sp, 2
	}

	FlashError(8);
}

void interrupt EscOpcodeException(void)	 	// Rector 7
{
	SendStringPoll("\r\nESC OPCODE EXCEPTION (INT 7)\r\n");

	// Display register contents
	asm {
		push	ss
		push	bp
		call	near ptr DisplayRegisters
		add		sp, 2
	}

	FlashError(9);
}


// Setup error handlers for hardware error interrupts
void SetupErrorHandlers(void)
{
	SetVect(0x00, DivideErrorException);
	//SetVect(0x01, TraceInterrupt);
	//SetVect(0x02, NonmaskableInterrupt);
	//SetVect(0x03, BreakPpointInterrupt);
	SetVect(0x04, OverflowException);
	SetVect(0x05, ArrayBoundsException);
	SetVect(0x06, UnusedOpcodeException);
	SetVect(0x07, EscOpcodeException);
}
