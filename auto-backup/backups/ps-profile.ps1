# Define paths
$ProfilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$ModulesPath = "$env:USERPROFILE\Documents\PowerShell\Modules"
$BackupPath = "D:\AutoBackups\PowerShellBackup"  # Change this to your preferred backup location

Write-Host "Backing up PowerShell profile and modules..."

    # Ensure the backup directory exists
    if (!(Test-Path $BackupPath)) {
        New-Item -ItemType Directory -Path $BackupPath -Force
    }

    # Backup profile script
    if (Test-Path $ProfilePath) {
        Copy-Item -Path $ProfilePath -Destination "$BackupPath\Microsoft.PowerShell_profile.ps1" -Force
        Write-Host "PowerShell profile backed up successfully."
    } else {
        Write-Host "PowerShell profile not found!"
    }

    # Backup PowerShell modules
    if (Test-Path $ModulesPath) {
        robocopy $ModulesPath "$BackupPath\Modules" /E /R:1 /W:1
        Write-Host "PowerShell modules backed up successfully."
    } else {
        Write-Host "No custom PowerShell modules found."
    }