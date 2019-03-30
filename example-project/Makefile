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

# Change this to match your XC16 and XC16++ version and path
XC16DIR := /opt/microchip/xc16/v1.26
#XC16DIR := "C:\Program Files (x86)\Microchip\xc16\v1.26"
#XC16DIR := /Applications/microchip/xc16/v1.26

# Example options for the C compiler
# Option -no-legacy-libc is only necessary for xc16 >= v1.25, older versions
# will not understand it and print a warning message, but it will not harm the
# compilation process
CFLAGS := -mcpu=$(TARGET_CHIP) -mno-eds-warn -no-legacy-libc

# Example options for the C++ compiler. Note that -fno-exceptions -fno-rtti
# are always required because this compiler does not support neither exceptions
# nor runtime type identification (RTTI). -D__bool_true_and_false_are_defined is
# only necessary if your code includes stdbool.h
CXXFLAGS := $(CFLAGS) -fno-exceptions -fno-rtti -D__bool_true_and_false_are_defined

LDSCRIPT := $(XC16DIR)/support/$(TARGET_FAMILY)/gld/p$(TARGET_CHIP).gld
LDFLAGS := --local-stack -p$(TARGET_CHIP) --script $(LDSCRIPT) --heap=512 -L$(XC16DIR)/lib -L$(XC16DIR)/lib/$(TARGET_FAMILY)
LIBS := -lc -lpic30 -lm # List any other library you need here (order matters)

.DEFAULT_GOAL := all
.PHONY: all clean
OBJS := main.o clock.o led.o timer1.o minilibstdc++.o

all: result.hex

# Rule to compile C source files (using the official C compiler)
%.o: %.c
	$(XC16DIR)/bin/xc16-gcc $(CFLAGS) -c $< -o $@

# Rule to compile C++ source files (using the unofficial C++ compiler)
%.o: %.cpp
	$(XC16DIR)/bin/xc16-g++ $(CXXFLAGS) -c $< -o $@

# Rule to link together object files created through distinct compiler invocations
result.elf: $(OBJS)
	$(XC16DIR)/bin/xc16-ld $(LDFLAGS) $^ $(LIBS) -o $@

# Rule to convert the resulting ELF file into a HEX file
result.hex: result.elf
	$(XC16DIR)/bin/xc16-bin2hex $<

clean:
	$(RM) result.elf result.hex $(OBJS)
