///////////////////////////////////////////////////////////////////////////////
// Name: PLoad.c
// Author: Wade S. Fife
// Last Modified: July 10, 2003
// Description: Program loader to load EE 425 binaries written for Emu86 onto
//   a AMD Am186ES microcontroller on a TERN A-Core-86 board.
//
// Notes: This file contains the main code for the loader logic as well as code
//   to begin execution and return from execution.
//
///////////////////////////////////////////////////////////////////////////////

#include <ae.h>
#include <mem.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

#include "SerialPort.h"
#include "LED.h"
#include "8086.h"
#include "IntLib.h"
#include "PIO.h"
#include "ErrorHandle.h"


#define TRUE 1
#define FALSE 0


// CODE PARAMETERS //

#define IVT_SIZE	1024


// SERIAL INTERFACE COMMANDS //

#define CMD_LOAD		'L'
#define CMD_IVT_START	'I'
#define CMD_BIN_START	'B'
#define CMD_EXEC		'E'
#define CMD_RESET_SER	'R'

#define NOT_STARTED 0
#define STARTED 	1

#define IN_BUFFER_SIZE	2048	// WARNING: Check the .cfg file to be sure that
#define OUT_BUFFER_SIZE	16384u	// this much is available in the data segment.
// #define OUT_BUFFER_SIZE	49152u

#define MAX_WAIT_STRING	20


// GLOBALS /////////////////////////////////////////////////////////////////////

BYTE	IVT_data[IVT_SIZE];
BYTE	inBuffer[IN_BUFFER_SIZE];
BYTE	outBuffer[OUT_BUFFER_SIZE];


// FUNCTIONS //////////////////////////////////////////////////////////////////

// Blocks until string is received on serial port.
BOOL WaitString(char *string)
{
	static char data[MAX_WAIT_STRING];
	int i, length;

	for(length = 0; string[length] != 0; length++);		// Get string length
	data[length-1] = 0;		// Make sure data's not the same as last call
	i = 0;

	while(memcmp(string, data, length)) {
		// Read next byte
		data[i] = RecvByte();

		if(data[i] == string[i]) i++;
		else {
			// Adjust data to neares matching point
			i++;
			do {
				i--;
				memmove(data, data+1, i);
			} while(memcmp(string, data, i));
		}
	}

	return TRUE;
}

// Copies Interrupt Vector Table from IVT_data to address 0:0, but avoids
// certain vector entries that need to be preserved (e.g. serial port interrupt)
void SetIVT(void)
{
	// Steal interrupts 08h-10h based on user needs (i.e., copy from user's binary)
	_fmemcpy((WORD far *)0x20, (WORD far *)(IVT_data+0x20), 4*9);

	// Update remaining IVT memory space with user binary
	_fmemcpy((WORD far *)0x54, (WORD far *)(IVT_data+0x54), IVT_SIZE - 0x54);
}


// Reads from serial port until CMD_EOC is received (use after errors).
void SkipToEOC(void)
{
	WaitString("<END>");
}


// Receives binary executable form serial port 1 in response to the command
// CMD_LOAD. The data that follows CMD_LOAD, which this function reads, must be
// sent in the following form/order:
// (WORD)IVT_size,
// (WORD)IVT_dest_addr,	  						- Only if IVT_size != 0
// (DWORD)binary_size
// (DWORD)binary_dest_addr,						- Only if binary_size != 0
// (BYTE)CMD_IVT_START, (BYTE[])IVT_data,		- Only if IVT_size != 0
// (BYTE)CMD_BIN_START, (BYTE[])binary_data		- Only if binary_size != 0
// (BYTE)CMD_EOC
// NOTES:
//    IVT = "Interrupt Vector Table". It must be separate to avoid crashing.
//    If IVT_size is 0, IVT_dest_addr and IVT_data shouldn't be sent.
//    If binary_size is 0, binary_dest_addr and binary_data shouldn't be sent.
void ReceiveBinary(void)
{
	WORD sizeIVT;
	DWORD sizeBin;
	WORD startAddrIVT;
	DWORD startAddrBin;
	BYTE cmd;

	memset(IVT_data, 0, IVT_SIZE);

	sends("Receiving binary file...\r\n");

	// Get size of IVT being used
	sizeIVT = RecvWord();
	sendf("IVT size:       %u (0x%X)\r\n", sizeIVT, sizeIVT);

	// Get location to start IVT copy
	if(sizeIVT) {
		startAddrIVT = RecvWord();
		sendf("IVT address:    %u (0x%X)\r\n", startAddrIVT, startAddrIVT);
	}

	// Get size of binary data
	sizeBin = RecvDword();
	sendf("Binary size:    %lu (0x%lX)\r\n", sizeBin, sizeBin);

	// Get physical addr for binary data
	if(sizeBin) {
		startAddrBin = RecvDword();
		sendf("Binary address: %lu (0x%lX)\r\n", startAddrBin, startAddrBin);
	}

	// Verify IVT size isn't too large
	if(startAddrIVT + sizeIVT > IVT_SIZE) {
		sendf("\r\nERROR: IVT size %u with address 0x%X is invalid.\r\nWaiting for end of command...", sizeIVT, startAddrIVT);
		SkipToEOC();
		sends("\r\n<DONE>");
		return;
	}

	// Receive IVT
	if(sizeIVT != 0) {
		cmd = RecvByte();
		if(cmd != CMD_IVT_START) {
			sends("\r\nERROR: Exptected start of interrupt vector table (IVT).\r\nWaiting for end of command...");
			SkipToEOC();
			sends("\r\n<DONE>");
			return;
		}
		sends("Receiving interrupt vector table...\r\n");
		RecvData(IVT_data, sizeIVT);
	}

	// Receive Binary
	if(sizeBin != 0) {
		BYTE huge *data;
		DWORD count;

		cmd = RecvByte();
		if(cmd != CMD_BIN_START) {
			sends("\r\nERROR: Exptected start of binary data.\r\nWaiting for end of command...");
			SkipToEOC();
			sends("\r\n<DONE>");
			return;
		}
		sends("Receiving binary");
		//RecvFarData(PhysicalToLogical(startAddrBin), (WORD)sizeBin);	// Old, no feedback version
		data = PhysicalToLogical(startAddrBin);
		count = sizeBin;
		for(count = 0; count < sizeBin; count++) {
			*data ++ = RecvByte();
			if(((WORD)count & 0xFF) == 0) SendByte('.');	// Send feedback to indicate continuous reception
		}
		sends("\r\n");
	}

	// Verify End of Command
	if(RecvByte() != '<' || RecvByte() != 'E' || RecvByte() != 'N' || RecvByte() != 'D' || RecvByte() != '>') {
		sends("\r\nERROR: Exptected end of command.\r\nStill waiting for end of command...");
		SkipToEOC();
		sends("\r\n<DONE>");
		return;
	}

	sends("Binary received\r\n<DONE>");
}


// Sets up and starts execution of a received binary in response to the command
// CMD_EXEC. It reads the offset and segment (in that order) where execution is
// to begin from the serial port.
void ExecBinary(void)
{
	WORD startSegment, startOffset;
	static int execState = NOT_STARTED;

	// Get segment and offset from serial port
	startOffset = RecvWord();
	startSegment = RecvWord();
	//startOffset = 0x100;
	//startSegment = 0;

	// Verify End of Command
	if(RecvByte() != '<' || RecvByte() != 'E' || RecvByte() != 'N' || RecvByte() != 'D' || RecvByte() != '>') {
		sends("\r\nERROR: Exptected end of command.\r\nStill waiting for end of command...");
		SkipToEOC();
		sends("\r\n<DONE>");
		return;
	}

	sendf("Execution started at %04X:%04X\r\n\r\n-----------------------------------------------------------\r\n<DONE>", startSegment, startOffset);

	// Wait until message sent
	WaitSend();

	// Disable interrupts
	asm cli

	// Write new IVT
	SetIVT();

	// Set up Emu86 like Interrupts
	SetupInterrupts();

	// Signal program start on LED
	SetLED(LED_OFF);

	// Setup exit code (so that ret returns control back to this program)
	// B44C  mov  ah,4C
	// CD21  int  21
	dWrite(0, 0xFFFC, 0x21CD4CB4ul);	// Set code to call exit service routine
	wWrite(0, 0xFFFA, 0xFFFC);			// Set return address to injected code

	// Save executions state so that execution will return to the point after
	// this call when the binary terminates.
	SetReturnPoint();
	if(execState == STARTED) {
		execState = NOT_STARTED;
		SetLED(LED_ON);
		asm		sti
		return;
	}
	execState = STARTED;

	asm {
		// Save local variables (before stack pointer change)
		mov	cx, startSegment
		mov	bx, startOffset

		// Set SS:SP
		mov	ss, cx
		mov	sp, 0xFFFA	// Location of return address

		// Put flags, CS, then IP on stack for iret
		mov	ax, 0x0200		// IF bit set
		push	ax
		push	cx
		push	bx

		// Reset other registers
		mov	ds, cx
		mov	es, cx
		mov	ax, 0
		mov	bx, 0
		mov	cx, 0
		mov	dx, 0
		mov	bp, 0
		mov	si, 0
		mov	di, 0

		// Jumpt to start location
		iret
	}
}


// Loop that receives commands from serial port 1 and calls the appropriate
// handler.
void ExecLoop(void)
{
	BYTE cmd;

	while(TRUE) {
		sends("\r\nAwaiting command start...\r\n");

		// Wait for start of command
		WaitString("<CMD>");
		sends("<READY>");

		// Get command id
		cmd = RecvByte();

		switch(cmd) {
		case CMD_LOAD:
			ReceiveBinary();
			break;
		case CMD_EXEC:
			ExecBinary();
			break;
		case CMD_RESET_SER:
			WaitSendComplete();
			ResetSerialPort();
			sends("Serial port reset\r\n<DONE>");
			break;
		default:
			sendf("Received unknown command: %d (0x%X)\r\n", (WORD)cmd, (WORD)cmd);
			WaitSendComplete();
			ResetSerialPort();
			sends("Serial port reset\r\n");
			break;
		}
	}
}


void main(void)
{
	// Initialize Processor for Tern board
	ae_init();

	// Setup serial port for 38,400 baud.
	InitSerialPort(BAUD_RATE(38400ul), inBuffer, IN_BUFFER_SIZE, outBuffer, OUT_BUFFER_SIZE);

	// Setup interrupt handlers for processor exceptions
	SetupErrorHandlers();

	// Flash LED to indicate start.
	FlashLED(2);

	ExecLoop();
}
