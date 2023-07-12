#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR="${SCRIPT_DIR}/../.."

source "${ROOT_DIR}/.env"

echo "\nBuilding rkbuilder docker image for RUST_VERSION=${RUST_VERSION} and BINDGEN_VERSION=${BINDGEN_VERSION} from UBUNTU_VERSION=${RKB_UBUNTU_VERSION}"

set -x
${DOCKER_SUDO} docker build \
  --build-arg UBUNTU_VERSION=${RKB_UBUNTU_VERSION} \
  --build-arg UNAME="${RKB_UNAME}" \
  --build-arg UID=${RKB_UID} \
  --build-arg GID=${RKB_GID} \
  --build-arg WDIR=${RKB_WORKDIR} \
  --build-arg RUST_VERSION=${RUST_VERSION} \
  --build-arg BINDGEN_VERSION=${BINDGEN_VERSION} \
  -t ${RKB_TAG} ${ROOT_DIR}/${RKB_DOCKERFILE_DIRPATH}

