#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR="${SCRIPT_DIR}/../.."

source "${ROOT_DIR}/.env"

echo "\nBuilding rkqemu docker image for RUST from UBUNTU_VERSION=${RKE_UBUNTU_VERSION}"

set -x
${DOCKER_SUDO} docker build \
  --build-arg UBUNTU_VERSION=${RKE_UBUNTU_VERSION} \
  --build-arg UNAME="${RKE_UNAME}" \
  --build-arg UID=${RKE_UID} \
  --build-arg GID=${RKE_GID} \
  --build-arg WDIR=${RKE_WORKDIR} \
  -t ${RKE_TAG} ${ROOT_DIR}/${RKE_DOCKERFILE_DIRPATH}

