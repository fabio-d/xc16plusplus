#include "other.h"

int main (int argc, char *argv[])
{
	other();
	other('a');
	other((short)0);
	other((unsigned short)0);
	other(0);
	other(0u);
	other(0l);
	other(0ul);
	other(0ll);
	other(0ull);
	other(.0f);
	other(.0);
	return 0;
}
