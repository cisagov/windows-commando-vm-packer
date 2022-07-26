$ErrorActionPreference = "SilentlyContinue"

$category = $env:CATEGORY

try {
    $ret = iex "choco install C:\\packages\\$category.config -y"
}
catch {

}

exit 0
