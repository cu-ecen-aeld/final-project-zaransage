#!/bin/bash

TARGET="qemu"
while getopts "m:" opt; do
    case $opt in
        m) TARGET=$OPTARG ;;
        *) echo "Usage: $0 [-m qemu|rpi4]"; exit 1 ;;
    esac
done

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

git -C "${SCRIPT_DIR}" submodule init
git -C "${SCRIPT_DIR}" submodule sync
git -C "${SCRIPT_DIR}" submodule update

export TEMPLATECONF="${SCRIPT_DIR}/poky/meta-poky/conf"
source "${SCRIPT_DIR}/poky/oe-init-build-env" "${SCRIPT_DIR}/build"

if [ "$TARGET" = "rpi4" ]; then
    cp "${SCRIPT_DIR}/conf/local.conf.rpi4" conf/local.conf
else
    cp "${SCRIPT_DIR}/conf/local.conf.qemu" conf/local.conf
fi

bitbake-layers show-layers | grep "meta-aesd" > /dev/null
if [ $? -ne 0 ]; then
    bitbake-layers add-layer "${SCRIPT_DIR}/meta-aesd"
fi

if [ "$TARGET" = "rpi4" ]; then
    bitbake-layers show-layers | grep "meta-raspberrypi" > /dev/null
    if [ $? -ne 0 ]; then
        bitbake-layers add-layer "${SCRIPT_DIR}/meta-raspberrypi"
    fi
fi

set -e
bitbake core-image-aesd
