#ifndef YAKK__H_
#define YAKK__H_
#include "yaku.h"
#include "lab6defs.h"

#define NULL 0
#define EVENT_WAIT_ALL 1
#define EVENT_WAIT_ANY 0

extern unsigned int YKCtxSwCount;
extern unsigned int YKIdleCount;
extern unsigned int YKTickNum;

enum taskState
{
	RUNNING,
	DELAYED,
	SUSPENDED,
	READY,
	EVENT_SUSPEND
};

typedef struct sem
{
	int value;
} YKSEM;

typedef struct event
{
	unsigned flags;
} YKEVENT;

typedef struct taskblock
{							/* the TCB struct definition */
		unsigned int ip;
    void *stackptr;			/* pointer to current top of stack */
    enum taskState state;		/* current state */
    char priority;			/* current priority */
    int delay;				/* #ticks yet to wait */
		YKSEM *semaphore;
		unsigned char inUse;
		unsigned flagMask;
		unsigned eventType;
		YKEVENT *event;
}  TCB;

typedef struct taskblock *TCBptr;

typedef struct queue
{
  void ** start;
  unsigned size;
  unsigned headIndex;
  unsigned tailIndex;
  YKSEM * semaphore;
	unsigned numTasks;
} YKQ;

void YKInitialize();
void YKEnterMutex();
void YKExitMutex();
void YKIdleTask();
void YKNewTask(void (* task)(void), void *taskStack, unsigned char priority);
void YKRun(void);
void YKScheduler();
void YKDispatcher();
void YKDispatcherHelper();
void YKDispatcherFirst();
void *YKCreateContext(void *stckptr, unsigned int ip);
void YKDelayTask(unsigned count);
void YKEnterISR();
void YKExitISR();
void YKTickHandler();
YKSEM* YKSemCreate(int initialValue);
void YKSemPend(YKSEM *semaphore);
void YKSemPost(YKSEM *semaphore);
void pushed();
void popped();
void YKDispatcherNoSave();
YKQ *YKQCreate(void **start, unsigned size);
void *YKQPend(YKQ *queue);
int YKQPost(YKQ *queue, void *msg);
YKEVENT *YKEventCreate(unsigned initialValue);
unsigned YKEventPend(YKEVENT *event, unsigned eventMask, int waitMode);
void YKEventSet(YKEVENT *event, unsigned eventMask);
void YKEventReset(YKEVENT *event, unsigned eventMask);

#endif /* YAKK__H_ */
