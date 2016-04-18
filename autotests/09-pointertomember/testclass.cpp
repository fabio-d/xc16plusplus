#include <stdio.h>

#include "testclass.h"

testclass::testclass()
{
	a = 1;
	b = 2;
}

void testclass::m1()
{
	printf("m1 called\n");
}

void testclass::m2()
{
	printf("m2 called\n");
}
