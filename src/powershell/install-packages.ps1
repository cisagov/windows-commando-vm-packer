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
    iex "choco upgrade C:\\packages\\$p.config -y"
    refreshenv
}
