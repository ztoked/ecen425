///////////////////////////////////////////////////////////////////////////////
// Name: LED.h
// Author: Wade S. Fife
// Last Modified: July 10, 2003
// Description: Header file for LED.c
//
///////////////////////////////////////////////////////////////////////////////

#ifndef LED_H
#define LED_H

void EnableLED(void);
void SetLED(int b);
void ToggleLED(void);
void FlashLED(int numFlashes);
void FlashError(int numFlashes);

extern volatile int LEDstate;

#define LED_ON	0
#define	LED_OFF 1

#endif	// #ifndef LED_H
