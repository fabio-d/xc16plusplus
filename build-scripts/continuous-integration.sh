#!/bin/bash

# This file is equivalent to the CI workflow that runs on GitHub.
# It can be used to compile XC16++ locally.

cd "$(dirname "$0")"
set -ex

# Build docker containers with the necessary compilation environment
./build-container.sh linux-build
./build-container.sh win32-build
./build-container.sh osx-build

# Build all XC16++ variants
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
