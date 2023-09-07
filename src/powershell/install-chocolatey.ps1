# Install and configure Chocolatey
# See: https://community.chocolatey.org/

function Install-Chocolatey {
    # Download and execute the Chocolatey install script
    iex ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))
}

function Set-ChocoConfig {
    # Configure Chocolatey to reference packages from Mandiant's VM-Packages repository
    # See: https://github.com/mandiant/VM-Packages
    iex "choco sources add --name vm-packages --source 'https://www.myget.org/F/vm-packages/api/v2;https://myget.org/F/vm-packages/api/v2' --priority 1"
    iex "choco feature enable --name allowGlobalConfirmation"
    iex "choco feature enable --name allowEmptyChecksums"
    Write-Output "[*] Chocolatey successfully configured to use Mandiant VM-Packages repository"

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
}

Write-Output "[ ] Attempting to install and configure Chocolatey"

# Download and execute Chocolatey install script
Set-ExecutionPolicy Bypass -Scope Process -Force

# Enable TLS 1.2 support for .NET framework using the security protocol type 3072
# See https://learn.microsoft.com/en-us/dotnet/api/system.net.securityprotocoltype?view=net-5.0#fields
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

try {
    # Download and execute the Chocolatey install script
    Install-Chocolatey
    Set-ChocoConfig
    Write-Output "[*] Chocolatey successfully installed and configured"
} catch {
    Write-Error "[*] Failed to install and configure Chocolatey" -ErrorAction Stop
}

# Install Microsoft C and C++ runtime libraries
choco upgrade --yes vcredist-all

# Install common Flare VM packages
choco install common.vm --yes --force

# Reference Chocolatey profile and refresh environment variables
Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
refreshenv
