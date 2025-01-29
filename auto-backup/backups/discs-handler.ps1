# Define backup location
$BackupFile = "D:\DriveLetterBackup.txt" # Change this to your preferred backup location

Write-Host "Backing up drive letter assignments..."
$drives = Get-WmiObject Win32_Volume | Where-Object { $_.DriveLetter -ne $null } | Select-Object DriveLetter, DeviceID

$drives | ForEach-Object {
    "$($_.DriveLetter) $($_.DeviceID)" | Out-File -Append -FilePath $BackupFile
}

Write-Host "Backup completed! File saved to: $BackupFile"