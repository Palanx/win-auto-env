param (
    [string]$BackupLocation,
    [string]$Name
)

# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\..\..\..\Constants.psm1"
Import-Module "$ScriptDir\..\..\..\Core.psm1"

# Define backup location
$QuickAccessPath1 = "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations"
$QuickAccessPath2 = "$env:APPDATA\Microsoft\Windows\Recent\CustomDestinations"
$RegistryBackup = "$BackupLocation\QuickAccessRegistry.reg"

try
{
    # Ensure the backup directory exists.
    if (!(Test-Path $BackupLocation)) {
        Write-Host "Backup not found in path '$BackupLocation'!" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    }

    # Ensure the Registry Backup path exist.
    if (!$(Test-Path $RegistryBackup)) {
        Write-Host "No Registry Backup in '$RegistryBackup' found!"
        return $Global:STATUS_FAILURE
    }

    Write-Host "Restoring '$Name'..."

    # Restore Quick Access files
    if (Test-Path "$BackupLocation\AutomaticDestinations") {
        robocopy "$BackupLocation\AutomaticDestinations" $QuickAccessPath1 /E /R:1 /W:1
    }
    if (Test-Path "$BackupLocation\CustomDestinations") {
        robocopy "$BackupLocation\CustomDestinations" $QuickAccessPath2 /E /R:1 /W:1
    }

    # Restore Registry settings.
    reg import $RegistryBackup
    Write-Host "Registry settings restored."

    Restart-Explorer

    Write-Host "$($UTF.CheckMark) '$Name' Backup Restore completed!" -ForegroundColor Green
    return $Global:STATUS_SUCCESS
}
catch
{
    Write-Host "$($UTF.CrossMark) Exception occurred Recovering the '$Name' Backup: $(Get-ExceptionDetails $_)" -ForegroundColor Red
    return $Global:STATUS_FAILURE
}