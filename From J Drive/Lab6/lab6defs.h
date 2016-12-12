/*
File: lab6defs.h
Revision date: 4 November
Description: Required definitions for EE 425 lab 6 (Message queues)
*/
#ifndef LAB6DEFS__H_
#define LAB6DEFS__H_

#define MSGARRAYSIZE      20

struct msg
{
    int tick;
    int data;
};

typedef struct msg* msgPtr;

#endif /* LAB6DEFS__H_ */
