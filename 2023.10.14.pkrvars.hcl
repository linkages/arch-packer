guest_os_type = "other5xLinux64Guest"

# VM
cpus        = 4
ram         = 4096
disk_size   = 163840
network     = "Guest"
mac_address = "d6:df:8b:c6:f6:56"
vm_name     = "archie-template-2023-10-14-remote"

iso_url          = "http://www.gtlib.gatech.edu/pub/archlinux/iso/2023.10.14/archlinux-2023.10.14-x86_64.iso"
iso_checksum     = "sha256:292269ba9bf8335b6a885921a00d311cdc1dcbe9a1375f297f7f3ecfe31c36a7"
use_local_mirror = "1"

# Build
boot_command = [
  "<enter><wait60><wait60><wait60><wait60><wait30>",
  "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/enable-ssh.sh<enter><wait5>",
  "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/install-tools.sh<enter><wait5>",
  "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/poweroff.timer<enter><wait5>",
  "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/traditional-naming.conf<enter><wait5>",
  "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/20-wired.network<enter><wait5>",
  "/usr/bin/bash ./enable-ssh.sh<enter><wait5>",
  "/usr/bin/bash ./install-tools.sh<enter><wait10>"
]
