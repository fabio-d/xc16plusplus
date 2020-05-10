#!/bin/bash
cd "$(dirname "$0")"

if [ "$#" -lt 2 ];
then
	echo "Usage: $0 vN.NN os [src-dir]"
	echo "os can be linux, windows or osx"
	echo "Optional src-dir is e.g. /opt/microchip/xc16/v1.00. If not specified, the default one will be assumed"
	exit 1
fi

XC16VER=$1
OS=$2
XC16DIR=$3

case "$OS" in
	linux)
		DEFAULT_XC16DIR='/opt/microchip/xc16/'$XC16VER
		;;
	windows)
		DEFAULT_XC16DIR='"C:\Program Files (x86)\Microchip\xc16\'$XC16VER'"'
		;;
	osx)
		DEFAULT_XC16DIR='/Applications/microchip/xc16/'$XC16VER
		;;
	*)
		echo "Invalid OS"
		exit 1
esac

set -ex
export XZ_OPT=-9

tar cJf xc16-$XC16VER-$OS.tar.xz \
    --owner=0 --group=0 --transform "s|^|$XC16VER/|" \
    -C "${XC16DIR:-$DEFAULT_XC16DIR}" \
    bin/ include/ lib/ support/
