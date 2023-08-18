$category = $env:Category
$driveLetter = $env:DriveLetter
$packagesDir = $env:PackagesDir
Write-Output "Installing packages for category ${category} in ${driveLetter}:\\${packagesDir}"

# Set Chocolatey install directory to the assigned drive letter
# This must be re-set in between Windows restarts
setx ChocolateyInstall ${driveLetter}:\Chocolatey /M
SET "ChocolateyInstall=${driveLetter}:\Chocolatey"

[xml]$xml = Get-Content "${driveLetter}:\\${packagesDir}\\${category}.config"

$xml.SelectNodes("//$packagesDir/package") | ForEach-Object {
    $packageID = $_.id
    Write-Output "### current package: $packageID ####################################################"
    choco upgrade $packageID --yes --no-progress
}

# Reference Chocolatey profile and refresh environment variables
Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
refreshenv

exit 0
