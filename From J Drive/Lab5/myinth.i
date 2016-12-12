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
# 3 "myinth.c" 2

int ticks = 0;
extern int KeyBuffer;
extern YKSEM *NSemPtr;

void tickHandler()
{
 int val;
 YKEnterMutex();
 val = ++ticks;
 YKExitMutex();
 printString("\nTICK ");
 printInt(val);
 printNewLine();
}

void keyboardHandler()
{
 int i = 0;
 int value;
 YKEnterMutex();
 value = KeyBuffer;
 YKExitMutex();

 if(value == 'd')
 {
  printString("\nDELAY KEY PRESSED\n");
  while(i < 5000)
  {
   ++i;
  }
  printString("DELAY COMPLETE\n");
 }
 else if(value == 'p')
 {
  YKSemPost(NSemPtr);
 }
 else
 {
  printString("\nKEYPRESS (");
  printChar(value);
  printString(") IGNORED\n");
 }
}
