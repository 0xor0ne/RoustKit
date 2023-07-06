#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR="${SCRIPT_DIR}/../.."

source "${ROOT_DIR}/.env"

echo "${SCRIPT_DIR}/rm_container.sh"
${SCRIPT_DIR}/rm_container.sh

get_status() {
    STATUS=`${DOCKER_SUDO} docker container inspect -f '{{.State.Status}}' "${LKB_RUN_NAME}" 2>&1`
    echo "${STATUS}"
}

if [ "$(get_status)" = "running" ] ; then
    echo "Something went wrong. Container ${LKB_RUN_NAME} is still running"
    exit 1
fi

echo "Removing image"
${DOCKER_SUDO} docker image rm ${LKB_TAG}
