///////////////////////////////////////////////////////////////////////////////
// Name: IntLib.c
// Author: Wade S. Fife
// Last Modified: July 10, 2003
// Description: This file is the core code that allows the AMD board to mimic
//   the EE 425 8086 simulator (Emu86).
//
// Notes: The file contains an ISR for the serial port that reads commands from
//   the serial port and generates the same interrupts via software that Emu86
//   would generates. For example if a line is cleared in simptris, the
//   simptris machine sends the value 39 to the microcontroller's serial port.
//   The ISR in this file interprets this command and generates a software
//   interrupt 0xF (the line clear interrupt) by reading address located in
//   interrupt vector 0xF, adjusting the CPU flags, and jumping to that address
//   in memory, just as if "INT 0xF" were executed.
//
//   The file also contains code to emulate the DOS-like services emulated in
//   Emu86 (e.g., text output) and the simptris command interrupt (e.g., slide
//   piece, rotate piece, etc.) as well as code to setup and handle timer ticks.
//
///////////////////////////////////////////////////////////////////////////////

#include <mem.h>
#include "IntLib.h"
#include "LED.h"
#include "8086.h"
#include "SerialPort.h"
#include "PIO.h"
#include "SimptrisCom.h"


// GLOBAL VARIABLES ///////////////////////////////////////////////////////////

// ISR Pointers
void interrupt (*OldSerialPort1_ISR)(void);
void interrupt (*OldInt21h)(void);
void interrupt (*OldSimptrisInt)(void);
void interrupt (*OldTimerISR)(void);

// CPU execution state restored when user binary is finished
CPU_state	gExecutionState;

// Lengths of simptris messages sent to microcontroller
static const BYTE CmdLength[] = {1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1,15,1,1};

// Variables for serial port ISR
static int iCmd;
static ComData serCmd;


// FUNCTIONS //////////////////////////////////////////////////////////////////

// Responds to simptris messages received
void interrupt HandleReceivedByte(void)
{
	// WARNING: DO NOT ADD NON-STATIC LOCAL VARIABLES!

	// Pause timer counting
	TimerPause();

	// Handle serial port interrupt, see if byte received.
	if(SerialPortHandler()) ((BYTE *)&serCmd)[iCmd++] = RecvByte();
	else goto ExitSerInt;

	// Is command valid?
	if(serCmd.type > MAX_CMD) {
		serCmd.type = 0xFF;
		iCmd = 0;

		SendData("<WARNING: Board received bad command!>", 38);

		goto ExitSerInt;
	}

	// Is command complete? (check length)
	if(iCmd < CmdLength[serCmd.type]) goto ExitSerInt;

	// Set es = 0 for use below
	asm {
		xor		ax, ax
		mov		es, ax
	}


	// Handle the command
	switch(serCmd.type) {
	case SIG_GAME_OVER:			//  1-byte signal - (BYTE)signal
		asm {
			mov		si, SIMP_GAME_OVER_INT*4
			jmp		JumpISR
		}

	case SIG_NEW_STRAIGHT_0_0:	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
	case SIG_NEW_STRAIGHT_0_1:
	case SIG_NEW_STRAIGHT_0_2:
	case SIG_NEW_STRAIGHT_0_3:
	case SIG_NEW_STRAIGHT_0_4:
	case SIG_NEW_STRAIGHT_0_5:
		/*
		// ************** DEBUG
		SendBytePoll('n');
		// **************
		*/
		asm {
			mov		al, byte ptr serCmd.type
			mov		ah, 0
			mov		dx, word ptr serCmd.id
			sub		ax, SIG_NEW_STRAIGHT_0_0

			mov		word ptr es:[TET_PIECE_ID_ADDR], dx
			mov		word ptr es:[TET_PIECE_TYPE_ADDR], 1
			mov		word ptr es:[TET_ORIENT_ADDR], 0
			mov		word ptr es:[TET_COLUMN_ADDR], ax

			mov		si, SIMP_NEW_PIECE_INT*4
			jmp		JumpISR
		}
	case SIG_NEW_STRAIGHT_1_0:
	case SIG_NEW_STRAIGHT_1_1:
	case SIG_NEW_STRAIGHT_1_2:
	case SIG_NEW_STRAIGHT_1_3:
	case SIG_NEW_STRAIGHT_1_4:
	case SIG_NEW_STRAIGHT_1_5:
		/*
		// ************** DEBUG
		SendBytePoll('n');
		// **************
		*/
		asm {
			mov		al, byte ptr serCmd.type
			mov		ah, 0
			mov		dx, word ptr serCmd.id
			sub		ax, SIG_NEW_STRAIGHT_1_0

			mov		word ptr es:[TET_PIECE_ID_ADDR], dx
			mov		word ptr es:[TET_PIECE_TYPE_ADDR], 1
			mov		word ptr es:[TET_ORIENT_ADDR], 1
			mov		word ptr es:[TET_COLUMN_ADDR], ax

			mov		si, SIMP_NEW_PIECE_INT*4
			jmp		JumpISR
		}

	case SIG_NEW_CORNER_0_0:	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
	case SIG_NEW_CORNER_0_1:
	case SIG_NEW_CORNER_0_2:
	case SIG_NEW_CORNER_0_3:
	case SIG_NEW_CORNER_0_4:
	case SIG_NEW_CORNER_0_5:
		/*
		// ************** DEBUG
		SendBytePoll('n');
		// **************
		*/
		asm {
			mov		al, byte ptr serCmd.type
			mov		ah, 0
			mov		dx, word ptr serCmd.id
			sub		ax, SIG_NEW_CORNER_0_0

			mov		word ptr es:[TET_PIECE_ID_ADDR], dx
			mov		word ptr es:[TET_PIECE_TYPE_ADDR], 0
			mov		word ptr es:[TET_ORIENT_ADDR], 0
			mov		word ptr es:[TET_COLUMN_ADDR], ax

			mov		si, SIMP_NEW_PIECE_INT*4
			jmp		JumpISR
		}
	case SIG_NEW_CORNER_1_0:
	case SIG_NEW_CORNER_1_1:
	case SIG_NEW_CORNER_1_2:
	case SIG_NEW_CORNER_1_3:
	case SIG_NEW_CORNER_1_4:
	case SIG_NEW_CORNER_1_5:
		/*
		// ************** DEBUG
		SendBytePoll('n');
		// **************
		*/
		asm {
			mov		al, byte ptr serCmd.type
			mov		ah, 0
			mov		dx, word ptr serCmd.id
			sub		ax, SIG_NEW_CORNER_1_0

			mov		word ptr es:[TET_PIECE_ID_ADDR], dx
			mov		word ptr es:[TET_PIECE_TYPE_ADDR], 0
			mov		word ptr es:[TET_ORIENT_ADDR], 1
			mov		word ptr es:[TET_COLUMN_ADDR], ax

			mov		si, SIMP_NEW_PIECE_INT*4
			jmp		JumpISR
		}
	case SIG_NEW_CORNER_2_0:
	case SIG_NEW_CORNER_2_1:
	case SIG_NEW_CORNER_2_2:
	case SIG_NEW_CORNER_2_3:
	case SIG_NEW_CORNER_2_4:
	case SIG_NEW_CORNER_2_5:
		/*
		// ************** DEBUG
		SendBytePoll('n');
		// **************
		*/
		asm {
			mov		al, byte ptr serCmd.type
			mov		ah, 0
			mov		dx, word ptr serCmd.id
			sub		ax, SIG_NEW_CORNER_2_0

			mov		word ptr es:[TET_PIECE_ID_ADDR], dx
			mov		word ptr es:[TET_PIECE_TYPE_ADDR], 0
			mov		word ptr es:[TET_ORIENT_ADDR], 2
			mov		word ptr es:[TET_COLUMN_ADDR], ax

			mov		si, SIMP_NEW_PIECE_INT*4
			jmp		JumpISR
		}
	case SIG_NEW_CORNER_3_0:
	case SIG_NEW_CORNER_3_1:
	case SIG_NEW_CORNER_3_2:
	case SIG_NEW_CORNER_3_3:
	case SIG_NEW_CORNER_3_4:
	case SIG_NEW_CORNER_3_5:
		/*
		// ************** DEBUG
		SendBytePoll('n');
		// **************
		*/
		asm {
			mov		al, byte ptr serCmd.type
			mov		ah, 0
			mov		dx, word ptr serCmd.id
			sub		ax, SIG_NEW_CORNER_3_0

			mov		word ptr es:[TET_PIECE_ID_ADDR], dx
			mov		word ptr es:[TET_PIECE_TYPE_ADDR], 0
			mov		word ptr es:[TET_ORIENT_ADDR], 3
			mov		word ptr es:[TET_COLUMN_ADDR], ax

			mov		si, SIMP_NEW_PIECE_INT*4
			jmp		JumpISR
		}

	case SIG_RECEIVED:			//  1-byte signal - (BYTE)signal
		/*
		// ************** DEBUG
		SendBytePoll('r');
		// **************
		*/
		asm {
			mov		si, SIMP_RECEIVED_INT*4
			jmp		JumpISR
		}

	case SIG_TOUCHDOWN:			// 15-byte signal - (BYTE)signal, (WORD)pieceID,  (WORD)col0, (WORD)col1, (WORD)col2, (WORD)col3, (WORD)col4, (WORD)col5
		/*
		// ************** DEBUG
		SendBytePoll('d');
		// **************
		*/
		asm {
			mov		dx, word ptr serCmd.id
			mov		word ptr es:[TET_TOUCHDOWN_ADDR], dx

			mov		dx, word ptr serCmd.p0
			mov		word ptr es:[TET_BITMAP_ADDR+0x0], dx	// Col 1 (leftmost)
			mov		dx, word ptr serCmd.p1
			mov		word ptr es:[TET_BITMAP_ADDR+0x2], dx	// Col 2
			mov		dx, word ptr serCmd.p2
			mov		word ptr es:[TET_BITMAP_ADDR+0x4], dx	// Col 3
			mov		dx, word ptr serCmd.p3
			mov		word ptr es:[TET_BITMAP_ADDR+0x6], dx	// Col 4
			mov		dx, word ptr serCmd.p4
			mov		word ptr es:[TET_BITMAP_ADDR+0x8], dx	// Col 5
			mov		dx, word ptr serCmd.p5
			mov		word ptr es:[TET_BITMAP_ADDR+0xA], dx	// Col 6 (rightmost)

			mov		si, SIMP_TOUCHDOWN_INT*4
			jmp		JumpISR
		}

	case SIG_LINE_CLEAR:		//  1-byte signal - (BYTE)signal
		/*
		// ************** DEBUG
		SendBytePoll('c');
		// **************
		*/
		asm {
			mov		si, SIMP_LINE_CLEAR_INT*4
			jmp		JumpISR		// Flow through
		}

	case SIG_TERMINATE:
		/*
		// ************** DEBUG
		SendBytePoll('x');
		// **************
		*/
		OUTW(EOI, NS_EOI_CMD);
		Terminate();

	default:
		/*
		// ************** DEBUG
		SendBytePoll('e');
		// **************
		*/
		// Reset for next time
		iCmd = 0;
		serCmd.type = 0xFF;
		goto ExitSerInt;
	}

JumpISR:
	// Reset variables for next time
	iCmd = 0;
	serCmd.type = 0xFF;

	OUTW(EOI, NS_EOI_CMD);
	TimerGo();

	// Generate interrupt seamlessly (as if this ISR had never been called)
	// This section expects the address for the vector entry to be in si
	asm {
		// Setup ds for addressing
		xor		ax, ax
		mov		ds, ax

		// Restore registers ax, bx, cx
		mov		cx, [bp+12]
		mov		bx, [bp+14]
		mov		ax, [bp+16]

		// Replace bytes where ax, bx, and cx were with iret paramaters for user ISR
		mov		dx, [bp+22]	// Get flags that were saved on stack
		and		dx, 0xFCFF	// Set TF and IF to 0
		mov		[bp+16], dx	// Store flags
		mov		dx, [si+2]
		mov		[bp+14], dx	// Store cs
		mov		dx, [si]
		mov		[bp+12], dx	// Store ip

		// Restore remaining registers
		pop		bp
		pop		di
		pop		si
		pop		ds
		pop		es
		pop		dx

		// Jump to the ISR
		iret
	}

ExitSerInt:
	OUTW(EOI, NS_EOI_CMD);
	TimerGo();
}


// Calls user's Tick ISR
void interrupt TimerISR(void)
{
	// Issue EOI
	OUTW(EOI, NS_EOI_CMD);

	/*
	// ************** DEBUG
	SendBytePoll('t');
	// **************
	*/
	asm {
		// Verify that interrupt is set
		xor		ax, ax
		mov		ds, ax
		mov		si, [TICK_INT*4]
		mov		di, [TICK_INT*4+2]
		mov		ax, si
		or		ax, di
		jz		SkipINT

		// Generate interrupt seamlessly (as if this ISR had never been called)

		// Restore registers ax, bx, cx
		mov		cx, [bp+12]
		mov		bx, [bp+14]
		mov		ax, [bp+16]

		// Replace bytes where ax, bx, and cx were with iret paramaters for user ISR
		mov		dx, [bp+22]	// Get flags that were saved on stack
		and		dx, 0xFCFF	// Set TF and IF to 0
		mov		[bp+16], dx	// Store flags
		mov		[bp+14], di	// Store cs for user interrupt
		mov		[bp+12], si	// Store ip for user interrupt

		// Restore remaining registers
		pop		bp
		pop		di
		pop		si
		pop		ds
		pop		es
		pop		dx

		iret
	}

SkipINT:
}


/* NOTE: This ISR assumes regs are saved by compiler in the order shown below
   (bp at [bp], di at [bp+2], etc). If this is not the case, the function may
   need to be modified.
WORD rbp, WORD rdi, WORD rsi, WORD rds, WORD res,
WORD rdx, WORD rcx, WORD rbx, WORD rax,
WORD rip, WORD rcs, WORD rflags
*/
// Handle Simptris services (Software Interrupt)
void interrupt SimptrisInt(void)
{
//	WORD rax, rbx, rcx, rdx;

	TimerPause();		// Stop ticks

	asm {
		cmp		ah, SLIDE_PIECE
		je		SlidePiece
		cmp		ah, ROTATE_PIECE
		je		RotatePiece
		cmp		ah, SEED_NUMBER
		je		SeedNumber
		cmp		ah, START_SIMPTRIS
		je		StartSimptris

		jmp 	ExitSimptrisInt
	}

	// Note: After calls to putser1(), values that were saved on stack are
	//       used since putser1() kills the register conents. (NOTE: bp is on top of stack)

	SlidePiece:
		// AL>	Direction
		// DX>	Piece ID
		asm {
			// Send command (same as direction, in this case)
			push	ax
			call	near ptr SendByte

			// Send lo byte of pieceID
			push	word [bp+10]	// DX
			call	near ptr SendByte

			// Send hi byte of pieceID
			push	word [bp+11]	// DX (hi byte)
			call	near ptr SendByte

			// Adjust stack
			add		sp, 6
		}
		goto ExitSimptrisInt;

	RotatePiece:
		// AL>	Direction
		// DX>	Piece ID
		asm {
			add		al, CMD_ROTATE_LEFT

			// Send command (same as direction + CMD_ROTATE_LEFT)
			push	ax
			call	near ptr SendByte

			// Send lo byte of pieceID
			push	word [bp+10]	// DX
			call	near ptr SendByte

			// Send hi byte of pieceID
			push	word [bp+11]	// DX (hi byte)
			call	near ptr SendByte

			// Adjust stack
			add		sp, 6
		}
		goto ExitSimptrisInt;

	SeedNumber:
		// CX,DX>	Seed number
		asm {
			// Send command
			push	CMD_SEED
			call	near ptr SendByte
			
			// Send lo byte of lo word
			push	word [bp+10]	// DX
			call	near ptr SendByte

			// Send hi byte of lo word
			push	word [bp+11]	// DX (hi byte)
			call	near ptr SendByte

			// Send lo byte of hi word
			push	word [bp+12]	// CX
			call	near ptr SendByte

			// Send hi byte of hi word
			push	word [bp+13]	// CX (hi byte)
			call	near ptr SendByte

			// Adjust stack
			add		sp, 10
		}
		goto ExitSimptrisInt;

	StartSimptris:
		SendByte(CMD_START);

	// Cleanup //
ExitSimptrisInt:
	TimerGo();		// Start ticks again
}



/* NOTE: This ISR assumes regs are saved by compiler in the order shown below
   (bp at [bp], di at [bp+2], etc). If this is not the case, the function may
   need to be modified.
WORD rbp, WORD rdi, WORD rsi, WORD rds, WORD res,
WORD rdx, WORD rcx, WORD rbx, WORD rax,
WORD rip, WORD rcs, WORD rflags
*/
// Handle select DOS interrupt 21h services. (Software Interrupt)
void interrupt Int21h(void)
{
	// Note: BP and DS are modified in the interrupt boiler plate code.

	TimerPause();

	// Service number in ah
	asm {
		// /*
		cmp		ah, 0x02
		je		service0x02		// Print character
		cmp		ah, 0x09
		je		service0x09		// Print '$' terminated string
		cmp		ah, 0x40
		je		service0x40		// Write to device (e.g., screen)
		// */
		cmp		ah, 0x4C
		je		service0x4C		// Terminate program
	}
	sends("ERROR: Requested INT 21h service not supported.\r\n");
	goto	ExitInt21h;

	service0x02:	// Character output. DL is 8-bit character to print
		SendByte(_DL);
		goto ExitInt21h;

	service0x09:	// String output. DS:DX points to '$' terminated string
		asm {
			mov		ax, [bp+6]
			push	ax			// Push string offset
			push	dx			// Push string segment
			call	near ptr SendDosStringFar
			add		sp, 4
		}
		goto ExitInt21h;

	service0x40:	// Write to device or file. Only supports deivce 0x01 (stdout). BX is handle, CX is num bytes, DS:DX points to data to write.
		// if(_BX != 1) goto ExitInt21h;	// Don't bother to check this. Direct all output to serial port
		asm {
			push	cx			// Push num bytes
			mov		ax, [bp+6]
			push	ax			// Push string offset
			push	dx			// Push string segment
			call	near ptr SendDataFar
			add		sp, 6
		}
		goto ExitInt21h;

	service0x4C:	// Terminate with return code. AL is return code
		asm {
			// Send exit signal
			push	CMD_EXIT
			call	near ptr SendByte
			pop		cx

			// Send exit code
			push	word [bp+16]	// Push ax from stack
			call	near ptr SendByte
			pop		cx

			call	near ptr Terminate
			// NOTE: The call to Terminate() never returns.
		}

		// Cleanup //
ExitInt21h:
	TimerGo();		// Start ticks again
}


// Resets timer, interrupt vectors, and restores execution to last saved point.
void Terminate(void)
{
	asm	cli

	// Restore interrupts and hardware timer state
	RestoreInterrupts();

	// Return to last saved execution point
	LoadReturnPoint();
}


// Pause timer 2 (i.e., make it so it doesn't count). This will cause
// timer 1 to stop as well when in prescale mode.
// NOTE: This function doesn't change any registers.
void TimerPause(void)
{
	asm {
		push	ax
		push	dx

		// Disable timer
		mov		dx, T2CON	// Timer 2 mode/control register  0xff66
		in		ax, dx
		and		ax, 0x7FFF
		or		ax, 0x4000
		out		dx, ax

		pop		dx
		pop		ax
	}
}

// Un-pause timer 2 (i.e., make it count again). This will cause
// timer 1 to go as well when in prescale mode.
// NOTE: This function doesn't change any registers.
void TimerGo(void)
{
	asm {
		push	ax
		push	dx

		// Enable timer
		mov		dx, T2CON	// Timer 2 mode/control register  0xff66
		in		ax, dx
		or		ax, 0xC000
		out		dx, ax

		pop		dx
		pop		ax
	}
}

// Sets up timer 1, prescaled by timer 2. Argument maxCount is max count for
// timer 1 and argument scalar is the max count for timer 1. For example, with
// a 40 MHz cpu, if you want interrupt 0x12 to interrupt at a rate of F Hz,
// set scalar to X and maxCount to (40000000 / 4 / X / F), where X is the
// smallest value that makes maxCount able to fit in a 16 bit register.
// The 4 is there because timer 2 is incremented every 4 cpu clock cycles. The
// timer will be accurate to within (X*5E-8).
void SetupTimer(WORD maxCount, WORD scalar, void interrupt (*pISR)(void))
{
	asm pushf
	asm cli

	// Set interrupt vector
	OldTimerISR = GetVect(0x12);
	if(pISR != NULL) SetVect(0x12, pISR);

	asm {
		// Reset count registers
		xor		ax, ax
		mov		dx, T1CNT
		out		dx, ax		// Reset T1CNT
		mov		dx, T2CNT
		out		dx, ax		// Reset T2CNT

		// Set max count
		mov		ax, word ptr [maxCount]
		mov		dx, T1CMPA
		out		dx, ax		// Set T1CMPA to high word
		mov		ax, word ptr [scalar]
		mov		dx, T2CMPA
		out		dx, ax		// Set T2CMPA to low word

		// Unmask timers interrupt bit in interrupt controller
		mov		dx, IMASK
		in		ax, dx
		and		ax, 0xFFFE
		out		dx, ax

		// Setup interrupt control register (enabled, low priority)
		mov		dx, TCUCON
		mov		ax, 0x0007
		out		dx, ax

		// Setup timers (user T1CMPA only for timer 1, prescaled by timer 2)
		mov		ax, 0xE009	// 1110 0000 0000 1001
		mov		dx, T1CON
		out		dx, ax
		mov		ax, 0xC001	// 1100 0000 0000 0001
		mov		dx, T2CON
		out		dx, ax
	}

	asm popf
}

// Disable timers 1 and 2, and restore interrupt vector & settings
// That is, undo call to SetupTimer().
void DisableTimer(void)
{
	asm pushf
	asm cli

	// Set interrupt vector
	SetVect(0x12, OldTimerISR);

	asm {
		// Mask timers interrupt in interrupt controller
		mov		dx, IMASK
		in		ax, dx
		or		ax, 0x0001
		out		dx, ax

		// Reset interrupt control register (disabled, low priority)
		mov		dx, TCUCON
		mov		ax, 0x000F
		out		dx, ax

		// Disable timers 1 and 2
		mov		ax, 0x4000
		mov		dx, T2CON
		out		dx, ax
		mov		dx, T1CON
		out		dx, ax

		// Reset count registers
		xor		ax, ax
		mov		dx, T1CNT
		out		dx, ax
		mov		dx, T2CNT
		out		dx, ax
	}

	asm popf
}



// Set up hardware and software ISR vectors as well as the timer
// to emulate simulator.
void SetupInterrupts(void)
{
	asm	pushf
	asm	cli

	// AM186 HARDWARE INTERRUPT VECTORS
	// 00h Divide Error Exception
	// 01h Trace Interrupt
	// 02h Nonmaskable Interrupt (NMI)
	// 03h Breakpoint Interrupt (for debugging)
	// 04h INTO Detected Overflow Exception
	// 05h Array Bounds Exception
	// 06h Unused Opcode Exception
	// 07h ESC Opcode Exception
	// 08h Timer 0 Interrupt
	// 09h Reserved for AMD use
	// 0Ah DMA 0 Interrupt / INT5 Interrupt
	// 0Bh DMA 1 Interrupt / INT6 Interrupt
	// 0Ch INT0 Interrupt
	// 0Dh INT1 Interrupt
	// 0Eh INT2 Interrupt
	// 0Fh INT3 Interrupt
	// 10h INT4 Interrupt
	// 11h Asynchronous Serial Port 1
	// 12h Timer 1 Interrupt
	// 13h Timer 2 Interrupt
	// 14h Asynchronous Serial Port 0
	// 15h Reserved for AMD use
	// ... ...
	// 1Fh Reserved for AMD use

	// EMU86 INTERRUPT VECTORS
	// 08h Reset
	// 09h Tick
	// 0Ah Keyboard
	// 0Bh Simptris Game Over
	// 0Ch Simptris New Piece
	// 0Dh Simptris Received
	// 0Eh Simptris Touchdown
	// 0Fh Simptris Clear
	// 10h PC BIOS Services
	// ...
	// 21h DOS Services
	// 22h Simptris Services

	// Steal INT 21h for DOS-like services
	OldInt21h = GetVect(0x21);
	SetVect(0x21, Int21h);

	// Steal interrupt for Simptris services
	OldSimptrisInt = GetVect(SIMPTRIS_INT);
	SetVect(SIMPTRIS_INT, SimptrisInt);

	// Setup timer
	SetupTimer(TIMER_MAX_COUNT, TIMER_SCALAR, TimerISR);

	// Overide serial port ISR
	OldSerialPort1_ISR = GetVect(0x11);
	SetVect(0x11, HandleReceivedByte);

	// Initialize new serial port ISR variables
	iCmd = 0;
	serCmd.type = 0xFF;

	asm popf
}


// Restore interrupts to what they were before call to SetupInterrupts()
void RestoreInterrupts(void)
{
	asm		pushf
	asm		cli

	// Restore INT 21h for DOS-like services
	SetVect(0x21, OldInt21h);

	// Restore interrupt for Simptris services
	SetVect(SIMPTRIS_INT, OldSimptrisInt);

	// Restore timer and it's interrupt vector
	DisableTimer();

	// Restore normal serial port ISR
	SetVect(0x11, OldSerialPort1_ISR);

	asm		popf
}


// Save execution state in *pState (It can be restored by RestoreExecState())
// WARNING: Because this function saves SS:SP but not any values on the stack,
//    calling RestoreExecState() some time after SaveExecState() may not behave
//    as you expect, since the stack region of memory may have been changed.
void SaveExecState(CPU_state far *pState)
{
	WORD ipValue;
	CPU_state far *pSource = NULL;

	asm	{
		// Save execution state (same order as ExecutionState struct)

		pushf

		push	es
		push	ds
		push	ss
		push	cs

		push	di
		push	si
		push	word [bp]		// Use saved bp for bp
		push	bp				// Use bp as value for sp (will be adjusted later)
		push	ax				// Use AX as place-holder for ip, for now.

		push	dx
		push	cx
		push	bx
		push	ax

		// Save location of execution state (current sp value)
		mov		word ptr [pSource+0], sp
		mov		word ptr [pSource+2], ss

		// Save value of ip from stack
		mov		ax, [bp+2]
		mov		ipValue, ax

	}

	// Copy saved state
	_fmemcpy(pState, pSource, sizeof(*pState));

	// Restore statck
	asm	add		sp, 28

	// Copy correct address IP
	pState->ip = ipValue;

	// Adjust for correct SP (skip saved bp, sp, and param)
	pState->sp += 4;
}


// Restore execution state passed in *pState (probably saved by SaveExecState())
// WARNING: Because this function saves SS:SP but not any values on the stack,
//    calling RestoreExecState() some time after SaveExecState() may not behave
//    as you expect, since the stack region of memory may have been changed.
void RestoreExecState(CPU_state far *pState)
{
	// Restore state
	asm {
		// Point ds:bp to ExecState
		lds		bx, pState

		// Restore general registers
		mov		ax, [bx+0]
		mov		cx, [bx+4]
		mov		dx, [bx+6]

		mov		bp, [bx+12]

		mov		si, [bx+14]
		mov		di, [bx+16]

		// Restore stack
		mov		ss, [bx+20]
		mov		sp, [bx+10]

		// Put other registers on stack for restore
		push	word [bx+26]		// flags
		push	word [bx+18]		// cs
		push	word [bx+8]			// ip
		push	word [bx+2]			// bx
		push	word [bx+22]		// ds
		push	word [bx+24]		// es

		// Restore es, ds, bp
		pop		es
		pop		ds
		pop		bx

		// Restor cs, ip, and flags
		iret
	}
}
