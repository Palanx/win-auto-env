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

    Write-Host "Restoring '$Name'..."

    $isBackupRestored = $false;
    # Restore Quick Access files.
    if (Test-Path "$BackupLocation\AutomaticDestinations") {
        robocopy "$BackupLocation\AutomaticDestinations" $QuickAccessPath1 /E /R:1 /W:1
        Write-Host "$($UTF.CheckMark) Automatic Destinations restored successfully." -ForegroundColor DarkGreen
        $isBackupRestored = $true;
    }
    else
    {
        Write-Host "$($UTF.WarningSign) No Automatic Destinations backup found!" -ForegroundColor DarkRed
    }
    if (Test-Path "$BackupLocation\CustomDestinations") {
        robocopy "$BackupLocation\CustomDestinations" $QuickAccessPath2 /E /R:1 /W:1
        Write-Host "$($UTF.CheckMark) Custom Destinations restored successfully." -ForegroundColor DarkGreen
        $isBackupRestored = $true;
    }
    else
    {
        Write-Host "$($UTF.WarningSign) No Custom Destinations backup found!" -ForegroundColor DarkRed
    }

    # Restore Registry settings.
    if (Test-Path $RegistryBackup) {
        reg import $RegistryBackup
        Write-Host "$($UTF.CheckMark) QuickAccess reg restored successfully." -ForegroundColor DarkGreen
        $isBackupRestored = $true;
    }
    else
    {
        Write-Host "$($UTF.WarningSign) No QuickAccess reg Backup found!" -ForegroundColor DarkRed
    }

    Restart-Explorer

    if ( !$isBackupRestored )
    {
        Write-Host "$($UTF.WarningSign) No Automatic/Custom Destinations or 'QuickAccess' reg to Restore." -ForegroundColor Green
    }
    else
    {
        Restart-Explorer
        Write-Host "$($UTF.CheckMark) '$Name' Backup Restore completed!" -ForegroundColor Green
    }
    return $Global:STATUS_SUCCESS
}
catch
{
    Write-Host "$($UTF.CrossMark) Exception occurred Recovering the '$Name' Backup: $(Get-ExceptionDetails $_)" -ForegroundColor Red
    return $Global:STATUS_FAILURE
}