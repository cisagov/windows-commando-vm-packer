$category = $env:Category
$packagesDir = $env:PackagesDir
Write-Output "Installing packages for category ${category} in C:\\${packagesDir}"

[xml]$xml = Get-Content "C:\\${packagesDir}\\${category}.config"

$xml.SelectNodes("//$packagesDir/package") | ForEach-Object {
    $packageID = $_.id
    Write-Output "### current package: $packageID ####################################################"
    Install-BoxstarterPackage -PackageName $packageID
}

exit 0
