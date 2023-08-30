# Download and execute Chocolatey install script
Set-ExecutionPolicy Bypass -Scope Process -Force

# Enable TLS 1.2 support for .NET framework using the security protocol type 3072
# See https://learn.microsoft.com/en-us/dotnet/api/system.net.securityprotocoltype?view=net-5.0#fields
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

# Download and execute the Chocolatey install script
InstallChocolatey

# Install Microsoft C and C++ runtime libraries
iex "choco upgrade --yes vcredist-all"

# Install Boxstarter
InstallBoxstarter

# Install common Flare VM packages
choco install common.vm -y --force

# Reference Chocolatey profile and refresh environment variables
Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
refreshenv

function InstallChocolatey {
    # Download and execute the Chocolatey install script
    iex ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))

    # Configure Chocolatey to use Mandiant's VM-Packages repository
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

function InstallBoxstarter {
    Import-Module "${Env:ProgramData}\boxstarter\boxstarter.chocolatey\boxstarter.chocolatey.psd1" -Force

    # Install Boxstarter
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1'))
    Get-Boxstarter -Force

    # Fix verbosity issues with Boxstarter v3
    # See: https://github.com/chocolatey/boxstarter/issues/501
    $fileToFix = "${Env:ProgramData}\boxstarter\boxstarter.chocolatey\Chocolatey.ps1"
    $offendingString = 'if ($val -is [string] -or $val -is [boolean]) {'
    if ((Get-Content $fileToFix -raw) -contains $offendingString) {
        $fixString = 'if ($val -is [string] -or $val -is [boolean] -or $val -is [system.management.automation.actionpreference]) {'
        ((Get-Content $fileToFix -raw) -replace [regex]::escape($offendingString),$fixString) | Set-Content $fileToFix
    }
    $fileToFix = "${Env:ProgramData}\boxstarter\boxstarter.chocolatey\invoke-chocolatey.ps1"
    $offendingString = 'Verbose           = $VerbosePreference'
    if ((Get-Content $fileToFix -raw) -contains $offendingString) {
        $fixString = 'Verbose           = ($global:VerbosePreference -eq "Continue")'
        ((Get-Content $fileToFix -raw) -replace [regex]::escape($offendingString),$fixString) | Set-Content $fileToFix
    }
}
