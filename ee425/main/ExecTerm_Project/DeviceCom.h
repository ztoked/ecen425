//////////////////////////////////////////////////////////////////////////////
//
// File: DeviceCom.h
// Author: Wade Fife
// Last Modified: May 15, 2003
// Description: Header file for DeviceCom.cpp.
//
// Notes: This file contains values used for communication between ExecTerm
//   (running on the PC) and PLoad (running on the Am186 microcontroller).
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Simptris Communications Values

// NOTE: All values sent and received are assumed to be little endian!

// Commands sent by player system
#define CMD_SLIDE_LEFT		0	// 3-byte command - (BYTE)command, (WORD)pieceID
#define CMD_SLIDE_RIGHT		1	// 3-byte command - (BYTE)command, (WORD)pieceID
#define CMD_ROTATE_LEFT		2	// 3-byte command - (BYTE)command, (WORD)pieceID
#define CMD_ROTATE_RIGHT	3	// 3-byte command - (BYTE)command, (WORD)pieceID
#define CMD_SEED			4	// 5-byte command - (BYTE)command, (DWORD)seed
#define CMD_START			5	// 1-byte command - (BYTE)command
#define CMD_EXIT			6	// 1-byte command - (BYTE)command, (WORD)exitCode


// Signals sent by game system
#define SIG_GAME_OVER			0	//  1-byte signal - (BYTE)signal
#define SIG_NEW_STRAIGHT_0_0	1	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_STRAIGHT_0_1	2	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_STRAIGHT_0_2	3	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_STRAIGHT_0_3	4	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_STRAIGHT_0_4	5	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_STRAIGHT_0_5	6	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_STRAIGHT_1_0	7	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_STRAIGHT_1_1	8	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_STRAIGHT_1_2	9	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_STRAIGHT_1_3	10	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_STRAIGHT_1_4	11	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_STRAIGHT_1_5	12	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_0_0		13	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_0_1		14	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_0_2		15	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_0_3		16	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_0_4		17	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_0_5		18	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_1_0		19	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_1_1		20	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_1_2		21	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_1_3		22	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_1_4		23	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_1_5		24	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_2_0		25	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_2_1		26	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_2_2		27	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_2_3		28	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_2_4		29	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_2_5		30	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_3_0		31	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_3_1		32	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_3_2		33	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_3_3		34	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_3_4		35	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_NEW_CORNER_3_5		36	//  3-byte signal - (BYTE)signal, (WORD)newPieceID
#define SIG_RECEIVED			37	//  1-byte signal - (BYTE)signal
#define SIG_TOUCHDOWN			38	// 15-byte signal - (BYTE)signal, (WORD)pieceID,  (WORD)col0, (WORD)col1, (WORD)col2, (WORD)col3, (WORD)col4, (WORD)col5
#define SIG_LINE_CLEAR			39	//  1-byte signal - (BYTE)signal

#define SIG_TERMINATE			40	//  1-byte signal = (BYTE)signal

#define SIG_NEW_STRAIGHT(ORIEN,COL) (SIG_NEW_STRAIGHT_0_0 + (ORIEN)*6 + (COL))
#define SIG_NEW_CORNER(ORIEN,COL) (SIG_NEW_CORNER_0_0 + (ORIEN)*6 + (COL))


//////////////////////////////////////////////////////////////////////////////
// Data types

#pragma pack(push, 1)	// Byte align structures (no padding)

typedef struct {
	BYTE type;
	WORD id;
	WORD p0,p1,p2,p3,p4,p5;
} ComData;

#pragma pack(pop)		// Return to normal padding


//////////////////////////////////////////////////////////////////////////////
// Function Return Values

#define STATUS_OK			1
#define STATUS_EXIT			2
#define STATUS_FORCED_QUIT	3
#define STATUS_ERROR		4


//////////////////////////////////////////////////////////////////////////////
// Function Prototypes

void InitDeviceCom(CSimptris *Simptris, CProgramWindow *Window);
bool InitPort(char *portName, DWORD baudRate);
void ClosePort(void);
bool LoadBinary(char *path);
bool ExecBinary(void);
bool WaitCommand(BYTE command);
void SetCPU(double clockRate, double simpCallFreq);
int ExecLoop(void);
int HandleCommand(BYTE command);
void ClearSerialBuffer(void);
bool ReadData(void *dest, DWORD numBytes);
bool WaitString(char *string);
bool WriteDataRead(void *data, DWORD numBytes);
bool WriteData(void *data, DWORD numBytes);
inline BOOL CheckQuit(void);
unsigned __int64 SystemTick(void);



