#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR="${SCRIPT_DIR}/../.."

source "${ROOT_DIR}/.env"

set -x
rootfs_file=`find ${ROOT_DIR} -name "${RFS_NAME}"`
kernel_file=`find ${ROOT_DIR} -name vmlinux`

if [ "${rootfs_file}" == "" ] ; then
    echo "Root file system ${RFS_NAME} not found"
    exit 1
fi

if [ "${kernel_file}" == "" ] ; then
    echo "Kernel image not found"
    exit 1
fi

pushd ${ROOT_DIR}
if [ "${PWD}" != "${WDIR}" ] ; then
    echo "Unexpected environment ${ROOT_DIR} != ${WDIR}"
    exit 1
fi
popd

# qemupid=`pgrep qemu-system-${RKE_QEMU_ARCH}`
qemupid=`pgrep qemu`
if [ ! -z "${qemupid}" ] ; then
    kill -9 ${qemupid}
fi

if [ -f "${RKE_QEMU_PIDFILE}" ] ; then
    rm ${RKE_QEMU_PIDFILE}
fi

qemu-system-${RKE_QEMU_ARCH} \
    -m ${RKE_QEMU_MEM} \
    -smp ${RKE_QEMU_SMP} \
    -kernel ${RKE_QEMU_KIMAGE} \
    -cpu ${RKE_QEMU_CPU} \
    -append "${RKE_QEMU_APPEND}" \
    ${RKE_QEMU_FSMOUNT} \
    ${RKE_QEMU_NET} \
    ${RKE_QEMU_GRAPHIC} -pidfile ${RKE_QEMU_PIDFILE} ${RKE_QEMU_KVM}
set +x
