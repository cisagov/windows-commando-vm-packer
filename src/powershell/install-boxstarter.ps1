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

    # Set Windows Explorer options
    # See: https://boxstarter.org/winconfig#set-windowsexploreroptions
    Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowFullPathInTitleBar

    # Import Boxstarter Chocolatey module to enable Chocolatey commands
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
