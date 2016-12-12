#include "clib.h"
#include "yakk.h"

int ticks = 0;
extern int KeyBuffer;
extern YKSEM *NSemPtr;

void tickHandler()
{
	int val;
	YKEnterMutex();
	val = ++ticks;
	YKExitMutex();
	printString("\nTICK ");
	printInt(val);
	printNewLine();
}

void keyboardHandler()
{
	int i = 0;
	int value;
	YKEnterMutex();
	value = KeyBuffer;
	YKExitMutex();

	if(value == 'd')
	{
		printString("\nDELAY KEY PRESSED\n");
		while(i < 5000)
		{
			++i;
		}
		printString("DELAY COMPLETE\n");
	}
	else if(value == 'p')
	{
		YKSemPost(NSemPtr);
	}
	else
	{
		printString("\nKEYPRESS (");
		printChar(value);
		printString(") IGNORED\n");
	}
}
