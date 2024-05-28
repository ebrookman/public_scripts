# Check if the D: drive is already provisioned
if (Get-Volume -DriveLetter D -ErrorAction SilentlyContinue) {
    Write-Output "D: drive is already provisioned. Exiting script."
    exit
}

# Initialize variables
$DataDisk = Get-Disk | Where-Object { $_.PartitionStyle -eq 'RAW' }
$Volume = Get-Partition -DiskNumber $DataDisk.Number | Where-Object { $_.DriveLetter -eq $null }

# Format the data disk
$Volume | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Data" -Confirm:$false

# Assign a drive letter to the data disk
$Volume | Add-PartitionAccessPath -AccessPath "D:\" -AssignDriveLetter

# Persist the drive letter assignment
Set-Partition -DriveLetter "D" -NewDriveLetter "D" -Confirm:$false

Write-Output "Data disk formatted and assigned to D: drive."
