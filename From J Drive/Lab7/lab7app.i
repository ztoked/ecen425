# 1 "lab7app.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "lab7app.c"






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
# 8 "lab7app.c" 2
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
# 9 "lab7app.c" 2
# 1 "lab7defs.h" 1
# 15 "lab7defs.h"
extern YKEVENT *charEvent;
extern YKEVENT *numEvent;
# 10 "lab7app.c" 2





YKEVENT *charEvent;
YKEVENT *numEvent;

int CharTaskStk[512];
int AllCharsTaskStk[512];
int AllNumsTaskStk[512];
int STaskStk[512];



void CharTask(void)
{
    unsigned events;

    printString("Started CharTask     (2)\n");

    while(1) {
        events = YKEventPend(charEvent,
                             0x1 | 0x2 | 0x4,
                             0);

        if(events == 0) {
            printString("Oops! At least one event should be set "
                        "in return value!\n");
        }

        if(events & 0x1) {
            printString("CharTask     (A)\n");
            YKEventReset(charEvent, 0x1);
        }

        if(events & 0x2) {
            printString("CharTask     (B)\n");
            YKEventReset(charEvent, 0x2);
        }

        if(events & 0x4) {
            printString("CharTask     (C)\n");
            YKEventReset(charEvent, 0x4);
        }
    }
}


void AllCharsTask(void)
{
    unsigned events;

    printString("Started AllCharsTask (3)\n");

    while(1) {
        events = YKEventPend(charEvent,
                             0x1 | 0x2 | 0x4,
                             1);


        if(events != 0) {
            printString("Oops! Char events weren't reset by CharTask!\n");
        }

        printString("AllCharsTask (D)\n");
    }
}


void AllNumsTask(void)
{
    unsigned events;

    printString("Started AllNumsTask  (1)\n");

    while(1) {
        events = YKEventPend(numEvent,
                             0x1 | 0x2 | 0x4,
                             1);

        if(events != (0x1 | 0x2 | 0x4)) {
            printString("Oops! All events should be set in return value!\n");
        }

        printString("AllNumsTask  (123)\n");

        YKEventReset(numEvent, 0x1 | 0x2 | 0x4);
    }
}


void STask(void)
{
    unsigned max, switchCount, idleCount;
    int tmp;

    YKDelayTask(1);
    printString("Welcome to the YAK kernel\r\n");
    printString("Determining CPU capacity\r\n");
    YKDelayTask(1);
    YKIdleCount = 0;
    YKDelayTask(5);
    max = YKIdleCount / 25;
    YKIdleCount = 0;

    YKNewTask(CharTask, (void *) &CharTaskStk[512], 2);
    YKNewTask(AllNumsTask, (void *) &AllNumsTaskStk[512], 1);
    YKNewTask(AllCharsTask, (void *) &AllCharsTaskStk[512], 3);

    while (1)
    {
        YKDelayTask(20);

        YKEnterMutex();
        switchCount = YKCtxSwCount;
        idleCount = YKIdleCount;
        YKExitMutex();

        printString("<<<<< Context switches: ");
        printInt((int)switchCount);
        printString(", CPU usage: ");
        tmp = (int) (idleCount/max);
        printInt(100-tmp);
        printString("% >>>>>\r\n");

        YKEnterMutex();
        YKCtxSwCount = 0;
        YKIdleCount = 0;
        YKExitMutex();
    }
}


void main(void)
{
    YKInitialize();

    charEvent = YKEventCreate(0);
 printString("charEvent: ");
 printWord(charEvent);
 printNewLine();
    numEvent = YKEventCreate(0);
 printString("numEvent: ");
 printWord(numEvent);
 printNewLine();
    YKNewTask(STask, (void *) &STaskStk[512], 0);

    YKRun();
}
