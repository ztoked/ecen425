#include "clib.h"

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
