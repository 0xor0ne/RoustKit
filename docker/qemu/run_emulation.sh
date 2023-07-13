#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR="${SCRIPT_DIR}/../.."

source "${ROOT_DIR}/.env"

usage () {
    echo "Usage: $0 [-b | --background]"
}

background=0

while [[ $# -gt 0 ]] ; do
  case "$1" in
    -b|--background )
      background=1
      shift 1
      ;;
    -h|--help)
      usage
      exit 1
      ;;
    --)
      shift;
      break
      ;;
    *)
      echo "Unexpected option: $1"
      shift
      ;;
  esac
done

echo "Background=${background}"

set -x
${SCRIPT_DIR}/rm_container.sh
if [ ${background} -eq 0 ]; then
    ${SCRIPT_DIR}/run.sh ${RKE_WORKDIR}/docker/qemu/emulate.sh
else
    ${SCRIPT_DIR}/run.sh -n -d ${RKE_WORKDIR}/docker/qemu/emulate.sh
fi
set +x

