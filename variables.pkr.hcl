variable "country" {
  type    = string
  default = "US"
}

variable "headless" {
  type    = string
  default = "false"
}

variable "iso_checksum" {
  type    = string
  default = "sha1:f0e9a794dbbc2f593389100273a3714d46c5cecf"
}

variable "iso_url" {
  type    = string
  default = "https://mirrors.edge.kernel.org/archlinux/iso/2021.03.01/archlinux-2021.03.01-x86_64.iso"
}

variable "ssh_timeout" {
  type    = string
  default = "20m"
}

variable "write_zeros" {
  type    = string
  default = "false"
}

# VM
variable "cpus" {
  type = number
  default = 2
}
variable "ram" {
  type = number
  default = 2048
}
variable "network" {}
variable "mac_address" {}
variable "disk_size" {
  type = number
  default = 8192
}
variable "disk_thin_provisioned" {
  type = bool
  default = true
}
variable "guest_os_type" {}

variable "vm_name" {}

# Build
variable "boot_command" {}
variable "http_directory" {}
// variable "http_proxy" {}
// variable "https_proxy" {}
// variable "no_proxy" {}


# SSH
variable "ssh_username" {}
variable "ssh_password" {
  type = string
  default = ""
  sensitive = true
}
# vCenter
variable "vcenter_address" {}
variable "vcenter_ignore_ssl" {
  type = bool
  default = true
}
variable "vcenter_user" {}
variable "vcenter_password" {
  type = string
  default = ""
  sensitive = true
}
variable "vcenter_dc" {}
variable "vcenter_cluster" {}
variable "vcenter_host" {}
variable "vcenter_datastore" {}
variable "vcenter_folder" {}
variable "vcenter_content_library" {}
# OS Data