Write-Output "[ ] Attempting to initialize D drive volume"

# Initialize Raw Disk from EBS Volume and Assign it to Drive letter D
Stop-Service -Name ShellHWDetection
Get-Disk | Where PartitionStyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "EBS Volume" -Confirm:$false
Start-Service -Name ShellHWDetection

# # Scan the disk to detect the current volume size
# "rescan" | diskpart

# # Get the current available disks
# "list disk" | diskpart

# $disks = Get-Disk
# foreach ($disk in $disks)
# {
#     $partitions = Get-Partition -DiskNumber $disk.Number
#     foreach ($partition in $partitions)
#     {
#         Write-Output "LUN Number: $($partition.Number)"
#         Write-Output "Drive Letter: $($partition.DriveLetter)"
#     }
# }

# # Get the current C drive volume
# $originalVolumeSizeGB = $(Get-Volume -DriveLetter C).Size / 1GB

# # Partition the C drive to the maximum Amazon EBS volume size available
# Resize-Partition -DriveLetter C -Size $(Get-PartitionSupportedSize -DriveLetter D).SizeMax -ErrorAction "continue"

# # Do not continue if the C drive volume is already extended
# if (!$?) {
#     Write-Output "[*] C drive volume is already extended: $originalVolumeSizeGB GB"
#     return
# }

# # Rescan the disk to detect the updated volume size
# "rescan" | diskpart

# # Get the current available disks
# "list disk" | diskpart

# Get the D drive volume
$volumeSizeGB = $(Get-Volume -DriveLetter D).Size / 1GB

# # Verify the C drive volume was extended
# Write-Output "[ ] Verifying C drive volume was extended"
# if ($volumeSizeGB -le $originalVolumeSizeGB) {
#     Write-Error "[X] Failed to extend C drive volume" -ErrorAction Stop
# }

Write-Output "[*] Successfully initialized D drive volume: $volumeSizeGB GB"
