#!/bin/bash
if [ "$#" -ne 2 ];
then
	echo "This is an auxiliary script, called by test-in-container.sh within the container"
	echo "It is NOT meant to be invoked directly"
	exit 1
fi

XC16VER=$1
OS=$2
XC16PKG="$(echo /xc16plusplus-test/binaries-xc16/*)"
XC16PLUSPLUSPKG="$(echo /xc16plusplus-test/binaries-xc16plusplus/*)"

echo "Initializing WINE..."
export WINEPREFIX=/wine/prefix
mkdir $WINEPREFIX && wineboot

echo "Installing compiler..."

# XC16
mkdir -p $WINEPREFIX/drive_c/Program\ Files\ \(x86\)/Microchip/xc16/$XC16VER
cd $WINEPREFIX/drive_c/Program\ Files\ \(x86\)/Microchip/xc16/$XC16VER
tar xJf "$XC16PKG" --strip-components=1

# XC16++
unzip "$XC16PLUSPLUSPKG" 'bin/bin/*.exe' bin/create_xc16plusplus_symlinks.cmd
cd bin && wine cmd /c create_xc16plusplus_symlinks.cmd nopause

echo "Compiling tests..."

cd /xc16plusplus-test/autotests

# For some reason the current directory is not automatically added to python's
# search path. That is, instead of simply running
#  Z:\\python\\python.exe -m testrun
# we need the following workaround:
wine "Z:\\python\\python.exe" -uc 'import sys,os; sys.path.append(os.getcwd()); import testrun.__main__' \
	compile "C:\\Program Files (x86)\\Microchip\\xc16\\$XC16VER" -o ../output-bundle.zip
