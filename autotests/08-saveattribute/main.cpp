#include <stdio.h>
#include <xc.h>

volatile bool interrupted = false;
volatile int preserved_variable = 1234;
volatile char nonpreserved_variable = 'A';

extern "C" void __attribute__((__interrupt__, __auto_psv__, __shadow__, __save__((preserved_variable)))) _T1Interrupt(void)
{
	IFS0bits.T1IF = 0;
	preserved_variable = 5678;
	nonpreserved_variable = 'B';
	interrupted = true;
}

int main (int argc, char *argv[])
{
	TMR1 = 0;
	T1CONbits.TON = 1;
	IFS0bits.T1IF = 0;
	IEC0bits.T1IE = 1;

	while (!interrupted);

	printf("%d %c\n", preserved_variable, nonpreserved_variable);

	return 0;
}
