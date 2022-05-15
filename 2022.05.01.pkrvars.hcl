guest_os_type   = "other5xLinux64Guest"

# VM
cpus      = 4
ram       = 4096
disk_size = 163840
network   = "Guest"
mac_address = "d6:df:8b:c6:f6:56"
vm_name   = "archie-template-2022-05-01-remote"

iso_url   = "http://www.gtlib.gatech.edu/pub/archlinux/iso/2022.05.01/archlinux-2022.05.01-x86_64.iso"
iso_checksum = "sha1:3700a16d4fcabbd29e9a7fbc97da732c4577dc2a"
use_local_mirror = "1"

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
