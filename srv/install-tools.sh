#!/usr/bin/env bash

MIRROR="Server = http://docker-2.benshoshan.com:8888/\$repo/os/\$arch"
echo ${MIRROR} > /etc/pacman.d/mirrorlist

/usr/bin/pacman -Sy
/usr/bin/pacman -S --noconfirm open-vm-tools
/usr/bin/systemctl start vmtoolsd.service
