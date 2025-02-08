# Define backup and restore paths
$ChromeProfilePath = "$env:LOCALAPPDATA\Google\Chrome\User Data"
$BackupPath = "D:\AutoBackups\ChromeBackup"  # Change this to your preferred backup location

Write-Host "Closing Google Chrome..."
# Attempt to stop Chrome gracefully, fallback to force if needed
$chromeProcesses = Get-Process -Name chrome -ErrorAction SilentlyContinue
if ($chromeProcesses) {
    $chromeProcesses | Stop-Process -Force -ErrorAction SilentlyContinue

    # Wait until all Chrome processes are terminated
    while (Get-Process -Name chrome -ErrorAction SilentlyContinue) {
        Start-Sleep -Milliseconds 500  # Check every 0.5 seconds
    }
    
    Write-Host "Google Chrome has been closed."
} else {
    Write-Host "Google Chrome is not running."
}

if (Test-Path $BackupPath) {
    Write-Host "Restoring Chrome profile..."
    robocopy $BackupPath $ChromeProfilePath /E /R:1 /W:1
    Write-Host "Restore completed successfully."
} else {
    Write-Host "Backup not found!"
}
