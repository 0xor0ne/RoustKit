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
rm -rf ${ROOT_DIR}/kernel/linux

print_new_phase_title "Removing kernel build"
rm -rf ${ROOT_DIR}/kernel/build

print_new_phase_title "Removing kernel archives"
for f in `ls ${ROOT_DIR}/kernel/archive` ; do
    rm ${ROOT_DIR}/kernel/archive/${f}
done

print_new_phase_title "Removing docker images"
${ROOT_DIR}/docker/lkbuilder/rm_container.sh
${ROOT_DIR}/docker/lkbuilder/rm_image.sh

print_new_phase_title "Cleaning Rust LKM"
make -C ${ROOT_DIR}/src clean

