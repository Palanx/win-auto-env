param (
    [string]$BackupLocation,
    [string]$Name
)

# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\..\..\..\Constants.psm1"
Import-Module "$ScriptDir\..\..\..\Core.psm1"

# Define Chrome profile path.
$ChromeProfilePath = "$env:LOCALAPPDATA\Google\Chrome\User Data"

try
{
    # Ensure the backup directory exists.
    if (!(Test-Path $BackupLocation)) {
        New-Item -ItemType Directory -Path $BackupLocation -Force
    }

    Write-Host "Backing up '$Name'..."

    if (Test-Path $ChromeProfilePath)
    {
        robocopy $ChromeProfilePath $BackupLocation /E /XD "Cache" "Code Cache" "Service Worker" /R:1 /W:1

        # Backup Chrome profile excluding cache
        robocopy $ChromeProfilePath $BackupLocation /E /XD "Cache" "Code Cache" "Service Worker" /R:1 /W:1

        # Ensure session files are included
        $sessionBackupPath = "$BackupLocation\Default\Sessions"
        if (!(Test-Path $sessionBackupPath)) {
            New-Item -ItemType Directory -Path $sessionBackupPath -Force
        }

        Copy-Item "$ChromeProfilePath\Default\Current Session" $BackupLocation\Default\ -Force
        Copy-Item "$ChromeProfilePath\Default\Current Tabs" $BackupLocation\Default\ -Force
        Copy-Item "$ChromeProfilePath\Default\Last Session" $BackupLocation\Default\ -Force
        Copy-Item "$ChromeProfilePath\Default\Last Tabs" $BackupLocation\Default\ -Force
    }
    else
    {
        Write-Host "Path '$ChromeProfilePath' for Chrome profile doesn't exist."
        return $Global:STATUS_FAILURE
    }

    Write-Host "$($UTF.CheckMark) '$Name' Backup completed! Saved to: '$BackupLocation'" -ForegroundColor Green
    return $Global:STATUS_SUCCESS
}
catch
{
    Write-Host "$($UTF.CrossMark) Exception occurred generating the '$Name' Backup: $(Get-ExceptionDetails $_)" -ForegroundColor Red
    return $Global:STATUS_FAILURE
}
