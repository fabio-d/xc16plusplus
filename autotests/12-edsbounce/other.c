#include <stdio.h>

#include "other.h"

// declare an array that is too big for regular data memory, the linker will
// allocate it in the extended data space
#define COUNT_16KB_OF_INTS (32l * 1024 / 4)
__eds__ int var_in_eds[COUNT_16KB_OF_INTS] __attribute__((eds));

// return pointer to last element
eds_ptr_t get_eds_buffer_addr()
{
	return var_in_eds +  COUNT_16KB_OF_INTS - 1;
}

void write_eds(eds_ptr_t addr, int val)
{
	*addr = val;
}

int read_eds(eds_ptr_t addr)
{
	return *addr;
}
