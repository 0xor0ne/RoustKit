#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR="${SCRIPT_DIR}/.."
KSRC_D=${ROOT_DIR}/kernel/linux
KBLD_D=${ROOT_DIR}/kernel/build
KCFG_D=${ROOT_DIR}/kernel/configs

source "${ROOT_DIR}/.env"

cd ${KSRC_D}

set -x
mkdir -p ${KBLD_D}
cp ${KCFG_D}/default ${KBLD_D}/.config

make O=${KBLD_D} LLVM=1 ARCH=x86_64 olddefconfig
make O=${KBLD_D} LLVM=1 ARCH=x86_64 -j2 all
set +x

cd ${ROOT_DIR}

