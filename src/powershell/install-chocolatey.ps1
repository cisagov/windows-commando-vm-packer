# Download and execute Chocolatey install script
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Configure chocolatey to use FireEye's package repository
iex "choco sources add -n=fireeye -s https://www.myget.org/F/fireeye/api/v2 --priority 1"
iex "choco feature enable -n allowGlobalConfirmation"
iex "choco feature enable -n allowEmptyChecksums"

& powercfg -change -monitor-timeout-ac 0 | Out-Null
& powercfg -change -monitor-timeout-dc 0 | Out-Null
& powercfg -change -disk-timeout-ac 0 | Out-Null
& powercfg -change -disk-timeout-dc 0 | Out-Null
& powercfg -change -standby-timeout-ac 0 | Out-Null
& powercfg -change -standby-timeout-dc 0 | Out-Null
& powercfg -change -hibernate-timeout-ac 0 | Out-Null
& powercfg -change -hibernate-timeout-dc 0 | Out-Null

iex "choco upgrade -y vcredist-all.flare"
refreshenv
