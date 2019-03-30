#include "clock.h"
#include "led.h"
#include "timer1.h"

#include <xc.h>
#include <libpic30.h>

// Very minimal set of configuration bits, so that this example can be easily
// ported to any PIC24/dsPIC chip
#pragma config FWDTEN = OFF
#pragma config FCKSM = CSECMD
#pragma config FNOSC = FRC

// Our timer interrupt event receiver
class my_timer_callback : public timer::callback
{
	public:
		explicit my_timer_callback(led::base_led *led);

	protected:
		void fired(); // this overrides a pure virtual method

	private:
		led::base_led *led;
		int sw_postscaler;
};

my_timer_callback::my_timer_callback(led::base_led *led)
: led(led), sw_postscaler(0)
{
}

void my_timer_callback::fired()
{
	if (sw_postscaler-- == 0)
	{
		led->toggle();
		sw_postscaler = 10;
	}
}

// Example of template function
template <typename T>
bool is_even(const T &value)
{
	return value % 2 == 0;
}

int main()
{
	int counter = 0;

	// Call a function that is implemented as C code in clock.c
	// The only reason why it is implemented in C is to demonstrate how to
	// call C code from C++.
	clock_init();

	// Allocate a ioport_led instance on the heap. Heap size is controlled
	// by the --heap=nnn linker option (see Makefile).
	// Note how we can downcast the pointer to the newly created object to
	// its base class
	led::base_led *my_led = new led::ioport_led(&TRISA, &LATA, 4);

	for (int i = 0; i < 10; i++)
	{
		my_led->toggle(); // <- We are calling a virtual method here!
		__delay_ms(100);
	}

	while (true)
	{
		// We are calling an instance of a template function here!
		const bool even = is_even(counter++);

		if (even)
		{
			// This creates a my_timer_callback object on the stack.
			// Stack size is configurable with linker options too,
			// but it is usually automatically configured to be as
			// big as all unused RAM memory after the heap
			my_timer_callback timer_cb(my_led);

			timer::timer1_start(&timer_cb);
			__delay_ms(5000);
			timer::timer1_stop();
		}
		else
		{
			__delay_ms(1000);
		}
	}

	// This actually is never executed in this example, but it shows how to
	// free objects created with the new operator.
	delete my_led;
}
