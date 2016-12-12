//Kernel routines written in C. Global variables used by kernel code or shared by kernel and application code should also be defined in this file.

// How do we push everything in the dispatcher
// How do we access the values being popped off by iret
// Should saving context happen in the scheduler?
// Should the scheduler be in assembly?

#include "yakk.h"// TODO: save context for YKCurrTask
#include "clib.h"
	// IP, CS, Flags, Regs

#define DEFAULT_STACK_SIZE 12
#define TASK_INDEX 0
#define FLAGS_INDEX 2
#define FLAGS_MASK 0x0200 //TODO: fix

unsigned int YKCtxSwCount;
unsigned int YKIdleCount;
int IdleStk[STACK_SIZE];
int kernelStarted = 0;
unsigned char readyToStart = 0;
unsigned char runningTask = 0;
unsigned char firstTime = 1;
unsigned int nextTask;

TCB    YKTCBArray[MAX_TASKS+1];	/* array to allocate all needed TCBs
				   												(extra one is for the idle task) */
void YKInitialize()
{
	int i;
	// code to construct doubly linked available TCB list from initial
	for (i = 0; i < MAX_TASKS; ++i)
	{
		YKTCBArray[i].priority = 100;
		YKTCBArray[i].inUse = 0;
	}

	YKNewTask(YKIdleTask, (void *)&IdleStk[STACK_SIZE], 99);
	readyToStart = 0;
}

void YKIdleTask()
{
	while(1)
	{
		YKEnterMutex();
		++YKIdleCount;
		YKExitMutex();
	}
}

void YKNewTask(void (* task)(void), void *taskStack, unsigned char priority)
{
	/* code to insert an entry in doubly linked ready list sorted by
       priority numbers (lowest number first).  tmp points to TCB
       to be inserted */
	int i;

	for (i = 0; i < MAX_TASKS; ++i)
	{
		if (!YKTCBArray[i].inUse)
					break;
	}

	YKTCBArray[i].ip = (unsigned int) task;
	YKTCBArray[i].stackptr = taskStack;
	YKTCBArray[i].state = RUNNING;
	YKTCBArray[i].delay = 0;
	YKTCBArray[i].inUse = 1;
	YKTCBArray[i].priority = priority;
	readyToStart = 1;

	if(kernelStarted)
	{
		YKScheduler();
	}
}

void YKRun(void)
{
	if (kernelStarted || !readyToStart)
		return;

	YKEnterMutex();
	kernelStarted = 1;
	YKExitMutex();

	YKScheduler();
}

void YKScheduler()
{
	int i;
	unsigned char maxPriority = YKTCBArray[runningTask].priority;
	unsigned char toRun = runningTask;

	YKEnterMutex();

	for (i = 0; i <= MAX_TASKS; ++i)
	{
		if (!YKTCBArray[i].inUse)
			break;
		if (YKTCBArray[i].priority < YKTCBArray[runningTask].priority)
		{
			maxPriority = YKTCBArray[i].priority;
			toRun = i;
			nextTask = YKTCBArray[i].ip;
		}
	}

	if (runningTask == toRun && !firstTime)
		return;

	if (kernelStarted)
	{
		firstTime = 0;
		++YKCtxSwCount;
		runningTask = toRun;
		YKDispatcher();
	}
}

/*
void YKDelayTask(unsigned count)
{
}

void YKEnterISR()
{
}

void YKExitISR()
{
}

void YKTickHandler()
{
}

YKSEM* YKSemCreate(int initialValue)
{
	return 0;
}

void YKSemPend(YKSEM *semaphore)
{
}

void YKSemPost(YKSEM *semaphore)
{
}

YKQ *YKQCreate(void **start, unsigned size)
{
	return 0;
}

void *YKQPend(YKQ *queue)
{
}

int YKQPost(YKQ *queue, void *msg)
{
}

YKEVENT *YKEventCreate(unsigned initialValue)
{
	return 0;
}


unsigned YKEventPend(YKEVENT *event, unsigned eventMask, int waitMode)
{
	return 0;
}

void YKEventSet(YKEVENT *event, unsigned eventMask)
{
}

void YKEventReset(YKEVENT *event, unsigned eventMask)
{
}
*/
