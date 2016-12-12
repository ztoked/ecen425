//A .h file for kernel code, not modified by user.
//It should include declarations such as the TCB, YKSEM, and YKQ, as well as prototypes for the kernel functions.
//Global variables shared by kernel and application code should be declared as extern in this file.

//it should include extern declarations for things defined in yakc.c, such as YKCtxSwCount and YKIdleCount, as well as the prototypes for the kernel functions. This file should not include any code or definitions that the application programmer might need to modify.
#ifndef YAKK__H_
#define YAKK__H_
#include "yaku.h"

#define NULL 0

extern unsigned int YKCtxSwCount;
extern unsigned int YKIdleCount;
extern unsigned int YKTickNum;

//extern unsigned int YKTickNum;

enum taskState
{
	RUNNING,
	DELAYED,
	SUSPENDED,
	READY
};

typedef struct taskblock
{							/* the TCB struct definition */
		unsigned int ip;
    void *stackptr;			/* pointer to current top of stack */
    enum taskState state;		/* current state */
    char priority;			/* current priority */
    int delay;				/* #ticks yet to wait */
		unsigned char inUse;
		unsigned char hasRun;
}  TCB;

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
/*
YKSEM* YKSemCreate(int initialValue);
void YKSemPend(YKSEM *semaphore);
void YKSemPost(YKSEM *semaphore);
YKQ *YKQCreate(void **start, unsigned size);
void *YKQPend(YKQ *queue);
int YKQPost(YKQ *queue, void *msg);
YKEVENT *YKEventCreate(unsigned initialValue);
unsigned YKEventPend(YKEVENT *event, unsigned eventMask, int waitMode);
void YKEventSet(YKEVENT *event, unsigned eventMask);
void YKEventReset(YKEVENT *event, unsigned eventMask);
*/

#endif /* YAKK__H_ */
