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
$SSHPath = "$env:USERPROFILE\.ssh"

try
{
    # Ensure the backup directory exists.
    if (!(Test-Path $BackupLocation)) {
        New-Item -ItemType Directory -Path $BackupLocation -Force
    }

    Write-Host "Backing up '$Name'..."

    if (Test-Path $SSHPath)
    {
        robocopy $SSHPath $BackupLocation /E /R:1 /W:1
    }
    else
    {
        Write-Host "$($UTF.CrossMark) Path '$SSHPath' for SSH Keys doesn't exist." -ForegroundColor Red
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