# Define paths
$ProfilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$ModulesPath = "$env:USERPROFILE\Documents\PowerShell\Modules"
$BackupPath = "D:\PowerShellBackup"  # Change this to your preferred backup location

Write-Host "Restoring PowerShell profile and modules..."

    # Ensure the PowerShell profile directory exists
    if (!(Test-Path "$env:USERPROFILE\Documents\PowerShell")) {
        New-Item -ItemType Directory -Path "$env:USERPROFILE\Documents\PowerShell" -Force
    }

    # Restore profile script
    if (Test-Path "$BackupPath\Microsoft.PowerShell_profile.ps1") {
        Copy-Item -Path "$BackupPath\Microsoft.PowerShell_profile.ps1" -Destination $ProfilePath -Force
        Write-Host "PowerShell profile restored successfully."
    } else {
        Write-Host "No PowerShell profile backup found!"
    }

    # Restore PowerShell modules
    if (Test-Path "$BackupPath\Modules") {
        robocopy "$BackupPath\Modules" $ModulesPath /E /R:1 /W:1
        Write-Host "PowerShell modules restored successfully."
    } else {
        Write-Host "No PowerShell module backup found!"
    }