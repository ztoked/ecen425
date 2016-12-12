# 1 "3A.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "3A.c"
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
# 2 "3A.c" 2

int AsmFunction(int a, char b, char c, int d, int e);

int gvar = 0;

void main(void)
{
    switch (gvar) {
  case 0:
   gvar += 5;
   gvar *= 5;
   break;
  case 1:
   gvar *= 5;
   gvar -= 5;
   break;
  case 2:
   gvar *= 5;
   gvar /= 2;
   break;
  case 3:
   gvar -= 1;
   gvar /= 2;
   break;
  case 4:
   gvar *= 7;
   gvar -= 9;
   break;
  case 5:
   gvar -= 2;
   gvar /= 3;
   break;
  case 6:
   gvar += 3;
   gvar /= 9;
   break;
  case 7:
   gvar *= gvar;
   gvar /= 7;
   break;
  default:
   gvar = 0;
   break;
 }
}
