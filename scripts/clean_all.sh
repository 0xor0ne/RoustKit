#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR="${SCRIPT_DIR}/.."

source "${ROOT_DIR}/.env"

print_new_phase_title() {
    echo ""
    echo ""
    echo ""
    echo "###################################################################################################"
    echo "###################################################################################################"
    echo "@@@@@ $1"
    echo "###################################################################################################"
    echo "###################################################################################################"
    sleep 2
}

print_new_phase_title "Removing kernel source"
set -x
rm -rf ${ROOT_DIR}/kernel/linux
set +x

print_new_phase_title "Removing kernel build"
set -x
rm -rf ${ROOT_DIR}/kernel/build
set +x

print_new_phase_title "Removing kernel archives"
set -x
for f in `ls ${ROOT_DIR}/kernel/archive` ; do
    rm ${ROOT_DIR}/kernel/archive/${f}
done
set +x

print_new_phase_title "Cleaning Rust LKM"
set -x
make -C ${ROOT_DIR}/src clean
set +x

print_new_phase_title "Removing RSA keys"
set -x
rm -rf ${ROOT_DIR}/docker/rootfs/.ssh
set +x

print_new_phase_title "Removing docker images"
set -x
${ROOT_DIR}/docker/lkbuilder/rm_container.sh
${ROOT_DIR}/docker/lkbuilder/rm_image.sh
${ROOT_DIR}/docker/rootfs/rm_container.sh
${ROOT_DIR}/docker/rootfs/rm_image.sh
set +x

print_new_phase_title "Removing rootfs directory"
set -x
D=`find . -name "${RFS_NAME}" -exec dirname {} \;`
if [ "${D}" != "" ] ; then
    rm -r "${ROOT_DIR}/${D}"
fi
set +x
