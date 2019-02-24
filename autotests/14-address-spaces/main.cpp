#include <stdio.h>

// declare an array that is too big for regular data memory, the linker will
// allocate it in the extended data space
#define COUNT_16KB_OF_INTS (32l * 1024 / 4)
__eds__ int var_in_eds[COUNT_16KB_OF_INTS] __attribute__((eds));

typedef __eds__ int *eds_ptr_t;

// return pointer to last element
eds_ptr_t get_eds_buffer_addr()
{
	return var_in_eds +  COUNT_16KB_OF_INTS - 1;
}

void write_eds(__eds__ int *addr, int val)
{
	*addr = val;
}

int read_eds(__eds__ int *addr)
{
	return *addr;
}

int main (int argc, char *argv[])
{
	eds_ptr_t ptr = get_eds_buffer_addr();
	__eds__ int *ptr2 = ptr;

#if 0 /* do not print address because output must not depend on the address */
	printf("ptr = 0x%lx\n", ptr);
#endif

	printf("sizeof(int*) = %u\n", (unsigned int)sizeof(int*));
	printf("sizeof(__eds__ int*) = %u\n", (unsigned int)sizeof(__eds__ int*));
	printf("sizeof(eds_ptr_t) = %u\n", (unsigned int)sizeof(eds_ptr_t));
	printf("sizeof(ptr) = %u\n", (unsigned int)sizeof(ptr));

	if ((unsigned long)ptr > 0xffff)
		printf("ptr points to high memory\n");
	else
		printf("ptr does not point to high memory\n");

	write_eds(ptr, 1234);

	printf("*ptr2 = %d\n", *ptr);
	printf("*(__eds__ int*)ptr = %d\n", *(__eds__ int*)ptr);
	printf("*static_cast<__eds__ int*>(ptr) = %d\n", *static_cast<__eds__ int*>(ptr));
	printf("read_eds(ptr) = %d\n", read_eds(ptr));

	return 0;
}
