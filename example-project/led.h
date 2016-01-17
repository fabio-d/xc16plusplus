#ifndef LED_H
#define LED_H

#include <stdint.h>

namespace led {

// A generic LED abstraction with a pure virtual method
class base_led
{
	public:
		explicit base_led(bool initial_value);
		virtual ~base_led();

		void toggle();

	protected:
		virtual void set_value(bool new_value) = 0;

	private:
		bool current_value;
};

// A concrete LED class, that controls a LED that is directly connected to
// a digital I/O pin
class ioport_led : public base_led
{
	public:
		ioport_led(volatile uint16_t *TRIS_register, volatile uint16_t *LAT_register, unsigned int bit_index, bool initial_value = false);

	protected:
		void set_value(bool new_value);

	private:
		volatile uint16_t *LAT_register;
		const uint16_t bit_mask;
};

}

#endif
