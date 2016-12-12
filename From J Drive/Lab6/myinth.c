#include "clib.h"
#include "yakk.h"
#include "lab6defs.h"

int ticks = 0;
extern int KeyBuffer;
extern YKQ *MsgQPtr;
extern struct msg MsgArray[];
extern int GlobalFlag;

void tickHandler()
{
	int val;
	static int next = 0;
	static int data = 0;

	YKEnterMutex();
	val = ++ticks;
	YKExitMutex();


  /* create a message with tick (sequence #) and pseudo-random data */
  MsgArray[next].tick = YKTickNum;
  data = (data + 89) % 100;
  MsgArray[next].data = data;
  if (YKQPost(MsgQPtr, (void *) &(MsgArray[next])) == 0)
	{
		printString("  TickISR: queue overflow! \n");
	}
  else if (++next >= MSGARRAYSIZE)
	{
		next = 0;
	}
}

void keyboardHandler()
{
	YKEnterMutex();
	GlobalFlag = 1;
	YKExitMutex();
}
