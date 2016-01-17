#include "led.h"

#include <xc.h>

namespace led {

base_led::base_led(bool initial_value)
: current_value(initial_value)
{
}

base_led::~base_led()
{
}

void base_led::toggle()
{
	current_value = !current_value;
	set_value(current_value);
}

ioport_led::ioport_led(volatile uint16_t *TRIS_register, volatile uint16_t *LAT_register, unsigned int bit_index, bool initial_value)
: base_led(initial_value), LAT_register(LAT_register), bit_mask(1 << bit_index)
{
	*TRIS_register &= ~bit_mask;

	if (initial_value)
		*LAT_register |= bit_mask;
	else
		*LAT_register &= ~bit_mask;
}

void ioport_led::set_value(bool new_value)
{
	if (new_value)
		*LAT_register |= bit_mask;
	else
		*LAT_register &= ~bit_mask;
}

}
