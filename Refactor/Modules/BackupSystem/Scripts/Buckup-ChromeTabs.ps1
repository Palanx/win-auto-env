# Define backup and restore paths
$ChromeProfilePath = "$env:LOCALAPPDATA\Google\Chrome\User Data" # Change this to your preferred backup location
$BackupPath = "D:\AutoBackups\ChromeBackup"

if (Test-Path $ChromeProfilePath) {
    Write-Host "Backing up Chrome profile..."
    robocopy $ChromeProfilePath $BackupPath /E /XD "Cache" "Code Cache" "Service Worker" /R:1 /W:1
    Write-Host "Backup completed successfully."
} else {
    Write-Host "Chrome profile not found!"
}
