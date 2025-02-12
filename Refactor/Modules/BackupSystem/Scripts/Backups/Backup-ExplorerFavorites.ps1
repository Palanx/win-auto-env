param (
    [string]$BackupLocation,
    [string]$Name
)

# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\..\..\..\Constants.psm1"
Import-Module "$ScriptDir\..\..\..\Core.psm1"

# Define quick access paths.
$QuickAccessPath1 = "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations"
$QuickAccessPath2 = "$env:APPDATA\Microsoft\Windows\Recent\CustomDestinations"

try
{
    # Ensure the backup directory exists.
    if (!(Test-Path $BackupLocation)) {
        New-Item -ItemType Directory -Path $BackupLocation -Force
    }

    # Define backup file location.
    $registryBackup = "$BackupLocation\QuickAccessRegistry.reg"

    Write-Host "Backing up '$Name'..."

    # Ensure backup directory exists.
    if (!(Test-Path $BackupLocation)) {
        New-Item -ItemType Directory -Path $BackupLocation -Force
    }

    # Backup Quick Access files.
    if (Test-Path $QuickAccessPath1) {
        robocopy $QuickAccessPath1 "$BackupLocation\AutomaticDestinations" /E /R:1 /W:1
    }
    if (Test-Path $QuickAccessPath2) {
        robocopy $QuickAccessPath2 "$BackupLocation\CustomDestinations" /E /R:1 /W:1
    }

    # Backup Registry settings.
    reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\QuickAccess" $registryBackup /y

    Write-Host "$($UTF.CheckMark) '$Name' Backup completed! Saved to: '$BackupLocation'" -ForegroundColor Green
    return $Global:STATUS_SUCCESS
}
catch
{
    Write-Host "$($UTF.CrossMark) Exception occurred generating the '$Name' Backup: $(Get-ExceptionDetails $_)" -ForegroundColor Red
    return $Global:STATUS_FAILURE
}