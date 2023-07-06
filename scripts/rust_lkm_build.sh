#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR="${SCRIPT_DIR}/.."
RLKM_D=${ROOT_DIR}/src

source "${ROOT_DIR}/.env"

cd ${RLKM_D}

set -x
make $@
set +x

cd ${ROOT_DIR}

