//A .h file for kernel code, to be modified by the user.
//It should include things such as the #define statements for idle task's stack size,
//the maximum numbers of tasks, semaphores, and message queues, etc.

//This will include the #define statements for the maximum number of tasks, the maximum number of semaphores, and the maximum number of message queues

#define STACK_SIZE 256
#define MAX_TASKS 5
#define MAX_QUEUES 5
#define MAX_EVENTS 5
#define MAX_SEM (5 + MAX_QUEUES + MAX_EVENTS)
