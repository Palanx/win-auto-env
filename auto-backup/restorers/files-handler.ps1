# Define backup destination
$BackupLocation = "D:\FileBackup" # Change this to your preferred backup location

# Define paths to back up using $env:USERPROFILE (makes script portable)
$PathsToBackup = @(
    "$env:USERPROFILE\OneDrive\Documents\FromSoftware",
    "$env:USERPROFILE\OneDrive\Documents\My Games",
    "$env:USERPROFILE\OneDrive\Documents\NBGI",
    "$env:USERPROFILE\OneDrive\Imágenes",
    "$env:USERPROFILE\OneDrive\Escritorio",
    "$env:USERPROFILE\AppData\Roaming\DS4Windows",
    "$env:USERPROFILE\AppData\Roaming\G HUB"
)

Write-Host "Starting restore process..."

foreach ($Path in $PathsToBackup) {
    $BackupTarget = $Path -replace [regex]::Escape($env:USERPROFILE), "$BackupLocation"
    
    if (Test-Path $BackupTarget) {
        Write-Host "Restoring: $BackupTarget -> $Path"
        robocopy $BackupTarget $Path /E /R:1 /W:1 /XO
    } else {
        Write-Host "Skipping (backup not found): $BackupTarget"
    }
}

Write-Host "Restore completed!"