$driveLetter = $env:DriveLetter
Write-Output "[ ] Attempting to initialize $driveLetter drive volume"

# Initialize a raw disk from an EBS volume and assign it to a specified drive letter
Stop-Service -Name ShellHWDetection
Get-Disk | Where PartitionStyle -eq "raw" | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -DriveLetter $driveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "EBS Volume" -Confirm:$false
Start-Service -Name ShellHWDetection

# Get the assigned drive volume size in GB
$volumeSizeGB = $(Get-Volume -DriveLetter $driveLetter).Size / 1GB

Write-Output "[*] Successfully initialized $driveLetter drive volume: $volumeSizeGB GB"
