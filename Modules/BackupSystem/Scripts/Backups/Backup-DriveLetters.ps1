param (
    [string]$BackupLocation,
    [string]$Name
)

# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\..\..\..\Constants.psm1"
Import-Module "$ScriptDir\..\..\..\Core.psm1"

try
{
    # Clear the backup file.
    Clear-Content -Path $BackupLocation -ErrorAction SilentlyContinue

    Write-Host "Backing up '$Name' assignment..."
    $drives = Get-WmiObject Win32_Volume | Where-Object { $_.DriveLetter -ne $null } | Select-Object DriveLetter, DeviceID

    $drives | ForEach-Object {
        "$( $_.DriveLetter ) $( $_.DeviceID )" | Out-File -Append -FilePath $BackupLocation
    }

    Write-Host "$( $UTF.CheckMark ) '$Name' Backup completed! Saved to: '$BackupLocation'" -ForegroundColor Green
    return $Global:STATUS_SUCCESS
}
catch
{
    Write-Host "$( $UTF.CrossMark ) Exception occurred generating the '$Name' Backup: $( Get-ExceptionDetails $_ )" -ForegroundColor Red
    return $Global:STATUS_FAILURE
}