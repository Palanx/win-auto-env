# Define backup file location
$BackupFile = "D:\DriveLetterBackup.txt"  # Change this to your preferred backup location

if (!(Test-Path $BackupFile)) {
    Write-Host "Backup file not found! Exiting..."
    exit
}

Write-Host "Restoring drive letter assignments..."
$backupData = Get-Content $BackupFile

foreach ($line in $backupData) {
    $parts = $line -split " "
    $driveLetter = $parts[0]
    $deviceID = $parts[1]

    $drive = Get-WmiObject Win32_Volume | Where-Object { $_.DeviceID -eq $deviceID }
    if ($drive) {
        Write-Host "Assigning $driveLetter to $($drive.DeviceID)..."
        $drive.DriveLetter = $driveLetter
        $drive.Put()
    }
}

Write-Host "Restore completed! Restarting Explorer..."
Stop-Process -Name explorer -Force
Start-Process explorer