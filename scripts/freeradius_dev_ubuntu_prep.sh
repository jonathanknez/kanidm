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


${SUDOCMD} apt-get -y install freeradius freeradius-utils libfreeradius-dev python-is-python3
