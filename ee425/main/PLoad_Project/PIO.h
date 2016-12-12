///////////////////////////////////////////////////////////////////////////////
// Name: PIO.h
// Author: Wade S. Fife
// Last Modified: July 10, 2003
// Description: This file contains numerous defenitions related to I/O (i.e.,
//   port numbers and commonly used values) on the AMD Am186ES micrcontroller.
//
///////////////////////////////////////////////////////////////////////////////

#ifndef PIO_H
#define PIO_H

// PIO OFFSET VALUES //

#define PCB_START	0xFF00				// Start of Peripheral Control Block (default)

#define SP1CT		(PCB_START + 0x10)	// Serial port 1 control register
#define SP1STS		(PCB_START + 0x12)	// Serial port 1 status register
#define SP1TD		(PCB_START + 0x14)	// Serial port 1 transfer register
#define SP1RD		(PCB_START + 0x16)	// Serial port 1 receive register
#define SP1BAUD 	(PCB_START + 0x18)	// Serial port 1 baud rate divisor

#define EOI			(PCB_START + 0x22)	// Port wich receives EOI commands

#define IMASK		(PCB_START + 0x28)	// Interrupt mask register

#define TCUCON		(PCB_START + 0x32)	// Timer interrupt control register
#define SP1CON		(PCB_START + 0x42)	// Serial port 1 interrupt control register
#define SP0CON		(PCB_START + 0x44)	// Serial port 0 interrupt control register

#define T0CNT		(PCB_START + 0x50)	// Timer 0 count register
#define T0CMPA		(PCB_START + 0x52)	// Timer 0 maxcount compare A register
#define T0CMPB		(PCB_START + 0x54)	// Timer 0 maxcount compare B register
#define T0CON		(PCB_START + 0x56)	// Timer 0 mode/control register
#define T1CNT		(PCB_START + 0x58)	// Timer 1 count register
#define T1CMPA		(PCB_START + 0x5A)	// Timer 1 maxcount compare A register
#define T1CMPB		(PCB_START + 0x5C)	// Timer 1 maxcount compare B register
#define T1CON		(PCB_START + 0x5E)	// Timer 1 mode/control register
#define T2CNT		(PCB_START + 0x60)	// Timer 2 count register
#define T2CMPA		(PCB_START + 0x62)	// Timer 2 maxcount compare A register
#define T2CON		(PCB_START + 0x66)	// Timer 2 mode/control register

#define PIOMODE0	(PCB_START + 0x70)	// PIO Mode Register 0
#define PIOMODE1	(PCB_START + 0x76)	// PIO Mode Register 1
#define PDIR0		(PCB_START + 0x72)	// PIO Direction Register 0
#define PDIR1		(PCB_START + 0x78)	// PIO Direction Register 1
#define PDATA0		(PCB_START + 0x74)	// PIO Data Register 0
#define PDATA1		(PCB_START + 0x7A)	// PIO Data Register 1

#define SP0CT		(PCB_START + 0x80)	// Serial port 0 control register
#define SP0STS		(PCB_START + 0x82)	// Serial port 0 status register
#define SP0TD		(PCB_START + 0x84)	// Serial port 0 transfer register
#define SP0RD		(PCB_START + 0x86)	// Serial port 0 receive register
#define SP0BAUD 	(PCB_START + 0x88)	// Serial port 0 baud rate divisor

#define D1DSTL		(PCB_START + 0XD4)	// DMA 1 destination address low
#define D1DSTH		(PCB_START + 0xD6)	// DMA 1 destination address high


// PORT SPECIFIC VALUES //

// Serial Port Control Register Masks //
#define SPCTL_MODE	0x0007
#define SPCTL_PE	0x0008
#define SPCTL_EVN	0x0010
#define SPCTL_RMODE	0x0020
#define SPCTL_TMODE	0x0040
#define SPCTL_RXIE	0x0080
#define SPCTL_TXIE	0x0100
#define SPCTL_FC	0x0200
#define SPCTL_TB8	0x0400
#define SPCTL_BRK	0x0800
#define SPCTL_RSIE	0x1000
#define SPCTL_DMA	0xE000

// Serial Port Status Register Masks //
#define SPSTS_HS0	0x002
#define SPSTS_TEMT	0x004
#define SPSTS_PER	0x008
#define SPSTS_OER	0x010
#define SPSTS_FER	0x020
#define SPSTS_THRE	0x040
#define SPSTS_RDR	0x080
#define SPSTS_RB8	0x100
#define SPSTS_BRK0	0x200
#define SPSTS_BRK1	0x400

// End of Interrupt Command //
#define NS_EOI_CMD	(0x8000)			// Non-specific EOI

#endif	// #ifndef PIO_H
