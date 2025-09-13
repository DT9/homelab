variable "admin_username" {
  type    = string
  default = "packer"
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "iso_path" {
  type    = string
  default = "C:/ISOs/en-us_windows_10_enterprise_ltsc_2021_x64_dvd_b4b31a3a.iso"
}

variable "iso_checksum" {
  type    = string
  default = "SHA256:B4B31A3A362E8942621A58F9B6636735E2F0A889A121D50E34B688A73C9A5A4A"
}

variable "vm_name" {
  type    = string
  default = "windows-golden-image"
}

packer {
  required_plugins {
    hyperv = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/hyperv"
    }
  }
}

source "hyperv-iso" "windows" {
  # VM and Builder Configuration
  vm_name                       = var.vm_name
  headless                      = true
  cpus                          = 4
  ram_size                      = 8192
  disk_size                     = 81920
  enable_secure_boot            = true
  enable_tpm                    = true
  generation                    = 2
  output_directory              = "output"
  temp_path                     = "."
  switch_name                   = "Default Switch" # Replace with your Hyper-V switch if needed

  # ISO and Boot Configuration
  iso_url                       = var.iso_path
  iso_checksum                  = var.iso_checksum
  http_directory                = "http"
  boot_command                  = ["<spacebar><wait5s><enter><wait60s>"] # Press space to boot from DVD, then Enter for setup
  boot_wait                     = "2m"

  # Communicator Settings
  communicator                  = "winrm"
  winrm_username                = var.admin_username
  winrm_password                = var.admin_password
  winrm_timeout                 = "4h"
  winrm_use_ssl                 = true
  winrm_insecure                = true

  # Floppy files for Autounattend.xml (alternative to http_directory)
  # floppy_files = [
  #   "http/Autounattend.xml"
  # ]
}

build {
  name    = "windows-golden-image-build"
  sources = ["source.hyperv-iso.windows"]

  provisioner "powershell" {
    inline = ["Install-Module -Name PSWindowsUpdate -Force -Confirm:$false -SkipPublisherCheck"]
  }

  provisioner "powershell" {
    inline = ["Get-WindowsUpdate -AcceptAll -Install -AutoReboot | Out-Null"]
  }


  provisioner "powershell" {
    scripts = [
      "scripts/00_install_choco.ps1",
      "scripts/01_install_software.ps1",
      "scripts/01a_install_nvidia_driver.ps1",
      "scripts/02_hardening_cis.ps1",
      "scripts/03_remove_bloatware.ps1",
      "scripts/05_validation.ps1",
      "scripts/04_cleanup.ps1"
    ]
  }

  provisioner "windows-restart" {
    restart_timeout = "30m"
  }
} 