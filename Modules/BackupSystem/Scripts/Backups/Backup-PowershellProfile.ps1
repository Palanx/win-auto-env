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

try
{
    # Ensure the backup directory exists.
    if (!(Test-Path $BackupLocation))
    {
        New-Item -ItemType Directory -Path $BackupLocation -Force
    }

    $isBackupCreated = $false;
    # Backup profile script.
    if (Test-Path $ProfilePath)
    {
        Copy-Item -Path $ProfilePath -Destination "$BackupLocation\Microsoft.PowerShell_profile.ps1" -Force
        Write-Host "$( $UTF.CheckMark ) PowerShell profile backed up successfully." -ForegroundColor DarkGreen
        $isBackupCreated = $true;
    }
    else
    {
        Write-Host "$( $UTF.WarningSign ) PowerShell profile not found!" -ForegroundColor DarkRed
    }

    # Backup PowerShell modules.
    if (Test-Path $ModulesPath)
    {
        robocopy $ModulesPath "$BackupLocation\Modules" /E /R:1 /W:1
        Write-Host "$( $UTF.CheckMark ) PowerShell modules backed up successfully." -ForegroundColor DarkGreen
        $isBackupCreated = $true;
    }
    else
    {
        Write-Host "$( $UTF.WarningSign ) Custom PowerShell modules not found!" -ForegroundColor DarkRed
    }

    if (!$isBackupCreated)
    {
        Write-Host "$( $UTF.WarningSign ) No PowerShell profile or module to backup." -ForegroundColor Green
    }
    else
    {
        Write-Host "$( $UTF.CheckMark ) '$Name' Backup completed! Saved to: '$BackupLocation'" -ForegroundColor Green
    }
    return $Global:STATUS_SUCCESS
}
catch
{
    Write-Host "$( $UTF.CrossMark ) Exception occurred generating the '$Name' Backup: $( Get-ExceptionDetails $_ )" -ForegroundColor Red
    return $Global:STATUS_FAILURE
}