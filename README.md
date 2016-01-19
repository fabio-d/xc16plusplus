# XC16++ release repository

***Unofficial*** C++ compiler for PIC24 and dsPIC chips, based on the [official
XC16 compiler from Microchip](http://www.microchip.com/pagehandler/en_us/devtools/mplabxc/).
It is neither endorsed nor supported in any form by Microchip.

## About XC16 (the official Microchip compiler)

The official XC16 compiler is actually a modified `gcc` version targeting PIC24
and dsPIC chips. The XC16 distribution also includes other software, but what is
important for our purposes is that since `gcc` is a GPLv3 project, the XC16
compiler sources are also covered by the GPLv3.
They can be downloaded from [the Microchip website](http://www.microchip.com/archived).
The only officially supported language is C but, given that `gcc` also supports
C++, it is possible to recompile `gcc` and enable it.

It actually takes a little more effort to obtain a working C++ compiler, and
this repository hosts some patches I created. The following section shows how to
apply them to Microchip's XC16 source releases, compile and install the C++
compiler on top of an existing XC16 installation.

Note that it is not possible to ship a C++ compiler that does not require an
existing XC16 installation, because all Microchip-supplied header files,
software libraries, linker scripts and even some pieces of the compiler
infrastructure are proprietary.

## Installation on top of an existing XC16 installation

### Linux

**Important**: Please note that **I only test 32-bit builds** and my experience
is that it is not trivial to build XC16 as a 32-bit executable on a 64-bit Linux
host (for example, even with the `CC='gcc -m32'` option, `libtool` still tries
to link 64-bit libraries during the build process on Fedora 22). Therefore, if
you are on a 64-bit Linux OS, usage of a VM or a 32-bit chroot to run the
compilation process is strongly recommended.

 1. Install `bison`, `flex`, `libstdc++-static` and `m4` as well as the standard
    set of build tools (incl. `make`, C and C++ compiler).
 2. Download the official Microchip source code for your XC16 version and unpack
    it (e.g. `unzip xc16-v1.24-src.zip`)
 3. Patch the source code using the patch file that is most appropriate for your
    version, for example:
    <pre>cd /path/to/v1.24.src/
    patch -p1 < /path/to/xc16plusplus_1_24.patch</pre>
 4. Run `./src_build.sh`.
 5. When the compilation process ends you will see some errors about `libgcc`,
    but they are expected. You should now have the following executables in your
    build tree under `v1.24.src/install/bin/bin/`, that must be copied to
    their final location:
     * `coff-cc1plus` &rarr; `/opt/microchip/xc16/v1.24/bin/bin/coff-cc1plus`
     * `coff-g++` &rarr; `/opt/microchip/xc16/v1.24/bin/bin/coff-g++`
     * `elf-cc1plus` &rarr; `/opt/microchip/xc16/v1.24/bin/bin/elf-cc1plus`
     * `elf-g++` &rarr; `/opt/microchip/xc16/v1.24/bin/bin/elf-g++`
 6. *(Only if you are using a VM or chroot to build XC16++)* Copy the previous
    files out of the VM/chroot and go back to your main system.
 7. Lastly, run the following commands:
    <pre>cd /opt/microchip/xc16/v1.24/bin/
    ln -s xc16-cc1 xc16-cc1plus
    ln -s xc16-gcc xc16-g++</pre>

### Windows

Windows executables can be compiled in Cygwin through MinGW. The resulting
executables will not depend on any Cygwin or MinGW library and, therefore, can
safely be copied to other systems. **I only test 32-bit builds**: even if you
have 64-bit Windows, follow the following steps literally, so that you will
obtain 32-bit executables.

TODO

## Limitations
 * There is no libstdc++, therefore all C++ features that rely on external
   libraries are not available:
    * No `std::cout` / `std::cerr`
    * No STL
    * No exceptions
    * No RTTI (runtime type identification), e.g. `typeid` and `dynamic_cast`
      cannot be used
 * Extended data space (EDS) is not supported. If your chip has more than 32K
   RAM, you will not be able to access any address above 32K from C++. Also,
   make sure that your stack is located in the low 32K region (the
   `--local-stack` linker option, enabled by default, does exactly this).
 * Address space qualifiers, such as `__eds__`, are not understood by the C++
   compiler.
 * The legacy C library (i.e. compiler option `-legacy-libc`) is not supported.
   If your XC16 version is 1.25 or newer, where `-legacy-libc` has become the
   default, make sure you set the `-no-legacy-libc` compiler option.

## Some tips
 * The standard `#include <libpic30.h>` does not compile in C++ (because
   *libpic30.h* contains `__eds__`). Use the *libpic30++.h* file provided in the
   *support-files* directory instead.
 * Compile *support-files/minilibstdc++.cpp* with your project (even if you do
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
 * Extended data space is not supported by the C++ compiler, but if you want to
   use the upper 32K RAM region you can write C code to access it and call it
   from your C++ code.

# License

Patches are released under the same license as the portion of the XC16 source
code they apply to, i.e. GNU General Public License, version 3 or (if
applicable) later. A copy of the GNU General Public License is available in this
repository (see file *LICENSE-GPL3*). The GPL **does not** extend to programs
compiled by XC16++.

The example project (*example-project/* subdirectory) and support files
(*support-files/* subdirectory) are released to public domain, under the terms
of the "UNLICENSE" (see file *LICENSE-UNLICENSE*).

## Hacking

This repository only contains patches to apply to Microchip's source archives.
If you want to **modify** the C++ compiler, the
[xc16plusplus-source](https://github.com/fabio-d/xc16plusplus-source)
repository is probably more convenient.
