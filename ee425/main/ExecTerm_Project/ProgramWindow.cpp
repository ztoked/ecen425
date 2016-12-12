// ProgramWindow.cpp: implementation of the CProgramWindow class.
//
//////////////////////////////////////////////////////////////////////

#include "ProgramWindow.h"
#include "SimptrisBoard.h"
#include <stdio.h>

#define BOARD_TOP		1	// Position of top of board
#define BOARD_LEFT		1	// Position of left side of board

const unsigned char initialScreen[] = {
	218, 196, 196, 196, 196, 196, 196, 191,
	179,  32,  32,  32,  32,  32,  32, 179,
	179,  32,  32,  32,  32,  32,  32, 179,
	210,  32,  32,  32,  32,  32,  32, 210,
	186,  32,  32,  32,  32,  32,  32, 186,
	186,  32,  32,  32,  32,  32,  32, 186,
	186,  32,  32,  32,  32,  32,  32, 186,
	186,  32,  32,  32,  32,  32,  32, 186,
	186,  32,  32,  32,  32,  32,  32, 186,
	186,  32,  32,  32,  32,  32,  32, 186,
	186,  32,  32,  32,  32,  32,  32, 186,
	186,  32,  32,  32,  32,  32,  32, 186,
	186,  32,  32,  32,  32,  32,  32, 186,
	186,  32,  32,  32,  32,  32,  32, 186,
	186,  32,  32,  32,  32,  32,  32, 186,
	186,  32,  32,  32,  32,  32,  32, 186,
	186,  32,  32,  32,  32,  32,  32, 186,
	200, 205, 205, 205, 205, 205, 205, 188,
};


CProgramWindow::CProgramWindow()
{
	hOutput = INVALID_HANDLE_VALUE;
}

CProgramWindow::~CProgramWindow()
{
	SMALL_RECT consoleWindowDim;
	COORD coord;
	int numCells;
	DWORD temp;

	if(hOutput != INVALID_HANDLE_VALUE) {
		// Set console size to 0
		consoleWindowDim.Bottom = 0;
		consoleWindowDim.Top = 0;
		consoleWindowDim.Left = 0;
		consoleWindowDim.Right = 0;
		SetConsoleWindowInfo(hOutput, TRUE, &consoleWindowDim);

		// Reset console attributes
		SetConsoleScreenBufferSize(hOutput, oldBufferSize);
		SetConsoleWindowInfo(hOutput, FALSE, &oldWindowSize);
		SetConsoleTextAttribute(hOutput, oldAttributes);

		// Clear console
		coord.X = 0;
		coord.Y = 0;
		numCells = (oldWindowSize.Right - oldWindowSize.Left + 1) * (oldWindowSize.Bottom - oldWindowSize.Top + 1);
		FillConsoleOutputAttribute(hOutput, oldAttributes, numCells, coord, &temp);
		FillConsoleOutputCharacter(hOutput, ' ', numCells, coord, &temp);

		// Set cursor position to (0,0)
		SetConsoleCursorPosition(hOutput, coord);
	}
}


void CProgramWindow::Init(int width, int height)
{
	WORD wAttributes;
	COORD dwSize;
	SMALL_RECT consoleWindowDim;
	CONSOLE_CURSOR_INFO consoleCursorInfo;
	CONSOLE_SCREEN_BUFFER_INFO bufferInfo;
	unsigned long int temp;

	// Get console handle
	hOutput = GetStdHandle(STD_OUTPUT_HANDLE);

	// Save current console info
	GetConsoleScreenBufferInfo(hOutput, &bufferInfo);
	oldBufferSize = bufferInfo.dwSize;
	oldWindowSize = bufferInfo.srWindow;
	oldAttributes = bufferInfo.wAttributes;

	// Set console title
	SetConsoleTitle("ExecTerm");

	// Set console size to 0
	consoleWindowDim.Bottom = 0;
	consoleWindowDim.Top = 0;
	consoleWindowDim.Left = 0;
	consoleWindowDim.Right = 0;
	SetConsoleWindowInfo(hOutput, TRUE, &consoleWindowDim);

	
	// Set buffer size
	dwSize.X = width;
	dwSize.Y = height;
	SetConsoleScreenBufferSize(hOutput, dwSize);

	// Set console size
	consoleWindowDim.Bottom = height-1;
	consoleWindowDim.Top = 0;
	consoleWindowDim.Left = 0;
	consoleWindowDim.Right = width-1;
	SetConsoleWindowInfo(hOutput, TRUE, &consoleWindowDim);

	// Clear console
	dwSize.X = 0;
	dwSize.Y = 0;
	wAttributes = FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
	FillConsoleOutputAttribute(hOutput, wAttributes, height*width, dwSize, &temp);
	FillConsoleOutputCharacter(hOutput, ' ', height*width, dwSize, &temp);

	// Change cursor attributes
	consoleCursorInfo.dwSize = 10;	// Percentage of cell to fill
	consoleCursorInfo.bVisible = TRUE;
	SetConsoleCursorInfo(hOutput, &consoleCursorInfo);

	// Move cursor
	//pos.X = pos.Y = 0;
	//SetConsoleCursorPosition(hOutput, dwSize);
	

	// Create scrolling output window
	window.InitWindow(14, 0, width-14, height);

	// Draw vertical line
	DWORD numBytesWritten;
	COORD pos;
	BYTE vChar = 179;
	pos.X = 13;
	for(pos.Y = 0; pos.Y < height; pos.Y++) {
		WriteConsoleOutputCharacter(hOutput, (const char *)&vChar, 1, pos, &numBytesWritten);
	}

//	SendScore(0);
}


void CProgramWindow::ClearWindow(void)
{
	CONSOLE_SCREEN_BUFFER_INFO screenInfo;
	COORD coord;
	unsigned long numCharsWritten;

	GetConsoleScreenBufferInfo(hOutput, &screenInfo);

	coord.X = coord.Y = 0;
	FillConsoleOutputCharacter(hOutput, ' ',  screenInfo.dwSize.X * screenInfo.dwSize.Y, coord, &numCharsWritten);

	SetConsoleCursorPosition(hOutput, coord);
}


void CProgramWindow::DrawBoardFrame(void)
{
	COORD pos;
	int i;
	unsigned long numBytesWritten;

	// Display board //
	pos.X = BOARD_LEFT;
	pos.Y = BOARD_TOP;
	for(i = 0; i < BOARD_HEIGHT+2*BOARD_BORDER; i++) {
		WriteConsoleOutputCharacter(hOutput, (const char *)&initialScreen[(BOARD_WIDTH+2)*i], BOARD_WIDTH+2, pos, &numBytesWritten);
		pos.Y++;
	}
	WriteConsoleOutputCharacter(hOutput, "Lines:      ", 12, pos, &numBytesWritten);

	SendScore(0);
}


void CProgramWindow::SendScore(unsigned score)
{
	char string[12];
	int length;
	COORD pos;
	unsigned long numBytesWritten;

	sprintf(string, "%u", score);
	for(length = 0; string[length] != '\0'; length++);
	pos.X = BOARD_LEFT + (BOARD_WIDTH+BOARD_BORDER);
	pos.Y = BOARD_TOP + (BOARD_HEIGHT+2*BOARD_BORDER);
	WriteConsoleOutputCharacter(hOutput, string, length, pos, &numBytesWritten);
}


void CProgramWindow::SendBoard(char *data)
{
	COORD pos;
	unsigned long numBytesWritten;
	int i;

	pos.X = BOARD_LEFT + BOARD_BORDER;
	pos.Y = BOARD_TOP + BOARD_HEIGHT;

	for(i = 0; i < BOARD_HEIGHT; i++) {
		WriteConsoleOutputCharacter(hOutput, (const char *)&data[(BOARD_WIDTH)*i], BOARD_WIDTH, pos, &numBytesWritten);
		pos.Y--;
	}
}


int CProgramWindow::printf(char *fmt, ...)
{
	static char buffer[2000];
	va_list argptr;
	int cnt;

	va_start(argptr, fmt);
	cnt = vsprintf(buffer, fmt, argptr);
	va_end(argptr);

	window.Print(buffer, cnt);

	return(cnt);
}
