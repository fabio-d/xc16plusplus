#include "variants.h"

int main (int argc, char *argv[])
{
	do_arg_none();
	do_arg_char();
	do_arg_string();
	do_arg_int();
	do_arg_float();
	do_arg_float_and_string();

#if WITH_LONGLONG
	do_arg_longlong();
#endif

	return 0;
}
