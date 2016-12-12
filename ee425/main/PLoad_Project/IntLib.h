///////////////////////////////////////////////////////////////////////////////
// Name: IntLib.h
// Author: Wade S. Fife
// Last Modified: July 10, 2003
// Description: HeaderFile for IntLib.c
//
// Notes: Many of the definitions in this file are based one the values ued by
//   the EE 425 Emu86 simulator. Changes in the simulator need to be reflected
//   in the #define values here. In the Emu86 project, these definitions are
//   contained in the file Bios.h.
//
///////////////////////////////////////////////////////////////////////////////


// Emu86 Defines //////////////////////////////////////////////////////////////

#ifndef INTLIB_H
#define INTLIB_H


////////////////////////////////
// Hardware Interrupt Numbers //

// External Interrupts (IRQs)
#define RESET_INT		0x08
#define TICK_INT		0x09
#define KEYBOARD_INT	0x0A

// Simptris Interrupts
#define SIMP_GAME_OVER_INT	0x0B
#define SIMP_NEW_PIECE_INT	0x0C
#define SIMP_RECEIVED_INT	0x0D
#define SIMP_TOUCHDOWN_INT	0x0E
#define SIMP_LINE_CLEAR_INT	0x0F


///////////////////////////////////////
// Software Interrupt Vector Numbers //

#define PC_BIOS_INT		0x10
#define SIMPTRIS_INT	0x1B
#define DOS_IO_INT		0x21


/////////////////////////////
// Important I/O addresses //

// Keyboard buffer
#define KEY_BUF_ADDR		0xC0

// Simptris communcations memory; Change ONLY TET_COM_ADDR to relocate
#define TET_COM_ADDR		0xC2
#define TET_PIECE_TYPE_ADDR	TET_COM_ADDR+0x0
#define TET_PIECE_ID_ADDR	TET_COM_ADDR+0x2
#define TET_ORIENT_ADDR		TET_COM_ADDR+0x4
#define TET_COLUMN_ADDR		TET_COM_ADDR+0x6
#define TET_TOUCHDOWN_ADDR	TET_COM_ADDR+0x8
#define TET_BITMAP_ADDR		TET_COM_ADDR+0xA 


//////////////////////////////
// Simptris Service Numbers //

#define SLIDE_PIECE		0x00
#define ROTATE_PIECE	0x01
#define SEED_NUMBER		0x02
#define START_SIMPTRIS	0x03

///////////////////////////////////////////////////////////////////////////////

#include "8086.h"

#pragma pack(push, 1)

typedef struct {
	BYTE type;
	WORD id;
	WORD p0,p1,p2,p3,p4,p5;
} ComData;

// DO NOT CHANGE THIS STUCT DEFINITION!
typedef struct {
	WORD	ax;		// 0
	WORD	bx;		// 2
	WORD	cx;		// 4
	WORD	dx;		// 6

	WORD	ip;		// 8
	WORD	sp;		// 10
	WORD	bp;		// 12
	WORD	si;		// 14
	WORD	di;		// 16

	WORD	cs;		// 18
	WORD	ss;		// 20
	WORD	ds;		// 22
	WORD	es;		// 24

	WORD	flags;	// 26
} CPU_state;

#pragma pack(pop)


// Timer counter defines
// NOTE: Timers 1 and 2 are setup in prescale mode. That is, timer 2 counrer is
// incremented every 4 clocks and timer 1 is incremented every time timer 2
// reaches its max count. Both use 16-bit counters.
#define TIMER_SCALAR 4			// Scale by 3
#define TIMER_MAX_COUNT 41667u	// Max count for about 60 Hz

extern CPU_state	gExecutionState;

// IntLib Function Prototypes
#define SetReturnPoint()	SaveExecState(&gExecutionState)
#define LoadReturnPoint()	RestoreExecState(&gExecutionState)
void interrupt HandleReceivedByte(void);
void Terminate(void);
void TimerPause(void);
void TimerGo(void);
void SetupTimer(WORD maxCount, WORD scalar, void interrupt far (*pISR)(void));
void DisableTimer(void);
void SetupInterrupts(void);
void RestoreInterrupts(void);
void SaveExecState(CPU_state far *pState);
void RestoreExecState(CPU_state far *pState);

#endif	// #ifndef INTLIB_H
