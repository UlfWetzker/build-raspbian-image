#!/bin/bash

apt-get update
apt-get install binfmt-support qemu-user-static apt-cacher-ng ca-certificates curl binutils git-core wget curl kmod

CUR=$(pwd)

cd /usr/src
git clone git://git.liw.fi/vmdebootstrap
apt-get install python-setuptools python-distro-info python-yaml
git clone git://git.liw.fi/cliapp python-cliapp
cd python-cliapp
python setup.py install
cd ../vmdebootstrap
python setup.py install

cd $CUR
echo ready for bootstrap.sh
