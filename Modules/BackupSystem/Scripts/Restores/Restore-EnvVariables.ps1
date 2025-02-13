param (
    [string]$BackupLocation,
    [string]$Name,
    [hashtable]$ExtraParameters = @{ }
)

# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\..\..\..\Constants.psm1"
Import-Module "$ScriptDir\..\..\..\Core.psm1"

try
{
    # Ensure the backup directory exists.
    if (!(Test-Path $BackupLocation))
    {
        Write-Host "Backup not found in path '$BackupLocation'!" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    }

    Write-Host "Restoring '$Name'..."

    # Read and restore variables
    Get-Content $BackupLocation | ForEach-Object {
        $parts = $_ -split "=", 2
        $varName = $parts[0]
        $varValue = $parts[1]

        [System.Environment]::SetEnvironmentVariable($varName, $varValue, "User")
        Write-Host "Restored: $varName"
    }

    Restart-Explorer

    Write-Host "$( $UTF.CheckMark ) '$Name' Backup Restore completed!" -ForegroundColor Green
    return $Global:STATUS_SUCCESS
}
catch
{
    Write-Host "$( $UTF.CrossMark ) Exception occurred Recovering the '$Name' Backup: $( Get-ExceptionDetails $_ )" -ForegroundColor Red
    return $Global:STATUS_FAILURE
}