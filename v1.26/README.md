# XC16++ for XC16 v1.26

Important notice! The device headers (i.e. `xc.h`) shipped with upstream XC16
are no longer compatible with options `-std=c++98`  and `-std=c++0x`. If your
project uses one of those, replace it respectively with `-std=gnu++98` or
`-std=gnu++0x`.

## Installation

Install XC16 first, then follow instructions in the [README file](../README.md)
in the parent directory.

Links to Microchip's XC16 installer:
- [Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.26-full-install-linux-installer.run) (sha1 bcd94dbf643ee3f2824254ec79ccece9d0ff27c8)
- [Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.26-full-install-windows-installer.exe) (sha1 9c506a493fefb536b152a70400313190e6b7df82)
- [OSX installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.26-full-install-osx-installer.dmg) (sha1 099e04d5fb300994b1da4593ca990a23f2a46cd2)

## Building from source

Download [Microchip's XC16 v1.26 source archive](http://ww1.microchip.com/downloads/en/DeviceDoc/MPLAB%20XC16%20v1.26.src.zip)
(sha1 88264d55a78cb8d5c13180c3baa4c2bf661c3c2d) and follow instructions in the
[BUILDING file](../BUILDING.md) in the parent directory.
