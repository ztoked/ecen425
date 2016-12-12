# 1 "yakc.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "yakc.c"
# 1 "yakk.h" 1


# 1 "yaku.h" 1
# 4 "yakk.h" 2
# 1 "lab6defs.h" 1
# 11 "lab6defs.h"
struct piece
{
    int id;
    int type;
    int orientation;
    int column;
};

typedef struct piece* piecePtr;
# 5 "yakk.h" 2





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
{
  unsigned int ip;
    void *stackptr;
    enum taskState state;
    char priority;
    int delay;
  YKSEM *semaphore;
  unsigned char inUse;
  unsigned flagMask;
  unsigned eventType;
  YKEVENT *event;
} TCB;

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
# 2 "yakc.c" 2
# 1 "clib.h" 1



void print(char *string, int length);
void printNewLine(void);
void printChar(char c);
void printString(char *string);


void printInt(int val);
void printLong(long val);
void printUInt(unsigned val);
void printULong(unsigned long val);


void printByte(char val);
void printWord(int val);
void printDWord(long val);


void exit(unsigned char code);


void signalEOI(void);
# 3 "yakc.c" 2





const int FLAGS_MASK = 0x0200;

unsigned int YKCtxSwCount;
unsigned int YKIdleCount;
unsigned int YKTickNum;
unsigned int YKInterruptDepth = 0;
int IdleStk[256];
int kernelStarted = 0;
unsigned char readyToStart = 0;
unsigned char runningTask = 0;
unsigned char firstTime = 1;
unsigned int pushedLevel = 0;
unsigned char contextSaved = 0;

TCBptr currentTask;
TCBptr nextTask;

TCB YKTCBArray[5 +1];


YKSEM YKSemArray[(5 + 5 + 5)];
unsigned int semIndex = 0;

YKQ YKQArray[5];
unsigned int qIndex = 0;

YKEVENT YKEventArray[5];
unsigned int eventIndex = 0;


void YKInitialize()
{
 int i;
 YKEnterMutex();

 for (i = 0; i < 5; ++i)
 {
  YKTCBArray[i].priority = 100;
  YKTCBArray[i].inUse = 0;
 }

 YKNewTask(YKIdleTask, (void *)&IdleStk[256], 99);
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

 for (i = 0; i <= 5; ++i)
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

}

void YKRun(void)
{
 if (kernelStarted || !readyToStart)
  return;


 kernelStarted = 1;

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

 for (i = 0; i <= 5; ++i)
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

  YKTCBArray[runningTask].delay = count;
  YKTCBArray[runningTask].state = DELAYED;
  contextSaved = 0;
  YKScheduler();

 YKExitMutex();
}

void YKEnterISR()
{
 ++YKInterruptDepth;



}

void YKExitISR()
{
 --YKInterruptDepth;



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
 for (i = 1; i <= 5; ++i) {
  if(YKTCBArray[i].state == DELAYED) {
   if(YKTCBArray[i].delay == 1) {
    YKTCBArray[i].state = READY;
   }
   --YKTCBArray[i].delay;
  }
 }
}





YKSEM* YKSemCreate(int initialValue)
{
 if(semIndex < (5 + 5 + 5))
 {
  YKSemArray[semIndex].value = initialValue;
  semIndex = semIndex + 1;
  return &YKSemArray[semIndex-1];
 }
 return 0;
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
 for(i = 1; i <= 5; i++)
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
 YKTCBArray[toRun].semaphore = 0;
 if(YKInterruptDepth <= 0)
 {
  contextSaved = 0;
  YKScheduler();
 }
 YKExitMutex();
}






YKQ *YKQCreate(void **start, unsigned size)
{
 if(qIndex < 5)
 {
  YKQArray[qIndex].start = start;
  YKQArray[qIndex].headIndex = 0;
  YKQArray[qIndex].tailIndex = 0;
  YKQArray[qIndex].size = size;
  YKQArray[qIndex].semaphore = YKSemCreate(0);
  qIndex = qIndex + 1;
  return &YKQArray[qIndex-1];
 }
 return 0;
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


void *YKQPend(YKQ *queue)
{
 void *returnVal = 0;
 YKEnterMutex();
 if(YKQEmpty(queue)) {

  if(queue->numTasks < 5) {
   queue->numTasks = queue->numTasks + 1;
  }
  YKSemPend(queue->semaphore);
 }

 returnVal = queue->start[queue->headIndex];
 queue->headIndex = (queue->headIndex + 1) % queue->size;





 YKExitMutex();
 return returnVal;
}


int YKQPost(YKQ *queue, void *msg)
{
 static unsigned char notFirst = 0;
 unsigned char wasEmpty = 0;
 YKEnterMutex();
 if(YKQFull(queue)) {
  YKExitMutex();
  return 0;
 }
 if(YKQEmpty(queue) && (queue->numTasks > 0)) {
  wasEmpty = 1;
 }


 queue->start[queue->tailIndex] = msg;





 queue->tailIndex = (queue->tailIndex + 1) % queue->size;

 if(wasEmpty) {
  if(queue->numTasks > 0) {
   queue->numTasks = queue->numTasks - 1;
  }
  YKSemPost(queue->semaphore);
 }

 YKExitMutex();
 return 1;
}







YKEVENT *YKEventCreate(unsigned initialValue)
{
 if(eventIndex < 5)
 {
  YKEventArray[eventIndex].flags = initialValue;
  eventIndex = eventIndex + 1;
  return &YKEventArray[eventIndex-1];
 }
 return 0;
}

unsigned char flagReady(YKEVENT *event, unsigned eventMask, int waitMode)
{
 if( (int)event && ((event->flags & eventMask) == eventMask) ||
   ((event->flags & eventMask) && (waitMode == 0)))
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
 for(i = 1; i <= 5; i++)
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
