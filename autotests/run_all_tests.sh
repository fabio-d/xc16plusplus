#!/bin/bash

# Usage: ./run_all_tests.sh [-j [N]] [-k] [/path/to/xc16/vX.YY ...]
#  > -j N and -k are passed as-is to make
#  > remaining arguments are interpret as paths to XC16++ installations to be tested

cd "$(dirname "$0")"

function run_make_test()
{
	echo "Running $OMF tests on $XC16DIR" >&2
	make "${MAKEARGS[@]}"
}

# Extract XC16 version from path (e.g. /opt/microchip/xc16/v1.23/ -> v1.23)
function version_from_path()
{
	VER="$(echo "$1" | sed -n 's|^.*[\\/]v\([0-9][0-9]*\.[0-9][0-9]*\)[^0-9]*$|\1|p')"
	if [ "$VER" == "" ];
	then
		echo "Failed to deduce XC16 version from path: $1" >&2
		exit 1
	fi

	echo v"$VER"
}

# Parse command-line arguments

MAKEARGS=(-s)
XC16PATHS=()

while [ "$#" != "0" ];
do
	case "$1" in
		-j|--jobs)
			if [ "$#" != "1" ];
			then
				MAKEARGS+=("$1" "$2")
			else
				MAKEARGS+=("$1")
			fi

			shift # consume two arguments
			;;
		-j*|--jobs*)
			MAKEARGS+=("$1")
			;;
		-k|--keep-going)
			MAKEARGS+=("$1")
			;;
		*)
			XC16PATHS+=("$1")
			;;
	esac

	shift
done

# If no XC16++ installation paths were specified, search in the default paths
if [ "${#XC16PATHS[@]}" == "0" ];
then
	if [ "$(uname)" == "Linux" ];
	then
		XC16BASEDIR=/opt/microchip/xc16
	elif [ "$(uname)" == "Darwin" ];
	then
		XC16BASEDIR=/Applications/microchip/xc16
	elif uname | grep -q CYGWIN;
	then
		XC16BASEDIR="C:\\Program Files\\Microchip\\xc16"
	else
		echo "Unsupported OS" >&2
		exit
	fi

	XC16PATHS=("$XC16BASEDIR"/*)
fi

# Run tests
echo "MAKEARGS=\"${MAKEARGS[@]}\"" >&2

SUCCESS_COUNTER=0
for XC16DIR in "${XC16PATHS[@]}";
do
	XC16VER=$(version_from_path "$XC16DIR") || continue
	echo "== $XC16DIR (version $XC16VER) ==" >&2

	export XC16DIR XC16VER
	OMF=coff run_make_test >&2 && SUCCESS_COUNTER=$((SUCCESS_COUNTER+1))
	OMF=elf run_make_test >&2 && SUCCESS_COUNTER=$((SUCCESS_COUNTER+1))
done

if [ "$SUCCESS_COUNTER" != "$((2*${#XC16PATHS[@]}))" ];
then
	echo "One or more tests failed" >&2
	exit 1
else
	echo "No failed tests" >&2
	exit 0
fi
