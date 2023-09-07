# Install and configure Boxstarter
# See: https://boxstarter.org/
function Install-Boxstarter {
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://boxstarter.org/bootstrapper.ps1"))
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

function Set-BoxstarterConfiguration {
    $Boxstarter.RebootOk = (-not $noReboots.IsPresent)
    $Boxstarter.AutoLogin = $true
    $Boxstarter.SuppressLogging = $true
    $global:VerbosePreference = "SilentlyContinue"
    Set-BoxstarterConfig -NugetSources "$desktopPath;.;https://www.myget.org/F/vm-packages/api/v2;https://chocolatey.org/api/v2"
    Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowFullPathInTitleBar
    Import-Module "${Env:ProgramData}\boxstarter\boxstarter.chocolatey\boxstarter.chocolatey.psd1" -Force
}

Write-Output "[ ] Attempting to install and configure Boxstarter"

try {
    # Install Boxstarter
    Install-Boxstarter
    # Set Boxstarter configuration
    Set-BoxstarterConfiguration
    Write-Output "[*] Boxstarter successfully installed and configured"
} catch {
    Write-Error "[*] Failed to install and configure Boxstarter" -ErrorAction Stop
}
