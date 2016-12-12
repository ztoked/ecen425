#include "clib.h"

int ticks = 0;
extern int KeyBuffer;

void tickHandler()
{
	++ticks;
	printString("\nTICK ");
	printInt(ticks);
	printNewLine();
}

void keyboardHandler()
{
	if(KeyBuffer == 'd')
	{
		int i = 0;
		printString("\nDELAY KEY PRESSED\n");
		while(i < 5000)
		{
			++i;
		}
		printString("DELAY COMPLETE\n");
	}
	else
	{
		printString("\nKEYPRESS (");
		printChar(KeyBuffer);
		printString(") IGNORED\n");
	}
}
