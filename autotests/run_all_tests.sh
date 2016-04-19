#!/bin/sh
MAKEARGS=("$@")

function run_make_test()
{
	echo "Running $OMF tests on $XC16DIR"
	make "${MAKEARGS[@]}"
}

if [ "$(uname)" == "Linux" ];
then
	XC16BASEDIR=/opt/microchip/xc16
elif [ "$(uname)" == "Darwin" ];
then
	XC16BASEDIR=/Applications/microchip/xc16
elif uname | grep -q CYGWIN;
then
	XC16BASEDIR="C:\\Program Files (x86)\\Microchip\\xc16"
else
	echo "Unsupported OS"
	exit
fi

export XC16DIR="$XC16BASEDIR/v1.23"
OMF=coff run_make_test
OMF=elf run_make_test

export XC16DIR="$XC16BASEDIR/v1.24"
OMF=coff run_make_test
OMF=elf run_make_test

export XC16DIR="$XC16BASEDIR/v1.25"
OMF=coff run_make_test
OMF=elf run_make_test
