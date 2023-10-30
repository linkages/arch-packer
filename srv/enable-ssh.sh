#!/usr/bin/env bash

PASSWORD=$(/usr/bin/openssl passwd -6 'archieIsRoot!')

# Vagrant-specific configuration
/usr/bin/useradd --password ${PASSWORD} --comment 'Archie install user' --create-home --user-group archie
echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10_archie
echo 'archie ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10_archie
/usr/bin/chmod 0440 /etc/sudoers.d/10_archie
/usr/bin/systemctl start sshd.service
