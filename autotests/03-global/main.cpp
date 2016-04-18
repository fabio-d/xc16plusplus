#include <stdio.h>

class MyClass
{
	public:
		MyClass(int arg1, const char *arg2);

		~MyClass();

		int x;
		const char *y;
};

MyClass globalObj(1, "2");

MyClass::MyClass(int arg1, const char *arg2)
: x(arg1), y(arg2)
{
	printf("ctor: %d %s\n", arg1, arg2);
}

MyClass::~MyClass()
{
	// xc16plusplus does not call global objects' destructors
	printf("dtor: this should not happen\n");
}

int main (int argc, char *argv[])
{
	printf("main: %d %s\n", globalObj.x, globalObj.y);
	return 0;
}
