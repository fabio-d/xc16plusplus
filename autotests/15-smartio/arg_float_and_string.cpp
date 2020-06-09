#include "variants.h"
#include <stdio.h>

static const char v2[] = "xyz";

void do_arg_float_and_string()
{
	float v = 3.14;
	printf("test %.2f %s\n", v, v2);
}
