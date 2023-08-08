Write-Output "[ ] Attempting to initialize D drive volume"

# Initialize Raw Disk from EBS Volume and Assign it to Drive letter D
Stop-Service -Name ShellHWDetection
Get-Disk | Where PartitionStyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "EBS Volume" -Confirm:$false
Start-Service -Name ShellHWDetection

# Get the D drive volume
$volumeSizeGB = $(Get-Volume -DriveLetter D).Size / 1GB

Write-Output "[*] Successfully initialized D drive volume: $volumeSizeGB GB"
