//////////////////////////////////////////////////////////////////////////////
//
// File: DeviceCom.cpp
// Author: Wade Fife
// Last Modified: July 10, 2003
// Description: Allows communication between a PC and an AMD Am186ES 
//   microcontroller on a TERN A-Core-86 board. It is intended to work in
//   conjunction with PLoad, a loader programming that should be running
//   on the Am186 microcontroller.
//
// Notes: This file contains code to load binaries onto the microcontroller 
//   by transfering them over the serial port and to cause the microcontroller 
//   the binary. It also plays simptris by accepting simptris commands from
//   the microcontroller via the serial port (e.g., start simptris, slide piece,
//   etc.) and sending simptris event signals over the serial port (e.g., 
//   new piece, line cleared, touchdown, etc.).
//
//   Any non-simptris data received on the serial port is assumed to text 
//   output and is dumped to the output window.
//
//////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <conio.h>
#include "Bios.h"
#include "Simptris.h"
#include "DeviceCom.h"

#define MIN(X,Y)	((X) < (Y) ? (X) : (Y))

#define MAX_WAIT_STRING		100

static CSimptris *pSimptris;
static CProgramWindow *pWindow;

static unsigned __int64 waitDelay;

static HANDLE hPort = INVALID_HANDLE_VALUE;


void signal_interrupt(int intID, int a, int b, int c, int d)
{
	ComData signal;
	DWORD size;
	DWORD numBytesWritten;

	switch (intID) {
	case TET_GAME_OVER:
		// Signal that the game has ended
		signal.type = SIG_GAME_OVER;
		size = 1;
		break;
	case TET_TOUCHDOWN:
		// Signal that a touchdown has occured
		// a is piece id
		// b through d are the 96 bits for the playing screen bitmap
		signal.type = SIG_TOUCHDOWN;
		signal.id = a;
		signal.p0 = (WORD)(b >> 16);
		signal.p1 = (WORD)(b);
		signal.p2 = (WORD)(c >> 16);
		signal.p3 = (WORD)(c);
		signal.p4 = (WORD)(d >> 16);
		signal.p5 = (WORD)(d);
		size = 15;
		break;
	case TET_PIECE_A:
		// Signal that a new corner peice has entered scene (type A)
		// a is piece id
		// b is piece orientation
		// c is entry column
		signal.type = SIG_NEW_CORNER(b,c);
		signal.id = a;
		size = 3;
		break;
	case TET_PIECE_B:
		// Signal that a new straight peice has entered scene (type B)
		// a is piece id
		// b is piece orientation
		// c is entry column
		signal.type = SIG_NEW_STRAIGHT(b,c);
		signal.id = a;
		size = 3;
		break;
	case TET_RECEIVED:
		// Signal that last command was received and Tetris is ready for a new command
		signal.type = SIG_RECEIVED;
		size = 1;
		break;
	case TET_LINE_CLEAR:
		// Signal that a line has been cleared
		signal.type = SIG_LINE_CLEAR;
		size = 1;
		break;
	default:
		return;
	}

	// This code causes to be printed the data that is being sent.
/*
	int i;
	pWindow->print("<SEND");
	for(i = 0; i < size; i++) pWindow->printf(" %02X", (DWORD)(((BYTE *)(&signal))[i]));
	pWindow->print(">");
*/

	// Send the signal	
	WriteFile(hPort, &signal, size, &numBytesWritten, NULL);
	if(size != numBytesWritten) {
		// ERROR ***************************************************************************************
		pWindow->printf("ERROR: Could not send the entire signal (signal type %u, error %u).\n", (DWORD)signal.type, GetLastError());
	}
}


// Call this function before any others!
void InitDeviceCom(CSimptris *Simptris, CProgramWindow *Window)
{
	pSimptris = Simptris;
	pWindow = Window;
}


// Set up COM port usage (1 stop bit, no parity, no flow control). Return true if successful, false otherwise.
// For baudRate use the #define values from WINBASE.H
// (see DCB struct in MSDN Library for more info).
bool InitPort(char *portName, DWORD baudRate)
{
	DCB portConfig = { 0 };
	COMMTIMEOUTS timeout = { 0 };

	// Clean up port (sometimes doesn't work first time);
	hPort = CreateFile(portName, GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, FILE_FLAG_WRITE_THROUGH, NULL);
	if(hPort != INVALID_HANDLE_VALUE) CloseHandle(hPort);
	
	// Open up requested com port
	hPort = CreateFile(
		portName,  
		GENERIC_READ | GENERIC_WRITE,       
		0, 
		NULL,
		OPEN_EXISTING,
		FILE_FLAG_WRITE_THROUGH,
		NULL
		);

	if(hPort == INVALID_HANDLE_VALUE) {
		pWindow->printf("ERROR: Couldn't open requested communications port (error %u).\n", GetLastError());
		return false;
	}

	// Configure port settings
	portConfig.DCBlength = sizeof(portConfig);

	portConfig.fBinary = 1;				// Binary mode
	
	portConfig.ByteSize  = 8;			// 8 Data bits
	portConfig.Parity    = NOPARITY;	// No parity
	
	portConfig.BaudRate  = baudRate;	// Set baud rate
	portConfig.StopBits  = ONESTOPBIT;	// Set number of stop bits 

	if(!SetCommState(hPort, &portConfig)) {
		pWindow->printf("ERROR: Couldn't not set port to requested settings (error %u).\n", GetLastError());
		return false;
	}

	/*
	// Set up events to wait for
	if(!SetCommMask(hPort, EV_RXCHAR)) {
		pWindow->printf("ERROR: Couldn't not configure port to signal events (error %u).\n", GetLastError());
		return false;
	}
	*/

	// Set Read blocking
	timeout.ReadIntervalTimeout = MAXDWORD;
	if(!SetCommTimeouts(hPort, &timeout)) {
		pWindow->printf("ERROR: Couldn't not set port Read to non-blocking mode (error %u).\n", GetLastError());
		return false;
	}

	return true;
}


// Terminate use of the communications port and free use.
void ClosePort(void)
{
	if(hPort != INVALID_HANDLE_VALUE) {
		CloseHandle(hPort);
		hPort = INVALID_HANDLE_VALUE;
	}
}

// Send signal that a command is next and wait for acknowledgment.
// Returns fals if an error occured or if a key was pressed to exit.
bool CmdStart(void)
{
	WriteData("<CMD>", 5);
	return WaitString("<READY>");
}

// Sends end of command signal and waits until end of command confirmation received.
// Returns false if an error occured or if a key was pressed to exit.
bool CmdEnd(void)
{
	WriteData("<END>", 5);
	return WaitString("<DONE>");
}



// Sends binary executable over serial port. The byte value CMD_LOAD
// signals that data follows. The data must be sent in the following form/order:
// (WORD)IVT_size,
// (WORD)IVT_dest_addr,	  							- Only if IVT_size != 0
// (DWORD)binary_size
// (DWORD)binary_dest_addr,							- Only if binary_size != 0
// (BYTE)CMD_IVT_START, (BYTE[])IVT_data,			- Only if IVT_size != 0
// (BYTE)CMD_BIN_START, (BYTE[])binary_data			- Only if binary_size != 0
// (BYTE)CMD_EOC
// NOTES:
//    IVT = "Interrupt Vector Table". It must be separate to avoid crashing.
//    If IVT_size is 0, IVT_dest_addr and IVT_data shouldn't be sent.
//    If binary_size is 0, binary_dest_addr and binary_data shouldn't be sent.
bool LoadBinary(char *path)
{
	BYTE *buffer;
	FILE *file;
	long size;
	
	// Load File //

	// Open file
	file = fopen(path, "rb");
	if(file == NULL) {
		pWindow->printf("Could not load file \"%s\".\n", path);
		return false;
	}

	// Get file size
	fseek(file, 0, SEEK_END);
	size = ftell(file);
	fseek(file, 0, SEEK_SET);

	// Allocate memory to load file
	buffer = (BYTE *)malloc(size);
	if(buffer == NULL) return false;

	// Read file
	if(fread(buffer, 1, size, file) != (size_t)size) {
		free(buffer);
		return false;
	}

	fclose(file);


	// Send File //

	// Send file over channel
	BYTE cmd;
	WORD sizeIVT;
	WORD addrIVT;
	DWORD sizeBin;
	DWORD addrBin;

	sizeIVT = (WORD)MIN(1024, size);
	sizeBin = size - sizeIVT;
	addrIVT = 0;
	addrBin = sizeIVT;

	
	// Send command to reset microcontroller's serial port (necessary on some computers)
	if(!CmdStart()) return false;
	cmd = 'R';
	if(!WriteData(&cmd, 1)) return false;
	Sleep(500);
	if(!CmdEnd()) return false;

	
	// Send load command

	if(!CmdStart()) return false;
	cmd = 'L';
	WriteDataRead(&cmd, 1);		// Send CMD_LOAD
	WriteDataRead(&sizeIVT, 2);	// Send IVT size
	WriteDataRead(&addrIVT, 2);	// Send IVT dest addr
	WriteDataRead(&sizeBin, 4);	// Send binary size
	if(sizeBin) WriteDataRead(&addrBin, 4);	// Send binary dest addr

	cmd = 'I';
	WriteDataRead(&cmd, 1);		// Send CMD_IVT_START
	if(!WriteDataRead(buffer, sizeIVT)) return false;
	
	if(sizeBin) {
		cmd = 'B';			// Send CMD_BIN_START
		WriteDataRead(&cmd, 1);
		if(!WriteDataRead(&buffer[sizeIVT], sizeBin)) return false;
	}

	// Send end of command signal and wait for acknowledgement
	if(!CmdEnd()) return false;

	return true;
}


bool ExecBinary(void)
{
	BYTE cmd;
	DWORD startOffset;
	DWORD startSegment;
	
	// Initiate command
	if(!CmdStart()) return false;

	// Send execute command
	cmd = 'E';
	startOffset = 0x100;
	startSegment = 0;
	
	WriteDataRead(&cmd, 1);
	WriteDataRead(&startOffset, 2);
	WriteDataRead(&startSegment, 2);

	// Send end of command signal, wait for acknowledgment
	if(!CmdEnd()) return false;

	return true;
}


void SetCPU(double clockRate, double simpCallFreq)
{
	// Determine number of cpu clocks for a delay of SIMP_DELAY

	waitDelay = (__int64)(clockRate/simpCallFreq);
}


int ExecLoop(void)
{
	unsigned __int64 nextTime;
	DWORD numBytesRead;
	//DWORD count = 0;
	BYTE command;
	int status;

	nextTime = SystemTick() + waitDelay;

	while(true) {
		// Check if a request has been made to quit.

		if(CheckQuit()) {
			// Send signal to terminate
			command = SIG_TERMINATE;
			WriteData(&command, 1);
			break;
		}

		// Do symptris cycle if time has elapsed
		// if(count++ % SIMP_TIME_SCALE == 0) pSimptris->handle_simptris();
		if(SystemTick() >= nextTime) {
				pSimptris->handle_simptris();
				
				// Reset clock counter
				nextTime = SystemTick() + waitDelay;
		}
		
		// Check for new communication 
		ReadFile(hPort, &command, 1, &numBytesRead, NULL);
		if(numBytesRead != 0) {
			status = HandleCommand(command);
			if(status != STATUS_OK) return status;
		}
	}

	// Stop simptris from running
	pSimptris->EndGame();

	return STATUS_FORCED_QUIT;
}


// Wait for a conneciton. Return true if successful, false otherwise.
bool WaitCommand(BYTE command)
{
	DWORD numBytesRead;
//	DWORD event;
	BYTE cmd = 0;

	// Wait for byte to arrive
	while(true) {
		if(CheckQuit()) return false;
		// WaitCommEvent(hPort, &event, NULL);
		ReadFile(hPort, &cmd, 1, &numBytesRead, NULL);
		if(cmd == command) break;
	}

	return true;
}



int HandleCommand(BYTE command)
{
	BYTE b;
	WORD w;
	DWORD dw;

	switch(command) {
	case CMD_SLIDE_LEFT:
		ReadData(&w, 2);
		pSimptris->SlidePieceCmd(w, 0);
		break;
	case CMD_SLIDE_RIGHT:
		ReadData(&w, 2);
		pSimptris->SlidePieceCmd(w, 1);
		break;
	case CMD_ROTATE_LEFT:
		ReadData(&w, 2);
		pSimptris->RotatePieceCmd(w, 0);
		break;
	case CMD_ROTATE_RIGHT:
		ReadData(&w, 2);
		pSimptris->RotatePieceCmd(w, 1);
		break;
	case CMD_SEED:
		ReadData(&dw, 4);
		pSimptris->seed(dw);
		break;
	case CMD_START:
		pSimptris->init_simptris();
		break;
	case CMD_EXIT:
		ReadData(&b, 1);
		pWindow->printf("\nProgram terminated with exit code: %d (0x%X).\n", (WORD)b, (WORD)b);
		return STATUS_EXIT;
	default:
		pWindow->printChar(command);
	}

	return STATUS_OK;
}


// Reads (or clears) data any buffered data from serial port.
void ClearSerialBuffer(void)
{
	DWORD numBytesRead;
	BYTE dest;

	do {
		ReadFile(hPort, &dest, 1, &numBytesRead, NULL);
	} while(numBytesRead);
}




bool ReadData(void *dest, DWORD numBytes)
{
	DWORD numBytesRead;
	//DWORD event;
	DWORD i = 0;

	while(i < numBytes) {
		//WaitCommEvent(hPort, &event, NULL);
		if(!ReadFile(hPort, &((BYTE *)dest)[i], numBytes-i, &numBytesRead, NULL)) return false;
		i += numBytesRead;
	}

	return true;
}

// Waits until the indicates string is received. It echos all received data except the string 
bool WaitString(char *string)
{
	char data[MAX_WAIT_STRING];
	DWORD numBytesRead;
	int i, length;

	length = strlen(string);
	data[length-1] = 0;	// Make sure data's it's not same as last call
	i = 0;

	while(memcmp(string, data, length)) {
		// Read next byte
		do {
			if(!ReadFile(hPort, &data[i], 1, &numBytesRead, NULL) || CheckQuit()) return false;
		} while(!numBytesRead);

		if(data[i] == string[i]) i++;
		else {
			// Adjust data to neares matching point
			i++;
			do {
				i--;
				pWindow->printChar(data[i]);	// Echo the character
				memmove(data, data+1, i);
			} while(memcmp(string, data, i));
		}
	}

	return true;
}


// Like WriteData() but reads back and displays any replies
bool WriteDataRead(void *data, DWORD numBytes)
{

	DWORD numBytesRead;
	DWORD numBytesWritten;
	BYTE b;
	DWORD i = 0;

	while(i < numBytes) {
		// Write data
		if(!WriteFile(hPort, &((BYTE *)data)[i], 1, &numBytesWritten, NULL) || CheckQuit()) return false;
		i += numBytesWritten;
		
		// Read and display any data
		do {
			ReadFile(hPort, &b, 1, &numBytesRead, NULL);
			if(numBytesRead) {
				pWindow->printChar(b);
				//getch();
			}
			if(CheckQuit()) return false;
		} while(numBytesRead);
	}

	return true;
}


bool WriteData(void *data, DWORD numBytes)
{
	DWORD numBytesWritten;
	DWORD i = 0;

	while(i < numBytes) {
		if(!WriteFile(hPort, &((BYTE *)data)[i], numBytes-i, &numBytesWritten, NULL)) return false;
		i += numBytesWritten;
	}

	return true;
}


unsigned __int64 SystemTick(void)
{
	unsigned __int64 tickCount;

	_asm {
		rdtsc	// Get processor time-stamp counter
		mov		dword ptr [tickCount], eax
		mov		dword ptr [tickCount+4], edx
	}

	return tickCount;
}

// Returns true if Esc key was pressed since last call.
inline BOOL CheckQuit(void)
{
	return GetAsyncKeyState(VK_ESCAPE);
}