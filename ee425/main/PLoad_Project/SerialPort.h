///////////////////////////////////////////////////////////////////////////////
// Name: SerialPort.h
// Author: Wade S. Fife
// Date: June 5, 2003
// Description: Header file for SerialPort.c
//
///////////////////////////////////////////////////////////////////////////////

#ifndef SERIAL_PORT_H
#define SERIAL_PORT_H

#include "8086.h"


// DEFINITIONS ////////////////////////////////////////////////////////////////

#define CPU_CLOCK_RATE			40000000l	// 40 MHz clock speed assumed
#define BAUD_RATE(DESIRED_BAD)	((unsigned)((double)(CPU_CLOCK_RATE) / 16.0 / (double)(DESIRED_BAD) + 0.5))

#define MAX_SENDF_STRING_SIZE	200


// TYPE DECLARATIONS //////////////////////////////////////////////////////////

// Serial port FIFO structure:
typedef struct {
	BYTE *inBuffer;		// Pointer to input buffer
	BYTE *inHead; 		// Input FIFO head pointer
	BYTE *inTail; 		// Input FIFO tail pointer
	BYTE *inMax;		// Max value an input buffer pointer can have + 1
	WORD inSize;		// Size of input buffer in bytes
	WORD inBytes;

	BYTE *outBuffer;	// Pointer to output buffer
	BYTE *outHead;		// Output FIFO head pointer
	BYTE *outTail;		// Output FIFO tail pointer
	BYTE *outMax;		// Max value an output buffer pointer can have + 1
	WORD outSize;		// Size of output buffer in bytes
	WORD outBytes;
} SerialPort;


// FUNCTION PROTOTYPES ////////////////////////////////////////////////////////

void interrupt SerialPortISR(void);
int SerialPortHandler(void);

void InitSerialPort(WORD baud_divisor, BYTE *in_buffer, WORD in_buffer_size, BYTE *out_buffer, WORD out_buffer_size);

void CloseSerialPort(void);
void ResetSerialPort(void);

void SetCallback(void (*funcPtr)(void));

WORD DataReady(void);

BYTE RecvByte(void);
WORD RecvWord(void);
DWORD RecvDword(void);
void RecvData(void *buffer, WORD numBytes);
void RecvFarData(void far *buffer, WORD numBytes);

void SendByte(BYTE data);
void SendWord(WORD data);
void SendDword(DWORD data);
void SendData(void *data, WORD numBytes);
void SendDataFar(void far *data, WORD numBytes);

void SendBytePoll(BYTE data);
void SendDataPoll(void *data, WORD numBytes);
void SendStringPoll(const char *string);

void sends(const char *string);
int sendf(const char *format, ...);
void SendDosStringFar(const char far *string);

void GenHexWord(WORD num, char *string);
void GenHexByte(BYTE num, char *string);
void SendHexWordPoll(WORD num);
void SendHexBytePoll(BYTE num);
void SendHexWord(WORD num);
void SendHexByte(BYTE num);

void WaitSend(void);
void WaitSendComplete(void);


#endif	// #ifndef SERIAL_PORT_H
