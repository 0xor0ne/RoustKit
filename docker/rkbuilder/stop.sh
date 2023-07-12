#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR="${SCRIPT_DIR}/../.."

source "${ROOT_DIR}/.env"

get_status() {
    STATUS=`${DOCKER_SUDO} docker container inspect -f '{{.State.Status}}' "${RKB_RUN_NAME}" 2>&1`
    echo "${STATUS}"
}

RUNNING=0

if [ "$(get_status)" = "running" ] ; then
    RUNNING=1

    echo "Stopping container ${RKB_RUN_NAME}"
    ${DOCKER_SUDO} docker stop ${RKB_RUN_NAME}
fi

if [ "$(get_status)" = "running" ] ; then
    RUNNING=1

    echo "Container ${RKB_RUN_NAME} is still running. Trying to kill it..."

    {DOCKER_SUDO} docker kill ${RKB_RUN_NAME}
fi

if [ "$(get_status)" = "running" ] ; then
    RUNNING=1
else
    RUNNING=0
fi

echo "Running=${RUNNING}"

