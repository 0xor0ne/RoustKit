#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR="${SCRIPT_DIR}/.."

source "${ROOT_DIR}/.env"


proceed=1
if [ -d "${ROOT_DIR}/kernel/linux" ] ; then
    if [ ! -z "$(ls -A ${ROOT_DIR}/kernel/linux)" ] ; then
        proceed=0
        echo "Linux source/build directories exist. You can:"
        echo "- Keep them [k], or"
        echo "- Remove them [r] and start from scratch"
        read -p "Type k or r (default k) " keep

        if [ "${keep}" != "k" -a "${keep}" != "r" ] ; then
            keep="k"
        fi

        if [ "${keep}" == "r" ] ; then
            set -x
            rm -rf "${ROOT_DIR}/kernel/linux"
            rm -rf "${ROOT_DIR}/kernel/build"
            mkdir -p "${ROOT_DIR}/kernel/linux"
            set +x
            proceed=1
        fi
    fi
else
    mkdir -p "${ROOT_DIR}/kernel/linux"
fi

if [ ${proceed} == 1 ] ; then
    ${SCRIPT_DIR}/kernel_source_download.sh
    ${SCRIPT_DIR}/kernel_source_extract.sh
fi

