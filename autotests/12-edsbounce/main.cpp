#include <stdio.h>

#include "other.h"

int main (int argc, char *argv[])
{
	eds_ptr_t ptr = get_eds_buffer_addr();

#if 0 /* do not print them because output must not depend on the address */
	printf("ptr = 0x%lx\n", ptr);
#endif

	if (ptr > 0xffff)
		printf("ptr points to high memory\n");
	else
		printf("ptr does not to high memory\n");

	write_eds(ptr, 1234);

	printf("%d\n", read_eds(ptr));

	return 0;
}
