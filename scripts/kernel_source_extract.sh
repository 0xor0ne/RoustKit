#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR="${SCRIPT_DIR}/.."

source "${ROOT_DIR}/.env"

if [ -d "${ROOT_DIR}/kernel/linux" ] ; then
    if [ ! -z "$(ls -A ${ROOT_DIR}/kernel/linux)"] ; then
        echo "${ROOT_DIR}/kernel/linux already exists and is not empty. Remove it before proceeding."
        exit 1
    fi
else
    mkdir -p kernel/linux
fi

echo "Extracting kernel/archive/${KERNEL_ARCHIVE_NAME} in kernel/linux"
tar -C kernel/linux -xf kernel/archive/${KERNEL_ARCHIVE_NAME} --strip-components=1

