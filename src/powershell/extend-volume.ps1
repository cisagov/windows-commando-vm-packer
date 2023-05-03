Write-Output "[ ] Attempting to extend C drive volume"

# Scan the disk to detect the current volume size
"rescan" | diskpart

# Get the C drive volume
$originalVolumeSizeGB = $(Get-Volume -DriveLetter C).Size / 1GB

# Get the C drive partition to the maximum Amazon EBS volume size available
Resize-Partition -DriveLetter C -Size $(Get-PartitionSupportedSize -DriveLetter C).SizeMax

# Rescan the disk to detect the updated volume size
"rescan" | diskpart

# Verify the C drive volume was extended
$volumeSizeGB = $(Get-Volume -DriveLetter C).Size / 1GB
Write-Output "[ ] Verifying C drive volume was extended"
if ($volumeSizeGB -le $originalVolumeSizeGB) {
    Write-Error "[X] Failed to extend C drive volume" -ErrorAction Stop
}

Write-Output "[*] Successfully extended C drive volume: $volumeSizeGB GB"
