variable "ami_regions" {
  default     = []
  description = "The list of AWS regions to copy the AMI to once it has been created. Example: [\"us-east-1\"]"
  type        = list(string)
}

variable "build_region" {
  default     = "us-east-1"
  description = "The region in which to retrieve the base AMI from and build the new AMI."
  type        = string
}

variable "build_region_kms" {
  default     = "alias/cool-amis"
  description = "The ID or ARN of the KMS key to use for AMI encryption."
  type        = string
}

variable "is_prerelease" {
  default     = false
  description = "The pre-release status to use for the tags applied to the created AMI."
  type        = bool
}

variable "region_kms_keys" {
  default     = {}
  description = "A map of regions to copy the created AMI to and the KMS keys to use for encryption in that region. The keys for this map must match the values provided to the aws_regions variable. Example: {\"us-east-1\": \"alias/example-kms\"}"
  type        = map(string)
}

variable "release_tag" {
  default     = ""
  description = "The GitHub release tag to use for the tags applied to the created AMI."
  type        = string
}

variable "release_url" {
  default     = ""
  description = "The GitHub release URL to use for the tags applied to the created AMI."
  type        = string
}

variable "skip_create_ami" {
  default     = false
  description = "Indicate if Packer should not create the AMI."
  type        = bool
}

# The 'winrm_password' variable is configured as an optional variable because
# the cisagov/pre-commit-packer hook does not support passing variables to
# `packer validate`. Once this limitation is removed this should be changed to
# a required variable. Please see the following for more information:
# https://github.com/cisagov/windows-server-packer/issues/21
variable "winrm_password" {
  default     = ""
  description = "The password used to connect to the instance via WinRM."
  sensitive   = true
  type        = string
}

variable "winrm_username" {
  default     = "Administrator"
  description = "The username used to connect to the instance via WinRM."
  type        = string
}

data "amazon-ami" "windows_server_2022" {
  filters = {
    name                = "Windows_Server-2022-English-Full-Base-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["amazon"]
  region      = var.build_region
}


locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "windows" {
  ami_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/xvda"
    encrypted             = true
    volume_size           = 500
    volume_type           = "gp3"
  }
  ami_name                    = "windows-commando-vm-${local.timestamp}-x86_64-ebs"
  ami_regions                 = var.ami_regions
  associate_public_ip_address = true
  communicator                = "winrm"
  encrypt_boot                = true
  instance_type               = "t3.large"
  kms_key_id                  = var.build_region_kms
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/xvda"
    encrypted             = true
    no_device             = false
    volume_size           = 500
    volume_type           = "gp3"
  }
  region             = var.build_region
  region_kms_key_ids = var.region_kms_keys
  skip_create_ami    = var.skip_create_ami
  source_ami         = data.amazon-ami.windows_server_2022.id
  subnet_filter {
    filters = {
      "tag:Name" = "AMI Build"
    }
  }
  tags = {
    Application        = "Windows Commando VM"
    Base_AMI_Name      = data.amazon-ami.windows_server_2022.name
    GitHub_Release_URL = var.release_url
    OS_Version         = "Windows Server 2022"
    Pre_Release        = var.is_prerelease
    Release            = var.release_tag
    Team               = "VM Fusion - Development"
  }
  user_data_file = "src/winrm_bootstrap.txt"
  vpc_filter {
    filters = {
      "tag:Name" = "AMI Build"
    }
  }
  winrm_insecure = true
  winrm_password = var.winrm_password
  winrm_timeout  = "20m"
  winrm_use_ssl  = true
  winrm_username = var.winrm_username
}

build {
  sources = [
    "source.amazon-ebs.windows"
  ]

  provisioner "powershell" {
    # Wait 10 seconds before executing the disable-defender.ps1 powershell script.
    # This gives a small grace period between booting up for the first time and running the first provisioner.
    pause_before = "10s"
    scripts      = ["src/powershell/disable-defender.ps1"]
  }

  provisioner "windows-restart" {
    # Wait a maximum of 30 minutes for Windows to restart.
    # The build will fail if the restart process takes longer than 30 minutes.
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    # Wait 30 seconds before executing the next provisioner.
    # This gives a grace period between restarting Windows and running the next provisioner.
    pause_before = "30s"
    scripts = [
      "src/powershell/check-defender.ps1",
      "src/powershell/enable-rdp.ps1",
      "src/powershell/initialize-volume.ps1",
      "src/powershell/install-chocolatey.ps1"
    ]
  }

  provisioner "powershell" {
    # Create "packages" directory before uploading them in the next provisioner.
    inline = ["mkdir D:\\packages"]
  }

  provisioner "file" {
    # Upload package lists to the "packages" directory.
    destination = "D:\\packages"
    source      = "src/packages/"
  }

  provisioner "powershell" {
    # Install general packages
    environment_vars = ["CATEGORY=general"]
    script           = "src/powershell/install-category.ps1"
  }

  provisioner "windows-restart" {
    # Wait a maximum of 30 minutes for Windows to restart.
    # The build will fail if the restart process takes longer than 30 minutes.
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    # Install Docker packages
    environment_vars = ["CATEGORY=docker"]
    script           = "src/powershell/install-category.ps1"
  }

  provisioner "windows-restart" {
    # Wait a maximum of 30 minutes for Windows to restart.
    # The build will fail if the restart process takes longer than 30 minutes.
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    # Install evasion packages
    environment_vars = ["CATEGORY=evasion"]
    script           = "src/powershell/install-category.ps1"
  }

  provisioner "windows-restart" {
    # Wait a maximum of 30 minutes for Windows to restart.
    # The build will fail if the restart process takes longer than 30 minutes.
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    # Install exploitation packages
    environment_vars = ["CATEGORY=exploitation"]
    script           = "src/powershell/install-category.ps1"
  }

  provisioner "windows-restart" {
    # Wait a maximum of 30 minutes for Windows to restart.
    # The build will fail if the restart process takes longer than 30 minutes.
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    # Install information gathering packages
    script           = "src/powershell/install-category.ps1"
    environment_vars = ["CATEGORY=information-gathering"]
  }

  provisioner "windows-restart" {
    # Wait a maximum of 30 minutes for Windows to restart.
    # The build will fail if the restart process takes longer than 30 minutes.
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    # Install Kali packages
    environment_vars = ["CATEGORY=kali"]
    script           = "src/powershell/install-category.ps1"
  }

  provisioner "windows-restart" {
    # Wait a maximum of 30 minutes for Windows to restart.
    # The build will fail if the restart process takes longer than 30 minutes.
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    # Install networking packages
    environment_vars = ["CATEGORY=networking"]
    script           = "src/powershell/install-category.ps1"
  }

  provisioner "windows-restart" {
    # Wait a maximum of 30 minutes for Windows to restart.
    # The build will fail if the restart process takes longer than 30 minutes.
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    # Install password packages
    environment_vars = ["CATEGORY=passwords"]
    script           = "src/powershell/install-category.ps1"
  }

  provisioner "windows-restart" {
    # Wait a maximum of 30 minutes for Windows to restart.
    # The build will fail if the restart process takes longer than 30 minutes.
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    # Install reverse engineering packages
    environment_vars = ["CATEGORY=reverse-engineering"]
    script           = "src/powershell/install-category.ps1"
  }

  provisioner "windows-restart" {
    # Wait a maximum of 30 minutes for Windows to restart.
    # The build will fail if the restart process takes longer than 30 minutes.
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    # Install utility packages
    environment_vars = ["CATEGORY=utilities"]
    script           = "src/powershell/install-category.ps1"
  }

  provisioner "windows-restart" {
    # Wait a maximum of 30 minutes for Windows to restart.
    # The build will fail if the restart process takes longer than 30 minutes.
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    # Install vulnerability analysis packages
    environment_vars = ["CATEGORY=vulnerability-analysis"]
    script           = "src/powershell/install-category.ps1"
  }

  provisioner "windows-restart" {
    # Wait a maximum of 30 minutes for Windows to restart.
    # The build will fail if the restart process takes longer than 30 minutes.
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    # Install web application packages
    environment_vars = ["CATEGORY=web-applications"]
    script           = "src/powershell/install-category.ps1"
  }

  provisioner "windows-restart" {
    # Wait a maximum of 30 minutes for Windows to restart.
    # The build will fail if the restart process takes longer than 30 minutes.
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    # Install wordlist packages
    environment_vars = ["CATEGORY=wordlists"]
    script           = "src/powershell/install-category.ps1"
  }

  provisioner "windows-restart" {
    # Wait a maximum of 30 minutes for Windows to restart.
    # The build will fail if the restart process takes longer than 30 minutes.
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    inline = ["Write-Output 'Complete!'"]
  }
}
