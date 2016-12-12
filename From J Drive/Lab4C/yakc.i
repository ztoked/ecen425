# 1 "yakc.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "yakc.c"







# 1 "yakk.h" 1







# 1 "yaku.h" 1
# 9 "yakk.h" 2



extern unsigned int YKCtxSwCount;
extern unsigned int YKIdleCount;
extern unsigned int YKTickNum;

enum taskState
{
 RUNNING,
 DELAYED,
 SUSPENDED,
 READY
};

typedef struct taskblock
{
  unsigned int ip;
    void *stackptr;
    enum taskState state;
    char priority;
    int delay;
  unsigned char inUse;
} TCB;

typedef struct taskblock *TCBptr;

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
# 9 "yakc.c" 2
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
# 10 "yakc.c" 2





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

TCBptr currentTask;
TCBptr nextTask;

TCB YKTCBArray[3 +1];

void YKInitialize()
{
 int i;
 YKEnterMutex();

 for (i = 0; i < 3; ++i)
 {
  YKTCBArray[i].priority = 100;
  YKTCBArray[i].inUse = 0;
 }

 YKNewTask(YKIdleTask, (void *)&IdleStk[256], 99);
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



 int i;
 YKEnterMutex();

 for (i = 0; i <= 3; ++i)
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

 for (i = 0; i <= 3; ++i)
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

  YKTCBArray[runningTask].delay = count;
  YKTCBArray[runningTask].state = DELAYED;
  YKScheduler();

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
 for (i = 1; i <= 3; ++i)
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
