# Example C++ project

This folder contains a simple LED-blinking project that shows how to invoke the
C++ compiler, how to mix C and C++ source files in a project and how to write in
C++ for PIC24/dsPIC chips. All code in this folder is released to public domain
(see *LICENSE-UNLICENSE* in the parent directory), so you can use it as starting
point for your projects.

## Compiling and running the project
 1. Edit the first lines of the *Makefile* to set your target chip
 2. Set `XC16DIR` in the *Makefile* to your XC16/XC16++ installation directory
 3. If necessary, edit *clock.c*, `FCY` in *clock.h* and the `#pragma config`
    section in *main.cpp* to adapt them to your chip
 4. Run `make`
 5. If no errors occur, *result.hex* will be created. Otherwise, run
    `make clean` and go back to 1.
 6. Flash the HEX file. For example, if you use the PICkit 2 programmer with a
    dsPIC33FJ128MC804:
    <pre>pk2cmd -PdsPIC33FJ128MC804 -Fresult.hex -M -R</pre>
