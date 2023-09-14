# Install and configure Boxstarter
# See: https://boxstarter.org/
function Install-Boxstarter {
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://boxstarter.org/bootstrapper.ps1"))
    Get-Boxstarter -Force
}

function Set-BoxstarterConfiguration {
    $Boxstarter.RebootOk = (-not $noReboots.IsPresent)
    $Boxstarter.AutoLogin = $true
    $Boxstarter.SuppressLogging = $true
    $global:VerbosePreference = "SilentlyContinue"

    # Add Chocolatey and Mandiant VM-Packages repositories as Boxstarter sources
    Set-BoxstarterConfig -NugetSources "$desktopPath;.;https://www.myget.org/F/vm-packages/api/v2;https://chocolatey.org/api/v2"

    # Import Boxstarter Chocolatey module to enable Chocolatey commands
    Import-Module "${Env:ProgramData}\boxstarter\boxstarter.chocolatey\boxstarter.chocolatey.psd1" -Force
}

# Change some Windows Explorer configuration options. This matches the configuration
# performed for Commando VM images:
# https://github.com/mandiant/commando-vm/blob/688599b87966c757524a7a19a9a6de2359885b3f/install.ps1#L1050
function Configure-Windows-Explorer {
    # See: https://boxstarter.org/winconfig#set-windowsexploreroptions
    Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowFullPathInTitleBar
}

Write-Output "[ ] Attempting to install and configure Boxstarter"

try {
    # Install Boxstarter
    Install-Boxstarter
    # Set Boxstarter configuration
    Set-BoxstarterConfiguration
    # Set Windows Explorer options
    Set-BoxstarterWindowsExplorerOptions

    Write-Output "[*] Boxstarter successfully installed and configured"
} catch {
    Write-Error "[*] Failed to install and configure Boxstarter" -ErrorAction Stop
}
