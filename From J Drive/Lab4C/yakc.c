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
const int FLAGS_MASK = 0x0200;

unsigned int YKCtxSwCount;
unsigned int YKIdleCount;
unsigned int YKTickNum;
unsigned int YKInterruptDepth = 0;
int IdleStk[STACK_SIZE];
int kernelStarted = 0;
unsigned char readyToStart = 0;
unsigned char runningTask = 0;
unsigned char firstTime = 1;

TCBptr currentTask;
TCBptr nextTask;

TCB    YKTCBArray[MAX_TASKS+1];	/* array to allocate all needed TCBs
				   												(extra one is for the idle task) */
void YKInitialize()
{
	int i;
	YKEnterMutex();
	// code to construct doubly linked available TCB list from initial
	for (i = 0; i < MAX_TASKS; ++i)
	{
		YKTCBArray[i].priority = 100;
		YKTCBArray[i].inUse = 0;
	}

	YKNewTask(YKIdleTask, (void *)&IdleStk[STACK_SIZE], 99);
	readyToStart = 0;
	// YKExitMutex();
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
	YKEnterMutex();

	for (i = 0; i <= MAX_TASKS; ++i)
	{
		if (!YKTCBArray[i].inUse)
					break;
	}

	YKTCBArray[i].ip = (unsigned int) task;
	YKTCBArray[i].stackptr = taskStack;
	YKTCBArray[i].state = READY;
	YKTCBArray[i].delay = 0;
	YKTCBArray[i].inUse = 1;
	YKTCBArray[i].priority = priority;
	YKCreateContext(YKTCBArray[i].stackptr, YKTCBArray[i].ip);
	YKTCBArray[i].stackptr += 24;
	readyToStart = 1;

	if(kernelStarted)
	{
		currentTask = &YKTCBArray[i];
		YKScheduler();
	}
	YKExitMutex();
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
	unsigned char maxPriority = 100;
	unsigned char toRun = 0;

	YKEnterMutex();

	for (i = 0; i <= MAX_TASKS; ++i)
	{
		if (!YKTCBArray[i].inUse)
			break;
		if (YKTCBArray[i].priority < maxPriority && YKTCBArray[i].state == READY)
		{
				maxPriority = YKTCBArray[i].priority;
				toRun = i;
		}
	}
	nextTask = &YKTCBArray[toRun];

	if (!kernelStarted)
		return;

	if (runningTask == toRun && !firstTime)
	{
		YKExitMutex();
		return;
	}
	if(firstTime) {
		firstTime = 0;
		currentTask = &YKTCBArray[toRun];
		runningTask = toRun;
		YKDispatcherFirst();
	}
	++YKCtxSwCount;
	currentTask = &YKTCBArray[runningTask];
	runningTask = toRun;
	YKDispatcher();
}


void YKDelayTask(unsigned count)
{
	YKEnterMutex();
	// if(count > 0) {
		YKTCBArray[runningTask].delay = count;
		YKTCBArray[runningTask].state = DELAYED;
		YKScheduler();
	// }
	YKExitMutex();
}

void YKEnterISR()
{
	YKEnterMutex();
	++YKInterruptDepth;
	YKExitMutex();
}

void YKExitISR()
{
	YKEnterMutex();
	--YKInterruptDepth;
	if(YKInterruptDepth == 0 && kernelStarted && readyToStart) {
		YKScheduler();
	}
	YKExitMutex();
}

void YKTickHandler()
{
	int i;
	YKEnterMutex();
	++YKTickNum;
	for (i = 1; i <= MAX_TASKS; ++i)
	{
		if(YKTCBArray[i].state == DELAYED) {
			if(YKTCBArray[i].delay == 1) {
				YKTCBArray[i].state = READY;
			}
			--YKTCBArray[i].delay;
		}
	}
	YKExitMutex();
}

/*
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
