#pragma once

#include "baseclass.h"

class derivclass : public baseclass
{
	public:
		static baseclass *create_instance();

		derivclass();
		~derivclass();

		void virtualmethod1();
		void virtualmethod2();
};
