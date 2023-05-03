Write-Output "[ ] Attempting to extend C drive volume"

# Rescan the disk to detect the current volume size
"rescan" | diskpart

# Get the C drive partition to the maximum Amazon EBS volume size
Resize-Partition -DriveLetter C -Size $(Get-PartitionSupportedSize -DriveLetter C).SizeMax

# Verify the C drive volume was extended
$volumeSize = Get-Volume -DriveLetter C
$volumeSizeGB = $volumeSize.Size / 1GB
Write-Output "[ ] Verifying C drive volume was extended"
if ($volumeSize.Size -ne $volumeSize.SizeRemaining) {
    Write-Error "[X] Failed to extend C drive volume" -ErrorAction Stop
}

Write-Output "[*] Successfully extended C drive volume: $volumeSizeGB GB"
