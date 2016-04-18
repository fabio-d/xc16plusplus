#include <stdio.h>

#include "testclass.h"

testclass testobj;

void print_var(int testclass::*var)
{
	printf("%d\n", testobj.*var);
}

void run_method(void (testclass::*func)())
{
	(testobj.*func)();
}

int main (int argc, char *argv[])
{
	print_var(&testclass::a);
	print_var(&testclass::b);

	run_method(&testclass::m1);
	run_method(&testclass::m2);

	return 0;
}
