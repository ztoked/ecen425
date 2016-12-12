//////////////////////////////////////////////////////////////////////////////
//
// File: main.cpp
// Author: Wade Fife
// Last Modified: July 10, 2003
// Description: Main file for ExecTerm (Execution Terminal). ExecTerm allows
//   EE 425 binaries intended for the Emu86 simulator to be loaded and executed
//   by transfering them to an AMD Am186ES microcontroller on a TERN A-Core-86
//   board.
//
// Notes: This file contains code initialize the terminal window and simptris 
//   board. It also contains the menu system for user conrol.
//
//   The files ProgramWindow.cpp and Simptris.cpp are taken from Emu86 and 
//   have been changed very little to allow them to work here.
//
//   The file ConsoleWindow.cpp/.h contains an object that allows the creation
//   of a sub window in the console window for text output.
//
//////////////////////////////////////////////////////////////////////////////

#include <windows.h>
#include <conio.h>
#include <stdio.h>
#include <time.h>

#include "Simptris.h"
#include "DeviceCom.h"
#include "ConsoleWindow.h"

#define COM_PORT	"COM1"
#define BAUD_RATE	CBR_38400

#define DEFAULT_SIMP_FREQ	(500.0)	// Desired call frequency (in Hz) to handle_simptris()


char comPort[5];

CSimptris simptris;
CProgramWindow window;


void BinToHex(char *dest, void *data, int numBytes)
{
	int i;
	BYTE b;
	
	
	numBytes <<= 1;
	i = 0;
	
	while(numBytes--) {
		b = ((BYTE *)data)[i>>1];
		
		// Get high nibble if i is even, low nibble if odd
		if(i & 1) b = (b & 0x0F);
		else b = (b & 0xF0) >> 4;

		// Convert nibble to ascii hex
		if(b >=0 && b <= 9) b += '0';
		else b += 'A'- 0xA;

		dest[i] = b;

		i++;
	}

	dest[i] = 0;
}


HWND GetConsoleWindowHandle(void)
{
	__int64 timeStamp;
	char tempTitle[2*sizeof(timeStamp)];
	TCHAR oldTitle[512];
	HWND hWnd;

	// Generate unique window title
	timeStamp = SystemTick();
	BinToHex(tempTitle, &timeStamp, sizeof(timeStamp));

	// Backup old console window title
	if(GetConsoleTitle(oldTitle, sizeof(oldTitle)/sizeof(TCHAR)) == 0) return NULL;
	SetConsoleTitle(tempTitle);

	// Find the window we just named to tempTitle
	hWnd = FindWindow(NULL, tempTitle);

	// Restore old title
	SetConsoleTitle(oldTitle);
	return hWnd;
}


/*
int GetString(char *dest, int maxSize)
{
	int i;
	char c;

	i = 0;

	while(1) {
		if(i >= maxSize-1) break;
		c = getch();
		if(c == '\r' || c == '\n') break;
		if(c == '\b') {
			if(i > 0){
				putchar('\b');
				putchar(' ');
				putchar('\b');
				i--;
			}
		}
		else {
			putchar(c);
			dest[i] = c;
			i++;
		}
	}

	dest[i] = 0;	// Null terminate

	return i;	// Return length
}
*/

int GetFloatString(char *dest, int maxSize)
{
	int i;
	char c;

	i = 0;

	while(1) {
		if(i >= maxSize-1) break;
		c = getch();
		if(c == '\r' || c == '\n') break;
		if(c == '\b') {
			if(i > 0){
				putchar('\b');
				putchar(' ');
				putchar('\b');
				i--;
			}
		}
		else if((c >= '0' && c <= '9') || c == '.') {
			putchar(c);
			dest[i] = c;
			i++;
		}
	}

	dest[i] = 0;	// Null terminate

	return i;	// Return length
}

char ToLower(char c)
{
	if(c >= 'A' && c <= 'Z') c -= ('A' - 'a');
	return c;
}

char ToUpper(char c)
{
	if(c >= 'a' && c <= 'z') c -= ('a' - 'A');
	return c;
}


double GetProcessorSpeed(void)
{
	time_t sec;
	unsigned __int64 start, end;

	// Wait until next second
	sec = time(NULL);
	while(time(NULL) == sec);
	sec = time(NULL);

	start = SystemTick();

	// Wait 1 second
	while(time(NULL) == sec);

	end = SystemTick();

	return (double)(__int64)(end - start);
}


void InitFileDlg(HWND hWnd, OPENFILENAME *dlg, char *filePath, int nameLength)
{
	//tatic char *filter[] = { "Binary executables", "*.bin", "COM file", "*.com\0" };

	memset(dlg, 0, sizeof(OPENFILENAME));
	dlg->lStructSize = sizeof(OPENFILENAME);
	dlg->hwndOwner = hWnd;
    dlg->lpstrFilter = "Binary executables (*.bin)\0*.bin\0COM files (*.com)\0*.com\0All files (*.*)\0*.*\0"; //filter;

	filePath[0] = '\0';		// No default file
    dlg->lpstrFile = filePath;
    dlg->nMaxFile = nameLength;

    dlg->lpstrTitle = "Executable File Load";
    
	dlg->Flags = OFN_FILEMUSTEXIST | OFN_HIDEREADONLY | OFN_NOCHANGEDIR;
}

void PlayLoop(void)
{
	OPENFILENAME dlg;
	HWND hWnd;
	char filePath[MAX_PATH+1];
	char c;

	filePath[0] = '\0';

	hWnd = GetConsoleWindowHandle();

	InitFileDlg(hWnd, &dlg, filePath, MAX_PATH);

	// Display file open dialog box for first time. (Set window to very top, since for some reason dialog box appears behind console window first time)
	SetWindowPos(hWnd, HWND_TOPMOST, NULL, NULL, NULL, NULL, SWP_NOMOVE | SWP_NOSIZE);
	if(GetOpenFileName(&dlg)) c = 'r';
	else c = 0;
	SetWindowPos(hWnd, HWND_NOTOPMOST, NULL, NULL, NULL, NULL, SWP_NOMOVE | SWP_NOSIZE);

	while(true) {
		// Load file
		if(c == 'l') {
			if(GetOpenFileName(&dlg)) c = 'r';
			else c = 0;
		}
		
		// Execute file
		if(c == 'r') {
			if(filePath[0] != '\0') {
				window.DrawBoardFrame();
				
				// Set up serial port
				if(InitPort(comPort, BAUD_RATE)) {
					window.print("\nTerminal started\n_________________________________________________________________\n");
					ClearSerialBuffer();
					
					if(LoadBinary(filePath)) {
						// Send signal to start execution, if succeeds, enter execution loop
						if(ExecBinary()) ExecLoop();
						else window.print("Execution failed.\n");
					}
					else window.print("Load failed.\n");
					window.print("\n_________________________________________________________________\n");
					
					// Close com port
					ClosePort();
				}
				else window.printf("Serial port %s could not be used.\n", comPort);
			}
			else window.printf("No binary to run again. Load file first.\n");
		}

		// Display options menu
		while(kbhit()) getch();	// Clear any keyboard input
		window.print("\nOptions:  R> Run again  L> Load new file  E> Exit ");
		while(true) {
			c = ToLower(getch());
			if(c == 'r' || c == 'l' || c == 'e' || c == 27) break;
		}
		if(c == 'e' || c == 27) break;
		window.print("\n");
	}
}

//FILE *dork;
void main(int argc, char *argv[])
{
//	dork = fopen("output.txt", "w");
//	if(dork == NULL) {
//		printf("Couldn't create output file.\n");
//		return;
//	}

	char *ptr;
	char string[20];
	double clockRate;
	double callFreq;

	// Get command line
	if(argc > 1) {
		// Convert argument to uppercase
		ptr = argv[1];
		while(*ptr != '\0') *ptr++ = ToUpper(*ptr);

		if(
			!strcmp(argv[1], "COM1") ||
			!strcmp(argv[1], "COM2") ||
			!strcmp(argv[1], "COM3") ||
			!strcmp(argv[1], "COM4")
			) strcpy(comPort, argv[1]);
		else {
			printf("Invalid argument: \"%s\". Should be COM1, COM2, COM3, or COM4.\n", argv[1]);
			return;
		}
	}
	else strcpy(comPort, COM_PORT);

	// Set up output windows
	window.Init(80, 25);
	window.DrawBoardFrame();
	
	// Set up simptris
	simptris.SetWindow(&window);
	
	InitDeviceCom(&simptris, &window);

	// Set CPU speed
	clockRate = 0;
	window.printf("Enter CPU speed in MHz (or press Enter to measure):\n");
	while(clockRate <= 0) {
		if(GetFloatString(string, 20) != 0) {
			clockRate = atof(string);
			clockRate *= 1000000.0;
		}
		else clockRate = GetProcessorSpeed();
	}
	window.printf("%f MHz CPU\n\n", clockRate / 1000000.0);

	// Get simptris call frequency
	callFreq = 0;
	window.printf("Enter desired Simptris freq in Hz (or press Enter for 500 Hz):\n");
	while(callFreq <= 0) {
		if(GetFloatString(string, 20) != 0) {
			callFreq = atof(string);
		}
		else callFreq = DEFAULT_SIMP_FREQ;
	}
	window.printf("%f Hz\n", callFreq);

	SetCPU(clockRate, callFreq);

	PlayLoop();

//	fclose(dork);
}
