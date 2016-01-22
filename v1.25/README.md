# XC16++ for XC16 v1.25

Important notice! Upstream XC16 was modified to use the MPLAB C30 C library by
default (i.e. option ```-legacy-libc``` has been made the default option). It is
not compatible with the C++ compiler, so be sure you compile your firmwares with
the ```-no-legacy-libc``` compiler option.

## Installation

Download [Microchip's XC16 v1.25 source archive](http://ww1.microchip.com/downloads/en/DeviceDoc/v1.25.src.zip)
(sha1 291e8579fb1a0d10a0fc16a0640042cb3ac02bd4) and follow instructions in
the [README file in the parent directory](../README.md).
