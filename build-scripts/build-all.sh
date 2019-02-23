#!/bin/bash
cd "$(dirname "$0")"
set -ex

# Build docker containers with the necessary compilation environment
./build-containers.sh linux win32 osx

# Build all xc16++ variants
./build-targets.sh v1.23 linux win32 osx
./build-targets.sh v1.24 linux win32 osx
./build-targets.sh v1.25 linux win32 osx
