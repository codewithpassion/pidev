#!/bin/bash

# Defaults
DEFAULT_MAINTAINER=info@sofarocean.com
MAINTAINER=${DEFAULT_MAINTAINER}
set -e

function print-help() 
{ 
cat <<_EOF
Debian packager.
Options:
    -t|--ci-commit-tag: Tag to use for versioning. Usually should be the environment variable CI_COMMIT_TAG.
    -m|--maintainer: Maintainer of the package. Defaults to ${DEFAULT_MAINTAINER}.
    -a|--arch: Architecture for the debian package or 'all'.
    --distro: Debian distribution code. 
    -n|--package-name: Package name
    --description: Description
    --after-install: Path to after install script for debian package
    --before-remove: Path to before remove script for debian package
    -b|--build-dir: Build dir where to get the contents for the deb file from.
    -h: This help
_EOF
}

# Parse arguments
PARAMS=""
while (( "$#" )); do
  case "$1" in
    -t|--ci-commit-tag)
      CI_COMMIT_TAG=$2
      shift 2
      ;;
    -m|--maintainer)
      MAINTAINER=$2
      shift 2
      ;;
    -a|--arch)
      ARCH=$2
      shift 2
      ;;
    --distro)
      DISTRO=$2
      shift 2
      ;;
    -n|--package-name)
      PACKAGE_NAME="$2"
      shift 2
      ;;
    --description)
      DESCRIPTION=("--description \"$2\"")
      shift 2
      ;;
    --after-install)
      AFTER_INSTALL="--after-install $2"
      shift 2
      ;;
    --before-remove)
      BEFORE_REMOVE="--before-remove $2"
      shift 2
      ;;
    -b|--build-dir)
      BUILD_DIR=$2
      shift 2
      ;;
    -d|--depends)
      DEPENDS=("$DEPENDS -d \"$2\"")
      shift 2
      ;;
    -h|--help)
      print-help    
      exit 0
      shift
      ;;    
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"

HAS_ERROR=0
if [ "${CI_COMMIT_TAG}" == "" ]; then echo "ERROR: commit tag can not be empty." >&2 && HAS_ERROR=1; fi
if [ "${ARCH}" == "" ]; then echo "ERROR: arch can not be empty." >&2 && HAS_ERROR=1; fi
if [ "${DISTRO}" == "" ]; then echo "ERROR: Distro can not be empty." >&2 && HAS_ERROR=1; fi
if [ "${PACKAGE_NAME}" == "" ]; then echo "ERROR: Package name can not be empty." >&2 && HAS_ERROR=1; fi
if [ "${DESCRIPTION}" == "" ]; then echo "ERROR: Description can not be empty." >&2 && HAS_ERROR=1; fi
if [ "${BUILD_DIR}" == "" ]; then echo "ERROR: Build dir can not be empty." >&2 && HAS_ERROR=1; fi
if [ ${HAS_ERROR} -eq 1 ]; then exit 1; fi


python3 -c "from semantic_version import Version; import sys; Version( sys.argv[1] ); print( 'PASS' )" ${CI_COMMIT_TAG}
(if [ $? -ne 0 ]; then echo "ERROR: commit tag not valid '$CI_COMMIT_TAG'." >&2 && exit 1; fi)

# Convert the last - to ~ so that debian does the handling of the package version right.
VERSION_TAG=`echo ${CI_COMMIT_TAG}  | sed 's/\(.*\)-/\1~/'`

# Package as .deb
FPM="fpm -f \
    -m ${MAINTAINER} \
    -s dir \
    -t deb \
    -a ${ARCH} \
    -n ${PACKAGE_NAME} \
    -v ${VERSION_TAG} \
    ${DEPENDS} \
    ${AFTER_INSTALL} \
    ${BEFORE_REMOVE} \
    ${DESCRIPTION} \
    -C ${BUILD_DIR} ./"

eval $FPM


