#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR="${SCRIPT_DIR}/../.."

source "${ROOT_DIR}/.env"

echo "\nBuilding lkbuilder docker image for RUST_VERSION=${RUST_VERSION} and BINDGEN_VERSION=${BINDGEN_VERSION} from UBUNTU_VERSION=${LKB_UBUNTU_VERSION}"

set -x
${DOCKER_SUDO} docker build \
  --build-arg UBUNTU_VERSION=${LKB_UBUNTU_VERSION} \
  --build-arg UNAME="${LKB_UNAME}" \
  --build-arg UID=${LKB_UID} \
  --build-arg GID=${LKB_GID} \
  --build-arg WDIR=${LKB_WORKDIR} \
  --build-arg RUST_VERSION=${RUST_VERSION} \
  --build-arg BINDGEN_VERSION=${BINDGEN_VERSION} \
  -t ${LKB_TAG} ${ROOT_DIR}/${LKB_DOCKERFILE_DIRPATH}

