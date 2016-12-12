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

int ticks = 0;
extern int KeyBuffer;

void tickHandler()
{
 ++ticks;
 printString("\nTICK ");
 printInt(ticks);
 printNewLine();
}

void keyboardHandler()
{
 if(KeyBuffer == 'd')
 {
  int i = 0;
  printString("\nDELAY KEY PRESSED\n");
  while(i < 5000)
  {
   ++i;
  }
  printString("DELAY COMPLETE\n");
 }
 else
 {
  printString("\nKEYPRESS (");
  printChar(KeyBuffer);
  printString(") IGNORED\n");
 }
}
