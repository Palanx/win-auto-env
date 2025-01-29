# Define backup file location
$BackupFile = "D:\EnvBackup.txt" # Change this to your preferred backup location

if (!(Test-Path $BackupFile)) {
    Write-Host "Backup file not found! Exiting..."
    exit
}

Write-Host "Restoring environment variables..."

# Read and restore variables
Get-Content $BackupFile | ForEach-Object {
    $parts = $_ -split "=", 2
    $varName = $parts[0]
    $varValue = $parts[1]

    [System.Environment]::SetEnvironmentVariable($varName, $varValue, "User")
    Write-Host "Restored: $varName"
}

Write-Host "Environment variables restored! Restarting Explorer..."
Stop-Process -Name explorer -Force
Start-Process explorer