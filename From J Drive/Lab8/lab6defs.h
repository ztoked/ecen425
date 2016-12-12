/*
File: lab6defs.h
Revision date: 4 November
Description: Required definitions for EE 425 lab 6 (Message queues)
*/
#ifndef LAB6DEFS__H_
#define LAB6DEFS__H_

#define PIECEARRAYSIZE  40

struct piece
{
    int id;
    int type;
    int orientation;
    int column;
};

typedef struct piece* piecePtr;

#endif /* LAB6DEFS__H_ */
