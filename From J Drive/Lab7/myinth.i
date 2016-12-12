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
# 3 "myinth.c" 2
# 1 "lab7defs.h" 1
# 15 "lab7defs.h"
extern YKEVENT *charEvent;
extern YKEVENT *numEvent;
# 4 "myinth.c" 2

extern int KeyBuffer;
extern YKEVENT *charEvent;
extern YKEVENT *numEvent;


void tickHandler()
{

}

void keyboardHandler()
{
    char c;
    c = KeyBuffer;

    if(c == 'a') YKEventSet(charEvent, 0x1);
    else if(c == 'b') YKEventSet(charEvent, 0x2);
    else if(c == 'c') YKEventSet(charEvent, 0x4);
    else if(c == 'd') YKEventSet(charEvent, 0x1 | 0x2 | 0x4);
    else if(c == '1') YKEventSet(numEvent, 0x1);
    else if(c == '2') YKEventSet(numEvent, 0x2);
    else if(c == '3') YKEventSet(numEvent, 0x4);
    else {
        print("\nKEYPRESS (", 11);
        printChar(c);
        print(") IGNORED\n", 10);
    }
}
