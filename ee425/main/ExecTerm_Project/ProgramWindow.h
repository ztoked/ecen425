// ProgramWindow.h: interface for the CProgramWindow class.
//
//////////////////////////////////////////////////////////////////////

#ifndef PROGRAM_WINDOW_H
#define PROGRAM_WINDOW_H

#include <windows.h>
#include "ConsoleWindow.h"

class CProgramWindow  
{
private:
	HANDLE hOutput;
	CConsoleWindow window;
	
	COORD oldBufferSize;
	SMALL_RECT oldWindowSize;
	WORD oldAttributes;

public:
	CProgramWindow();
	virtual ~CProgramWindow();

	void Init(int width, int height);
	void ClearWindow(void);
	void DrawBoardFrame(void);
	void SendScore(unsigned score);
	void SendBoard(char *data);

	void print(char *string) { window.Print(string); }
	void printChar(char c)	{ window.PrintChar(c); }
	int printf(char *fmt, ...);
};

#endif	// #ifndef PROGRAM_WINDOW_H

