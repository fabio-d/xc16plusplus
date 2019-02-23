#include <stdio.h>

int main (int argc, char *argv[])
{
#ifdef __XC16PLUSPLUS__
	printf("OK\n");
#endif

	int expectNumber = __XC16PLUSPLUS_REVISION__;

	return 0;
}
