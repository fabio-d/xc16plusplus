#include <stdio.h>

void other(void)
{
	printf("other(void)\n");
}

void other(char)
{
	printf("other(char)\n");
}

void other(short)
{
	printf("other(int)\n");
}

void other(unsigned short)
{
	printf("other(unsigned short)\n");
}

void other(int)
{
	printf("other(int)\n");
}

void other(unsigned int)
{
	printf("other(unsigned int)\n");
}

void other(long)
{
	printf("other(long)\n");
}

void other(unsigned long)
{
	printf("other(unsigned long)\n");
}

void other(long long)
{
	printf("other(long long)\n");
}

void other(unsigned long long)
{
	printf("other(unsigned long long)\n");
}

void other(float)
{
	printf("other(float)\n");
}

void other(double)
{
	printf("other(double)\n");
}
