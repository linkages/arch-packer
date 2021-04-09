#!/usr/bin/bash -x

# Clean the pacman cache.
echo ">>>> cleanup.sh: Cleaning pacman cache.."
echo ">>>> cleanup.sh: Cleaning pacman cache.." >> /root/cleanup.log
/usr/bin/pacman -Scc --noconfirm

/usr/bin/systemctl disable dhcpcd@eth0.service

# Remove archie
#echo ">>>> cleanup.sh: Removing the archie user and group"
#/usr/bin/userdel -r archie
#/usr/bin/groupdel archie

#echo ">>>> cleanup.sh: Cleaning up sudoers"
#rm /etc/sudoers.d/10_archie

# Write zeros to improve virtual disk compaction.
if [[ $WRITE_ZEROS == "true" ]]; then
    echo ">>>> cleanup.sh: Writing zeros to improve virtual disk compaction.."
    echo ">>>> cleanup.sh: Writing zeros to improve virtual disk compaction.." >> /root/cleanup.log
    zerofile=$(/usr/bin/mktemp /zerofile.XXXXX)
    /usr/bin/dd if=/dev/zero of="$zerofile" bs=1M
    #  /usr/bin/rm -f "$zerofile"
    /usr/bin/sync
fi

echo ">>>> cleanup.sh: Cleaning up any cloud-init stuff"
