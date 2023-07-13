#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR="${SCRIPT_DIR}/.."

source "${ROOT_DIR}/.env"

SRC_DIR="${ROOT_DIR}/src"
DST_DIR="/tmp"

usage () {
    echo "Usage: $0 [-s <src_dir>] [-d <dst_dir>]"
}

while [[ $# -gt 0 ]] ; do
  case "$1" in
    -s|--src )
      SRC_DIR="$1"
      shift 2
      ;;
    -d|--dst )
      DST_DIR="$1"
      shift 2
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


set -x
scp -F ${ROOT_DIR}/.ssh_config -r ${SRC_DIR} rkqemu:${DST_DIR}
set +x


