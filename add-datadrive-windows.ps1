# add-data-drive-windows.ps1

Write-Output "Starting setup..."

    # Change DVD drive letter to Z:
    #$dvdDrive = Get-WmiObject -Query "SELECT * FROM Win32_CDROMDrive" | Select-Object -First 1
          #  Write-Output "Changing DVD drive letter from D: to Z:"
          #  Set-Partition -DriveLetter D -NewDriveLetter Z


    # Initialize data drives
    $disks = Get-Disk | Where-Object partitionstyle -eq 'raw' | Sort-Object number
    $letters = 68..87 | ForEach-Object { [char]$_ }
    $count = 0
    $labels = "data1","data2"

    foreach ($disk in $disks) {
        $driveLetter = $letters[$count].ToString()
        Write-Output "Initializing disk number $($disk.Number) with drive letter $driveLetter"
        $disk |
        Initialize-Disk -PartitionStyle GPT -PassThru |
        New-Partition -UseMaximumSize -DriveLetter $driveLetter |
        Format-Volume -FileSystem NTFS -NewFileSystemLabel $labels[$count] -Confirm:$false -Force
        $count++
    }

    Write-Output "Setup complete."
