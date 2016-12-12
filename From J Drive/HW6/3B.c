#include "clib.h"

int AsmFunction(int a, char b, char c, int d, int e);

int gvar = 0;

void main(void)
{
    switch (gvar) {
		case 35: 
			gvar += 5;
			gvar *= 5;
			break;
		case 226: 
			gvar *= 5;
			gvar -= 5;
			break;
		case 401: 
			gvar *= 5;
			gvar /= 2; 
			break;
		case 427: 
			gvar -= 1;
			gvar /= 2; 
			break;
		case 425: 
			gvar *= 7;
			gvar -= 9; 
			break;
		case 5: 
			gvar -= 2;
			gvar /= 3; 
			break;
		case 999: 
			gvar += 3;
			gvar /= 9; 
			break;
		case 101: 
			gvar *= gvar;
			gvar /= 7; 
			break;
		default: 
			gvar = 0; 
			break;
	}
}
