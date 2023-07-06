#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR="${SCRIPT_DIR}/.."

source "${ROOT_DIR}/.env"

set -x
${ROOT_DIR}/scripts/kernel_build.sh
${ROOT_DIR}/scripts/rust_lkm_build.sh
set +x


