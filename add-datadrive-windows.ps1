# add-data-drive-windows.ps1

Write-Output "Starting setup..."

try {
    # Change DVD drive letter to Z:
    $dvdDrive = Get-WmiObject -Query "SELECT * FROM Win32_CDROMDrive" | Select-Object -First 1
    if ($dvdDrive) {
        $dvdDriveLetter = $dvdDrive.Drive.Substring(0, 2)  # Extract the current drive letter (e.g., 'D:')
        $volume = Get-Volume -DriveLetter $dvdDriveLetter
        if ($volume) {
            Write-Output "Changing DVD drive letter from $dvdDriveLetter to Z:"
            Set-Partition -DriveLetter $dvdDriveLetter -NewDriveLetter Z
        } else {
            Write-Output "No volume found for DVD drive letter $dvdDriveLetter"
        }
    } else {
        Write-Output "No DVD drive found"
    }

    # Initialize data drives
    $disks = Get-Disk | Where-Object partitionstyle -eq 'raw' | Sort-Object number
    $letters = 68..87 | ForEach-Object { [char]$_ }
    $count = 0
    $labels = "data1","data2"

    foreach ($disk in $disks) {
        $driveLetter = $letters[$count].ToString()
        Write-Output "Initializing disk number $($disk.Number) with drive letter $driveLetter"
        $disk |
        Initialize-Disk -PartitionStyle MBR -PassThru |
        New-Partition -UseMaximumSize -DriveLetter $driveLetter |
        Format-Volume -FileSystem NTFS -NewFileSystemLabel $labels[$count] -Confirm:$false -Force
        $count++
    }

    Write-Output "Setup complete."
} catch {
    Write-Output "An error occurred: $_"
    throw
}
