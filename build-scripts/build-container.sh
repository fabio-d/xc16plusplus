#!/bin/bash
cd "$(dirname "$0")/containers"
set -ex

if [ "$#" -ne 1 ];
then
	echo "Usage: $0 image-name"
	echo "image-name must be the name of a Dockerfile without .Dockerfile extension"
	exit 1
fi

IMAGE_NAME=$1
docker build -t xc16plusplus:$IMAGE_NAME - < $IMAGE_NAME.Dockerfile
