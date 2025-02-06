Import-Module "$PSScriptRoot\..\shared\winget-utils.psm1" -Force
Import-Module "$PSScriptRoot\..\shared\start-process-utils.psm1" -Force
Import-Module "$PSScriptRoot\..\shared\global-variables.psm1" -Force

# Define the folder containing the scripts
$BackupsFolder = "$PSScriptRoot\backups\"
 
# Ensure the script is running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Script needs to be run as administrator. Restarting with elevated privileges..." -ForegroundColor Red
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "$UTFHourglassNotDone Backup process started." -ForegroundColor Magenta
Invoke-Scripts -ScriptsFolderPath $BackupsFolder


Write-Host "`nPress any key to return..."
Read-Host