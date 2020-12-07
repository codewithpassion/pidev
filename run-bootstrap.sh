#!/usr/bin/env bash
DEFAULT_WS=${HOME}/devel
if [ -z "$1" ]
then
    WORKSPACE=$DEFAULT_WS
else 
    WORKSPACE=$1
fi

docker run --rm -it \
    -v ${WORKSPACE}:/data \
    -v ${HOME}/.local/pidev/:/home/user/.conan/data \
    pidev/raspberrypi3-debian-core-bootstrap:jessie \
    bash