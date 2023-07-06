#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR="${SCRIPT_DIR}/.."

source "${ROOT_DIR}/.env"

wget -O ${ROOT_DIR}/kernel/archive/${KERNEL_ARCHIVE_NAME} ${KERNEL_SOURCE_URL}

