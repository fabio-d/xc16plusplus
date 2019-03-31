# XC16++ release repository

***Unofficial*** C++ compiler for PIC24 and dsPIC chips, based on the [official
XC16 compiler from Microchip](https://www.microchip.com/mplab/compilers).
It is neither endorsed nor supported in any form by Microchip.

## Download

Precompiled packages are available. They contain some executables that can be
**added to an existing XC16 installation** to enable the C++ language (choose
the one that matches your XC16 version). XC16++ precompiled executables, full
source code and patches can be **downloaded at
https://github.com/fabio-d/xc16plusplus/releases**.

Installation instructions are provided below in this document.

This repository (*xc16plusplus*) only contains source code in form of patches
that can be applied to Microchip's official source code (available at
[Microchip's MPLAB-XC website](https://www.microchip.com/mplab/compilers) under
the *Downloads Archive* tab).

The same code, but in form of already-patched source trees is kept in the
companion development
[xc16plusplus-source](https://github.com/fabio-d/xc16plusplus-source/branches/all)
repository (there is one branch for each supported XC16 version).

## About XC16 (the official Microchip compiler)

The official XC16 compiler is actually a modified `gcc` version targeting PIC24
and dsPIC chips. The XC16 distribution also includes other software, but what is
important for our purposes is that since `gcc` is a GPLv3 project, the XC16
compiler sources are also covered by the GPLv3. They can be downloaded from
Microchip's website (see previous section). The only officially supported
language is C but, given that `gcc` also supports C++, it is possible to
recompile `gcc` and enable `g++`!

It actually takes a little more effort to obtain a working C++ compiler, and
this repository hosts some patches I created. The following section shows how to
apply them to Microchip's XC16 source releases, compile and install the C++
compiler on top of an existing XC16 installation.

Note that it is not possible to ship a stand-alone C++ compiler that does not
require an existing XC16 installation, because all Microchip-supplied header
files, software libraries, linker scripts and even some pieces of the compiler
infrastructure are proprietary.

## Installation on top of an existing XC16 installation from binary packages

If you download a precompiled XC16++ package, you will find the following files
in its `bin/bin` subdirectory:
 * `coff-cc1plus` (Linux and OS X) or `coff-cc1plus.exe` (Windows)
 * `coff-g++` (Linux and OS X) or `coff-g++.exe` (Windows)
 * `elf-cc1plus` (Linux and OS X) or `elf-cc1plus.exe` (Windows)
 * `elf-g++` (Linux and OS X) or `elf-g++.exe` (Windows)

They must be copied to the `bin/bin` directory of the main XC16 installation,
whose path can vary according to how XC16 was installed. The default path is
(assuming XC16 version 1.24):
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

On **Windows**, you need Administrator rights in order to create symbolic links.
Therefore, no symbolic links are included in Windows packages. Instead, a
`bin\create_xc16plusplus_symlinks.cmd` is provided, which can be copied to
XC16's `bin` directory and run as Administrator to automatically create the
symbolic links directly on the target system. After creating the links, the
script will show a confirmation message. You can delete it afterwards.

## Building XC16++ from source

There are several ways to build XC16++, as documented in the
[BUILDING.md](https://github.com/fabio-d/xc16plusplus/blob/master/BUILDING.md)
file.

## Limitations
 * There is no libstdc++, therefore all C++ features that rely on external
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
   If your XC16 version is 1.25 or newer, where `-legacy-libc` has become the
   default, make sure you set the `-no-legacy-libc` compiler option.

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
   for example:
```C++
extern "C" void __attribute__((__interrupt__, __auto_psv__, __shadow__)) _T1Interrupt(void)
{
  // Put C++ code here
}
```

# License

Patches are released under the same license as the portion of the XC16 source
code they apply to, i.e. GNU General Public License, version 3 or (if
applicable) later. A copy of the GNU General Public License is available in this
repository (see file *LICENSE-GPL3*). The GPL **does not** extend to programs
compiled by XC16++.

The example project (*example-project/* subdirectory) and support files
(*support-files/* subdirectory) are released to public domain, under the terms
of the "UNLICENSE" (see file *LICENSE-UNLICENSE*).
