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

echo "Installing compiler..."

# XC16
mkdir -p /opt/microchip/xc16/$XC16VER
cd /opt/microchip/xc16/$XC16VER
tar xJf "$XC16PKG" --strip-components=1

# XC16++
mkdir xc16plusplus-tmp
tar xzf "$XC16PLUSPLUSPKG" --strip-components=1 -C xc16plusplus-tmp
cd xc16plusplus-tmp/bin
mv xc16-cc1plus xc16-g++ -t ../../bin
mv bin/* -t ../../bin/bin
cd ../../
rm -rf xc16plusplus-tmp

echo "Compiling tests..."

cd /xc16plusplus-test/autotests
python3 -um testrun compile /opt/microchip/xc16/$XC16VER -o ../output-bundle.zip
