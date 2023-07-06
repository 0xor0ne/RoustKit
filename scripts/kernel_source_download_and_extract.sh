#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR="${SCRIPT_DIR}/.."

source "${ROOT_DIR}/.env"

${SCRIPT_DIR}/kernel_source_download.sh
${SCRIPT_DIR}/kernel_source_extract.sh

