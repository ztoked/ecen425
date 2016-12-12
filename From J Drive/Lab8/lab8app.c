/*
File: lab7app.c
Revision date: 10 November 2005
Description: Application code for EE 425 lab 7 (Event flags)
*/

#include "clib.h"
#include "yakk.h"                     /* contains kernel definitions */
#include "lab6defs.h"
#include "lab7defs.h"
#include "simptris.h"

#define TASK_STACK_SIZE   512         /* stack size in words */
#define PIECE_Q_SIZE 10

int CPUTaskStk[TASK_STACK_SIZE];     /* a stack for each task */
int SimTaskStk[TASK_STACK_SIZE];

struct piece pieceArray[PIECEARRAYSIZE];  /* buffers for message content */

YKSEM *commandSem;


void *PieceQ[PIECE_Q_SIZE];
YKQ  *PieceQPtr;

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
    YKNewTask(SimTask, (void *) &SimTaskStk[TASK_STACK_SIZE], 0);
    YKNewTask(CPUTask, (void *) &CPUTaskStk[TASK_STACK_SIZE], 1);

    PieceQPtr = YKQCreate(PieceQ, PIECE_Q_SIZE);

    commandSem = YKSemCreate(0);
    YKRun();
}
