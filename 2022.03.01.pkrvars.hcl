guest_os_type   = "other5xLinux64Guest"

# VM
cpus      = 4
ram       = 4096
disk_size = 163840
network   = "Guest"
mac_address = "d6:df:8b:c6:f6:56"
vm_name   = "archie-template-2022-03-01-remote"

iso_url   = "http://www.gtlib.gatech.edu/pub/archlinux/iso/2022.03.01/archlinux-2022.03.01-x86_64.iso"
iso_checksum = "sha1:64070acf60ac342d7aaddddfa0448f5900c4a0a5"
use_local_mirror = "0"

# Build
ssh_username   = "archie"
ssh_password   = "archieIsRoot!"
http_directory = "./srv"
boot_command     = [
  "<enter><wait10><wait10><wait10>",
  "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/enable-ssh.sh<enter><wait5>",
  "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/install-tools.sh<enter><wait5>",
  "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/poweroff.timer<enter><wait5>",  
  "/usr/bin/bash ./enable-ssh.sh<enter><wait5>",
  "/usr/bin/bash ./install-tools.sh<enter><wait10>"
]
