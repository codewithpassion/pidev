#!/bin/bash
set -e

DEPLOY=0

for i in "$@"
do
case $i in
    --bootstrap)
    BOOTSTRAP=1
    BOOTSTRAP_TAG="-bootstrap"
    shift
    ;;
    -p=*|--platform=*)
    BUILD_PLATFORM="${i#*=}"
    shift # past argument=value
    ;;
    --deploy)
    DEPLOY=1
    shift
    ;;
    *)
          # unknown option
    ;;
esac
done

case ${BUILD_PLATFORM} in 
    "amd64"|"raspberrypi3"|"raspberrypi3-buster") 
    ;;
    *)
        echo "Invalid platform: \"${BUILD_PLATFORM}\"" >&2
        exit 1
    ;;
esac 

# Get the short git SHA
GIT_SHA="$(git rev-parse --short HEAD)"

if [ "$BUILD_PLATFORM" == "amd64" ]; then
    DIST_NAME="bionic"
    TAG_NAME="${BUILD_PLATFORM}-ubuntu-core${BOOTSTRAP_TAG}:${DIST_NAME}"
elif [ "$BUILD_PLATFORM" == "raspberrypi3" ]; then
    DIST_NAME="jessie"
    TAG_NAME="${BUILD_PLATFORM}-debian-core${BOOTSTRAP_TAG}:${DIST_NAME}"

    # Run qemu static registration
    # The trailing --reset is for the qemu register: remove all registered binfmt_misc before re-registering all supported processors except the current one
    # https://github.com/multiarch/qemu-user-static
    docker run --rm --privileged multiarch/qemu-user-static:register --reset
elif [ "$BUILD_PLATFORM" == "raspberrypi3-buster" ]; then
    DIST_NAME="buster"
    TAG_NAME="raspberrypi3-debian-core${BOOTSTRAP_TAG}:${DIST_NAME}"

    # Run qemu static registration
    # The trailing --reset is for the qemu register: remove all registered binfmt_misc before re-registering all supported processors except the current one
    # https://github.com/multiarch/qemu-user-static
    docker run --rm --privileged multiarch/qemu-user-static:register --reset
else
    echo "Error: Unexpected BUILD_PLATFORM!" >&2
    exit 1
fi

TAG_NAME_EXT="${TAG_NAME}-${GIT_SHA}"



echo "Build Docker image: ${TAG_NAME_EXT}"

# Pull latest image before building, but don't fail if it doesn't exist yet
docker pull "pidev/${TAG_NAME}" || true

# Build image
docker build \
    --build-arg DIST_NAME=${DIST_NAME} \
    --cache-from "pidev/${TAG_NAME}" \
    -t "pidev/${TAG_NAME}" \
    -t "pidev/${TAG_NAME_EXT}" \
    -f "docker${BOOTSTRAP_TAG}/${BUILD_PLATFORM}/Dockerfile" \
    ./docker

# Push image
if [ ${DEPLOY} == 1 ]; then
    docker push "pidev/${TAG_NAME}"
    docker push "pidev/${TAG_NAME_EXT}"
fi