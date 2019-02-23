# Building XC16++ from source

There are two ways to compile XC16++:
 - Using the official build script, derived from the one in the XC16 source
   archive released by Microchip. It is not possible to cross-compile XC16 for a
   different OS with this method.
 - Using a custom build script that enables cross-compilation of XC16++, for all
   supported platforms, under a single Linux system.

The second method, in combination with a docker-based fixed environment, is the
one that is used for XC16++ releases. Please refer to the
`build-scripts/build-all.sh` script for the details.

## How to build the C++ compiler using `src_build.sh`

`src_build.sh` is the script that comes with the official XC16 source release.
It has been slightly patched to make it possible to build the C++ compiler
natively on each supported platform, as the following instructions show.

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
the C++ compiler for all supported platforms under Linux.

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
