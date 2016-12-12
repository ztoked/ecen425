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
# 3 "myinth.c" 2


extern int KeyBuffer;
extern int NewPieceID;
extern int NewPieceType;
extern int NewPieceOrientation;
extern int NewPieceColumn;
extern YKQ *PieceQPtr;
extern struct piece pieceArray[];
extern YKSEM *commandSem;
# 27 "myinth.c"
void newPieceHandler()
{
 static int next = 0;

  pieceArray[next].id = NewPieceID;
  pieceArray[next].type = NewPieceType;
  pieceArray[next].orientation = NewPieceOrientation;
  pieceArray[next].column = NewPieceColumn;

  if (YKQPost(PieceQPtr, (void *) &(pieceArray[next])) == 0)
 {
  printString("TickISR: queue overflow!\n");
 }
  else if (++next >= 40)
 {
  next = 0;
 }
}
# 62 "myinth.c"
void receivedCommandHandler()
{
  YKSemPost(commandSem);
}
# 81 "myinth.c"
void touchdownHandler()
{
}






void lineClearHandler()
{
}





void gameoverHandler()
{
  printString("GAMEOVER\n");
  exit(0);
}

void tickHandler()
{

}

void keyboardHandler()
{
}
