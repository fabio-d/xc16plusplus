#!/bin/bash

# Tests whether the current XC16 version is equal or newer than the specified one
# e.g. $XC16_VERSION=v1.23 xc16ver_ge v1.22 -> true
function xc16ver_ge()
{
	CURRENT_MAJOR=$(echo "$XC16_VERSION" | cut -d. -f1 | tr -d v)
	CURRENT_MINOR=$(echo "$XC16_VERSION" | cut -d. -f2)
	TEST_MAJOR=$(echo "$1" | cut -d. -f1 | tr -d v)
	TEST_MINOR=$(echo "$1" | cut -d. -f2)

	if [ $CURRENT_MAJOR -eq $TEST_MAJOR ];
	then
		[ $CURRENT_MINOR -ge $TEST_MINOR ]
	else
		[ $CURRENT_MAJOR -ge $TEST_MAJOR ]
	fi
}

cd "$(dirname "$0")"

if [ "$#" -le 1 ];
then
	echo "Usage: $0 vN.NN target1 [target2 [target3]]"
	echo "targetN can be linux, windows or osx"
	exit 1
fi

# Path to the "xc16plusplus-source" repository.
# This can also be overridden and set to a local path. For example:
#  export XC16PLUSPLUS_SOURCE_REPO=/path/to/xc16plusplus-source
if [ -z "$XC16PLUSPLUS_SOURCE_REPO" ];
then
	export XC16PLUSPLUS_SOURCE_REPO="git@github.com:fabio-d/xc16plusplus-source"
fi

XC16_VERSION=$1
shift

set -ex

# Create build directory
mkdir "build-$XC16_VERSION"
cd "build-$XC16_VERSION"

# Download source code
git clone "$XC16PLUSPLUS_SOURCE_REPO" src --depth 1 -b "xc16++-$XC16_VERSION"
cd src

# Read XC16++ revision
XC16PLUSPLUS_REVISION=r$(sed -n 's/^XC16PLUSPLUS_REVISION=\([0-9]*\).*/\1/p' build_xc16plusplus.sh)

for TARGET_OS in $*;
do
	if [ "$XC16_VERSION" == "v1.50" ];
	then
		TARGET_OS_WITH_BITS="$TARGET_OS"64
	else
		TARGET_OS_WITH_BITS="$TARGET_OS"32
	fi

	INSTALL_DIR="$(pwd)"/install-"$TARGET_OS_WITH_BITS"
	RELEASE_DIRNAME="xc16plusplus-$XC16_VERSION$XC16PLUSPLUS_REVISION-$TARGET_OS"

	# Compile XC16++ executables
	docker run --net=none --rm --user=$(id -u):$(id -g) \
		--volume="$(pwd)":/xc16plusplus-build \
		--workdir=/xc16plusplus-build \
		xc16plusplus:"$TARGET_OS-build" \
		bash ./build_xc16plusplus.sh "$TARGET_OS_WITH_BITS"

	# Fill $RELEASE_DIRNAME directory
	mkdir "../$RELEASE_DIRNAME"
	pushd "../$RELEASE_DIRNAME"
	cp -r --target-directory=. \
		"$INSTALL_DIR"/bin/ \
		../../../LICENSE-GPL3.txt \
		../../../LICENSE-UNLICENSE.txt \
		../../../README.md \
		../../../example-project/

	# Run and remove the Makefile-generator.sh script
	example-project/Makefile-generator.sh $XC16_VERSION \
		$TARGET_OS > example-project/Makefile
	rm example-project/Makefile-generator.sh

	# Create other customized files and, finally, a tar.gz/zip package
	if [ "$TARGET_OS" == "windows" ];
	then
		# Customize version number in create_xc16plusplus_symlinks.cmd
		sed "s,\(C:\\\\Program.*\)\\\\v[0-9]\.[0-9]*\\\\bin,\1\\\\$XC16_VERSION\\\\bin," \
			../../create_xc16plusplus_symlinks.cmd > bin/create_xc16plusplus_symlinks.cmd

		if xc16ver_ge "v2.00";
		then
			grep -F -v "@if %success% equ 1 call:createcopy \"coff-pa.exe\" \"coff-paplus.exe\"" \
				bin/create_xc16plusplus_symlinks.cmd > bin/create_xc16plusplus_symlinks.cmd_tmp
			mv bin/create_xc16plusplus_symlinks.cmd_tmp bin/create_xc16plusplus_symlinks.cmd
		fi

		# Convert text files to DOS line endings
		unix2dos LICENSE-GPL3.txt LICENSE-UNLICENSE.txt README.md \
			bin/create_xc16plusplus_symlinks.cmd \
			example-project/*

		zip -r9X "../$RELEASE_DIRNAME.zip" *
	else
		# Create symbolic links
		ln -s xc16-cc1 bin/xc16-cc1plus
		ln -s xc16-gcc bin/xc16-g++
		if ! xc16ver_ge "v2.00";
		then
			ln -s coff-pa bin/bin/coff-paplus
		fi
		ln -s elf-pa bin/bin/elf-paplus

		cd ..
		GZIP=-9 tar zcvf "$RELEASE_DIRNAME.tar.gz" \
			--format=pax --mode='g-w,o-w' \
			--owner=0 --group=0 "$RELEASE_DIRNAME"
	fi

	popd

	# Remove temporary $RELEASE_DIRNAME directory
	rm -rf "../$RELEASE_DIRNAME"
done

# Remove build files
cd .. && rm -rf src
