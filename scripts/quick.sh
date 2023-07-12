#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR="${SCRIPT_DIR}/.."

source "${ROOT_DIR}/.env"

print_new_phase_title() {
    echo ""
    echo ""
    echo ""
    echo "####################################################################################################"
    echo "####################################################################################################"
    echo "@@@@@ $1"
    echo "####################################################################################################"
    echo "####################################################################################################"
    sleep 2
}

print_new_phase_title "Downloading and extracting Linux kernel source"
${ROOT_DIR}/scripts/kernel_source_download_and_extract.sh
print_new_phase_title "Building rkbuilder Docker image"
${ROOT_DIR}/docker/rkbuilder/build.sh
print_new_phase_title "Building Linux kernel and Rust LKM inside rkbuilder Docker container"
${ROOT_DIR}/docker/rkbuilder/run.sh ${RKB_WORKDIR}/scripts/build_kernel_and_rust_lkm.sh

print_new_phase_title "Building rkrootfs Docker image"
${ROOT_DIR}/docker/rootfs/build.sh
print_new_phase_title "Creating root filesystem"
${ROOT_DIR}/docker/rootfs/create_rootfs.sh

print_new_phase_title "Building rkqemu Docker image"
${ROOT_DIR}/docker/qemu/build.sh
print_new_phase_title "Running emulation"
${ROOT_DIR}/docker/qemu/run_emulation.sh

