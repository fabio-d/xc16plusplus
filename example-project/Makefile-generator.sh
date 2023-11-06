#!/bin/bash
XC16VER=$1
case "$2" in
	linux)
		XC16DIR='/opt/microchip/xc16/'$XC16VER
		;;
	windows)
		XC16DIR='"C:\Program Files (x86)\Microchip\xc16\'$XC16VER'"'
		;;
	osx)
		XC16DIR='/Applications/microchip/xc16/'$XC16VER
		;;
	*)
		echo "Usage: $0 vN.NN <linux | windows | osx>"
		exit 1
esac

# Tests whether the current XC16 version is older than the specified one
# e.g. XC16VER=v1.23 xc16ver_lt v1.25 -> true
function xc16ver_lt()
{
	CURRENT_MAJOR=$(echo "$XC16VER" | cut -d. -f1 | tr -d v)
	CURRENT_MINOR=$(echo "$XC16VER" | cut -d. -f2)
	TEST_MAJOR=$(echo "$1" | cut -d. -f1 | tr -d v)
	TEST_MINOR=$(echo "$1" | cut -d. -f2)

	if [ $CURRENT_MAJOR -eq $TEST_MAJOR ];
	then
		[ $CURRENT_MINOR -lt $TEST_MINOR ]
	else
		[ $CURRENT_MAJOR -lt $TEST_MAJOR ]
	fi
}

# Tests whether the current XC16 version is equal or newer than the specified one
# e.g. XC16VER=v1.23 xc16ver_ge v1.22 -> true
function xc16ver_ge()
{
	CURRENT_MAJOR=$(echo "$XC16VER" | cut -d. -f1 | tr -d v)
	CURRENT_MINOR=$(echo "$XC16VER" | cut -d. -f2)
	TEST_MAJOR=$(echo "$1" | cut -d. -f1 | tr -d v)
	TEST_MINOR=$(echo "$1" | cut -d. -f2)

	if [ $CURRENT_MAJOR -eq $TEST_MAJOR ];
	then
		[ $CURRENT_MINOR -ge $TEST_MINOR ]
	else
		[ $CURRENT_MAJOR -ge $TEST_MAJOR ]
	fi
}

CFLAGS=('-mcpu=$(TARGET_CHIP)')
LDFLAGS=('-p$(TARGET_CHIP)' '--script' '$(LDSCRIPT)' '--heap=512' '-L$(XC16DIR)/lib' '-L$(XC16DIR)/lib/$(TARGET_FAMILY)')

if xc16ver_ge v1.20;
then
	CFLAGS+=(-mno-eds-warn)
	LDFLAGS+=(--local-stack)
fi

if xc16ver_ge v1.25 && xc16ver_lt v2.00;
then
	CFLAGS+=(-no-legacy-libc)
fi

if xc16ver_ge v2.00;
then
	LIBS=('-lc99' '-lc99-pic30')
else
	LIBS=('-lc' '-lpic30')
fi

LIBS+=(-lm)

cat <<EOF
# Change these values to the right values for your chip
TARGET_CHIP := 33FJ128MC804
TARGET_FAMILY := dsPIC33F
# or
#TARGET_CHIP := 33EP512GP502
#TARGET_FAMILY := dsPIC33E
# or
#TARGET_CHIP := 24FJ32GB002
#TARGET_FAMILY := PIC24F
# or
#your own values

# Change this to match your XC16/XC16++ path
XC16DIR := $XC16DIR

# Options for the C and C++ compilers
#  - The __bool_true_and_false_are_defined macro is necessary to prevent
#    stdbool.h from redefining bool (which is a built-in type in C++)
#  - Note that -fno-exceptions -fno-rtti are always required because the C++
#    compiler does not support neither exceptions nor runtime type
#    identification (RTTI).
CFLAGS := ${CFLAGS[*]}
CXXFLAGS := \$(CFLAGS) -D__bool_true_and_false_are_defined -fno-exceptions -fno-rtti

# Options for the linker
LDSCRIPT := \$(XC16DIR)/support/\$(TARGET_FAMILY)/gld/p\$(TARGET_CHIP).gld
LDFLAGS := ${LDFLAGS[*]}
LIBS := --start-group ${LIBS[*]} --end-group

.DEFAULT_GOAL := all
.PHONY: all clean
OBJS := main.o clock.o led.o timer1.o minilibstdc++.o

all: result.hex

# Rule to compile C source files (using the official C compiler)
%.o: %.c
	\$(XC16DIR)/bin/xc16-gcc \$(CFLAGS) -c $< -o \$@

# Rule to compile C++ source files (using the unofficial C++ compiler)
%.o: %.cpp
	\$(XC16DIR)/bin/xc16-g++ \$(CXXFLAGS) -c $< -o \$@

# Rule to link together object files created through distinct compiler invocations
result.elf: \$(OBJS)
	\$(XC16DIR)/bin/xc16-ld \$(LDFLAGS) \$^ \$(LIBS) -o \$@

# Rule to convert the resulting ELF file into a HEX file
result.hex: result.elf
	\$(XC16DIR)/bin/xc16-bin2hex $<

clean:
	\$(RM) result.elf result.hex \$(OBJS)
EOF
