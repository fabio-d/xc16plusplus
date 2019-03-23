# XC16++ for XC16 v1.25

Important notice! Unlike the previous version, upstream XC16 now uses the MPLAB
C30 C library by default (i.e. option ```-legacy-libc``` was made the default
option). It is not compatible with the C++ compiler, so be sure you compile your
firmware with the ```-no-legacy-libc``` compiler option.

This XC16 version is supported by XC16++ since v1.

## Installation

Install XC16 first, then follow instructions in the [README file](../README.md)
in the parent directory.

Links to Microchip's XC16 installer:
- [Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.25-full-install-linux-installer.run) (sha1 df3b205d69533ba12659f2e068b7628a01a28f2d)
- [Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.25-full-install-windows-installer.exe) (sha1 7b797abac05a06fe615566e29e8983fe4d16ab86)
- [OSX installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.25-full-install-osx-installer.dmg) (sha1 70f6727791d1cad06b4351d9c026bfdcbac4587f)

## Building from source

Download [Microchip's XC16 v1.25 source archive](http://ww1.microchip.com/downloads/en/DeviceDoc/v1.25.src.zip)
(sha1 291e8579fb1a0d10a0fc16a0640042cb3ac02bd4) and follow instructions in the
[BUILDING file](../BUILDING.md) in the parent directory.
