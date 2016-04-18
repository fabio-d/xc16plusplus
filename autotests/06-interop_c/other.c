#include <stdio.h>

#include "other.h"

void c_function(int a, bool b, int c)
{
	if (a == 1 && b == true && c == 3)
		printf("This is C (good args)!\n");
	else
		printf("This is C (bad args)!\n");
}
