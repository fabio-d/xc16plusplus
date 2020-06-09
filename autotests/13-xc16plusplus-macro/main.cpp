#include <stdio.h>

static int useNumber;

int main (int argc, char *argv[])
{
#ifdef __XC16PLUSPLUS__
	int expectNumber = __XC16PLUSPLUS_REVISION__;
#endif

    useNumber = expectNumber;
	return 0;
}
