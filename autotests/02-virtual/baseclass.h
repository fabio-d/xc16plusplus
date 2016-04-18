#pragma once

class baseclass
{
	public:
		baseclass();
		virtual ~baseclass();

		void nonvirtualmethod();
		virtual void virtualmethod1();
		virtual void virtualmethod2() = 0;
};
