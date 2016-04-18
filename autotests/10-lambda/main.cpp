#include <stdio.h>

template <typename LambdaFunc>
void call_lambda(LambdaFunc func)
{
	func(1);
	func(2);
	func(3);
	func(4);
}

int main (int argc, char *argv[])
{
	int counter = 0;

	auto incr = [&](int amount)
	{
		printf("incr by %d\n", amount);
		counter += amount;
	};

	call_lambda(incr);

	printf("final value is %d\n", counter);

	return 0;
}
