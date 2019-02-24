#!/bin/bash
cd "$(dirname "$0")"

declare -A MCHPTARBALLS
declare -A TOPLEVELDIRS
MCHPTARBALLS["v1.23"]='xc16-v1.23-src.zip'
TOPLEVELDIRS["v1.23"]='v1.23_src_archive'
MCHPTARBALLS["v1.24"]='xc16-v1.24-src.zip'
TOPLEVELDIRS["v1.24"]='v1.24.src'
MCHPTARBALLS["v1.25"]='v1.25.src.zip'
TOPLEVELDIRS["v1.25"]='v1.25.src'
MCHPTARBALLS["v1.26"]='MPLAB XC16 v1.26.src.zip'
TOPLEVELDIRS["v1.26"]='v1.26.src'

XC16_VERSION=$1
shift

set -ex

# Create build directory
mkdir "build-$XC16_VERSION"
cd "build-$XC16_VERSION"

# Extract source code
unzip "../tarballs/${MCHPTARBALLS[$XC16_VERSION]}"
cd "${TOPLEVELDIRS[$XC16_VERSION]}"

# Apply xc16++ patches
cat "../../../$XC16_VERSION"/*.patch | patch -p1

# Read xc16++ version
XC16PLUSPLUS_VERSION=$(sed -n 's/.*XC16PLUSPLUS_VERSION=\(v[^ ]*\).*/\1/p' src_build.sh)

for TARGET_OS in $*;
do
	INSTALL_DIR="$(pwd)"/install-"$TARGET_OS"
	RELEASE_DIRNAME="x16plusplus-$XC16PLUSPLUS_VERSION-$TARGET_OS-$XC16_VERSION"

	# Compile xc16++ executables
	docker run --tty --rm --user=$(id -u):$(id -g) \
		--volume="$(pwd)":/xc16plusplus-build \
		--workdir=/xc16plusplus-build \
		xc16plusplus-build:"$TARGET_OS" \
		bash ./xc16plusplus_only.sh "$TARGET_OS"

	# Fill $RELEASE_DIRNAME directory
	mkdir "../$RELEASE_DIRNAME"
	pushd "../$RELEASE_DIRNAME"
	cp -r --target-directory=. \
		"$INSTALL_DIR"/bin/ \
		../../../LICENSE-GPL3 \
		../../../LICENSE-UNLICENSE \
		../../../README.md \
		../../../example-project/ \
		../../../support-files/

	# Set XC16 version in the XC16DIR path, uncomment the line corresponding
	# to the target OS
	case $TARGET_OS in
		linux)
			OSFOLDERPATTERN=opt
			;;
		osx)
			OSFOLDERPATTERN=Applications
			;;
		win32)
			OSFOLDERPATTERN=Program
			;;
	esac
	sed \
		-e "s,^#\?\(XC16DIR :=.*[/\\]\)v[0-9]\.[0-9]*,#\1$XC16_VERSION," \
		-e "s,#\(XC16DIR :=.*$OSFOLDERPATTERN\),\1," \
		-i example-project/Makefile

	# Create other customized files and, finally, a tar.gz/zip package
	if [ "$TARGET_OS" == "win32" ];
	then
		# Customize version number in create_xc16plusplus_symlinks.cmd
		sed "s,\(C:\\\\Program.*\)\\\\v[0-9]\.[0-9]*\\\\bin,\1\\\\$XC16_VERSION\\\\bin," \
			../../create_xc16plusplus_symlinks.cmd > bin/create_xc16plusplus_symlinks.cmd

		# Convert text files to DOS line endings
		unix2dos LICENSE-GPL3 LICENSE-UNLICENSE README.md \
			bin/create_xc16plusplus_symlinks.cmd \
			example-project/* support-files/*

		zip -r9X "../$RELEASE_DIRNAME.zip" *
	else
		# Create symbolic links
		ln -s xc16-cc1 bin/xc16-cc1plus
		ln -s xc16-gcc bin/xc16-g++
		ln -s coff-pa bin/bin/coff-paplus
		ln -s elf-pa bin/bin/elf-paplus

		cd ..
		GZIP=-9 tar zcvf "$RELEASE_DIRNAME.tar.gz" \
			--format=pax --mode='g-w,o-w' \
			--owner=0 --group=0 "$RELEASE_DIRNAME"
	fi

	popd
done
