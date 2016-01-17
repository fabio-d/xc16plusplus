#include "timer1.h"

#include <xc.h>

namespace timer {

static callback *timer1_handler;

/* This is how to define interrupt handlers. It is the same as C, but with an
 * extra extern "C" prefix */
extern "C" void __attribute__((__interrupt__, __auto_psv__, __shadow__)) _T1Interrupt(void)
{
	IFS0bits.T1IF = 0;
	timer1_handler->fired();
}

void timer1_start(callback *handler)
{
	timer1_handler = handler;

	TMR1 = 0;
	T1CONbits.TON = 1;
	IFS0bits.T1IF = 0;
	IEC0bits.T1IE = 1;
}

void timer1_stop()
{
	IEC0bits.T1IE = 0;
	T1CONbits.TON = 0;
}

callback::~callback()
{
}

}
