guest_os_type = "other5xLinux64Guest"

# VM
cpus        = 4
ram         = 4096
disk_size   = 163840
network     = "Guest"
mac_address = "d6:df:8b:c6:f6:56"
vm_name     = "archie-template-2024-07-01-remote"

iso_url          = "http://www.gtlib.gatech.edu/pub/archlinux/iso/2024.07.01/archlinux-2024.07.01-x86_64.iso"
iso_checksum     = "sha256:398dceea2d04767fbb8b61a9e824f2c8f5eacf62b2cb5006fd63321d978d48bc"
use_local_mirror = "1"

# Build
boot_command = [
  "<enter><wait60><wait60><wait60>",
  "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/enable-ssh.sh<enter><wait5>",
  "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/install-tools.sh<enter><wait5>",
  "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/poweroff.timer<enter><wait5>",
  "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/traditional-naming.conf<enter><wait5>",
  "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/20-wired.network<enter><wait5>",
  "/usr/bin/bash ./enable-ssh.sh<enter><wait5>",
  "/usr/bin/bash ./install-tools.sh<enter><wait10>"
]
