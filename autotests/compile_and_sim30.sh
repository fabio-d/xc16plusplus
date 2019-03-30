#!/bin/sh
# Run a C/C++ program inside the sim30 simulator shipped with XC16
#   Usage: ./compile_and_sim30.sh <source-files...>
# If at least one C++ file is present, C++ support files are automatically
# linked in too.
# The XC16DIR and XC16VER environment variables must be set, e.g.
#   XC16DIR=/opt/microchip/xc16/v1.23
#   XC16VER=v1.23

function to_native_path()
{
	if uname | grep -q CYGWIN;
	then
		cygpath -w "$1"
	else
		echo "$1"
	fi
}

# Tests whether the current XC16 version is equal or newer than the specified one
# e.g. XC16VER=v1.23 xc16ver_ge v1.22 -> true
function xc16ver_ge()
{
	CURRENT_MAJOR=$(echo "$XC16VER" | cut -d. -f1 | tr -d v)
	CURRENT_MINOR=$(echo "$XC16VER" | cut -d. -f2)
	TEST_MAJOR=$(echo "$1" | cut -d. -f1 | tr -d v)
	TEST_MINOR=$(echo "$1" | cut -d. -f2)

	if [ $CURRENT_MAJOR -eq $TEST_MAJOR ];
	then
		[ $CURRENT_MINOR -ge $TEST_MINOR ]
	else
		[ $CURRENT_MAJOR -ge $TEST_MAJOR ]
	fi
}

THISDIR="$(cd "$(dirname "$0")" && pwd)"
EXAMPLEPROJECTDIR="$(to_native_path "$THISDIR/../example-project")"

if [ "$XC16DIR" == "" ];
then
	echo "Error: \$XC16DIR is not set!" >&2
	exit 1
fi

if [ "$XC16VER" == "" ];
then
	echo "Error: \$XC16VER is not set!" >&2
	exit 1
fi

if [ "$TARGET_CHIP" == "" ];
then
	echo "Error: \$TARGET_CHIP is not set!" >&2
	exit 1
fi

if [ "$TARGET_FAMILY" == "" ];
then
	echo "Error: \$TARGET_FAMILY is not set!" >&2
	exit 1
fi

if [ "$SIM30_DEVICE" == "" ];
then
	echo "Error: \$SIM30_DEVICE is not set!" >&2
	exit 1
fi

if [ "$OMF" != "coff" ] && [ "$OMF" != "elf" ];
then
	echo "Error: \$OMF is not set or it is neither \"coff\" nor \"elf\"!" >&2
	exit 1
fi

CFLAGS=()
CXXFLAGS=()
LDFLAGS=()

if xc16ver_ge v1.20;
then
	CFLAGS+=(-mno-eds-warn)
	LDFLAGS+=(--local-stack)
fi

if xc16ver_ge v1.25;
then
	CFLAGS+=(-no-legacy-libc)
fi

CFLAGS+=(-omf=$OMF -mcpu="$TARGET_CHIP")
CXXFLAGS+=("${CFLAGS[@]}" -fno-exceptions -fno-rtti -D__bool_true_and_false_are_defined -std=gnu++0x)
LDSCRIPT="$XC16DIR/support/$TARGET_FAMILY/gld/p$TARGET_CHIP.gld"
LDFLAGS+=(-omf=$OMF -p"$TARGET_CHIP" --report-mem --script "$LDSCRIPT" --heap=512 -L"$XC16DIR/lib" -L"$XC16DIR/lib/$TARGET_FAMILY")
LIBS=(-lc -lpic30 -lm)

function __verboserun()
{
	echo "+ $@" >&2
	"$@"
}

set -e
TEMPDIR=$(mktemp -d -t compile_and_sim30.XXXXXXX)
trap "rm -rf '$TEMPDIR'" exit

declare -a OBJFILES
CXX_SUPPORT_FILES=false

for SRCFILE in "$@";
do
	case "$SRCFILE" in
		*.c)
			__verboserun "$XC16DIR/bin/xc16-gcc" "${CFLAGS[@]}" \
				-c -o "$(to_native_path "$TEMPDIR/$SRCFILE.o")" \
					"$(to_native_path "$SRCFILE")"
			OBJFILES+=("$(to_native_path "$TEMPDIR/$SRCFILE.o")")
			;;
		*.cpp)
			if ! $CXX_SUPPORT_FILES;
			then
				CXX_SUPPORT_FILES=true
				__verboserun "$XC16DIR/bin/xc16-g++" \
					"${CXXFLAGS[@]}" -c -o \
					"$(to_native_path "$TEMPDIR/minilibstdc++.o")" \
					"$(to_native_path "$EXAMPLEPROJECTDIR/minilibstdc++.cpp")"
				OBJFILES+=("$(to_native_path "$TEMPDIR/minilibstdc++.o")")
			fi
			mkdir -p "$(dirname "$TEMPDIR/$SRCFILE.o")"
			__verboserun "$XC16DIR/bin/xc16-g++" "${CXXFLAGS[@]}" \
				-c -o "$(to_native_path "$TEMPDIR/$SRCFILE.o")" \
					"$(to_native_path "$SRCFILE")"
			OBJFILES+=("$(to_native_path "$TEMPDIR/$SRCFILE.o")")
			;;
	esac
done

__verboserun "$XC16DIR/bin/xc16-ld" "${LDFLAGS[@]}" \
	-o "$(to_native_path "$TEMPDIR/result.elf")" \
	"${OBJFILES[@]}" "${LIBS[@]}" \
	--save-gld="$(to_native_path "$TEMPDIR/gld")" >&2
__verboserun "$XC16DIR/bin/xc16-bin2hex" -omf=$OMF "$(to_native_path "$TEMPDIR/result.elf")"

cat > "$TEMPDIR/sim30-script" << EOF
ld $SIM30_DEVICE
lp $(to_native_path "$TEMPDIR/result.hex")
rp
io nul $(to_native_path "$TEMPDIR/output.txt")
e
q
EOF

set +e
__verboserun perl -e 'alarm 10; exec @ARGV' "$XC16DIR/bin/sim30" \
	"$(to_native_path "$TEMPDIR/sim30-script")" >&2
case "$?" in
	0)
		echo "sim30 succeeded!" >&2

		# Normalize line endings when running on windows
		sed 's/\r\r$/\r/' "$TEMPDIR/output.txt"
		;;
	142)
		echo "Simulation timed out (killed after 10 seconds)"
		exit 1
		;;
	*)
		exit 1
		;;
esac
