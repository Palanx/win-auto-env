# Define backup destination
$BackupLocation = "D:\FileBackup" # Change this to your preferred backup locatio

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

Write-Host "Starting backup process..."

foreach ($Path in $PathsToBackup) {
    if (Test-Path $Path) {
        $BackupTarget = $Path -replace [regex]::Escape($env:USERPROFILE), "$BackupLocation"
        Write-Host "Backing up: $Path -> $BackupTarget"
        robocopy $Path $BackupTarget /E /R:1 /W:1 /XO
    } else {
        Write-Host "Skipping (not found): $Path"
    }
}

Write-Host "Backup completed!"