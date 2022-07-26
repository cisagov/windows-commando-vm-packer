$category = $env:CATEGORY
$ErrorActionPreference = "Continue"

try {
    iex "choco install C:\\packages\\$category.config -y"
}
catch { }
