# XC16++ release repository

***Unofficial*** C++ compiler for PIC24 and dsPIC chips, based on the [official
XC16 compiler from Microchip](https://www.microchip.com/mplab/compilers).
It is neither endorsed nor supported in any form by Microchip.

## Download

Precompiled packages are available. They contain some executables that can be
**added to an existing XC16 installation** to enable the C++ language (choose
the one that matches your XC16 version and operating system). Precompiled XC16++
executables can be **downloaded at
https://github.com/fabio-d/xc16plusplus/releases**.

Installation instructions are provided below in this document.

This project is based on Microchip's official source code (available at
[Microchip's MPLAB-XC website](https://www.microchip.com/mplab/compilers) under
the *Downloads Archive* tab). Full source code of the C++ compiler executables
(i.e. source code from Microchip, with some patches to enable C++ support) can
be found in the
[xc16plusplus-source](https://github.com/fabio-d/xc16plusplus-source/branches/all)
repository (there is one branch for each supported XC16 version).

## About XC16 (the official Microchip compiler)

The official XC16 compiler is actually a modified `gcc` version targeting PIC24
and dsPIC chips. In fact, the XC16 distribution also includes some proprietary
software; however, since `gcc` is a GPLv3 project, the XC16 compiler sources are
also covered by the GPLv3. They can be downloaded from Microchip's website (see
previous section). The only officially supported language is C but, given that
`gcc` also supports C++, it is possible to recompile it with a different set
of configuration flags and enable the C++ frontend too!

It actually takes a little more effort to obtain a *working* C++ compiler, and
this project hosts some patches and auxiliary files to make it possible.

Note that it is not possible to ship a stand-alone C++ compiler that does not
require an existing XC16 installation, because some Microchip-supplied header
files, software libraries, linker scripts and even some pieces of the compiler
pipeline are proprietary.

## Installation

If you download a precompiled XC16++ package, you will find the following files
in its `bin/bin` subdirectory:
 * `coff-cc1plus` (Linux and OS X) or `coff-cc1plus.exe` (Windows)
 * `coff-g++` (Linux and OS X) or `coff-g++.exe` (Windows)
 * `elf-cc1plus` (Linux and OS X) or `elf-cc1plus.exe` (Windows)
 * `elf-g++` (Linux and OS X) or `elf-g++.exe` (Windows)

They must be copied to the `bin/bin` directory of an existing XC16 installation.
The default path is (assuming XC16 version 1.24):
 * `/opt/microchip/xc16/v1.24/bin/bin` (Linux)
 * `C:\Program Files (x86)\Microchip\xc16\v1.24\bin\bin` (Windows)
 * `/Applications/microchip/xc16/v1.24/bin/bin` (OS X)

If you download a **Linux** or **OS X** package, the `bin` and `bin/bin`
directories in the package also contain some symbolic links that must be copied
to the corresponding XC16 installation directory, along with the main
executables:
 * `bin/xc16-cc1plus` (symlink to `xc16-cc1`)
 * `bin/xc16-g++` (symlink to `xc16-gcc`)
 * `bin/bin/coff-paplus` (symlink to `coff-pa`)
 * `bin/bin/elf-paplus` (symlink to `elf-pa`)

On **Windows**, you have to copy those files, instead of symlinking them.
Therefore, no symbolic links are included in Windows packages. Instead, a
`bin\create_xc16plusplus_symlinks.cmd` is provided, which can be copied to
XC16's `bin` directory (the outer one, not `bin\bin`!) and run as Administrator
to automatically copy the necessary files directly on the target system. After
creating the copies, the script will show a confirmation message. You can delete
it afterwards.

## Building XC16++ from source

There are several ways to build XC16++, as documented in the
[BUILDING.md](https://github.com/fabio-d/xc16plusplus/blob/master/BUILDING.md)
file.

## Limitations
 * There is no libstdc++. Therefore, all C++ features that rely on external
   libraries are not available:
    * No `std::cout` / `std::cerr`
    * No STL
    * No exceptions
    * No RTTI (runtime type identification), e.g. `typeid` and `dynamic_cast`
      cannot be used
 * Extended data space (EDS) is only partly supported. In particular, objects
   cannot be placed in EDS memory (because `this` is a 16-bit data pointer).
 * Some EDS definitions that are valid in C are not supported in C++ parser,
   such as the following example:
```C
// This syntax, which is valid C code, does not compile in XC16++
int * __psv__ psv_pointer_to_int __attribute__((space(psv)));

// You can use this equivalent snippet, which is accepted by XC16++
typedef int *intstar;
intstar __psv__ psv_pointer_to_int __attribute__((space(psv)));
```
 * If your code uses pointers to variables/objects allocated in the stack,
   make sure that your stack is located in the low 32K region (the
   `--local-stack` linker option, enabled by default, does exactly this).
 * The legacy C library (i.e. compiler option `-legacy-libc`) is not supported.
   If your XC16 version is between 1.25 and 1.70, where `-legacy-libc` is the
   default, make sure you set the `-no-legacy-libc` compiler option. Starting
   from version 2.00 the options `-legacy-libc` and `-no-legacy-libc` are no
   longer supported, because the compiler will always use a new library to
   support the C99 standard.

## Some tips
 * Include *example-project/minilibstdc++.cpp* with your project (even if you do
   not use dynamic memory allocation), otherwise some symbols will not be
   resolved successfully by the linker.
 * Always compile C++ code with `-fno-exceptions` and `-fno-rtti` to avoid
   compiling code that relies on unsupported C++ features.
 * Define macro `__bool_true_and_false_are_defined` before including
   *stdbool.h*, so that it will not attempt to redefine such native C++
   keywords. It is a good idea to define it on the command line with the
   `-D__bool_true_and_false_are_defined` compiler option.
 * C symbols referenced from C++ code will not be resolved correctly unless they
   are marked as `extern "C"`.
 * Interrupt service routines written in C++ must be marked as `extern "C"` too,
   for instance:
```C++
extern "C" void __attribute__((__interrupt__, __auto_psv__, __shadow__)) _T1Interrupt(void)
{
  // Put C++ code here
}
```

# License

The compiler is subject to the original `gcc` license, i.e. GNU General Public
License, version 3 or later. A copy of the GNU General Public License is
attached (see file `LICENSE-GPL3.txt`).

Please note that the GPL **does not** extend to programs compiled by XC16++,
whose licensing terms are entirely up to the user. You will probably want to
link your firmware against Microchip's support libraries (`libc`, `libm`, ...),
that have their own licensing terms (see XC16's license).

The automatic tests (`autotests/` subdirectory) are released under the same
license as the compiler: GNU General Public License, version 3 or later.

The build scripts (`build-scripts/` subdirectory) and the example project
(`example-project/` subdirectory) are released to public domain, under the terms
of the "UNLICENSE" (see file `LICENSE-UNLICENSE.txt`).
