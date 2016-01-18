#include <stdlib.h>

// Simple new and delete operator implementation based on malloc and free
void *operator new(size_t size)
{
	return malloc(size);
}

void *operator new[](size_t size)
{
	return malloc(size);
}

void operator delete(void *p)
{
	free(p);
}

void operator delete[](void *p)
{
	free(p);
}

// Simple implementation of the function that gets tied to pure virtual methods.
// Note that it is impossible to actually run this function through valid C++
// code.
extern "C" __attribute__((noreturn, naked)) void __cxa_pure_virtual()
{
	asm("reset");
	while(1);
}

#ifdef __XC16ELF
// If we are using the ELF object format, the follwing symbols are required by
// the code that initialized statically-allocated global objects. COFF uses a
// different ABI and does not need them
void *__dso_handle = 0;
extern "C" int __cxa_atexit(void (*destructor) (void *), void *arg, void *dso)
{
	return 0;
}
#endif
