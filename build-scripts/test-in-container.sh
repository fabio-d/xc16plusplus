#!/bin/bash

if [ "$#" -lt 2 ];
then
	echo "Usage: $0 vN.NN OS xc16-vN.NN-OS.tar.xz xc16plusplus-vN.NNrXX-OS"
	echo "OS can be linux, windows or osx"
	echo "xc16-vN.NN-OS.tar.xz is an archive produced by the pack-xc16-binaries.sh tool"
	echo "xc16plusplus-vN.NNrXX-OS.tar.gz/.zip is a XC16++ package build by the build-targets.sh tool"
	exit 1
fi

XC16VER=$1
OS=$2

set -ex

TMPDIR="$(mktemp -d)"
trap "rm -rf $TMPDIR" exit

mkdir -p "$TMPDIR/binaries-xc16" "$TMPDIR/binaries-xc16plusplus"
cp "$3" -t "$TMPDIR/binaries-xc16"
cp "$4" -t "$TMPDIR/binaries-xc16plusplus"

cd "$(dirname "$0")"

case "$OS" in
	linux)
		XC16DIR='/opt/microchip/xc16/'$XC16VER
		cp "$PWD/test-in-container-linux-helper.sh" "$TMPDIR/helper.sh"
		;;
	windows)
		echo Testing windows target is not supported yet && exit 1
		XC16DIR='"C:\Program Files (x86)\Microchip\xc16\'$XC16VER'"'
		cp "$PWD/test-in-container-windows-helper.sh" "$TMPDIR/helper.sh"
		;;
	osx)
		echo Testing osx target is not supported yet && exit 1
		XC16DIR='/Applications/microchip/xc16/'$XC16VER
		cp "$PWD/test-in-container-osx-helper.sh" "$TMPDIR/helper.sh"
		;;
	*)
		echo "Invalid OS"
		exit 1
esac

cp -r "../autotests" "../example-project" -t "$TMPDIR"

docker run --tty --rm --user=$(id -u):$(id -g) \
	--volume="$TMPDIR":/xc16plusplus-test \
	xc16plusplus:$OS-test \
	/xc16plusplus-test/helper.sh $XC16VER $OS
