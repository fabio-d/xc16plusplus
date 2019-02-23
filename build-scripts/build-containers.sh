#!/bin/bash
cd "$(dirname "$0")/dockerfiles"
set -ex

docker build . -t xc16plusplus-build:linux -f Dockerfile.linux
docker build . -t xc16plusplus-build:win32 -f Dockerfile.win32
docker build . -t xc16plusplus-build:osx -f Dockerfile.osx
