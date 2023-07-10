#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR="${SCRIPT_DIR}/../.."

source "${ROOT_DIR}/.env"

if [ ! -f "${SCRIPT_DIR}/.ssh/id_rsa.pub" ] ; then
    echo "Creating RSA key  ${SCRIPT_DIR}/.ssh/id_rsa"
    set -x
    mkdir -p "${SCRIPT_DIR}/.ssh"
    ssh-keygen -f "${SCRIPT_DIR}/.ssh/id_rsa" -t rsa -n 2048 -N ""
    set +x
else
    echo "Using existing RSA key ${SCRIPT_DIR}/.ssh/id_rsa"
fi

echo "\nBuilding rootfs docker image for RUST from UBUNTU_VERSION=${RFS_UBUNTU_VERSION}"

set -x
${DOCKER_SUDO} docker build \
  --build-arg UBUNTU_VERSION=${RFS_UBUNTU_VERSION} \
  --build-arg UNAME="${RFS_UNAME}" \
  --build-arg UID=${RFS_UID} \
  --build-arg GID=${RFS_GID} \
  --build-arg WDIR=${RFS_WORKDIR} \
  -t ${RFS_TAG} ${ROOT_DIR}/${RFS_DOCKERFILE_DIRPATH}

