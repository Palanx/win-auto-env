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
    # Ensure the backup directory exists.
    if (!(Test-Path $BackupLocation)) {
        Write-Host "Backup not found in path '$BackupLocation'!" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    }

    Write-Host "Restoring '$Name'..."

    # Restore Chrome profile.
    $backupData = Get-Content $BackupLocation

    foreach ($line in $backupData) {
        $parts = $line -split " "
        $driveLetter = $parts[0]
        $deviceID = $parts[1]

        $drive = Get-WmiObject Win32_Volume | Where-Object { $_.DeviceID -eq $deviceID }
        if ($drive) {
            Write-Host "Assigning $driveLetter to $($drive.DeviceID)..."
            $drive.DriveLetter = $driveLetter
            $drive.Put()
        }
    }

    Restart-Explorer

    Write-Host "$($UTF.CheckMark) '$Name' Backup Restore completed!" -ForegroundColor Green
    return $Global:STATUS_SUCCESS
}
catch
{
    Write-Host "$($UTF.CrossMark) Exception occurred Recovering the '$Name' Backup: $(Get-ExceptionDetails $_)" -ForegroundColor Red
    return $Global:STATUS_FAILURE
}