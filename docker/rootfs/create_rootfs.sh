#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR="${SCRIPT_DIR}/../.."

source "${ROOT_DIR}/.env"

set -x
${SCRIPT_DIR}/rm_container.sh
${SCRIPT_DIR}/run.sh sudo -E ${RFS_WORKDIR}/docker/rootfs/rootfs.sh \
    -n "${RFS_NAME}" \
    -l "${RFS_DST_DIR}" \
    -a ${RFS_ARCH} \
    -d ${RFS_DISTRIBUTION} \
    -p "${RFS_PACKAGES}" \
    -u ${RFS_USER} \
    -h "${RFS_HOSTNAME}" \
    -m "${RFS_MNT_BASE}"
set +x

