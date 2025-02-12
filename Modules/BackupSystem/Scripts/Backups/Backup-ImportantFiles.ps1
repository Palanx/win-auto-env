param (
    [string]$BackupLocation,
    [string]$Name,
    [hashtable]$ExtraParameters = @{}
)

# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\..\..\..\Constants.psm1"
Import-Module "$ScriptDir\..\..\..\Core.psm1"

try
{
    # Ensure the backup directory exists.
    if (!(Test-Path $BackupLocation)) {
        New-Item -ItemType Directory -Path $BackupLocation -Force
    }

    $pathsToBackup = $ExtraParameters['paths-to-backup']

    Write-Host "Backing up '$Name'..."

    foreach ($path in $pathsToBackup) {
        if (Test-Path $path) {
            Write-Host "Ensuring files are available offline in: $path"
            attrib -P -S "$path" -R /S /D

            $backupTarget = $path -replace [regex]::Escape($env:USERPROFILE), "$BackupLocation"
            Write-Host "Backing up Path: $path -> $backupTarget"
            robocopy $path $backupTarget /E /R:1 /W:1 /XO
        } else {
            Write-Host "Skipping Path (not found): $path"
        }
    }

    Write-Host "$($UTF.CheckMark) '$Name' Backup completed! Saved to: '$BackupLocation'" -ForegroundColor Green
    return $Global:STATUS_SUCCESS
}
catch
{
    Write-Host "$($UTF.CrossMark) Exception occurred generating the '$Name' Backup: $(Get-ExceptionDetails $_)" -ForegroundColor Red
    return $Global:STATUS_FAILURE
}