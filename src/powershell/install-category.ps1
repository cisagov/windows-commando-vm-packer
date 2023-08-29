$category = $env:Category
$packagesDir = $env:PackagesDir
Write-Output "Installing packages for category ${category} in C:\\${packagesDir}"

[xml]$xml = Get-Content "C:\\${packagesDir}\\${category}.config"

$xml.SelectNodes("//$packagesDir/package") | ForEach-Object {
    $packageID = $_.id
    Write-Output "### current package: $packageID ####################################################"
    choco upgrade $packageID --yes --no-progress
}

exit 0
