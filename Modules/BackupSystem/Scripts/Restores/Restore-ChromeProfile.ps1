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
        Write-Host "Backup not found in path '$BackupLocation'!" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    }

    Write-Host "Closing Google Chrome..."

    # Attempt to stop Chrome gracefully, fallback to force if needed.
    $chromeProcesses = Get-Process -Name chrome -ErrorAction SilentlyContinue
    if ($chromeProcesses)
    {
        $chromeProcesses | Stop-Process -Force -ErrorAction SilentlyContinue

        # Wait until all Chrome processes are terminated.
        while (Get-Process -Name chrome -ErrorAction SilentlyContinue)
        {
            Start-Sleep -Milliseconds 500  # Check every 0.5 seconds.
        }

        Write-Host "Google Chrome has been closed."
    }
    else
    {
        Write-Host "Google Chrome is not running."
    }

    Write-Host "Restoring '$Name'..."
    
    # Restore Chrome profile.
    robocopy $BackupLocation $ChromeProfilePath /E /R:1 /W:1

    Write-Host "$($UTF.CheckMark) '$Name' Backup Restore completed!" -ForegroundColor Green
    return $Global:STATUS_SUCCESS
}
catch
{
    Write-Host "$($UTF.CrossMark) Exception occurred Recovering the '$Name' Backup: $(Get-ExceptionDetails $_)" -ForegroundColor Red
    return $Global:STATUS_FAILURE
}
