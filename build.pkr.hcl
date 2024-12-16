build {
  sources = [
    # There are no Windows Server ARM64 base AMIs.
    # "source.amazon-ebs.arm64",
    "source.amazon-ebs.x86_64",
  ]

  provisioner "powershell" {
    # Wait 10 seconds before executing the disable-defender.ps1 powershell script.
    # This gives a small grace period between booting up for the first time and running the first provisioner.
    pause_before = "10s"
    scripts      = ["ansible/powershell/disable-defender.ps1"]
  }

  provisioner "windows-restart" {
    # Wait a maximum of 5 minutes for Windows to restart. The build will fail
    # if the restart process takes longer than 5 minutes.
    restart_timeout = "5m"
  }

  provisioner "powershell" {
    # Wait 30 seconds before executing the next provisioner. This gives a grace
    # period between restarting Windows and running the next provisioner.
    # Disable Windows Defender, enable and configure RDP, set the desktop
    # wallpaper, and install Chocolatey and Boxstarter.
    pause_before = "30s"
    scripts = [
      "ansible/powershell/check-defender.ps1",
      "ansible/powershell/enable-rdp.ps1",
      "ansible/powershell/set-wallpaper.ps1",
      "ansible/powershell/install-chocolatey.ps1",
      "ansible/powershell/install-boxstarter.ps1"
    ]
  }

  provisioner "windows-restart" {
    # Wait a maximum of 5 minutes for Windows to restart. The build will fail
    # if the restart process takes longer than 5 minutes.
    restart_timeout = "5m"
  }

  provisioner "powershell" {
    # Create "packages" directory before uploading them in the next provisioner.
    inline = ["mkdir C:\\${var.packages_dir}"]
  }

  provisioner "file" {
    # Upload package lists to the "packages" directory.
    destination = "C:\\${var.packages_dir}"
    source      = "ansible/${var.packages_dir}/"
  }

  provisioner "powershell" {
    # Install general packages.
    environment_vars = ["Category=general", "PackagesDir=${var.packages_dir}"]
    script           = "ansible/powershell/install-category.ps1"
  }

  provisioner "powershell" {
    # Install virtual machine packages managed by Mandiant.
    # See: https://github.com/mandiant/VM-Packages/tree/main/packages
    environment_vars = ["Category=mandiant-vm", "PackagesDir=${var.packages_dir}"]
    script           = "ansible/powershell/install-category.ps1"
  }

  provisioner "powershell" {
    inline = ["Write-Output 'Complete!'"]
  }
}
