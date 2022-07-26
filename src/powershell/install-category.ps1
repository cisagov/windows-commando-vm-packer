$category = $env:CATEGORY
$ErrorActionPreference = "Continue"
iex "choco install C:\\packages\\$category.config -y"
