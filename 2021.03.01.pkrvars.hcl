guest_os_type   = "other5xLinux64Guest"

# VM
cpus      = 2
ram       = 4096
disk_size = 32768
network   = "Guest"
mac_address = "d6:df:8b:c6:f6:56"
vm_name   = "archie-test"

# Build
ssh_username   = "archie"
ssh_password   = "archieIsRoot!"
http_directory = "./srv"
boot_command     = [
  "<enter><wait10><wait10><wait10><wait10>",
  "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/enable-ssh.sh<enter><wait5>",
  "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/install-tools.sh<enter><wait5>",
  "/usr/bin/curl -O http://{{ .HTTPIP }}:{{ .HTTPPort }}/poweroff.timer<enter><wait5>",  
  "/usr/bin/bash ./enable-ssh.sh<enter><wait5>",
  "/usr/bin/bash ./install-tools.sh<enter><wait10><wait10>"
]
