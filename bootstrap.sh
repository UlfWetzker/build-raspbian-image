#!/bin/bash

vmdebootstrap \
    --arch armhf \
    --distribution stretch \
    --mirror http://archive.raspbian.org/raspbian \
    --image `date +raspbian-stretch-%Y%m%d.img` \
    --size 2000M \
    --bootsize 64M \
    --boottype vfat \
    --root-password raspberry \
    --user=pi/raspberry \
    --sudo \
    --enable-dhcp \
    --log=log.debug \
    --log-level=debug \
    --log-keep=1 \
    --verbose \
    --no-kernel \
    --no-extlinux \
    --no-acpid \
    --hostname raspberry \
    --foreign /usr/bin/qemu-arm-static \
    --debootstrapopts="variant=minbase keyring=`pwd`/raspbian.org.gpg" \
    --package netbase aptitude \
    --pkglist \
    --customize `pwd`/customize.sh
