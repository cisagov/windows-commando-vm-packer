$category = $env:CATEGORY
Write-Output "Installing packages for category $category"

[xml]$xml = Get-Content "C:\\packages\\$category.config"

$xml.SelectNodes('//packages/package') | ForEach-Object {
    $packageID = $_.id
    Write-Output "### current package: $packageID ####################################################"
    choco upgrade $packageID --yes --no-progress
}

exit 0
