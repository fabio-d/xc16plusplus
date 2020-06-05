#!/bin/bash

if [ "$#" -le 1 ];
then
	echo "Usage: $0 output-report.zip test-bundle-1.zip [test-bundle-2.zip ...]" >&2
	exit 1
fi

set -e

# Resolve absolute path of output file
OUTPUT_FILE="$(realpath "$1")"
shift

# Resolve paths received in the arguments, and store their basename as the key
# and absolute path as the value.
declare -A MAPPED_FILES
for ARG in "$@";
do
	if [ ! -f "$ARG" ];
	then
		echo "Not a file (or non-existing) path: $ARG" >&2
		exit 1
	fi

	BASENAME="$(basename "$ARG")"
	if [ "${MAPPED_FILES["$BASENAME"]+_}" ];
	then
		echo "Cannot map multiple times: $BASENAME" >&2
		exit 1
	fi

	ABSPATH="$(realpath -e "$ARG")"
	MAPPED_FILES["$BASENAME"]="$ABSPATH"
done

# Generate a list of --volume docker options to map files into /input-bundles.
# The "--volume=..." directive is stored as the key, the target path within the
# container as the value.
declare -A VOLUME_OPTS
for BASENAME in "${!MAPPED_FILES[@]}";
do
	DIRECTIVE=--volume="${MAPPED_FILES["$BASENAME"]}":"/input-bundles/$BASENAME":ro
	VOLUME_OPTS["$DIRECTIVE"]="/input-bundles/$BASENAME"
done

cd "$(dirname "$0")"
set -x

TMPDIR="$(mktemp -d)"
trap "rm -rf $TMPDIR" exit

# We have to set the initial working directory to /tmp because that will be set
# as the home directory, and mbd needs a writable home.
docker run --tty --rm --user=$(id -u):$(id -g) \
	--volume="$PWD"/..:/xc16plusplus:ro \
	--volume="$TMPDIR":/output-dir \
	"${!VOLUME_OPTS[@]}" \
	-w /tmp \
	xc16plusplus:all-test-validate \
	sh -c 'cd /xc16plusplus/autotests && python3 -um testrun validate /opt/microchip/mplabx/v5.40 "$@"' --  --output "/output-dir/report.zip" "${VOLUME_OPTS[@]}"

cp -v "$TMPDIR/report.zip" "$OUTPUT_FILE"
