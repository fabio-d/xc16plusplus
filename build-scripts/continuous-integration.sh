#!/bin/bash

# This file is equivalent to the CI workflow that runs on GitHub.
#
# While it can be used to fully compile XC16++ locally (it will take really
# long), it is meant to be used as a guidance on how to build specific XC16++
# variants.
#
# The actual CI GitHub workflow can be found in .github/workflows/.

cd "$(dirname "$0")"
set -ex

# Build docker containers with the necessary compilation environment
# If you don't need to build for all platforms, you can skip the non-
# relevant ones.
#
./build-container.sh linux-build
./build-container.sh win32-build
./build-container.sh osx-build
./build-container.sh linux-test

# Build all XC16++ variants
#
# Again, you can skip the non-relevant versions and OS.
#
# Note: The target version must always be the first argument; the other
# arguments can be omitted or specified in any order depending on the
# desired target operating system(s).
#
./build-targets.sh v1.00 linux win32 osx
./build-targets.sh v1.10 linux win32 osx
./build-targets.sh v1.11 linux win32 osx
./build-targets.sh v1.20 linux win32 osx
./build-targets.sh v1.21 linux win32 osx
./build-targets.sh v1.22 linux win32 osx
./build-targets.sh v1.23 linux win32 osx
./build-targets.sh v1.24 linux win32 osx
./build-targets.sh v1.25 linux win32 osx
./build-targets.sh v1.26 linux win32 osx

# Test Linux variants (only Linxu builds can be tested in docker at the moment)
#
# Note: xc16-vN.NN-OS.tar.xz archives must be present in advance! Install XC16
# and use the pack-xc16-binaries.sh tool to build them.
#
# Note 2: the fourth parameter points to a file produced by the corresponding
# invocation of build-targets in the previous step. We use a wildcard in place
# of the revision number, so that this script does not need to be edited at
# every new revision.
#
./test-in-container.sh v1.00 linux xc16-v1.00-linux.tar.xz build-v1.00/xc16plusplus-v1.00r*-linux.tar.gz
./test-in-container.sh v1.10 linux xc16-v1.10-linux.tar.xz build-v1.10/xc16plusplus-v1.10r*-linux.tar.gz
./test-in-container.sh v1.11 linux xc16-v1.11-linux.tar.xz build-v1.11/xc16plusplus-v1.11r*-linux.tar.gz
./test-in-container.sh v1.20 linux xc16-v1.20-linux.tar.xz build-v1.20/xc16plusplus-v1.20r*-linux.tar.gz
./test-in-container.sh v1.21 linux xc16-v1.21-linux.tar.xz build-v1.21/xc16plusplus-v1.21r*-linux.tar.gz
./test-in-container.sh v1.22 linux xc16-v1.22-linux.tar.xz build-v1.22/xc16plusplus-v1.22r*-linux.tar.gz
./test-in-container.sh v1.23 linux xc16-v1.23-linux.tar.xz build-v1.23/xc16plusplus-v1.23r*-linux.tar.gz
./test-in-container.sh v1.24 linux xc16-v1.24-linux.tar.xz build-v1.24/xc16plusplus-v1.24r*-linux.tar.gz
./test-in-container.sh v1.25 linux xc16-v1.25-linux.tar.xz build-v1.25/xc16plusplus-v1.25r*-linux.tar.gz
./test-in-container.sh v1.26 linux xc16-v1.26-linux.tar.xz build-v1.26/xc16plusplus-v1.26r*-linux.tar.gz
