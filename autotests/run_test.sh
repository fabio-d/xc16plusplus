#!/bin/sh
# Given a subfolder name, run the test contained in it, by compiling all .c/.cpp
# files, running the program in the simulator and comparing the output against
# the expected_output.txt file.
# If a target_override.txt file is present, it must contain values for the
# TARGET_CHIP, TARGET_FAMILY and SIM30_DEVICE environemnt variables.
# If target_override.txt is not present, the following default values are
# assumed:
#   TARGET_CHIP=30F5016
#   TARGET_FAMILY=dsPIC30F
#   SIM30_DEVICE=dspic30super

cd "$(cd "$(dirname "$0")" && pwd)"

STDERR=/dev/stderr
STDOUT=$(mktemp -t run_test.XXXXXXX)
trap "rm '$STDOUT'" exit

# quiet command line switch: do not propagate compile_and_sim30.sh's stderr
if [ "$1" == "-q" ];
then
	STDERR=/dev/null
	shift
fi

if [ "$1" == "" ];
then
	echo "Usage: $0 [-q] subdirectory-name" >&2
	exit 1
fi

if [ -f "$1/target_override.txt" ];
then
	. "$1/target_override.txt"
else
	TARGET_CHIP=30F5016
	TARGET_FAMILY=dsPIC30F
	SIM30_DEVICE=dspic30super
fi

export TARGET_CHIP TARGET_FAMILY SIM30_DEVICE

find "$1" -name '*.c' -or -name '*.cpp' | xargs \
	./compile_and_sim30.sh >$STDOUT 2>$STDERR

if diff "$STDOUT" "$1/expected_output.txt";
then
	echo "Test $1 passed" >&2
	exit 0
else
	echo "Test $1 failed" >&2
	exit 1
fi
