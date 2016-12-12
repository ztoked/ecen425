# 1 "myinth.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "myinth.c"
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
# 2 "myinth.c" 2
# 1 "yakk.h" 1


# 1 "yaku.h" 1
# 4 "yakk.h" 2
# 1 "lab6defs.h" 1
# 11 "lab6defs.h"
struct msg
{
    int tick;
    int data;
};

typedef struct msg* msgPtr;
# 5 "yakk.h" 2



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

typedef struct sem
{
 int value;
} YKSEM;

typedef struct taskblock
{
  unsigned int ip;
    void *stackptr;
    enum taskState state;
    char priority;
    int delay;
  YKSEM *semaphore;
  unsigned char inUse;
} TCB;

typedef struct taskblock *TCBptr;

typedef struct queue
{
  void ** start;
  unsigned size;
  unsigned headIndex;
  unsigned tailIndex;
  YKSEM * semaphore;
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
# 3 "myinth.c" 2


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



  MsgArray[next].tick = YKTickNum;
  data = (data + 89) % 100;
  MsgArray[next].data = data;
  if (YKQPost(MsgQPtr, (void *) &(MsgArray[next])) == 0)
 {
  printString("  TickISR: queue overflow! \n");
 }
  else if (++next >= 20)
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
