#include <stdio.h>

#include "derivclass.h"

static derivclass instance;

baseclass *derivclass::get_instance()
{
	return &instance;
}

derivclass::derivclass()
{
	printf("derivclass created\n");
}

derivclass::~derivclass()
{
	printf("derivclass destroyed\n");
}

void derivclass::virtualmethod1()
{
	printf("derivclass::virtualmethod1 is running\n");
	baseclass::virtualmethod1();
}

void derivclass::virtualmethod2()
{
	printf("derivclass::virtualmethod2 is running\n");
}
