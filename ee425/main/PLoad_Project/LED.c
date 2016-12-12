///////////////////////////////////////////////////////////////////////////////
// Name: LED.c
// Author: Wade S. Fife
// Last Modified: July 10, 2003
// Description: Functions to initialize, set, toggle, and flash the LED on a
//   TERN A-core-86 board (AMD Am186ES microcontroller).
//
// Notes: If you use the LED, use only these functions so that LEDstate is
//   properly updated.
//
///////////////////////////////////////////////////////////////////////////////

#include "PIO.h"
#include "LED.h"


volatile int	LEDstate;

// Sets the pin connected to the LED (p12) to be an output, allowing use of LED.
// The call to ae_init() also does this, in addition to other things.
void EnableLED(void)
{
	// Set up LED port as output
	asm {
		mov	dx, PIOMODE0
		in		ax, dx
		or		ax, 0x1000	// Set bit 12
		out	dx, ax

		mov	dx, PDIR0	// PDIR0
		in		ax, dx
		and	ax, 0xEFFF	// Reset bit 12
		out	dx, ax
	}
}


// Turn to state b (i.e., 0 for on or 1 for off)
void SetLED(int b)
{
	LEDstate = b;
	asm {
		mov	ax, b			// Fetch b
		and	ax, 1			// Only want LSB
		mov	cl, 12
		shl	ax, cl		// Make bit 12

		mov	dx, PDATA0
		out	dx, ax
	}
}


// If LED is on, turn it off. If it is off, turn it on.
void ToggleLED(void)
{
	SetLED(LEDstate ? 0 : 1);
}


// Flash the LED numFlashes times
void FlashLED(int numFlashes)
{
	unsigned count, flashCount;
	int dummy = 0;

	//EnableLED();

	numFlashes <<= 1;

	for(flashCount = 0; flashCount < numFlashes; flashCount++) {
		ToggleLED();
		for(count = 0; count < 0xFFFFu; count++) dummy = dummy;
	}
}


// Flashes numFlashes times, pauses, flashes numFlashes times, etc.
// This function never returns!
void FlashError(int numFlashes)
{
	int dork;
	long count;
	int flashCount;

	dork = 0;

	SetLED(0);

	while(1) {
		for(flashCount = 0; flashCount < numFlashes; flashCount++) {
			for(count = 0; count < 0xFFFFl; count++) dork = dork;
			FlashLED(1);
		}
		for(count = 0; count < 500000l; count++) dork = dork;
	}
}
