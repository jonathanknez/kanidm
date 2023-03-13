#!/bin/bash

if [ "$(whoami)" == "root" ]; then
    SUDOCMD=""
else
    SUDOCMD="sudo"
fi

if [ -z "$(find /mnt/shared/  -maxdepth 1 -type f | head)" ]; then
    echo "Mounting shared dir..."
    ${SUDOCMD} mkdir -p /mnt/shared
    if [ "$(grep -c /mnt/shared)" -eq 0 ]; then
        echo "Adding shared folder to fstab"
        echo 'share	/mnt/shared	9p	trans=virtio,version=9p2000.L,rw,_netdev,nofail	0	0' | ${SUDOCMD} tee -a /etc/fstab
    fi
    ${SUDOCMD} mount /mnt/shared
fi


echo "Installing dependencies..."
../platform/debian/install_deps.sh || exit 1

if [ -z "${CARGO_TARGET_DIR}" ]; then
    # shellcheck disable=SC2016
    echo 'setting cargo target env var (CARGO_TARGET_DIR) to $HOME/target via /etc/profile'
    # shellcheck disable=SC2016
    echo 'export CARGO_TARGET_DIR="$HOME/target"' | ${SUDOCMD} tee -a /etc/profile
fi

${SUDOCMD} apt-get -y install \
    python-is-python3 \
    ripgrep\
    libtalloc-dev \
    libkqueue-dev \
    libcurl4-openssl-dev \
    libjson-c-dev \
    jq

MYDIR="$(basedir "$@")"

cd "${HOME}" || exit 1

"${MYDIR}/scripts/get-latest-freeradius-release.sh"

FRS_DIR="$(find "${HOME}" -maxdepth 1 -type d -name 'freeradius-server-*')"

cd "${FRS_DIR}" || exit 1
./configure --enable-developer || exit 1
make
