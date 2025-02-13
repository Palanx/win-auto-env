param (
    [string]$BackupLocation,
    [string]$Name
)

# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\..\..\..\Constants.psm1"
Import-Module "$ScriptDir\..\..\..\Core.psm1"

# Define quick access paths.
$QuickAccessPath1 = "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations"
$QuickAccessPath2 = "$env:APPDATA\Microsoft\Windows\Recent\CustomDestinations"

try
{
    # Ensure the backup directory exists.
    if (!(Test-Path $BackupLocation)) {
        New-Item -ItemType Directory -Path $BackupLocation -Force
    }

    # Define backup file location.
    $registryBackup = "$BackupLocation\QuickAccessRegistry.reg"

    Write-Host "Backing up '$Name'..."

    # Ensure backup directory exists.
    if (!(Test-Path $BackupLocation)) {
        New-Item -ItemType Directory -Path $BackupLocation -Force
    }

    $isBackupCreated = $false;
    # Backup Quick Access files.
    if (Test-Path $QuickAccessPath1) {
        robocopy $QuickAccessPath1 "$BackupLocation\AutomaticDestinations" /E /R:1 /W:1
        Write-Host "$($UTF.CheckMark) Automatic Destinations Backup created." -ForegroundColor DarkGreen
        $isBackupCreated = $true;
    }
    else
    {
        Write-Host "$($UTF.WarningSign) Automatic Destinations not found!" -ForegroundColor DarkRed
    }
    if (Test-Path $QuickAccessPath2) {
        robocopy $QuickAccessPath2 "$BackupLocation\CustomDestinations" /E /R:1 /W:1
        Write-Host "$($UTF.CheckMark) Custom Destinations Backup created." -ForegroundColor DarkGreen
        $isBackupCreated = $true;
    }
    else
    {
        Write-Host "$($UTF.WarningSign) Custom Destinations not found!" -ForegroundColor DarkRed
    }

    # Backup Registry settings.
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\QuickAccess"
    if (Test-Path $regPath) {
        # Get all registry properties (values).
        $regValues = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue
        # Get all subkeys.
        $regSubKeys = Get-ChildItem -Path $regPath -ErrorAction SilentlyContinue

        if ($regValues.PSObject.Properties.Count -gt 0 -or $regSubKeys.Count -gt 0) {
            # If there are values or subkeys, export the registry
            reg export $regPath $registryBackup /y
            Write-Host "$($UTF.CheckMark) Registry exported successfully." -ForegroundColor DarkGreen
            $isBackupCreated = $true;
        } else {
            Write-Host "$($UTF.WarningSign) Registry key exists but is empty, skipping export." -ForegroundColor DarkRed
        }
    } else {
        Write-Host "$($UTF.WarningSign) Registry key does not exist: $regPath" -ForegroundColor DarkRed
    }

    if ( !$isBackupCreated )
    {
        Write-Host "$($UTF.WarningSign) No Automatic/Custom Destinations or 'QuickAccess' reg to backup." -ForegroundColor Green
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