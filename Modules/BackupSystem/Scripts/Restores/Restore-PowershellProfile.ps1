param (
    [string]$BackupLocation,
    [string]$Name
)

# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\..\..\..\Constants.psm1"
Import-Module "$ScriptDir\..\..\..\Core.psm1"

# Define paths
$ProfilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$ModulesPath = "$env:USERPROFILE\Documents\PowerShell\Modules"
$PowerShellProfilePath = "$env:USERPROFILE\Documents\PowerShell"

try
{
    # Ensure the backup directory exists.
    if (!(Test-Path $BackupLocation)) {
        Write-Host "Backup not found in path '$BackupLocation'!" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    }

    Write-Host "Restoring '$Name'..."

    # Ensure the PowerShell profile directory exists.
    if (!(Test-Path $PowerShellProfilePath)) {
        New-Item -ItemType Directory -Path $PowerShellProfilePath -Force
    }

    $isBackupRestored = $false;
    # Restore profile script.
    if (Test-Path "$BackupLocation\Microsoft.PowerShell_profile.ps1") {
        Copy-Item -Path "$BackupLocation\Microsoft.PowerShell_profile.ps1" -Destination $ProfilePath -Force
        Write-Host "$($UTF.CheckMark) PowerShell profile restored successfully." -ForegroundColor DarkGreen
        $isBackupRestored = $true;
    } else {
        Write-Host "$($UTF.WarningSign) No PowerShell profile backup found!" -ForegroundColor DarkRed
    }

    # Restore PowerShell modules.
    if (Test-Path "$BackupLocation\Modules") {
        robocopy "$BackupLocation\Modules" $ModulesPath /E /R:1 /W:1
        Write-Host "$($UTF.CheckMark) PowerShell modules restored successfully." -ForegroundColor DarkGreen
        $isBackupRestored = $true;
    } else {
        Write-Host "$($UTF.WarningSign) No PowerShell module backup found!" -ForegroundColor DarkRed
    }

    if ( !$isBackupRestored )
    {
        Write-Host "$($UTF.WarningSign) No PowerShell profile or module to Restore." -ForegroundColor Green
    }
    else
    {
        Write-Host "$($UTF.CheckMark) '$Name' Backup Restore completed!" -ForegroundColor Green
    }
    return $Global:STATUS_SUCCESS
}
catch
{
    Write-Host "$($UTF.CrossMark) Exception occurred Recovering the '$Name' Backup: $(Get-ExceptionDetails $_)" -ForegroundColor Red
    return $Global:STATUS_FAILURE
}