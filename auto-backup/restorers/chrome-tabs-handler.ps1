# Define backup and restore paths
$ChromeProfilePath = "$env:LOCALAPPDATA\Google\Chrome\User Data"
$BackupPath = "D:\ChromeBackup"  # Change this to your preferred backup location

if (Test-Path $BackupPath) {
    Write-Host "Restoring Chrome profile..."
    robocopy $BackupPath $ChromeProfilePath /E /R:1 /W:1
    Write-Host "Restore completed successfully."
} else {
    Write-Host "Backup not found!"
}
