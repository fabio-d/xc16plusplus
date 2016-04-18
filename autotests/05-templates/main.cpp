#include <stdio.h>

#include "template.h"

extern void set_char_staticField(); // other.cpp

int main (int argc, char *argv[])
{
	FourElementsArray<int> intArr(1, 2, 3, 4);
	FourElementsArray<char> charArr('a', 'b', 'c', 'd');

	FourElementsArray<int>::staticField = templMin(6, 5);
	set_char_staticField();

	printf("%d %d %d %d %d\n", intArr.readAt(0), intArr.readAt(1), intArr.readAt(2), intArr.readAt(3), FourElementsArray<int>::staticField);
	printf("%c %c %c %c %c\n", charArr.readAt(0), charArr.readAt(1), charArr.readAt(2), charArr.readAt(3), FourElementsArray<char>::staticField);

	return 0;
}
