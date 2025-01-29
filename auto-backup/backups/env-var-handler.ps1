# Define backup file location
$BackupFile = "D:\EnvBackup.txt" # Change this to your preferred backup locatio

# List of specific environment variables to backup
$EnvVars = @("GIT_SSH")

Write-Host "Backing up specified environment variables..."

# Ensure backup file exists
if (Test-Path $BackupFile) { Remove-Item $BackupFile -Force }

# Backup each variable
foreach ($var in $EnvVars) {
    $value = [System.Environment]::GetEnvironmentVariable($var, "User")
    if ($value) {
        "$var=$value" | Out-File -Append -FilePath $BackupFile
        Write-Host "Backed up: $var"
    } else {
        Write-Host "Skipping: $var (Not found)"
    }
}

Write-Host "Backup completed! File saved to: $BackupFile"