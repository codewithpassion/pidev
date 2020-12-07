#!/usr/bin/env bash

# Default settings
DOCKER_COMMAND="docker"
NETWORK_CONFIG="bridge"
IMAGE_NAME="pidev/amd64-ubuntu-core:bionic"

# Default args
EXTRA_ARGS="--rm"
GDB_PERMISSION_ARGS="--cap-add=SYS_PTRACE --security-opt seccomp=unconfined"
DISPLAY_ARGS="--env=DISPLAY"
X11_ARGS="--volume=/tmp/.X11-unix:/tmp/.X11-unix:rw"

# Handle options
for i in "$@"
do
case $i in
    --arm)
    IMAGE_NAME="pidev/raspberrypi3-debian-core:jessie"
    shift
    ;;
    --buster)
    IMAGE_NAME="pidev/raspberrypi3-debian-core:buster"
    shift
    ;;
    --clion=*)
    USE_CLION=1
    CLION_VERSION="${i#*=}"
    CLION_SHORT_VERSION=${CLION_VERSION%.*}
    CLION_PATH="${HOME}/jetbrains/clion/${CLION_VERSION}"
    shift
    ;;
    --nvidia)
    DOCKER_COMMAND="nvidia-docker"
    NVIDIA_DOCKER_ARGS="-e NVIDIA_VISIBLE_DEVICES=all"
    shift
    ;;
    --host)
    NETWORK_CONFIG="host"
    shift
    ;;
    --priv)
    PRIVILIGED_ARGS="--privileged"
    shift
    ;;
    *)
          # unknown option
    ;;
esac
done

# ==================================
# Workspace and Development Cache

# Share current directory as the workspace in the container
WORKSPACE_DIR="${PWD}"
WORKSPACE_ARG="--volume=${WORKSPACE_DIR}:/home/user/workspace/"

# Local development files (caches, config, etc) get stored here
DEV_CACHE_DIR="${HOME}/.local/pidev/"
mkdir -p ${DEV_CACHE_DIR}

# ==================================
# Network settings
NETWORK_ARG="--network ${NETWORK_CONFIG}"

# ==================================
# Data directory

DATA_DIR="${DEV_CACHE_DIR}/data"
mkdir -p "${DATA_DIR}"
DATA_DIR_ARG="--volume=${DATA_DIR}:/data"

# ==================================
# Conan

# Share conan cache (make directories if they don't exist)
CONAN_DATA_DIR="${DEV_CACHE_DIR}/conan/data"
mkdir -p "${CONAN_DATA_DIR}"
CONAN_CACHE_ARG="--volume=${CONAN_DATA_DIR}:/home/user/.conan/data"

# Conan credentials
CONAN_USERNAME_ARG="--env=CONAN_USERNAME=${CONAN_USERNAME}"
CONAN_LOGIN_USERNAME_ARG="--env=CONAN_LOGIN_USERNAME=${CONAN_LOGIN_USERNAME}"
CONAN_PASS_ARG="--env=CONAN_PASSWORD=${CONAN_PASSWORD}"

# ===================================
# CLion settings

if [ "${USE_CLION}" == 1 ]; then
    CLION_IDE_ARG="--volume=${CLION_PATH}:/home/user/clion"

    CLION_SETTINGS_PATH="${DEV_CACHE_DIR}/clion/settings"
    CLION_PREFS_PATH="${DEV_CACHE_DIR}/clion/prefs"

    mkdir -p ${CLION_SETTINGS_PATH}
    mkdir -p ${CLION_PREFS_PATH}

    CLION_SETTINGS_ARG="--volume=${CLION_SETTINGS_PATH}:/home/user/.CLion${CLION_SHORT_VERSION}"
    CLION_PREFS_ARG="--volume=${CLION_PREFS_PATH}:/home/user/.java"
fi

# ===================================

${DOCKER_COMMAND} run -it \
    ${NETWORK_ARG} \
    ${PRIVILIGED_ARGS} \
    ${GDB_PERMISSION_ARGS} \
    ${NVIDIA_DOCKER_ARGS} \
    ${X11_ARGS} \
    ${DISPLAY_ARGS} \
    ${EXTRA_ARGS} \
    ${WORKSPACE_ARG} \
    ${DATA_DIR_ARG} \
    ${CLION_IDE_ARG} \
    ${CLION_SETTINGS_ARG} \
    ${CLION_PREFS_ARG} \
    ${CONAN_CACHE_ARG} \
    ${CONAN_USERNAME_ARG} \
    ${CONAN_LOGIN_USERNAME_ARG} \
    ${CONAN_PASS_ARG} \
    "${IMAGE_NAME}" \
    bash
