#!/bin/bash

TARGET="qemu"
while getopts "m:" opt; do
    case $opt in
        m) TARGET=$OPTARG ;;
        *) echo "Usage: $0 [-m qemu|rpi4]"; exit 1 ;;
    esac
done

if [ "$TARGET" = "rpi4" ]; then
    cp conf/local.conf.rpi4 conf/local.conf
else
    cp conf/local.conf.qemu conf/local.conf
fi

git submodule init
git submodule sync
git submodule update

source poky/oe-init-build-env

bitbake-layers show-layers | grep "meta-aesd" > /dev/null
if [ $? -ne 0 ]; then
    bitbake-layers add-layer ../meta-aesd
fi

if [ "$TARGET" = "rpi4" ]; then
    bitbake-layers show-layers | grep "meta-raspberrypi" > /dev/null
    if [ $? -ne 0 ]; then
        bitbake-layers add-layer ../meta-raspberrypi
    fi
fi

set -e
bitbake core-image-aesd
