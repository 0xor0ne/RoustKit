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
print_new_phase_title "Building lkbuilder Docker image"
${ROOT_DIR}/docker/lkbuilder/build.sh
print_new_phase_title "Building Linux kernel and Rust LKM inside lkbuilder Docker container"
${ROOT_DIR}/docker/lkbuilder/run.sh ${LKB_WORKDIR}/scripts/build_kernel_and_rust_lkm.sh

print_new_phase_title "Building rootfs Docker image"
${ROOT_DIR}/docker/rootfs/build.sh
print_new_phase_title "Creating root filesystem"
${ROOT_DIR}/docker/rootfs/create_rootfs.sh



