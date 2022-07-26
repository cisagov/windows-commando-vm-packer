# Download and execute Chocolatey install script
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Configure chocolatey to use FireEye's package repository
choco sources add -n=fireeye -s https://www.myget.org/F/fireeye/api/v2 --priority 1
choco upgrade -y vcredist-all.flare
refreshenv
