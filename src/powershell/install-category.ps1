$ErrorActionPreference = "SilentlyContinue"

$category = $env:CATEGORY

Write-Output "Installing packages for category $category"

$ret = ""
try {
    $ret = iex "choco install C:\\packages\\$category.config -y"
}
catch {

}

Write-Output "$ret"

exit 0
