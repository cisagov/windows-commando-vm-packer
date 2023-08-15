Write-Output "[ ] Attempting to initialize D drive volume"

# Initialize a raw disk from an EBS volume and assign it to drive letter D
Stop-Service -Name ShellHWDetection
Get-Disk | Where PartitionStyle -eq "raw" | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "EBS Volume" -Confirm:$false
Start-Service -Name ShellHWDetection

# Get the D drive volume size in GB
$volumeSizeGB = $(Get-Volume -DriveLetter D).Size / 1GB

Write-Output "[*] Successfully initialized D drive volume: $volumeSizeGB GB"
