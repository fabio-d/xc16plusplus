#include "variants.h"
#include <stdio.h>

#if __XC16_VERSION__ < 1030 // long long can only be printed starting from v1.30
#error This file will not work with XC16 older than v1.30
#endif

void do_arg_longlong()
{
	long long v = 1234567890987654321LL;
	printf("test %lld %lld\n", v, v);
}
