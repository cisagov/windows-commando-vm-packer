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
    iex "choco install C:\\packages\\$p.config -y"
    refreshenv
}

Write-Output "[*] Exiting with code 0"
Exit 0
