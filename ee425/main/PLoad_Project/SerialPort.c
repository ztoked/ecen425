///////////////////////////////////////////////////////////////////////////////
// Name: Serial.c
// Author: Wade S. Fife
// Date: June 5, 2003
// Description: Routines to initialize and use serial port 1.
//
// Notes: These routines set up serial port 1 to be interrupt driven. Two FIFOs
// are used; one for receiving data and one for sending data. The functions
// read from or write to the FIFOs and the ISR does the rest. Care must be
// taken to not send more data than the output buffer can contain and to not
// send data faster than the baud rate will allow. Doing so simply causes the
// FIFO to wrap around, overwriting data that may not have been sent.
//
///////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdarg.h>
#include "PIO.h"
#include "SerialPort.h"
#include "LED.h"


// GLOBAL /////////////////////////////////////////////////////////////////////

SerialPort ser1;
void interrupt far (*oldISR)(void);



// INTERRUPT SERVICE ROUTINE //////////////////////////////////////////////////

// Interrupt Service Routine to handle serial port
void interrupt SerialPortISR(void)
{
	SerialPortHandler();

	// Send EOI command
	OUTW(EOI, NS_EOI_CMD);
}


// This function actually does the work for the ISR.
// Returns 1 if a new byte was received, 0 otherwise.
// NOTE: You may overide the default ISR, but be sure to call this handler in
// the replacement ISR and don't forget to signal the EOI to the interrupt
// controller.
int SerialPortHandler(void)
{
	WORD status;

	asm		pushf
	asm		cli		// Make sure interrupts are disabled

	INW(status, SP1STS);

	// Handle transfer of next byte
	if((status & SPSTS_THRE) && (ser1.outBytes)) {
		if(ser1.outBytes > ser1.outSize) {
			SendStringPoll("\r\nERROR: Microcontroller serial port output buffer overflow.\r\n");
			while(1) FlashLED(1);
		}

		// Send next byte
		asm {
			// value = *ser1.outTail++;
			mov		bx, word ptr ser1.outTail
			mov		al, [bx]
			mov		ah, 0
			inc		word ptr ser1.outTail

			// OUTW(SP1TD, value)
			mov		dx, SP1TD
			out		dx, ax
		}

		// Adjust tail pointer
		if(ser1.outTail >= ser1.outMax) ser1.outTail = ser1.outBuffer;

		// Turn off transfer interrupt if buffer empty
		if(--ser1.outBytes == 0) {
			// Stop interrupts
			asm {
				mov		dx, SP1CT
				in		ax, dx
				and		ax, NOT SPCTL_TXIE
				out		dx, ax
			}
		}
	}

	// Handle incoming data
	if(status & SPSTS_RDR) {
		asm {
			// INW(value, SP1RD)
			mov		dx, SP1RD
			in		ax, dx

			// *ser1.inHead++ = value
			mov		bx, word ptr ser1.inHead
			mov		[bx], al
			inc		word ptr ser1.inHead
		}

		ser1.inBytes++;
		if(ser1.inHead >= ser1.inMax) ser1.inHead = ser1.inBuffer;

		if(ser1.inBytes > ser1.inSize) {
			SendStringPoll("\r\nERROR: Microcontroller serial port input buffer overflow.\r\n");
			while(1) FlashLED(1);
		}		

		asm		popf
		return  1;
	}

	asm		popf
	return 0;
}



// FUNCTIONS //////////////////////////////////////////////////////////////////

// Initalizes serial port 1 as well as associated data structures.
// This function must be called BEFORE using any other function in this file.
void InitSerialPort(WORD baud_divisor, BYTE *in_buffer, WORD in_buffer_size, BYTE *out_buffer, WORD out_buffer_size)
{
	asm	pushf
	asm cli

	ser1.inBuffer = in_buffer;
	ser1.inHead = in_buffer;
	ser1.inTail = in_buffer;
	ser1.inMax = in_buffer + in_buffer_size;
	ser1.inSize = in_buffer_size;
	ser1.inBytes = 0;

	ser1.outBuffer = out_buffer;
	ser1.outHead = out_buffer;
	ser1.outTail = out_buffer;
	ser1.outMax = out_buffer + out_buffer_size;
	ser1.outSize = out_buffer_size;
	ser1.outBytes = 0;

	oldISR = GetVect(0x11);

	SetVect(0x11, SerialPortISR);

	asm {
		// Setup serial port 1 pins (TXD1 and RXD1 to normal operation mode)
		mov		dx, PIOMODE1
		in		ax, dx
		and		ax, 0xE700
		out		dx, ax
		mov		dx, PDIR1
		in		ax, dx
		and		ax, 0xE700
		out		dx, ax

		// Set serial port control register
		mov		dx, SP1CT
		mov		ax, 0x00E1		//  0000 000? 1110 0001 	The ? is the TXIE (bit 8)
		out		dx, ax

		mov		dx, SP1BAUD
		mov		ax, baud_divisor
		out		dx, ax

		// Setup serial port 1 interrupt capability and mode (enable interrupt, set low priority)
		mov		dx, SP1CON
		in		ax, dx
		or		ax, 0x0017
		out		dx, ax

		// Unmask serial port 1 interrupt
		mov		dx, IMASK
		in		ax, dx
		and		ax, 0xFDFF
		//or		ax, 0x0200
		out		dx, ax
	}

	asm popf
}


// Disables the serial port and associated interrupts.
// WARNING: It is wise to call WaitSendComplete() before this function.
void CloseSerialPort(void)
{
	asm		pushf
	asm		cli

	// Restore old interrupt
	SetVect(0x11, oldISR);

	asm {
		// Mask interrupt in IMR
		mov		dx, IMASK
		in		ax, dx
		or		ax, 0x0200
		out		dx, ax

		// Reset serial port 1 control register
		mov		dx, SP1CT
		mov		ax, 0x0001
		out		dx, ax

		// Reset serial port 1 status register
		mov		dx, SP1STS
		xor		ax, ax
		out		dx, ax

		// Clear pending read-only bits in status register
		mov		dx, SP1STS
		in		ax, dx

		// Empty receive registers
		mov		dx, SP1RD
		in		ax, dx
		in		ax, dx
	}

	asm		popf
}


// Resets the serial port to its initial state working state. Any incoming or
// buffered data is lost. This may be necessary if the serial port cable is
// disconnected then reconnected to ensure proper transfer of data.
void ResetSerialPort(void)
{
	WORD baudDivisor, inBufferSize, outBufferSize;
	BYTE *inBuffer, *outBuffer;

	INW(baudDivisor, SP1BAUD);
	inBuffer = ser1.inBuffer;
	inBufferSize = ser1.inMax - ser1.inBuffer;
	outBuffer = ser1.outBuffer;
	outBufferSize = ser1.outMax - outBuffer;

	CloseSerialPort();
	InitSerialPort(baudDivisor, inBuffer, inBufferSize, outBuffer, outBufferSize);
}


// Returns number of bytes waiting to be read from input FIFO.
WORD DataReady(void)
{
	asm mov		ax, word ptr ser1.inBytes
	return _AX;
}


// Gets next byte from input FIFO. If no data in FIFO, waits until next
// byte received.
BYTE RecvByte(void)
{
	BYTE value;

	// Wait until data is ready
	asm {
	RecvByteLoop:
		cmp		word ptr ser1.inBytes, 0
		je		RecvByteLoop
	}

	// Get a byte
	ser1.inBytes--;
	value = *ser1.inTail++;
	if(ser1.inTail >= ser1.inMax) ser1.inTail = ser1.inBuffer;

	return value;
}


// Uses RecvData() to get a word from input FIFO.
WORD RecvWord(void)
{
	WORD data;
	RecvData(&data, sizeof(data));
	return data;
}


// Uses RecvData() to get a dword from input FIFO.
DWORD RecvDword(void)
{
	DWORD data;
	RecvData(&data, sizeof(data));
	return data;
}


// Gets numBytes bytes from input FIFO. If numBytes bytes are not available,
// the function blocks until the data is received.
void RecvData(void *buffer, WORD numBytes)
{
	// Get the data
	while(numBytes--) {
		// Wait until data is ready
		asm {
		RecvByteLoop:
			cmp		word ptr ser1.inBytes, 0
			je		RecvByteLoop
		}

		ser1.inBytes--;
		*((BYTE *)buffer)++ = *ser1.inTail++;
		if(ser1.inTail >= ser1.inMax) ser1.inTail = ser1.inBuffer;
	}
}


// Same as RecvData but using far pointers.
void RecvFarData(void far *buffer, WORD numBytes)
{
	// Get the data
	while(numBytes--) {
		// Wait until data is ready
		asm {
		RecvByteLoop:
			cmp		word ptr ser1.inBytes, 0
			je		RecvByteLoop
		}

		ser1.inBytes--;
		*((BYTE far *)buffer)++ = *ser1.inTail++;
		if(ser1.inTail >= ser1.inMax) ser1.inTail = ser1.inBuffer;
	}
}


// Queues the byte in output FIFO to be sent as soon as device is ready.
// The transfer interrupt driven.
void SendByte(BYTE data)
{
	/*
	// ************** DEBUG VERSION
	SendBytePoll(data);
	return;
	// **************
	*/

	*ser1.outHead++ = data;
	ser1.outBytes++;
	if(ser1.outHead >= ser1.outMax) ser1.outHead = ser1.outBuffer;

	// Enable the transfer interrupt
	asm {
		mov		dx, SP1CT
		in		ax, dx
		or		ax, SPCTL_TXIE
		out		dx, ax
	}
}


// Uses SendData() to send a word.
void SendWord(WORD data)
{
	SendData(&data, sizeof(data));
}


// Uses SendData() to send dword.
void SendDword(DWORD data)
{
	SendData(&data, sizeof(data));
}


// Queues data into the FIFO to be sent as soon as device is ready.
// The transfer interrupt driven.
void SendData(void *data, WORD numBytes)
{
	register WORD count;

	/*
	// ************** DEBUG VERSION
	SendDataPoll(data, numBytes);
	return;
	// **************
	*/

	count = numBytes;

	while(count--) {
		*ser1.outHead++ = *((BYTE *)data)++;
		if(ser1.outHead >= ser1.outMax) ser1.outHead = ser1.outBuffer;
	}

	ser1.outBytes += numBytes;

	// Enable the transfer interrupt
	asm {
		mov		dx, SP1CT
		in		ax, dx
		or		ax, SPCTL_TXIE
		out		dx, ax
	}
}


// Same as SendData() except that data is a far pointer.
void SendDataFar(void far *data, WORD numBytes)
{
	register WORD count;

	/*
	// ************** DEBUG VERSION
	while(numBytes--) SendBytePoll(*((BYTE far*)data)++);
	return;
	// **************
	*/

	count = numBytes;

	while(count--) {
		*ser1.outHead++ = *((BYTE far *)data)++;
		if(ser1.outHead >= ser1.outMax) ser1.outHead = ser1.outBuffer;
	}

	ser1.outBytes += numBytes;

	// Enable the transfer interrupt
	asm {
		mov		dx, SP1CT
		in		ax, dx
		or		ax, SPCTL_TXIE
		out		dx, ax
	}
}


// Sends a byte immediately using polling instead of interrupts.
// It will not return until the byte has been placed in transfer register.
// NOTE: Be careful using this function. No pending data should be in the output
//       FIFO when it is called. In other words, if this function is used in
//       conjunction with the interrupt driven send functions then WaitSend()
//       should be called before calling this function.
void SendBytePoll(BYTE data)
{
	asm	{
		// Wait until device is ready
		mov		dx, SP1STS
	SendBytePoll:
		in		ax, dx
		and		ax, SPSTS_THRE
		jz		SendBytePoll

		// Store byte
		mov		dx, SP1TD
		xor		ax, ax
		mov		al, data
		out		dx, ax
	}
}

// Sends numBytes bytes of data using polling instead of interrupts.
// It will not return until all data has been placed in transfer register.
// NOTE: Be careful using this function. No pending data should be in the output
//       FIFO when it is called. In other words, if this function is used in
//       conjunction with the interrupt driven send functions then WaitSend()
//       should be called before calling this function.
void SendDataPoll(void *data, WORD numBytes)
{
	asm {
		// Set up for loop
		mov		cx, numBytes
		mov		bx, data
	SendDataLoop:

		// Wait until device is ready
		mov		dx, SP1STS
	SendDataWaitLoop:
		in		ax, dx
		and		ax, SPSTS_THRE
		jz		SendDataWaitLoop

		// Store next byte
		mov		dx, SP1TD
		mov		al, [bx]
		mov		ah, 0
		out		dx, ax

		inc		bx
		loop	SendDataLoop
	}
}

// Sends null terminated string bytes of data using polling instead of interrupts.
// It will not return until all data has been placed in transfer register.
// NOTE: Be careful using this function. No pending data should be in the output
//       FIFO when it is called. In other words, if this function is used in
//       conjunction with the interrupt driven send functions then WaitSend()
//       should be called before calling this function.
void SendStringPoll(const char *string)
{
	asm {
		// Set up for loop
		mov		bx, string
	SendStringLoop:

		// Get next byte
		mov		cl, [bx]
		cmp		cl, 0
		je		ExitSendStringLoop

		// Wait until device is ready
		mov		dx, SP1STS
	SendStringWaitLoop:
		in		ax, dx
		and		ax, SPSTS_THRE
		jz		SendStringWaitLoop

		// Send next byte
		mov		dx, SP1TD
		mov		al, cl
		mov		ah, 0
		out		dx, ax

		inc		bx
		jmp		SendStringLoop

	ExitSendStringLoop:
	}
}


// Like SendData() but for a null terminated string.
void sends(const char *string)
{
	while(*string) {
		*ser1.outHead++ = *string++;
		ser1.outBytes++;
		if(ser1.outHead >= ser1.outMax) ser1.outHead = ser1.outBuffer;
	}

	// Enable the transfer interrupt
	asm {
		mov		dx, SP1CT
		in		ax, dx
		or		ax, SPCTL_TXIE
		out		dx, ax
	}
}

// Like printf, but sends the string over serial port (not including NULL)
// using SendData().
// Returns number of bytes sent.
// WARNING: The string must not exceed MAX_SENDF_STRING_SIZE.
int sendf(const char *format, ...)
{
	static char buffer[MAX_SENDF_STRING_SIZE];
	va_list argptr;
	int length;

	va_start(argptr, format);
	length = vsprintf(buffer, format, argptr);
	va_end(argptr);

	SendData(buffer, length);

	return length;
}

// Like sends, but for a DOS-style '$' terminated string.
void SendDosStringFar(const char far *string)
{
	/*
	// ************** DEBUG VERSION
	while(*string != '$') {
		SendBytePoll(*string++);
	}
	return;
	// **************
	*/

	while(*string != '$') {
		*ser1.outHead++ = *string++;
		ser1.outBytes++;
		if(ser1.outHead >= ser1.outMax) ser1.outHead = ser1.outBuffer;
	}

	// Enable the transfer interrupt
	asm {
		mov		dx, SP1CT
		in		ax, dx
		or		ax, SPCTL_TXIE
		out		dx, ax
	}
}

// Converts the word num to 4-digit an ASCII string.
void GenHexWord(WORD num, char *string)
{
	BYTE nibble;
	int i;

	for(i = 0; i < 4; i++) {
		nibble = (num & 0xF000) >> 12;
		num <<= 4;

		if(nibble <= 9) nibble += '0';
		else nibble += ('A'-10);

		string[i] = nibble;
	}
}

// Converts the byte num to a 2-digit ASCII string.
void GenHexByte(BYTE num, char *string)
{
	BYTE nibble;

	nibble = (num & 0xF0) >> 4;
	if(nibble <= 9) nibble += '0';
	else nibble += ('A'-10);
	string[0] = nibble;

	nibble = num & 0x0F;
	if(nibble <= 9) nibble += '0';
	else nibble += ('A'-10);
	string[1] = nibble;
}

// Sends num as a 4-digit ASCII string using SendDataPoll().
void SendHexWordPoll(WORD num)
{
	char string[4];

	GenHexWord(num, string);
	SendDataPoll(string, 4);
}

// Sends num as a 2-digit ASCII string using SendDataPoll().
void SendHexBytePoll(BYTE num)
{
	char string[2];

	GenHexByte(num, string);
	SendDataPoll(string, 2);
}

// Sends num as a 4-digit ASCII string using SendData().
void SendHexWord(WORD num)
{
	char string[4];

	GenHexWord(num, string);
	SendData(string, 4);
}


// Sends num as a 2-digit ASCII string using SendData().
void SendHexByte(BYTE num)
{
	char string[2];

	GenHexByte(num, string);
	SendData(string, 2);
}


// Blocks until all last byte in outgoing FIFO has been placed in transfer
// register.
void WaitSend(void)
{
	// Block until no more data in FIFO
	asm	{
	WaitSendLoop:
		mov		ax, word ptr ser1.outTail
		mov		bx, word ptr ser1.outHead
		cmp		ax, bx
		jne		WaitSendLoop
	}
}


// Blocks until all data in outgoing FIFO has been completely sent.
// Call this to ensure transfer before, for example, disabling the TX pin.
void WaitSendComplete(void)
{
	// Block until no more data in FIFO
	asm	{
	WaitSendCompleteA:
		mov		ax, word ptr ser1.outTail
		mov		bx, word ptr ser1.outHead
		cmp		ax, bx
		jne		WaitSendCompleteA
	}

	// Block until transmitter empty
	asm	{
		mov		dx, SP1STS
	WaitSendCompleteB:
		in		ax, dx
		test	ax, 0x0004
		jz		WaitSendCompleteB
	}
}




/*

///////////////////////////////////////////////////////////////////////////////
// Demo Code: /////////////////////////////////////////////////////////////////
// Use Hyperterminal connected to SER1 with the following settings:
// 115,200 baud, 8 data bits, no parity, 1 stop bit, no flow-control.
// Press 'S' to begin demo.

#define IN_BUFFER_SIZE		100
#define OUT_BUFFER_SIZE		2048

BYTE inBuffer[IN_BUFFER_SIZE];
BYTE outBuffer[OUT_BUFFER_SIZE];

void MyCallback(void)
{
	static int state = 0;

	// Toggle LED

	state = state ? 0 : 1;

	asm {
		mov	ax, state
		and	ax, 1
		mov	cl, 12
		shl	ax, cl

		mov	dx, PDATA0
		out	dx, ax
	}

}


void main(void)
{
	BYTE b;
	WORD w;
	DWORD d;
	BYTE buffer[10];
	int i;

	SerialPortISR();

	// Initialize serial port for baud rate of 115,200.
	InitSerialPort(BAUD_RATE(115200ul), inBuffer, IN_BUFFER_SIZE, outBuffer, OUT_BUFFER_SIZE);

	// Set up call back to toggle LED when byte received
	SetCallback(MyCallback);

	// Wait until byte received
	b = 0;
	while(b != 's' && b != 'S') b = RecvByte();
	sends("\r\nDemo started!\r\nNote that we've used the callback feature to cause the LED to toggle when a byte is received.\r\n");


	//// Demo DataReady() ////

	sends("\r\nDataReady() Demo\r\n\r\nDataReady() is waiting until 5 bytes received...");

	// Waiting until 5 bytes received
	while(DataReady() < 5);

	// Display received data
	sends("\r\nReceived 5 bytes: ");
	for(i = 0; i < 5; i++) sendf("0x%02X ", (WORD)RecvByte());
	sends("\r\n");


	//// Demo Receive Functions ////

	sends("\r\nReceive Function Demo\r\n\r\n");

	sends("Send a byte for RecvByte()...");
	b = RecvByte();
	sendf("RecvByte() returned: 0x%02X\r\n", (WORD)b);

	sends("Send a word for RecvWord()...");
	w = RecvWord();
	sendf("RecvWord() returned: 0x%04X\r\n", w);

	sends("Send a dword for RecvDword()...");
	d = RecvDword();
	sendf("RecvDword() returned: 0x%08lX\r\n", d);

	sends("Send 5 bytes for RecvData()...");
	RecvData(buffer, 5);
	sends("RecvData() received: ");
	for(i = 0; i < 5; i++) sendf("0x%02X ", (WORD)buffer[i]);
	sends("\r\nRecvFarData() is identical to RecvData() except it allows a far pointer.\r\n");


	//// Demo Send Functions ////

	sends("\r\nSend Function Demo\r\nSend a byte to continue...");
	RecvByte();
	sends("\r\n\r\n");

	sends("Here's 0x41 ('A') with SendByte(): ");
	SendByte(0x41);
	sends("\r\n");

	sends("Here's 0x4241 ('BA') with SendWord(): ");
	SendWord(0x4241);
	sends("\r\n");

	sends("Here's 0x44434241 ('DCBA') with SendDword(): ");
	SendDword(0x44434241ul);
	sends("\r\n");

	sends("Using WaitSend() to ensure previous bytes sent...\r\nHere's 0x41 ('A') with SendBytePoll(): ");
	WaitSend();
	SendBytePoll(0x41);
	sends("\r\n");

	sends("Using WaitSend() to ensure previous bytes sent...\r\nHere's 0x44434241 ('DCBA') with SendDataPoll(): ");
	WaitSend();
	d = 0x44434241ul;
	SendDataPoll(&d, 4);
	sends("\r\n");

	sends("Here is another sample of sends() sending a plain string.\r\n");
	sendf("Here is %s.\r\n", "another sample of sendf() sending a formatted string");

	
	//// Demo ResetSerialPort() ////

	sends("\r\nResetSerialPort() Demo\r\nSend a byte to continue...");
	RecvByte();
	sends("\r\n\r\n");

	sends("Resetting the serial port; Calling WaitSendComplete() to ensure all data completely sent...\r\n");
	WaitSendComplete();
	ResetSerialPort();
	sends("The serial port has been reset!\n\r\n");


	//// Demo CloseSerialPort() ////

	sends("\r\CloseSerialPort() Demo\r\nSend a byte to continue...");
	RecvByte();
	sends("\r\n\r\n");

	sends("Closing serial port (No more data should be received after the period).");
	WaitSendComplete();
	CloseSerialPort();
	
	SendDataPoll("If you see this, CloseSerialPort() didn't work!\r\n", 34);

	while(1);
}

*/
