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
./build-container.sh windows-build
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
./build-targets.sh v1.00 linux windows osx
./build-targets.sh v1.10 linux windows osx
./build-targets.sh v1.11 linux windows osx
./build-targets.sh v1.20 linux windows osx
./build-targets.sh v1.21 linux windows osx
./build-targets.sh v1.22 linux windows osx
./build-targets.sh v1.23 linux windows osx
./build-targets.sh v1.24 linux windows osx
./build-targets.sh v1.25 linux windows osx
./build-targets.sh v1.26 linux windows osx
./build-targets.sh v1.30 linux windows osx
./build-targets.sh v1.31 linux windows osx
./build-targets.sh v1.32 linux windows osx
./build-targets.sh v1.33 linux windows osx
./build-targets.sh v1.34 linux windows osx
./build-targets.sh v1.35 linux windows osx
./build-targets.sh v1.36 linux windows osx
./build-targets.sh v1.40 linux windows osx
./build-targets.sh v1.41 linux windows osx
./build-targets.sh v1.49 linux windows osx
./build-targets.sh v1.50 linux windows osx

# Test Linux variants (only Linux builds can be tested in docker at the moment)
#
# Note: xc16-vN.NN-OS.tar.xz archives must be present in advance! Install XC16
# and use the pack-xc16-binaries.sh tool to build them.
#
# Note 2: the fourth parameter points to a file produced by the corresponding
# invocation of build-targets in the previous step. We use a wildcard in place
# of the revision number, so that this script does not need to be edited at
# every new revision.
#
# Note 3: v1.49 is a "Functional Safety" release whose XC16 executables will not
# run without a specific license.
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
./test-in-container.sh v1.30 linux xc16-v1.30-linux.tar.xz build-v1.30/xc16plusplus-v1.30r*-linux.tar.gz
./test-in-container.sh v1.31 linux xc16-v1.31-linux.tar.xz build-v1.31/xc16plusplus-v1.31r*-linux.tar.gz
./test-in-container.sh v1.32 linux xc16-v1.32-linux.tar.xz build-v1.32/xc16plusplus-v1.32r*-linux.tar.gz
./test-in-container.sh v1.34 linux xc16-v1.34-linux.tar.xz build-v1.34/xc16plusplus-v1.34r*-linux.tar.gz
./test-in-container.sh v1.35 linux xc16-v1.35-linux.tar.xz build-v1.35/xc16plusplus-v1.35r*-linux.tar.gz
./test-in-container.sh v1.36 linux xc16-v1.36-linux.tar.xz build-v1.36/xc16plusplus-v1.36r*-linux.tar.gz
./test-in-container.sh v1.40 linux xc16-v1.40-linux.tar.xz build-v1.40/xc16plusplus-v1.40r*-linux.tar.gz
./test-in-container.sh v1.41 linux xc16-v1.41-linux.tar.xz build-v1.41/xc16plusplus-v1.41r*-linux.tar.gz
#./test-in-container.sh v1.49 linux xc16-v1.49-linux.tar.xz build-v1.49/xc16plusplus-v1.49r*-linux.tar.gz
./test-in-container.sh v1.50 linux xc16-v1.50-linux.tar.xz build-v1.50/xc16plusplus-v1.50r*-linux.tar.gz
