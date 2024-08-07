# This file was autogenerated by the BETA 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/from-1.5/variables#type-constraints for more info.

# "timestamp" template function replacement
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/from-1.5/blocks/source

source "vsphere-iso" "arch" {
  boot_command         = "${var.boot_command}"
  boot_wait            = "5s"
  CPUs                 = "${var.cpus}"
  RAM                  = "${var.ram}"
  boot_order           = "disk,cdrom"
  convert_to_template  = true
  datacenter           = "${var.vcenter_dc}"
  datastore            = "${var.vcenter_datastore}"
  disk_controller_type = ["pvscsi"]
  folder               = "${var.vcenter_folder}"
  guest_os_type        = "${var.guest_os_type}"
  #  cluster              = "${var.vcenter_cluster}"
  host                = "${var.vcenter_host}"
  http_directory      = "${var.http_directory}"
  insecure_connection = "${var.vcenter_ignore_ssl}"
  iso_url             = "${var.iso_url}"
  iso_checksum        = "${var.iso_checksum}"

  network_adapters {
    network      = "${var.network}"
    network_card = "vmxnet3"
    mac_address  = "${var.mac_address}"
  }

  password               = "${var.vcenter_password}"
  shutdown_command       = "sudo systemctl start systemd-poweroff.service"
  ssh_handshake_attempts = "200"
  ssh_password           = "${var.ssh_password}"
  ssh_port               = 22
  ssh_username           = "${var.ssh_username}"
  ssh_timeout            = "600s"

  storage {
    disk_size             = "${var.disk_size}"
    disk_thin_provisioned = "${var.disk_thin_provisioned}"
  }

  username       = "${var.vcenter_user}"
  vcenter_server = "${var.vcenter_address}"
  vm_name        = "${var.vm_name}"
}

build {
  name    = "arch-vsphere-iso"
  sources = ["source.vsphere-iso.arch"]

  provisioner "shell" {
    environment_vars = [
      "COUNTRY=${var.country}",
      "use_local_mirror=${var.use_local_mirror}",
      "password=${var.ssh_password}"
    ]
    valid_exit_codes = [0, 2300218]
    execute_command = "{{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    script          = "scripts/install-base.sh"
  }

  provisioner "shell" {
    inline            = ["sudo /usr/bin/systemctl reboot"]
    expect_disconnect = true
    pause_after       = "30s"
    skip_clean        = true
  }

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    only            = ["vsphere-iso"]
    script          = "scripts/install-vmware.sh"
  }

  provisioner "shell" {
    environment_vars = [
      "WRITE_ZEROS=${var.write_zeros}"
    ]
    execute_command = "{{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    script          = "scripts/cleanup.sh"
  }
}
