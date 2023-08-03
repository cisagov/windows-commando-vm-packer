Write-Output "[ ] Attempting to extend C drive volume"

Stop-Service -Name ShellHWDetection
Get-Disk | Where PartitionStyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "EBS Volume" -Confirm:$false
Start-Service -Name ShellHWDetection

$orignalDDriveVolumeSizeGB = $(Get-Volume -DriveLetter C).Size / 1GB

Write-Output "D drive volume size: $orignalDDriveVolumeSizeGB"

# Scan the disk to detect the current volume size
"rescan" | diskpart

# Get the current C drive volume
$originalVolumeSizeGB = $(Get-Volume -DriveLetter C).Size / 1GB

# Partition the C drive to the maximum Amazon EBS volume size available
Resize-Partition -DriveLetter C -Size $(Get-PartitionSupportedSize -DriveLetter C).SizeMax -ErrorAction "continue"

# Do not continue if the C drive volume is already extended
if (!$?) {
    Write-Output "[*] C drive volume is already extended: $originalVolumeSizeGB GB"
    return
}

# Rescan the disk to detect the updated volume size
"rescan" | diskpart

# Get the updated C drive volume
$volumeSizeGB = $(Get-Volume -DriveLetter C).Size / 1GB

# Verify the C drive volume was extended
Write-Output "[ ] Verifying C drive volume was extended"
if ($volumeSizeGB -le $originalVolumeSizeGB) {
    Write-Error "[X] Failed to extend C drive volume" -ErrorAction Stop
}

Write-Output "[*] Successfully extended C drive volume: $volumeSizeGB GB"
