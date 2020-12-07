#!/usr/bin/env bash
DEFAULT_WS=${HOME}/workspace
if [ -z "$1" ]
then
    WORKSPACE=$DEFAULT_WS
else 
    WORKSPACE=$1
fi

if [ ! -d "$WORKSPACE" ] 
then
    echo "Workspace directory does not exist: $WORKSPACE."
    echo "Consider ruinning: run-bootstrap.sh <PATH>"
    exit 1
fi

docker run --rm -it \
    -v ${WORKSPACE}:/data \
    -v ${HOME}/.local/pidev/:/home/user/.conan/data \
    pidev/raspberrypi3-debian-core-bootstrap:jessie \
    bash