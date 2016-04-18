#include <stdio.h>

#include "baseclass.h"

baseclass::baseclass()
{
	printf("baseclass created\n");
}

baseclass::~baseclass()
{
	printf("baseclass destroyed\n");
}

void baseclass::nonvirtualmethod()
{
	printf("baseclass::nonvirtualmethod is running\n");
}

void baseclass::virtualmethod1()
{
	printf("baseclass::virtualmethod1 is running\n");
}
