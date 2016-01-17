#include "clock.h"

#include <xc.h>

// This function is marked as extern "C" in clock.h, so that it can be called
// from our C++ main function.
void clock_init(void)
{
	PLLFBD = 40;
	CLKDIVbits.PLLPOST = 0;
	CLKDIVbits.PLLPRE = 0;

	__builtin_write_OSCCONH(0x01);
	__builtin_write_OSCCONL(0x01);

	while (OSCCONbits.COSC != 0b001);
	while (OSCCONbits.LOCK != 1);
}
