# Define backup location
$BackupPath = "D:\ExplorerFavoritesBackup" # Change this to your preferred backup locatio
$QuickAccessPath1 = "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations"
$QuickAccessPath2 = "$env:APPDATA\Microsoft\Windows\Recent\CustomDestinations"
$RegistryBackup = "$BackupPath\QuickAccessRegistry.reg"

Write-Host "Backing up File Explorer Quick Access favorites..."

# Ensure backup directory exists
if (!(Test-Path $BackupPath)) {
    New-Item -ItemType Directory -Path $BackupPath -Force
}

# Backup Quick Access files
if (Test-Path $QuickAccessPath1) {
    robocopy $QuickAccessPath1 "$BackupPath\AutomaticDestinations" /E /R:1 /W:1
}
if (Test-Path $QuickAccessPath2) {
    robocopy $QuickAccessPath2 "$BackupPath\CustomDestinations" /E /R:1 /W:1
}

# Backup Registry settings
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\QuickAccess" $RegistryBackup /y

Write-Host "Backup completed successfully!"