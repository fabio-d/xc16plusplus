#define FCY 8000000

#include <libpic30++.h>
#include <stdio.h>

int main (int argc, char *argv[])
{
	printf("ready...\n");
	__delay_ms(10);
	printf("go!\n");

	return 0;
}
