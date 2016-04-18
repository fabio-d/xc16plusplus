#include <stdio.h>

#include "baseclass.h"
#include "derivclass.h"

int main (int argc, char *argv[])
{
	baseclass *inst = derivclass::create_instance();
	inst->nonvirtualmethod();
	inst->virtualmethod1();
	inst->virtualmethod2();
	delete inst;

	return 0;
}
