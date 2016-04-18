#include <stdio.h>
#include <xc.h>

volatile int ticks = 0;

extern "C" void __attribute__((__interrupt__, __auto_psv__, __shadow__)) _T1Interrupt(void)
{
	IFS0bits.T1IF = 0;
	ticks++;
}

int main (int argc, char *argv[])
{
	TMR1 = 0;
	T1CONbits.TON = 1;
	IFS0bits.T1IF = 0;
	IEC0bits.T1IE = 1;

	int prev_ticks = -1;
	while (prev_ticks != 5)
	{
		if (prev_ticks == ticks)
			continue;

		prev_ticks = ticks;
		printf("%d\n", ticks);
	}

	printf("done\n");

	return 0;
}
