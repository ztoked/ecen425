//////////////////////////////////////////////////////////////////////////////
//
// File: ConsoleWindow.h
// Author: Wade Fife
// Last Modified: May 15, 2003
// Description: Header file for ConsoleWindow.cpp. Contains the class
//   CConsoleWindow.
//
//////////////////////////////////////////////////////////////////////////////

#ifndef CONSOLE_WINDOW_H
#define CONSOLE_WINDOW_H

#include <windows.h>

#define TAB_SIZE 8
#define DEFAULT_CURSOR_SIZE		25

class CConsoleWindow {
public:
	CConsoleWindow();
	virtual ~CConsoleWindow();

	bool InitWindow(int x, int y, int columns, int rows);
	void MakeActive(void);
	void ClearWindow(void);

	int GetCursorSize(void);
	bool GetCursorVis(void);
	void GetCursorPos(int *x, int *y);
	void SetCursorSize(int height);
	void SetCursorVis(bool visible);
	void SetCursorPos(int x, int y);

	void Scroll(void);

	void PrintChar(char c);
	void Print(char *string, int length);
	void Print(char *string);
	//void Refresh(void);

private:
	COORD pos;
	COORD orig;
	int numRows, numCols;
	HANDLE hOutput;
	char *buffer;
	CONSOLE_CURSOR_INFO cursorInfo;
};

#endif	// #ifndef CONSOLE_WINDOW_H
