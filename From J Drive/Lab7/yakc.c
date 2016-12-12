#include "yakk.h"
#include "clib.h"
#include "lab6defs.h"

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
unsigned int pushedLevel = 0;
unsigned char contextSaved = 0;

TCBptr currentTask;
TCBptr nextTask;

TCB    YKTCBArray[MAX_TASKS+1];	/* array to allocate all needed TCBs
				   												(extra one is for the idle task) */

YKSEM YKSemArray[MAX_SEM];
unsigned int semIndex = 0;

YKQ YKQArray[MAX_QUEUES];
unsigned int qIndex = 0;

YKEVENT YKEventArray[MAX_EVENTS];
unsigned int eventIndex = 0;


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
}
void pushed()
{
	pushedLevel = pushedLevel + 1;
	printString("Pushed: ");
	printInt(pushedLevel);
	printNewLine();
}

void popped()
{
	pushedLevel = pushedLevel - 1;
	printString("Popped: ");
	printInt(pushedLevel);
	printNewLine();
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
		contextSaved = 0;
		YKScheduler();
	}
	// YKExitMutex();
}

void YKRun(void)
{
	if (kernelStarted || !readyToStart)
		return;

	// YKEnterMutex();
	kernelStarted = 1;
	// YKExitMutex();
	contextSaved = 0;
	YKScheduler();
	YKExitMutex();
}

void YKScheduler()
{
	int i;
	unsigned char maxPriority = 100;
	unsigned char toRun = 0;

	if (!kernelStarted) return;

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

	if (runningTask == toRun && !firstTime)
	{
		// YKExitMutex();
		return;
	}
	if(firstTime) {
		firstTime = 0;
		currentTask = &YKTCBArray[toRun];
		runningTask = toRun;
		YKDispatcherFirst();
	}
	else
	{
		++YKCtxSwCount;
		currentTask = &YKTCBArray[runningTask];
		runningTask = toRun;
		if(contextSaved)
		{
			contextSaved = 0;
			YKDispatcherNoSave();
		}
		else
		{
			YKDispatcher();
		}
	}
}


void YKDelayTask(unsigned count)
{
	YKEnterMutex();
	// if(count > 0) {
		YKTCBArray[runningTask].delay = count;
		YKTCBArray[runningTask].state = DELAYED;
		contextSaved = 0;
		YKScheduler();
	// }
	YKExitMutex();
}

void YKEnterISR()
{
	++YKInterruptDepth;
	// printString("Entering ISR. Depth: ");
	// printInt(YKInterruptDepth);
	// printNewLine();
}

void YKExitISR()
{
	--YKInterruptDepth;
	// printString("Exiting ISR. Depth: ");
	// printInt(YKInterruptDepth);
	// printNewLine();
	if(YKInterruptDepth == 0 && kernelStarted && readyToStart)
	{
		contextSaved = 1;
		YKScheduler();
	}
}

void YKTickHandler()
{
	int i;
	YKEnterMutex();
	++YKTickNum;
	for (i = 1; i <= MAX_TASKS; ++i) {
		if(YKTCBArray[i].state == DELAYED) {
			if(YKTCBArray[i].delay == 1) {
				YKTCBArray[i].state = READY;
			}
			--YKTCBArray[i].delay;
		}
	}
}

/******************************************************/
/********************* SEMAPHORES *********************/
/******************************************************/
/******************************************************/
YKSEM* YKSemCreate(int initialValue)
{
	if(semIndex < MAX_SEM)
	{
		YKSemArray[semIndex].value = initialValue;
		semIndex = semIndex + 1;
		return &YKSemArray[semIndex-1];
	}
	return NULL;
}

void YKSemPend(YKSEM *semaphore)
{
	YKEnterMutex();
	if(semaphore->value <= 0)
	{
		YKTCBArray[runningTask].state = SUSPENDED;
		YKTCBArray[runningTask].semaphore = semaphore;
		semaphore->value = semaphore->value - 1;
		contextSaved = 0;
		YKScheduler();
	}
	else
	{
		semaphore->value = semaphore->value - 1;
	}
	YKExitMutex();
}

void YKSemPost(YKSEM *semaphore)
{
	int i;
	unsigned char maxPriority = 100;
	unsigned char toRun = 0;
	YKEnterMutex();
	for(i = 1; i <= MAX_TASKS; i++)
	{
		if(!YKTCBArray[i].inUse)
		{
			break;
		}
		if(YKTCBArray[i].semaphore == semaphore && YKTCBArray[i].priority < maxPriority)
		{
			toRun = i;
			maxPriority = YKTCBArray[i].priority;
		}
	}
	semaphore->value = semaphore->value + 1;
	if(toRun <= 0)
	{
		YKExitMutex();
		return;
	}
	YKTCBArray[toRun].state = READY;
	YKTCBArray[toRun].semaphore = NULL;
	if(YKInterruptDepth <= 0)
	{
		contextSaved = 0;
		YKScheduler();
	}
	YKExitMutex();
}

/**************************************************/
/********************* QUEUES *********************/
/**************************************************/
/**************************************************/

YKQ *YKQCreate(void **start, unsigned size)
{
	if(qIndex < MAX_QUEUES)
	{
		YKQArray[qIndex].start = start;
		YKQArray[qIndex].headIndex = 0;
		YKQArray[qIndex].tailIndex = 0;
		YKQArray[qIndex].size = size;
		YKQArray[qIndex].semaphore = YKSemCreate(0);
		qIndex = qIndex + 1;
		return &YKQArray[qIndex-1];
	}
	return NULL;
}

int YKQFull(YKQ *queue)
{
	if((queue->headIndex == queue->tailIndex + 1) || ((queue->headIndex == 0) && (queue->tailIndex == queue->size - 1)))
	{
		return 1;
	}
	return 0;
}

int YKQEmpty(YKQ *queue)
{
	unsigned char wasFull;
	if(queue->tailIndex == queue->headIndex)
	{
		return 1;
	}
	return 0;
}

/* POP */
void *YKQPend(YKQ *queue)
{
	void *returnVal = 0;
	YKEnterMutex();
	if(YKQEmpty(queue)) {
		// printString("Queue is empty\n");
		YKSemPend(queue->semaphore);
	}

	returnVal = queue->start[queue->headIndex];
	queue->headIndex = (queue->headIndex + 1) % queue->size;
	// printString("Contents of Pop. tick: ");
	// printInt(((msgPtr)returnVal)->tick);
	// printString(" data: ");
	// printInt(((msgPtr)returnVal)->data);
	// printNewLine();
	YKExitMutex();
	return returnVal;
}

/* PUSH */
int YKQPost(YKQ *queue, void *msg)
{
	static unsigned char notFirst = 0;
	unsigned char wasEmpty = 0;
	YKEnterMutex();
	if(YKQFull(queue)) {
		YKExitMutex();
		return 0;
	}
	if(YKQEmpty(queue) && notFirst) {
		wasEmpty = 1;
	}
	notFirst = 1;
	queue->start[queue->tailIndex] = msg;
	// printString("Contents of Push. tick: ");
	// printInt(((msgPtr)queue->start[queue->tailIndex])->tick);
	// printString(" data: ");
	// printInt(((msgPtr)queue->start[queue->tailIndex])->data);
	// printNewLine();
	queue->tailIndex = (queue->tailIndex + 1) % queue->size;

	if(wasEmpty) {
		YKSemPost(queue->semaphore);
	}

	YKExitMutex();
	return 1;
}



/******************************************************/
/*********************** EVENTS ***********************/
/******************************************************/
/******************************************************/
YKEVENT *YKEventCreate(unsigned initialValue)
{
	if(eventIndex < MAX_EVENTS)
	{
		YKEventArray[eventIndex].flags = initialValue;
		eventIndex = eventIndex + 1;
		return &YKEventArray[eventIndex-1];
	}
	return NULL;
}

unsigned char flagReady(YKEVENT *event, unsigned eventMask, int waitMode)
{
	if(	(int)event && ((event->flags & eventMask) == eventMask) ||
			((event->flags & eventMask) && (waitMode == EVENT_WAIT_ANY)))
	{
		printString("flag ready\n");
		return 1;
	}
	return 0;
}

unsigned YKEventPend(YKEVENT *event, unsigned eventMask, int waitMode)
{
	YKEnterMutex();
	if(flagReady(event, eventMask, waitMode)) {
		return event->flags;
	}
	YKTCBArray[runningTask].state = EVENT_SUSPEND;
	YKTCBArray[runningTask].event = event;
	YKTCBArray[runningTask].flagMask = eventMask;
	YKTCBArray[runningTask].eventType = waitMode;
	contextSaved = 0;
	YKScheduler();
	return event->flags;
}

void YKEventSet(YKEVENT *event, unsigned eventMask)
{
	int i;
	YKEnterMutex();
	event->flags = event->flags | eventMask;
	for(i = 1; i <= MAX_TASKS; i++)
	{
		if(!YKTCBArray[i].inUse)
		{
			break;
		}
		if(flagReady(YKTCBArray[i].event, YKTCBArray[i].flagMask, YKTCBArray[i].eventType))
		{
			if((YKTCBArray[i].event == event))
			{
				YKTCBArray[i].event = 0;
				YKTCBArray[i].flagMask = 0;
				YKTCBArray[i].state = READY;
			}
		}
	}
	contextSaved = 0;
	YKScheduler();
}

void YKEventReset(YKEVENT *event, unsigned eventMask)
{
	event->flags = event->flags & ~eventMask;
}
