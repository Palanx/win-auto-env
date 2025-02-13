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
        Write-Host "Backup not found in path '$BackupLocation'!" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    }

    $pathsToBackup = $ExtraParameters['paths-to-backup']

    Write-Host "Restoring '$Name'..."

    $pathsFound = [System.Collections.ArrayList]@()
    $pathsNotFound = [System.Collections.ArrayList]@()
    foreach ($path in $pathsToBackup) {
        # Expand path to recognize env variables.
        $path = $ExecutionContext.InvokeCommand.ExpandString($path)

        # Fix possible encoding problems.
        $path = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes($path))

        $backupTarget = $path -replace [regex]::Escape($env:USERPROFILE), "$BackupLocation"

        if (Test-Path $backupTarget) {
            Write-Host "Restoring: $backupTarget -> $path"
            robocopy $backupTarget $path /E /R:1 /W:1 /XO
            Write-Host "$($UTF.CheckMark) Path Restore completed: $path" -ForegroundColor Green
            $pathsFound.Add($path)
        } else {
            Write-Host "$($UTF.CrossMark) Skipping (backup not found): $backupTarget" -ForegroundColor Red
            $pathsNotFound.Add($path)
        }
    }

    if ($pathsFound.Count -eq 0)
    {
        Write-Host "$($UTF.CrossMark) All paths weren't found for '$Name' Backup Restore" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    }
    elseif ($pathsNotFound.Count -gt 0)
    {
        Write-Host "$($UTF.CheckMark) '$Name' Backup Restore completed with some fails!" -ForegroundColor DarkGreen
        Write-Host "Paths not found: " -ForegroundColor DarkRed
        $pathsNotFound | ForEach-Object { Write-Host "- $_" -ForegroundColor DarkRed }
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