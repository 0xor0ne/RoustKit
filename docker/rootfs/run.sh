#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR="${SCRIPT_DIR}/../.."

source "${ROOT_DIR}/.env"

# Check if container is running or exited
RUNNING=0
EXITED=0
CREATED=0
STATUS=`${DOCKER_SUDO} docker container inspect -f '{{.State.Status}}' "${RFS_RUN_NAME}" 2>&1`

if [ "$STATUS" = "running" ] ; then
    RUNNING=1
elif [ "$STATUS" = "exited" ] ; then
    EXITED=1
elif [ "$STATUS" = "created" ] ; then
    CREATED=1
    echo "Status: Created. Removing container..."
    ${SCRIPT_DIR}/rm_container.sh
fi

echo "Running=${RUNNING}"
echo "Exited=${EXITED}"
echo "Created=${CREATED}"

# Check if we must run in interactive mode
INTERACTIVE="-it"
if [ $# -gt 0 -a "$1" = "-n" ]
then
	INTERACTIVE=""
    shift
fi

echo "Interactive=${INTERACTIVE}"
echo "Add. Opts=${RFS_DOCKER_RUN_ADD_OPT}"

# Check if there are additional arguments
CMDS="bash"
if [ $# -gt 0 ]
then
	echo -e "Run arguments: \"$@\"\n"
    CMDS=$@
else
	echo -e "Run arguments: bash\n"
fi

if [ "${EXITED}" -eq 1 ] ; then
    set -x
    ${DOCKER_SUDO} docker start ${RFS_RUN_NAME}
    set +x

    # If not running, remove the container
    STATUS=`${DOCKER_SUDO} docker container inspect -f '{{.State.Status}}' "${RFS_RUN_NAME}" 2>&1`
    if [ "$STATUS" = "running" ] ; then
        RUNNING=1
    else
        echo "Short living container, removing it"
        set -x
        ${DOCKER_SUDO} docker rm ${RFS_RUN_NAME}
        set +x
        RUNNING=0
    fi
fi

if [ "${RUNNING}" -eq 1 ] ; then
    set -x
    ${DOCKER_SUDO} docker exec \
        ${INTERACTIVE} \
        ${RFS_RUN_NAME} ${CMDS}
    set +x
else
    set -x
    ${DOCKER_SUDO} docker run \
        ${INTERACTIVE} \
        ${RFS_DOCKER_RUN_ADD_OPT} \
        -v "${ROOT_DIR}:${RFS_WORKDIR}" \
        -v /tmp:/tmp \
        -e WDIR="${RFS_WORKDIR}" \
        --name ${RFS_RUN_NAME} \
        ${RFS_TAG} ${CMDS}
    set +x
fi

