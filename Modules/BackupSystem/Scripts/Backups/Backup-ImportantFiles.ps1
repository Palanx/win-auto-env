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

    $pathsFound = [System.Collections.ArrayList]@()
    $pathsNotFound = [System.Collections.ArrayList]@()
    foreach ($path in $pathsToBackup) {
        # Expand path to recognize env variables.
        $path = $ExecutionContext.InvokeCommand.ExpandString($path)

        # Fix possible encoding problems.
        $path = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes($path))

        if (Test-Path $path) {
            Write-Host "Ensuring files are available offline in: $path"
            attrib -P -S "$path" -R /S /D

            $backupTarget = $path -replace [regex]::Escape($env:USERPROFILE), "$BackupLocation"
            Write-Host "Backing up Path: $path -> $backupTarget"
            robocopy $path $backupTarget /E /R:1 /W:1 /XO
            Write-Host "$($UTF.CheckMark) Path Backup completed: $path" -ForegroundColor Green
            $pathsFound.Add($path)
        } else {
            Write-Host "$($UTF.CrossMark) Skipping Path (not found): $path" -ForegroundColor Red
            $pathsNotFound.Add($path)
        }
    }

    if ($pathsFound.Count -eq 0)
    {
        Write-Host "$($UTF.CrossMark) All paths weren't found for '$Name' Backup" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    }
    elseif ($pathsNotFound.Count -gt 0)
    {
        Write-Host "$($UTF.CheckMark) '$Name' Backup completed with some fails! Saved to: '$BackupLocation'" -ForegroundColor DarkGreen
        Write-Host "Paths not found: " -ForegroundColor DarkRed
        $pathsNotFound | ForEach-Object { Write-Host "- $_" -ForegroundColor DarkRed }
    }
    else
    {
        Write-Host "$($UTF.CheckMark) '$Name' Backup completed! Saved to: '$BackupLocation'" -ForegroundColor Green
    }
    return $Global:STATUS_SUCCESS
}
catch
{
    Write-Host "$($UTF.CrossMark) Exception occurred generating the '$Name' Backup: $(Get-ExceptionDetails $_)" -ForegroundColor Red
    return $Global:STATUS_FAILURE
}