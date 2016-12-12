//////////////////////////////////////////////////////////////////////////////
//
// File: ConsoleWindow.cpp
// Author: Wade Fife
// Last Modified: May 15, 2003
// Description: Implementaion of the CConsleWindow class. This object allows
//   the creation of subwindows within the current console window. These
//   subwindows behave like separate console windows, allowing regions of the 
//   console to be avoided when text is displayed.
//
//////////////////////////////////////////////////////////////////////////////

#include "ConsoleWindow.h"
#include <string.h>


CConsoleWindow::CConsoleWindow()
{
	buffer = NULL;
}

CConsoleWindow::~CConsoleWindow()
{
	if(buffer) free(buffer);
}

// Call this before calling any other function!
// (x,y) is the coordinate of the upper left cell of the new logical window object, relative to actual window; 
// (0,0) is the top left cell of window.
bool CConsoleWindow::InitWindow(int x, int y, int columns, int rows)
{
	// Save window info
	pos.X = 0;
	pos.Y = 0;
	orig.X = x;
	orig.Y = y;
	numRows = rows;
	numCols = columns;
	hOutput = GetStdHandle(STD_OUTPUT_HANDLE);

	// Create buffer for manipulation (with extra blank line)
	buffer = (char *)malloc(columns * rows + columns);
	if(buffer == NULL) return false;
	memset(buffer, ' ', columns * rows + columns);	// Add blank line at end of buffer.

	// Set up cursor
	cursorInfo.dwSize = DEFAULT_CURSOR_SIZE;
	cursorInfo.bVisible = true;
	MakeActive();

	return true;
}


// Returns a value from 1 to 100.
int CConsoleWindow::GetCursorSize(void)
{
	return cursorInfo.dwSize;
}


// Returns true if the cursor is visible, false otherwise.
bool CConsoleWindow::GetCursorVis(void)
{
	if(cursorInfo.bVisible) return true;
	return false;
}

// Stores the X and Y coordinates of cursor (relative to window object) in x and y.
void CConsoleWindow::GetCursorPos(int *x, int *y)
{
	*x = pos.X;
	*y = pos.Y;
}


// Height must be from 1 to 100
void CConsoleWindow::SetCursorSize(int height)
{
	if(height >= 1 && height <= 100) {
		cursorInfo.dwSize = height;
		SetConsoleCursorInfo(hOutput, &cursorInfo);
	}
}


// If visbile is true, makes the cursor visible. Otherwise hides the cursor.
void CConsoleWindow::SetCursorVis(bool visible)
{
	cursorInfo.bVisible = visible;
	SetConsoleCursorInfo(hOutput, &cursorInfo);
}


// Restore cursor visibility, size, and position
void CConsoleWindow::MakeActive(void)
{
	COORD coord;
	
	coord.X = orig.X + pos.X;
	coord.Y = orig.Y + pos.Y;

	SetConsoleCursorInfo(hOutput, &cursorInfo);
	SetConsoleCursorPosition(hOutput, coord);
}


// Clear the contents of the window and reposition the cursor at (0,0).
void CConsoleWindow::ClearWindow(void)
{
	int maxRow;
	char *blank;
	COORD coord;
	DWORD numBytes;

	blank = buffer + numCols*numRows;

	coord = orig;
	maxRow = coord.Y + numRows;
	while(coord.Y < maxRow) {
		WriteConsoleOutputCharacter(hOutput, blank, numCols, coord, &numBytes);
		coord.Y++;
	}

	SetCursorPos(0,0);
}


// Move corsur to (x,y) relative to window.
void CConsoleWindow::SetCursorPos(int x, int y)
{
	COORD coord;
	if(x < numRows && x >= 0 && y < numCols && y >= 0) {
		pos.X = x;
		pos.Y = y;
		coord.X = orig.X + x;
		coord.Y = orig.Y + y;
		SetConsoleCursorPosition(hOutput, pos);
	}
}


// Scroll window contents, don't move cursor
void CConsoleWindow::Scroll(void)
{
	DWORD numBytes;
	COORD coord;
	int row;
	
	coord.X = orig.X;
	coord.Y = orig.Y + 1;

	for(row = 0; row < numRows-1; row++) {
		ReadConsoleOutputCharacter(hOutput, buffer + row*numCols, numCols, coord, &numBytes);
		coord.Y++;
	}

	coord = orig;
	for(row = 0; row < numRows; row++) {
		WriteConsoleOutputCharacter(hOutput, buffer + row*numCols, numCols, coord, &numBytes);
		coord.Y++;
	}
}


// Print indicated character and move cursor.
void CConsoleWindow::PrintChar(char c)
{
	COORD coord;
	DWORD numBytesWritten;


	switch(c) {
	case '\n':
		if(pos.Y >= numRows-1) Scroll();
		else pos.Y++;
		pos.X = 0;
		break;
	case '\r':
		pos.X = 0;
		break;
	case '\t':
		pos.X += (TAB_SIZE - (pos.X % TAB_SIZE));
		if(pos.X >= numCols) PrintChar('\n');
		break;
	case '\b':
		if(pos.X > 0) pos.X--;
		break;
	default:
		// output character
		coord.X = orig.X + pos.X;
		coord.Y = orig.Y + pos.Y;
		WriteConsoleOutputCharacter(hOutput, &c, 1, coord, &numBytesWritten);
		
		// Update logical cursor position
		pos.X++;
		if(pos.X >= numCols) {
			PrintChar('\n');
			return;
		}

		// Move cursor
		coord.X++;
		SetConsoleCursorPosition(hOutput, coord);
		return;
	}

	// Move cursor
	coord.X = orig.X + pos.X;
	coord.Y = orig.Y + pos.Y;
	SetConsoleCursorPosition(hOutput, coord);
}


// Use PrintChar() to print length bytes of string.
void CConsoleWindow::Print(char *string, int length)
{
	while(length--) PrintChar(*string++);
}


// Use PrintChar() to print null terminated string.
void CConsoleWindow::Print(char *string)
{
	Print(string, strlen(string));
}
