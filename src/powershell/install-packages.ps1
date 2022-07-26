$packages = @(
    "general",
    "docker",
    "evasion",
    "exploitation",
    "information-gathering",
    "kali",
    "networking",
    "passwords",
    "reverse-engineering",
    "utilities",
    "vulnerability-analysis",
    "web-applications",
    "word-lists"
)

foreach ($p in $packages) {
    iex "choco install C:\\packages\\$p.config -y -force"
    Get-PSDrive
}
