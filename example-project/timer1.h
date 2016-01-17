#ifndef TIMER_H
#define LED_H

namespace timer {

class callback
{
	public:
		virtual ~callback();

		virtual void fired() = 0;
};

void timer1_start(callback *handler);
void timer1_stop();

}

#endif
