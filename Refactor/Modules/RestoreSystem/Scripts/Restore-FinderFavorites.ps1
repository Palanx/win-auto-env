# Define backup location
$BackupPath = "D:\AutoBackups\ExplorerFavoritesBackup"  # Change this to your preferred backup location
$QuickAccessPath1 = "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations"
$QuickAccessPath2 = "$env:APPDATA\Microsoft\Windows\Recent\CustomDestinations"
$RegistryBackup = "$BackupPath\QuickAccessRegistry.reg"

Write-Host "Restoring File Explorer Quick Access favorites..."

# Restore Quick Access files
if (Test-Path "$BackupPath\AutomaticDestinations") {
    robocopy "$BackupPath\AutomaticDestinations" $QuickAccessPath1 /E /R:1 /W:1
}
if (Test-Path "$BackupPath\CustomDestinations") {
    robocopy "$BackupPath\CustomDestinations" $QuickAccessPath2 /E /R:1 /W:1
}

# Restore Registry settings
if (Test-Path $RegistryBackup) {
    reg import $RegistryBackup
    Write-Host "Registry settings restored."
} else {
    Write-Host "No Registry backup found!"
}

# TODO: Required restart explorer

Write-Host "Restore completed successfully!"