$category = $env:CATEGORY
$driveLetter = $env:DriveLetter
Write-Output "Set write to $driveLetter drive"
Write-Output "Installing packages for category $category"

# Set Chocolatey install directory to the assigned drive letter
# This must be re-set inbetween Windows restarts
setx ChocolateyInstall ${driveLetter}:\Chocolatey /M
SET "ChocolateyInstall=${driveLetter}:\Chocolatey"

[xml]$xml = Get-Content "${driveLetter}:\\packages\\$category.config"

$xml.SelectNodes("//packages/package") | ForEach-Object {
    $packageID = $_.id
    Write-Output "### current package: $packageID ####################################################"
    choco upgrade $packageID --yes --no-progress
}

# Reference Chocolatey profile and refresh environment variables
Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
refreshenv

exit 0
