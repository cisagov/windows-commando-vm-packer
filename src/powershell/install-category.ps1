$ErrorActionPreference = "SilentlyContinue"

$category = $env:CATEGORY
Write-Output "Installing packages for category $category"

[xml]$xml = Get-Content "C:\\packages\\$category.config"

$xml.SelectNodes('//packages/package') | ForEach-Object {
    $packageID = $_.id
    Write-Output "### current package: $packageID ####################################################"
    try { choco upgrade $packageID -y --no-progress }
    catch { }
}

exit 0
