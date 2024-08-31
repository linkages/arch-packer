#!/usr/bin/env bash

# stop on errors
set -eu

if [[ $PACKER_BUILDER_TYPE == "qemu" ]]; then
  DISK='/dev/vda'
else
  DISK='/dev/sda'
fi

FQDN=${FQDN:-archie-template.benshoshan.com}
KEYMAP='us'
LANGUAGE='en_US.UTF-8'
PASSWORD=$(/usr/bin/openssl passwd -6 '${password}')
TIMEZONE='UTC'

CONFIG_SCRIPT='/usr/local/bin/arch-config.sh'
ROOT_PARTITION="${DISK}1"
TARGET_DIR='/mnt'
COUNTRY=${COUNTRY:-US}
#MIRROR=${USERMIRROR:-"http://www.gtlib.gatech.edu/pub/archlinux/\$repo/os/\$arch"}

echo ">>>> install-base.sh: Clearing partition table on ${DISK}.."
echo ">>>> install-base.sh: Clearing partition table on ${DISK}.." >> /tmp/install.log
/usr/bin/sgdisk --zap ${DISK}

echo ">>>> install-base.sh: Destroying magic strings and signatures on ${DISK}.."
/usr/bin/dd if=/dev/zero of=${DISK} bs=512 count=2048
/usr/bin/wipefs --all ${DISK}

echo ">>>> install-base.sh: Creating /root partition on ${DISK}.."
/usr/bin/sgdisk --new=1:2048:+1M ${DISK}
/usr/bin/sgdisk --typecode=1:21686148-6449-6E6F-744E-656564454649 ${DISK}

/usr/bin/sgdisk --new=2:0:+512M ${DISK}
/usr/bin/sgdisk --attributes=2:set:2 ${DISK}
/usr/bin/sgdisk --typecode=2:8300 ${DISK}
/usr/bin/mkfs.ext4 -O ^64bit -F -m 0 -q -L boot ${DISK}2

/usr/bin/sgdisk --new=3:0:0 ${DISK}
/usr/bin/sgdisk --typecode=3:8e00 ${DISK}

/usr/bin/pvcreate ${DISK}3
/usr/bin/vgcreate rootvg ${DISK}3
/usr/bin/lvcreate -nslashlv -L1G rootvg
/usr/bin/lvcreate -noptlv -L2G rootvg
/usr/bin/lvcreate -nhomelv -L2G rootvg
/usr/bin/lvcreate -nusrlv -L4G rootvg
/usr/bin/lvcreate -nvarlv -L4G rootvg

echo ">>>> install-base.sh: Creating filesystems (ext4).."
for fs in slash opt home usr var; do
    /usr/bin/mkfs.ext4 -O ^64bit -F -m 0 -q -L ${fs} /dev/rootvg/${fs}lv
done

echo ">>>> install-base.sh: Mounting new root to ${TARGET_DIR}.."
/usr/bin/mount -o noatime,discard,data=ordered,errors=remount-ro /dev/rootvg/slashlv ${TARGET_DIR}

/usr/bin/mkdir ${TARGET_DIR}/boot
/usr/bin/mount -o noatime,discard,data=ordered,errors=remount-ro ${DISK}2 ${TARGET_DIR}/boot

for fs in opt home usr var; do
    /usr/bin/mkdir ${TARGET_DIR}/${fs}
    /usr/bin/mount -o noatime,discard,data=ordered,errors=remount-ro /dev/rootvg/${fs}lv ${TARGET_DIR}/${fs}
done

echo ">>>> install-base.sh: Setting pacman ${COUNTRY} mirrors.."

# test to see if use_local_mirror is set
if [ ! -z ${use_local_mirror} ]; then
    # if it is set and set to "1" then use the local mirror
    if [ ${use_local_mirror} == "1" ]; then
	echo "using local";
	MIRROR="http://docker-2.benshoshan.com:8888/\$repo/os/\$arch"
    # otherwise use the remote mirror
    else
	echo "using remote";
	MIRROR="http://www.gtlib.gatech.edu/pub/archlinux/\$repo/os/\$arch"
   fi
# if use_local_mirror is not set, then use the remote
else
    echo "use_local_mirror not found. Setting to remote"
    MIRROR="http://www.gtlib.gatech.edu/pub/archlinux/\$repo/os/\$arch"
fi

echo "Server = ${MIRROR}"> /etc/pacman.d/mirrorlist

echo ">>>> install-base.sh: Bootstrapping the base installation.."
/usr/bin/pacstrap ${TARGET_DIR} base linux openssh lvm2 grub net-tools linux-headers open-vm-tools nfs-utils cloud-init cloud-guest-utils

echo ">>>> install-base.sh: Disabling predictable network interface names..."
/usr/bin/mkdir -p "${TARGET_DIR}/etc/systemd/network/99-default.link.d"
/usr/bin/install --mode=0644 /root/traditional-naming.conf "${TARGET_DIR}/etc/systemd/network/99-default.link.d/traditional-naming.conf"
#/usr/bin/ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules

echo ">>>> install-base.sh: Configuring systemd-network for wired DHCP..."
/usr/bin/install --mode=0644 /root/20-wired.network "${TARGET_DIR}/etc/systemd/network/20-wired.network"

# http://comments.gmane.org/gmane.linux.arch.general/48739
#echo ">>>> install-base.sh: Adding workaround for shutdown race condition.."
#/usr/bin/install --mode=0644 /root/poweroff.timer "${TARGET_DIR}/etc/systemd/system/poweroff.timer"

echo ">>>> install-base.sh: Configuring grub.."
/usr/bin/arch-chroot ${TARGET_DIR} grub-install --target=i386-pc ${DISK}
/usr/bin/arch-chroot ${TARGET_DIR} grub-mkconfig -o /boot/grub/grub.cfg

echo ">>>> install-base.sh: Generating the filesystem table.."
/usr/bin/genfstab -p ${TARGET_DIR} >> "${TARGET_DIR}/etc/fstab"

echo ">>>> install-base.sh: Generating the system configuration script.."
/usr/bin/install --mode=0755 /dev/null "${TARGET_DIR}${CONFIG_SCRIPT}"

CONFIG_SCRIPT_SHORT=`basename "$CONFIG_SCRIPT"`
cat <<-EOF > "${TARGET_DIR}${CONFIG_SCRIPT}"
  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Configuring hostname, timezone, and keymap.."
  echo '${FQDN}' > /etc/hostname
  /usr/bin/ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
  echo 'KEYMAP=${KEYMAP}' > /etc/vconsole.conf
  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Configuring locale.."
  /usr/bin/sed -i 's/#${LANGUAGE}/${LANGUAGE}/' /etc/locale.gen
  /usr/bin/locale-gen

  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Fixing mkinitcpio.conf.."
  /usr/bin/sed -i 's#udev#systemd#' /etc/mkinitcpio.conf
  /usr/bin/sed -i 's#block#block lvm2#' /etc/mkinitcpio.conf

  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Creating initramfs.."
  /usr/bin/mkinitcpio -p linux

  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Setting root pasword...[${PASSWORD}]"
  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Should have set password to: [${password}]"
  /usr/bin/usermod --password ${PASSWORD} root

  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Configuring network.."
  /usr/bin/systemctl enable systemd-networkd.service
  /usr/bin/systemctl enable systemd-resolved.service

  ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Configuring sshd.."
  /usr/bin/sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
  /usr/bin/systemctl enable sshd.service

  # Setup Archie user
  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Creating archie user.."
  /usr/bin/useradd --password ${PASSWORD} --comment 'Archie user' --create-home --user-group archie
  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Configuring sudo.."
  echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10_archie
  echo 'archie ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10_archie
  /usr/bin/chmod 0440 /etc/sudoers.d/10_archie

  echo "archie:archieIsRoot!" | /usr/bin/chpasswd 
  
  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Enabling Open-VM-Tools service.."
  /usr/bin/systemctl enable vmtoolsd.service

  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Enabling RPC Bind service.."
  /usr/bin/systemctl enable rpcbind.service

  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Enabling cloud-init services.."
  /usr/bin/systemctl enable cloud-init-local.service 
  /usr/bin/systemctl enable cloud-init.service
  /usr/bin/systemctl enable cloud-config.service
  /usr/bin/systemctl enable cloud-final.service
EOF

echo ">>>> install-base.sh: Entering chroot and configuring system.."
/usr/bin/arch-chroot ${TARGET_DIR} ${CONFIG_SCRIPT}
rm "${TARGET_DIR}${CONFIG_SCRIPT}"

echo ">>>> install-base.sh: Cleaning up cloud-init"
/usr/bin/arch-chroot ${TARGET_DIR} cloud-init clean
/usr/bin/arch-chroot ${TARGET_DIR} cloud-init clean --logs

echo ">>>> install-base.sh: Completing installation.."
/usr/bin/sync

/usr/bin/sleep 10

for dir in opt home usr var boot; do
    echo ">>>> install-base.sh: unmounting: [${dir}]"
    /usr/bin/umount ${TARGET_DIR}/${dir}
done;

/usr/bin/sync

/usr/bin/sleep 10

echo ">>>> install-base.sh: unmounting: slash"
/usr/bin/umount ${TARGET_DIR}

# Turning network interfaces down to make sure SSH session was dropped on host.
# More info at: https://www.packer.io/docs/provisioners/shell.html#handling-reboots
#echo '==> Turning down network interfaces and rebooting'
#for i in $(/usr/bin/ip link show | /usr/bin/grep ^.: | /usr/bin/awk '{print $2}' | /usr/bin/sed -e 's#:##g'); do
#    echo "Turning down: ${i}";
#    /usr/bin/ip link set ${i} down;
#done
#/usr/bin/systemctl reboot
echo ">>>> install-base.sh: Installation complete!"
exit 0
