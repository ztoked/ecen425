# 1 "lab8app.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "lab8app.c"






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
# 8 "lab8app.c" 2
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
# 9 "lab8app.c" 2

# 1 "lab7defs.h" 1
# 15 "lab7defs.h"
extern YKEVENT *charEvent;
extern YKEVENT *numEvent;
# 11 "lab8app.c" 2
# 1 "simptris.h" 1


void SlidePiece(int ID, int direction);
void RotatePiece(int ID, int direction);
void SeedSimptris(long seed);
void StartSimptris(void);
# 12 "lab8app.c" 2




int CPUTaskStk[512];
int SimTaskStk[512];

struct piece pieceArray[40];

YKSEM *commandSem;


void *PieceQ[10];
YKQ *PieceQPtr;

void SimTask()
{
  struct piece *curPiece;
  static unsigned char cornerType = 0;
  SeedSimptris((long)87245);
  StartSimptris();
  printString("Simptris Started\n");

  while(1)
  {
    curPiece = (struct piece *) YKQPend(PieceQPtr);
    if(curPiece->type == 1) {
      while(curPiece->column != 4)
      {
        if(curPiece->column < 4) {
          SlidePiece(curPiece->id, 1);
          curPiece->column = curPiece->column + 1;
          YKSemPend(commandSem);
        }
        else {
          SlidePiece(curPiece->id, 0);
          curPiece->column = curPiece->column - 1;
          YKSemPend(commandSem);
        }
      }
      if(curPiece->orientation == 1) {
        RotatePiece(curPiece->id, 1);
        YKSemPend(commandSem);
      }
    }
    else {
      if(curPiece->column == 0) {
        SlidePiece(curPiece->id, 1);
        curPiece->column = curPiece->column + 1;
        YKSemPend(commandSem);
      }
      else if(curPiece->column == 5) {
        SlidePiece(curPiece->id, 0);
        curPiece->column = curPiece->column - 1;
        YKSemPend(commandSem);
      }
      if(cornerType == 0) {
        switch (curPiece->orientation){
          case 0:
            break;
          case 1:
            RotatePiece(curPiece->id, 1);
            YKSemPend(commandSem);
            break;
          case 2:
            RotatePiece(curPiece->id, 1);
            YKSemPend(commandSem);
            RotatePiece(curPiece->id, 1);
            YKSemPend(commandSem);
            break;
          case 3:
            RotatePiece(curPiece->id, 0);
            YKSemPend(commandSem);
            break;
        }
        while(curPiece->column > 0)
        {
          SlidePiece(curPiece->id, 0);
          curPiece->column = curPiece->column - 1;
          YKSemPend(commandSem);
        }
        cornerType = 1;
      }
      else {
        switch (curPiece->orientation){
          case 0:
            RotatePiece(curPiece->id, 1);
            YKSemPend(commandSem);
            RotatePiece(curPiece->id, 1);
            YKSemPend(commandSem);
            break;
          case 1:
            RotatePiece(curPiece->id, 0);
            YKSemPend(commandSem);
            break;
          case 2:
            break;
          case 3:
            RotatePiece(curPiece->id, 1);
            YKSemPend(commandSem);
            break;
        }
        while(curPiece->column != 2)
        {
          if(curPiece->column < 2) {
            SlidePiece(curPiece->id, 1);
            curPiece->column = curPiece->column + 1;
            YKSemPend(commandSem);
          }
          else {
            SlidePiece(curPiece->id, 0);
            curPiece->column = curPiece->column - 1;
            YKSemPend(commandSem);
          }
        }
        cornerType = 0;
      }
    }
  }
}

void CPUTask()
{
  unsigned max, switchCount, idleCount;
  int tmp;

  YKDelayTask(1);
  YKDelayTask(1);
  YKIdleCount = 0;
  YKDelayTask(5);
  max = YKIdleCount / 25;
  YKIdleCount = 0;

  while (1)
  {
      YKDelayTask(20);

      YKEnterMutex();
      switchCount = YKCtxSwCount;
      idleCount = YKIdleCount;
      YKExitMutex();


      printString("<CS: ");
      printInt((int)switchCount);
      printString(", CPU: ");
      tmp = (int) (idleCount/max);
      printInt(100-tmp);
      printString(">\r\n");

      YKEnterMutex();
      YKCtxSwCount = 0;
      YKIdleCount = 0;
      YKExitMutex();
  }
}

void main(void)
{
    YKInitialize();
    YKNewTask(SimTask, (void *) &SimTaskStk[512], 0);
    YKNewTask(CPUTask, (void *) &CPUTaskStk[512], 1);

    PieceQPtr = YKQCreate(PieceQ, 10);

    commandSem = YKSemCreate(0);
    YKRun();
}
