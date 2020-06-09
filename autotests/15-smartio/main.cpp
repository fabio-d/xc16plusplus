#include "variants.h"

int main (int argc, char *argv[])
{
	do_disabled_smartio();

	do_arg_none();
	do_arg_char();
	do_arg_string();
	do_arg_int();
	do_arg_float();
	do_arg_float_and_string();

#if __XC16_VERSION__ >= 1030
	do_arg_longlong();
#endif

	return 0;
}
