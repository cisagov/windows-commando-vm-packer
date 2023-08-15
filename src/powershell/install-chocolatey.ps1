# Download and execute Chocolatey install script
Set-ExecutionPolicy Bypass -Scope Process -Force

# Enable TLS 1.2 support for .NET framework using the security protocal type 3072
# See https://learn.microsoft.com/en-us/dotnet/api/system.net.securityprotocoltype?view=net-5.0#fields
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

# Download and execute the Chocolatey install script
iex ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))

# Configure Chocolatey to use FireEye's package repository
iex "choco sources add --name fireeye --source https://www.myget.org/F/fireeye/api/v2 --priority 1"
iex "choco feature enable --name allowGlobalConfirmation"
iex "choco feature enable --name allowEmptyChecksums"
Write-Output "[*] Chocolatey successfully configured to use FireEye's package repository"

# Disable timeout settings to help with packages that take a long time to install
& powercfg -change -disk-timeout-ac 0 | Out-Null
& powercfg -change -disk-timeout-dc 0 | Out-Null
& powercfg -change -hibernate-timeout-ac 0 | Out-Null
& powercfg -change -hibernate-timeout-dc 0 | Out-Null
& powercfg -change -monitor-timeout-ac 0 | Out-Null
& powercfg -change -monitor-timeout-dc 0 | Out-Null
& powercfg -change -standby-timeout-ac 0 | Out-Null
& powercfg -change -standby-timeout-dc 0 | Out-Null

Write-Output "[*] Timeout settings successfully disabled"

# Install Microsoft C and C++ runtime libraries
iex "choco upgrade --yes vcredist-all.flare"

# Set Chocolatey install directory to D drive
setx ChocolateyInstall D:\Chocolatey /M
SET "ChocolateyInstall=D:\Chocolatey"

# Install Chocolatey profile
Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
refreshenv
