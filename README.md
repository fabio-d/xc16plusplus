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

## How to build the C++ compiler using `src_build.sh`

`src_build.sh` is the script that comes with the official XC16 source release.
It has been slightly patched to make it possible to build the C++ compiler
natively on each supported platform, as the following instructions show.
I also wrote an alternative script, that is described in the next section, which
is probably easier to use, especially under 64-bit Linux.

### Linux

**Important**: Please note that **I only test 32-bit builds** and my experience
is that it is not trivial to build XC16 as a 32-bit executable on a 64-bit Linux
host using `src_build.sh` (for example, even with the `CC='gcc -m32'` option,
`libtool` still tries to link 64-bit libraries during the build process on
Fedora 22). Therefore, if you are on a 64-bit Linux OS, usage of the alternative
`xc16plusplus_only.sh` script (see next section) is strongly recommended.

 1. Install `bison`, `flex`, `libstdc++-static` and `m4` as well as the standard
    set of build tools (incl. `make`, C and C++ compiler).
 2. Download the official Microchip source code for your XC16 version and unpack
    it (e.g. `unzip xc16-v1.24-src.zip`)
 3. Patch the source code using the patch file that is appropriate for your
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
 6. Lastly, run the following commands:
    <pre>cd /opt/microchip/xc16/v1.24/bin/
    ln -s xc16-cc1 xc16-cc1plus
    ln -s xc16-gcc xc16-g++
    cd bin/
    ln -s coff-pa coff-paplus
    ln -s elf-pa elf-paplus</pre>

### Windows

Windows executables can be compiled in Cygwin through MinGW. The resulting
executables will not depend on any Cygwin or MinGW library and, therefore, can
safely be copied to other systems. **I only test 32-bit builds**: even if you
have 64-bit Windows, follow the following steps literally, so that you will
obtain 32-bit executables.

 1. Install [Cygwin for 32-bit versions of Windows](http://cygwin.com/install.html)
    (even if your OS is 64-bit). In addition to the default packages, also
    select binary `gcc-core`, `gcc-g++`, `mingw-gcc-core`, `mingw-gcc-g++`,
    `gettext-devel`, `autoconf`, `bison`, `flex` and `m4` in the package
    selection screen during the installation procedure (you can use the search
    box in the top-left corner of the installer screen to find them).
 2. Download the official Microchip source code for your XC16 version and unpack
    it under `C:\cygwin\home\yourusername\`
 3. Download the patch file that is appropriate for your version and save it
    under `C:\cygwin\home\yourusername\`
 3. Open the Cygwin terminal and patch the source code using the patch file
    you downloaded, for example:
    <pre>cd v1.24.src/
    patch -p1 < ../xc16plusplus_1_24.patch</pre>
 4. Run `./src_build.sh`.
 5. When the compilation process ends you will see some errors about `libgcc`,
    but they are expected. You should now have the following executables in your
    build tree under `v1.24.src\install\bin\bin\` that must be copied to their
    final location:
     * `coff-cc1plus.exe` &rarr; `C:\Program Files (x86)\Microchip\xc16\v1.24\bin\bin\coff-cc1plus.exe`
     * `coff-g++.exe` &rarr; `C:\Program Files (x86)\Microchip\xc16\v1.24\bin\bin\coff-g++.exe`
     * `elf-cc1plus.exe` &rarr; `C:\Program Files (x86)\Microchip\xc16\v1.24\bin\bin\elf-cc1plus.exe`
     * `elf-g++.exe` &rarr; `C:\Program Files (x86)\Microchip\xc16\v1.24\bin\bin\elf-g++.exe`
 7. Lastly, run the following commands in the Command Prompt (as administrator):
    <pre>cd "\Program Files (x86)\Microchip\xc16\v1.24\bin"
    mklink xc16-cc1plus.exe xc16-cc1.exe
    mklink "xc16-g++.exe" xc16-gcc.exe
    cd bin
    mklink coff-paplus.exe coff-pa.exe
    mklink elf-paplus.exe elf-pa.exe</pre>
    (if the `mklink` command is not available, you can simply copy files intead
    of linking them)

### OS X

The official XC16 release targets OS X 10.5 and later. The 10.5 SDK is therefore
required if you want to create executables that can be used on every system
where XC16 itself can be executed. However, if you are only interested in being
able to run the C++ compiler on your computer, **any SDK will do** (but a small
manual edit to *build_XC16_451* will be necessary). In both cases, keep in mind
that **I only test 32 builds**, so make sure you always set *-arch i386* at step
4.

 1. Install the command line tools. As of OS X 10.9 it is as easy as running
    ` xcode-select --install` from the terminal and following the instructions.
    For older OS X version, please refer to [the *Install Xcode* section of the
    MacPorts manual](https://guide.macports.org/chunked/installing.xcode.html).
 2. Download the official Microchip source code for your XC16 version and unpack
    it (e.g. `unzip xc16-v1.24-src.zip`)
 3. Patch the source code using the patch file that is appropriate for your
    version, for example:
    <pre>cd /path/to/v1.24.src/
    patch -p1 < /path/to/xc16plusplus_1_24.patch</pre>
 4. This is the SDK selection step. Open *build_XC16_451* in a text editor,
    scroll to the line
    <pre>EXTRA_CFLAGS="-arch i386 -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5"</pre>
    and edit it as needed. Unless you are trying to make a portable executable,
    **it is probably easiest to use your system's default SDK, so change it to
    just**
    <pre>EXTRA_CFLAGS="-arch i386"</pre>
 5. Run `./src_build.sh`.
 6. When the compilation process ends you will see some errors about `libiconv`,
    but they are expected. You should now have the following executables in your
    build tree under `v1.24.src/install/bin/bin/`, that must be copied to
    their final location:
     * `coff-cc1plus` &rarr; `/Applications/microchip/xc16/v1.24/bin/bin/coff-cc1plus`
     * `coff-g++` &rarr; `/Applications/microchip/xc16/v1.24/bin/bin/coff-g++`
     * `elf-cc1plus` &rarr; `/Applications/microchip/xc16/v1.24/bin/bin/elf-cc1plus`
     * `elf-g++` &rarr; `/Applications/microchip/xc16/v1.24/bin/bin/elf-g++`
 7. Lastly, run the following commands:
    <pre>cd /Applications/microchip/xc16/v1.24/bin/
    ln -s xc16-cc1 xc16-cc1plus
    ln -s xc16-gcc xc16-g++
    cd bin/
    ln -s coff-pa coff-paplus
    ln -s elf-pa elf-paplus</pre>

## How to build the C++ compiler using `xc16plusplus_only.sh`

This is an alternative build script that I wrote to automatically cross-compile
the C++ compiler for all supported platforms under Linux. It has only been
tested on Fedora 22, but there is no reason why it should not work on other
Linux distros.

I use this script to generate precompiled packages for all platforms (see
`scripts/make_release.sh`) on 32-bit Fedora 22.

I recommend to use this script instead of `src_build.sh` when building a
compiler for Linux on 64-bit Linux.

 1. Install `bison`, `flex`, `m4`, `make` and the compiler that is appropriate
    for the OS you want to cross-compile for:
     * A regular Linux `gcc` compiler if you want to build a compiler that runs
       on Linux;
     * `mingw32-gcc` if you want to build a compiler that runs on Windows;
     * [osxcross](https://github.com/tpoechtrager/osxcross) if you want to
       build a compiler that runs on OS X (use the `MacOSX10.5.sdk` SDK).
 2. Download the official Microchip source code for your XC16 version and unpack
    it (e.g. `unzip xc16-v1.24-src.zip`)
 3. Patch the source code using the patch file that is appropriate for your
    version, for example:
    <pre>cd /path/to/v1.24.src/
    patch -p1 < /path/to/xc16plusplus_1_24.patch</pre>
 4. Run `xc16plusplus_only.sh` passing the name of the OS you want to
    cross-compile for:
     * `./xc16plusplus_only.sh linux` or
     * `./xc16plusplus_only.sh win32` or
     * `./xc16plusplus_only.sh osx`
 5. Install the resulting files (that can be found in the
    `install-*gnu-target-name*/bin/bin` subdirectory) on the target system as
    if you had used the `src_build.sh` script.

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
