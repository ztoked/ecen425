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

void YKInitialize();
void YKEnterMutex();
void YKExitMutex();
void YKIdleTask();
void YKNewTask(void (* task)(void), void *taskStack, unsigned char priority);
void YKRun(void);
void YKScheduler();
void YKDispatcher();
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







unsigned int YKCtxSwCount;
unsigned int YKIdleCount;
int IdleStk[256];
int kernelStarted = 0;
unsigned char readyToStart = 0;
unsigned char runningTask = 0;
unsigned char firstTime = 1;
unsigned int nextTask;

TCB YKTCBArray[3 +1];

void YKInitialize()
{
 int i;

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

 for (i = 0; i < 3; ++i)
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

 for (i = 0; i <= 3; ++i)
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
