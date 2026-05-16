#!/usr/bin/env bash

export LC_ALL=C

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/.. || exit

DOCKER_IMAGE=${DOCKER_IMAGE:-The-BlackRaven-Endeavor/blackravend-develop}
DOCKER_TAG=${DOCKER_TAG:-latest}

BUILD_DIR=${BUILD_DIR:-.}

rm docker/bin/*
mkdir docker/bin
cp $BUILD_DIR/src/blackravend docker/bin/
cp $BUILD_DIR/src/blackraven-cli docker/bin/
cp $BUILD_DIR/src/blackraven-tx docker/bin/
strip docker/bin/blackravend
strip docker/bin/blackraven-cli
strip docker/bin/blackraven-tx

docker build --pull -t $DOCKER_IMAGE:$DOCKER_TAG -f docker/Dockerfile docker
