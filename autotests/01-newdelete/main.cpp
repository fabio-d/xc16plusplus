#include <stdio.h>

extern "C" void *_heap, *_eheap;

int main (int argc, char *argv[])
{
	int *x = new int;
	*x = 1;

	int *y = new int[3];
	y[0] = 2;
	y[1] = 3;
	y[2] = 4;

#if __XC16_VERSION < 1011
	const unsigned long heap_start = (unsigned long)&_heap;
	const unsigned long heap_end = (unsigned long)&_eheap;
#else // __builtin_section_begin/end are only available since v1.11
	const unsigned long heap_start = __builtin_section_begin(".heap");
	const unsigned long heap_end = __builtin_section_end(".heap");
#endif
	const unsigned long x_addr = (unsigned long)x;
	const unsigned long y_addr = (unsigned long)y;

#if 0 /* do not print them because output must not depend on the address */
	printf("heap_start = 0x%lx\n", heap_start);
	printf("heap_end = 0x%lx\n", heap_end);
	printf("x_addr = 0x%lx\n", x_addr);
	printf("y_addr = 0x%lx\n", y_addr);
#endif

	if (heap_start <= x_addr && x_addr + sizeof(int) <= heap_end)
		printf("x is inside the heap region\n");
	else
		printf("x is outside the heap region\n");

	if (heap_start <= y_addr && y_addr + 3*sizeof(int) <= heap_end)
		printf("y is inside the heap region\n");
	else
		printf("y is outside the heap region\n");

	printf("%d %d %d %d\n", *x, y[0], y[1], y[2]);

	delete x;
	delete[] y;

	printf("done!\n");

	return 0;
}
