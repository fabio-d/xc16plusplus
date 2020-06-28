# XC16++ versioning scheme

XC16++ releases are identified by a single number, called "revision number",
which is incremented for every new release. Every XC16++ revision is compatible
with all XC16 versions that were available at the moment of the release.

Therefore, downloadable binary packages have two version numbers encoded in the
filename. For instance:
```
xc16plusplus-v1.30r2-linux.tar.gz
                  ^^ ----> This is XC16++ revision 2 ...
             ^^^^^ ------> ... to be installed on top of XC16 v1.30
```

The revision number of an installed XC16++ compiler can be queried with:
```
$ xc16-g++ --version
elf-g++ (Microchip Technology) 4.5.1 (XC16, Microchip v1.30, (A) XC16++ r2) Build date: Jun  6 2020
```

Starting from revision 2, the revision number is also implicitly defined as the
`__XC16PLUSPLUS_REVISION__` macro in all C++ compilation units.

**Note**: The first XC16++ release did not follow the above scheme: downloadable
binary packages have `v1` instead of `r1` in their names and only supported XC16
v1.23, v1.24 and v1.25.

# XC16++ changelog

## r1 (Apr 19, 2016)

* First XC16++ release. It only supports XC16 v1.23, v1.24 and v1.25.

## r2 (not released yet)

* Added support for **Named Address Spaces**: keywords such as `__eds__` and
  `__psv__` can now be used in C++ code. As a consequence, the previously
  suggested workaround of including `libpic30++.h` instead of `libpic30.h` is no
  longer needed and the `libpic30++.h` file has been removed from the release
  package.
* Macros `__XC16PLUSPLUS__` and `__XC16PLUSPLUS_REVISION__` are now implicitly
  defined in all compilation units.
* Support for **all XC16 versions released so far**, from v1.00 to v1.50. In
  order to match XC16's system requirements, XC16++'s v1.50 executables are
  64-bit on all platforms.

# Supported XC16 versions

This file lists all supported XC16 versions, links to download them from the
Microchip website and some notes about the corresponding XC16++ variant.

If you want to install XC16++, you have to download and run the XC16 installer
for you operating system (you can use one of the following links, provided for
convenience) first. Once XC16 is installed, you can unpack the corresponding
XC16++ release package on top of it. Please refer to [README.md](README.md) file
for the details.

The links to the source archives are provided for reference only. They contain
Microchip's official XC16 source code, without any patch from the XC16++
project. Please refer to the
[xc16plusplus-source](https://github.com/fabio-d/xc16plusplus-source/branches/all)
repository (there is one branch for each supported XC16 version) for the actual
XC16++ source code.

## v1.00

This is the first XC16 version ever released by Microchip.

- Supported since: XC16++ revision 2
- [Microchip's XC16 v1.00 Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1_00-linux-installer.run) (sha1 5d2c9478958c5ed2bf561e33ba7b31367b6e80d5)
- [Microchip's XC16 v1.00 Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1_00-windows-installer.exe) (sha1 7b3daac479f3bc1002091aa4d347eb696173620c)
- [Microchip's XC16 v1.00 OSX installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1_00-osx-installer.dmg) (sha1 3185bbcd04995d8f5fca1478867c436518a342c1)
- [Microchip's XC16 v1.00 source archive](http://ww1.microchip.com/downloads/Secure/en/DeviceDoc/MPLABX16_v1_00_SRC.zip) (sha1 7ce536bf7b0cc2d2c0a9868096d869a7dba1a21d)

## v1.10

- Supported since: XC16++ revision 2
- [Microchip's XC16 v1.10 Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.10-linux.tar) (sha1 2bdc53262d3c456db405231687a83778490e95f7)
- [Microchip's XC16 v1.10 Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.10-windows.exe) (sha1 4c34f081a1e3fe4377634054371260f4af094fc1)
- [Microchip's XC16 v1.10 OSX installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.10-osx.dmg) (sha1 797621c250744861701d67edda6c9cc49c7892b3)
- [Microchip's XC16 v1.10 source archive](http://ww1.microchip.com/downloads/Secure/en/DeviceDoc/XC16_v1.10.src.tgz) (sha1 a3526fcf18db8ecfad63343505d4f2473ceb0eb4)

## v1.11

- Supported since: XC16++ revision 2
- [Microchip's XC16 v1.11 Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.11-linux-installer.run) (sha1 656437bc6e31f6524e20795af83aaef246f9a53b)
- [Microchip's XC16 v1.11 Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.11-windows-installer.exe) (sha1 8f37e65fd830b39f8e62d0454d78cbcdf6f8ee98)
- [Microchip's XC16 v1.11 OSX installer](http://ww1.microchip.com/downloads/en/xc16-v1.11-osx-installer.dmg) (sha1 69f75001134e9096a629c4555794bb0985368583)
- [Microchip's XC16 v1.11 source archive](http://ww1.microchip.com/downloads/Secure/en/DeviceDoc/xc16_src_archive_v111.zip) (sha1 c885f1c434d9bd758b8033ccf8e2557eecd2ac85)

## v1.20

- Supported since: XC16++ revision 2
- [Microchip's XC16 v1.20 Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.20-linux-installer.run.tar) (sha1 417374dd3bec0261a64859e8e57572702ecfe872)
- [Microchip's XC16 v1.20 Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.20-windows-installer.exe) (sha1 418aceb9935daaa3f78893b72efbe88cb2d0642f)
- [Microchip's XC16 v1.20 OSX installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.20--osx-installer.dmg) (sha1 7916db9f6a863176950d21fb1952c0653bc8e89d)
- [Microchip's XC16 v1.20 source archive](http://ww1.microchip.com/downloads/Secure/en/DeviceDoc/xc16_v1_20_src.zip) (sha1 5f5f0c5d6b500eb6d36ab1e0e1839c436a0b2de7)

## v1.21

- Supported since: XC16++ revision 2
- [Microchip's XC16 v1.21 Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.21-linux-installer.run.tar) (sha1 936bf65f6b18aa817d469da25e81823d2271e68f)
- [Microchip's XC16 v1.21 Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.21-windows-installer.exe) (sha1 6500ddb406ebbf66ed1d8d741c742ae02722385a)
- [Microchip's XC16 v1.21 OSX installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.21--osx-installer.dmg) (sha1 ed7cde72136737d8c3264a9937d7efbf6fa68079)
- [Microchip's XC16 v1.21 source archive](http://ww1.microchip.com/downloads/Secure/en/DeviceDoc/XC16_v1_21_src.zip) (sha1 8b8741dc04b890bd1075f3733e1f657f3d679832)

## v1.22

- Supported since: XC16++ revision 2
- [Microchip's XC16 v1.22 Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.22-full-install-linux-installer.run) (sha1 b88757895c8b3fc10bd8921bb5c1caad6648a92f)
- [Microchip's XC16 v1.22 Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.22-full-install-windows-installer.exe) (sha1 657ed54f6ff927b6d1d494b27902b4d7207f9c24)
- [Microchip's XC16 v1.22 OSX installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.22-full-install-osx-installer.dmg) (sha1 09bb5a62c68d20586dfae96c1242c54c06a4d750)
- [Microchip's XC16 v1.22 source archive](http://ww1.microchip.com/downloads/Secure/en/DeviceDoc/xc16-v1.22-src.zip) (sha1 d175cb89c9bbe85bf551d62db67063e67fa93e6c)

## v1.23

- Supported since: XC16++ revision 1
- [Microchip's XC16 v1.23 Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.23-full-install-linux-installer.run) (sha1 be097e71e32001a2895291bf9a6637b33977e32d)
- [Microchip's XC16 v1.23 Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.23-full-install-windows-installer.exe) (sha1 12ccffc87c429afba5bc61bba5bd19d6e64f2ca3)
- [Microchip's XC16 v1.23 OSX installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.23-full-install-osx-installer.dmg) (sha1 a2da3dfb9295c26ceea182c20d8395de3f76e9b2)
- [Microchip's XC16 v1.23 source archive](http://ww1.microchip.com/downloads/Secure/en/DeviceDoc/xc16-v1.23-src.zip) (sha1 568d25d0cb0dcb7e53d122d4268398122e871382)

## v1.24

- Supported since: XC16++ revision 1
- [Microchip's XC16 v1.24 Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.24-full-install-linux-installer.run) (sha1 fc73b93ad60e8bf76bc36dec16f4ee47fd5204eb)
- [Microchip's XC16 v1.24 Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.24-full-install-windows-installer.exe) (sha1 71dc45d1c45cb1812ecd50e69b8b1fcbc89cbd22)
- [Microchip's XC16 v1.24 OSX installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.24-full-install-osx-installer.dmg) (sha1 9fcbab96777e4a671ee46dbc0e1afbf274a2440f)
- [Microchip's XC16 v1.24 source archive](http://ww1.microchip.com/downloads/Secure/en/DeviceDoc/xc16-v1.24-src.zip) (sha1 01cf99d130e2dfc9ea9a83122c9fb2a37a4191dc)

## v1.25

Unlike the previous versions, upstream XC16 now uses the MPLAB C30 C library by
default (i.e. option ```-legacy-libc``` was made the default option). It is not
compatible with the C++ compiler, so be sure you compile your firmware with the
```-no-legacy-libc``` compiler option.

- Supported since: XC16++ revision 1
- [Microchip's XC16 v1.25 Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.25-full-install-linux-installer.run) (sha1 df3b205d69533ba12659f2e068b7628a01a28f2d)
- [Microchip's XC16 v1.25 Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.25-full-install-windows-installer.exe) (sha1 7b797abac05a06fe615566e29e8983fe4d16ab86)
- [Microchip's XC16 v1.25 OSX installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.25-full-install-osx-installer.dmg) (sha1 70f6727791d1cad06b4351d9c026bfdcbac4587f)
- [Microchip's XC16 v1.25 source archive](http://ww1.microchip.com/downloads/Secure/en/DeviceDoc/v1.25.src.zip) (sha1 291e8579fb1a0d10a0fc16a0640042cb3ac02bd4)

## v1.26

The device headers (i.e. `xc.h`) shipped with upstream XC16 are no longer
compatible with options `-std=c++98` and `-std=c++0x`. If your project uses such
compiler options, replace them respectively with `-std=gnu++98` or
`-std=gnu++0x`.

- Supported since: XC16++ revision 2
- [Microchip's XC16 v1.26 Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.26-full-install-linux-installer.run) (sha1 bcd94dbf643ee3f2824254ec79ccece9d0ff27c8)
- [Microchip's XC16 v1.26 Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.26-full-install-windows-installer.exe) (sha1 9c506a493fefb536b152a70400313190e6b7df82)
- [Microchip's XC16 v1.26 OSX installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.26-full-install-osx-installer.dmg) (sha1 099e04d5fb300994b1da4593ca990a23f2a46cd2)
- [Microchip's XC16 v1.26 source archive](http://ww1.microchip.com/downloads/Secure/en/DeviceDoc/MPLAB%20XC16%20v1.26.src.zip) (sha1 88264d55a78cb8d5c13180c3baa4c2bf661c3c2d)

## v1.30

- Supported since: XC16++ revision 2
- [Microchip's XC16 v1.30 Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.30-full-install-linux-installer.run) (sha1 f983c689a3fbd5195308542c9264d3422c0bb955)
- [Microchip's XC16 v1.30 Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.30-full-install-windows-installer.exe) (sha1 3b15ba8b3b2dadf12c554023470990ed2aead29a)
- [Microchip's XC16 v1.30 OSX installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.30-full-install-osx-installer.dmg) (sha1 afa58532143cc1fad5b82a32f8b6329b45a04539)
- [Microchip's XC16 v1.30 source archive](http://ww1.microchip.com/downloads/Secure/en/DeviceDoc/v1.30.src.zip) (sha1 013ae13a574cfe73d1db242cb10e6acfc51fe34b)

## v1.31

- Supported since: XC16++ revision 2
- [Microchip's XC16 v1.31 Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.31-full-install-linux-installer.run) (sha1 76b40af59ed13b018c508971e6665936084d31a8)
- [Microchip's XC16 v1.31 Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.31-full-install-windows-installer.exe) (sha1 26b50ffa5e32cae1cec67875e8ed00668a5c5946)
- [Microchip's XC16 v1.31 OSX installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.31-full-install-osx-installer.dmg) (sha1 65154577aaddec40655d6fb8f8c6bf4a11e60ab1)
- [Microchip's XC16 v1.31 source archive](http://ww1.microchip.com/downloads/Secure/en/DeviceDoc/v1.31.src.zip) (sha1 d9523345d56c3ea955e05365cec27c58f4e5d4e6)

## v1.32

- Supported since: XC16++ revision 2
- [Microchip's XC16 v1.32 Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.32b-full-install-linux-installer.run) (sha1 f9ec383ac58822b0ab8979c24ca9f50c909355a1)
- [Microchip's XC16 v1.32 Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.32b-full-install-windows-installer.exe) (sha1 fc16d8c4b98a4b3f9e714379199a6dda6a198eb7)
- [Microchip's XC16 v1.32 OSX installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.32b-full-install-osx-installer.dmg) (sha1 076270f5955377d40992da7d4dca970c0e95f562)
- [Microchip's XC16 v1.32 source archive](http://ww1.microchip.com/downloads/Secure/en/DeviceDoc/v1.32B.src.zip) (sha1 91debd1ae79211abb43832463adc97015ce90dec)

## v1.33

- Supported since: XC16++ revision 2
- [Microchip's XC16 v1.33 Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.33-full-install-linux-installer.run) (sha1 a415f3923502e7b069a6626cacbe7d2578096ed8)
- [Microchip's XC16 v1.33 Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.33-full-install-windows-installer.exe) (sha1 74778b35c604cf972f58cbe651f9fa69f22c2280)
- [Microchip's XC16 v1.33 OSX installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.33-full-install-osx-installer.dmg) (sha1 6c0e2c962baeb5049d5584ef5d80f119c7f91a43)
- [Microchip's XC16 v1.33 source archive](http://ww1.microchip.com/downloads/Secure/en/DeviceDoc/v1.33.src.zip) (sha1 549c09d204999efaab8b6ce904e7c531f0db384d)

## v1.34

- Supported since: XC16++ revision 2
- [Microchip's XC16 v1.34 Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.34-full-install-linux-installer.run) (sha1 1888e848a7979a07440e7ee0194c70595d6aa2c9)
- [Microchip's XC16 v1.34 Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.34-full-install-windows-installer.exe) (sha1 24bbbbacdcd20a41ffe7dad2e8a62d4e2a992fa3)
- [Microchip's XC16 v1.34 OSX installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.34-full-install-osx-installer.dmg) (sha1 d841aee0c9bb4b0e4a2b83835d31059f1992a3aa)
- [Microchip's XC16 v1.34 source archive](http://ww1.microchip.com/downloads/Secure/en/DeviceDoc/v1.34.src.zip) (sha1 582b33380397c25c351fd3ea1b4fe21ed5e5e588)

## v1.35

- Supported since: XC16++ revision 2
- [Microchip's XC16 v1.35 Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.35-full-install-linux-installer.run) (sha1 97bf3e68b18ffd563c78b1f469786a9701742c86)
- [Microchip's XC16 v1.35 Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.35-full-install-windows-installer.exe) (sha1 240e5c26483f7f2f894d9357e052f284fa84b00e)
- [Microchip's XC16 v1.35 OSX installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.35-full-install-osx-installer.dmg) (sha1 f874a239ab64a4ebc0872d802cc3b25bea70431a)
- [Microchip's XC16 v1.35 source archive](http://ww1.microchip.com/downloads/Secure/en/DeviceDoc/v1.35.src.zip) (sha1 dc94036f3ec30a00c5ab19947e17efcd162405d2)

## v1.36

- Supported since: XC16++ revision 2
- [Microchip's XC16 v1.36 Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.36b-full-install-linux-installer.run) (sha1 8103cca06d65b849c153c39513b1a6df58fa0bf2)
- [Microchip's XC16 v1.36 Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.36b-full-install-windows-installer.exe) (sha1 0f49032de26af810aa90265b6d4385496d5ac7e7)
- [Microchip's XC16 v1.36 OSX installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.36b-full-install-osx-installer.dmg) (sha1 0095ee545343121ed2668cc0899e0d5cfb4d4c0a)
- [Microchip's XC16 v1.36 source archive](http://ww1.microchip.com/downloads/Secure/en/DeviceDoc/v1.36b.src.zip) (sha1 ad44b387b3a5859a8f8755190c427e26b02252f4)

## v1.40

- Supported since: XC16++ revision 2
- [Microchip's XC16 v1.40 Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.40-full-install-linux-installer.run) (sha1 885df4f65840c21dd6b6d6bcab1769e359e4878f)
- [Microchip's XC16 v1.40 Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.40-full-install-windows-installer.exe) (sha1 9c80f99be7da65692ce273dd5523c603b3957ac3)
- [Microchip's XC16 v1.40 OSX installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.40-full-install-osx-installer.dmg) (sha1 e97c1ddfcbf3170a736c4a77dfde54af8c9f9e5a)
- [Microchip's XC16 v1.40 source archive](http://ww1.microchip.com/downloads/Secure/en/DeviceDoc/XC16_v1.40.src.zip) (sha1 2384872681ff62f12ef41ef13c28bce9c297648d)

## v1.41

- Supported since: XC16++ revision 2
- [Microchip's XC16 v1.41 Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.41-full-install-linux-installer.run) (sha1 e3147b74b7e4ccb3960d19da8ec75fb1fc9447d0)
- [Microchip's XC16 v1.41 Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.41-full-install-windows-installer.exe) (sha1 9e3a03fa14ad4ea5fabacf6501f8b227ad1ea422)
- [Microchip's XC16 v1.41 OSX installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.41-full-install-osx-installer.dmg) (sha1 38549a6de160c22beb786f06c1bb28567f35ac8b)
- [Microchip's XC16 v1.41 source archive](http://ww1.microchip.com/downloads/Secure/en/DeviceDoc/v1.41.src.zip) (sha1 ac4d4bbc6bc0941d177d1f35609ff3eecaae38a1)

## v1.49

This XC16 version is a "Functional Safety" release. It requires a special
license from Microchip. The corresponding XC16++ compiler is available but
untested.

- Supported since: XC16++ revision 2
- [Microchip's XC16 v1.49 Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.49-full-install-linux-installer.run) (sha1 3e172ece50a52a6465f340d56cf122745e86b7e5)
- [Microchip's XC16 v1.49 Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.49-full-install-windows-installer.exe) (sha1 35ff8eb0c79407deb9c1498e7c60efc58a849cf7)
- [Microchip's XC16 v1.49 OSX installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.49-full-install-osx-installer.dmg) (sha1 2a3c61470074accad16cc5a369685e84ea485da6)
- [Microchip's XC16 v1.49 source archive](http://ww1.microchip.com/downloads/Secure/en/DeviceDoc/xc16-v1.49.src.zip) (sha1 ad2703fe4e2a8fece05885b50b0d2f960c236138)

## v1.50

This is the first 64-bit XC16 release by Microchip. Starting from this version,
XC16++ executables are compiled in 64-bit mode too.

- Supported since: XC16++ revision 2
- [Microchip's XC16 v1.50 Linux installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.50-full-install-linux64-installer.run) (sha1 5f7c10309d35535b3fce7007a25f01ca0de14094)
- [Microchip's XC16 v1.50 Windows installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.50-full-install-windows64-installer.exe) (sha1 005e264c2bfedcb6bfed5a73dea05bde8eec07fe)
- [Microchip's XC16 v1.50 OSX installer](http://ww1.microchip.com/downloads/en/DeviceDoc/xc16-v1.50-full-install-osx64-installer.dmg) (sha1 c2496a7dbb30a5bc0500903401adea505cfcee3c)
- [Microchip's XC16 v1.50 source archive](http://ww1.microchip.com/downloads/Secure/en/DeviceDoc/xc16-v1.50.src.zip) (sha1 4ec11ae3b01d74709213f867281f1ec2676e5b98)
