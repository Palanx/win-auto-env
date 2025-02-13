# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\..\Constants.psm1"
Import-Module "$ScriptDir\..\Core.psm1"

# Define the path of the config json.
$BackupConfigPath = "$ScriptDir\backup-system-config.json"

# Read JSON file and convert to PowerShell object.
$BackupConfigData = Get-Content -Path $BackupConfigPath -Raw | ConvertFrom-Json

# Define the location where the buckups will be stored.
$BackupsLocation = $BackupConfigData.'backups-location'

# Define the collection of backup configs.
$BackupConfigs = $BackupConfigData.'backups-configs'

# Start the Backup System process.
function Start-BackupSystem
{
    Write-Header -Title "Generate System Backup"

    # Ensure the backup location is created.
    $dateString = Get-Date -Format "yyyy-MM-dd"
    $backupsLocationWithDate = "$BackupsLocation\$dateString"
    if (!(Test-Path $backupsLocationWithDate))
    {
        New-Item -Path $backupsLocationWithDate -ItemType Directory | Out-Null
        Write-Host "Path '$backupsLocationWithDate' created to generate the backups."
    }

    $failedBackups = 0
    foreach ($backupConfig in $BackupConfigs)
    {
        if (!$backupConfig.enabled)
        {
            continue
        }

        $name = $backupConfig.name
        $requiresAdmin = $backupConfig.'backup-requires-admin'
        $scriptPath = $backupConfig.'backup-script'
        $configParameters = $backupConfig.'extra-parameters'
        $backupLocationName = $backupConfig.'backup-location-name'

        $infoString = "'$name' Backup '$dateString' process will be executed."
        Write-Host $infoString -ForegroundColor White
        Write-Separator -Width $infoString.Length

        try
        {
            # Define backup file location.
            $backupLocation = "$backupsLocationWithDate\$backupLocationName"

            # Define extra parameters.
            $extraParameters = @{
                "Name" = $name
                "BackupLocation" = "$backupLocation"
            }
            if ($null -ne $configParameters)
            {
                $hashtableParameters = @{}
                foreach ($key in $configParameters.PSObject.Properties.Name)
                {
                    $hashtableParameters[$key] = $configParameters.$key
                }

                $extraParameters['ExtraParameters'] = $hashtableParameters
            }

            $exitCode = Invoke-ScriptWithCorrectPermissions -ScriptPath "$ScriptDir$scriptPath" -ExtraParameters $extraParameters -RequiresAdmin $requiresAdmin | Select-Object -Last 1
            if ($exitCode -ne $Global:STATUS_SUCCESS)
            {
                throw "Error executing the '$name' Backup '$dateString' process (Exit Code: $exitCode)"
            }

            Write-Host "$($UTF.HeavyCheckMark) '$name' Backup '$dateString' process completed successfully.`n" -ForegroundColor Green
        }
        catch
        {
            Write-Host "$($UTF.CrossMark) Exception occurred in '$name' Backup '$dateString' process script execution: $(Get-ExceptionDetails $_)`n" -ForegroundColor Red
            $failedBackups++
        }
    }
    if ($failedBackups -gt 0) {
        Write-Host "$($UTF.WarningSign) WARNING: $failedBackups Backup '$dateString' processes failed.`n" -ForegroundColor Red
    } else {
        Write-Host "$($UTF.HeavyCheckMark) All Backup '$dateString' processes completed successfully!`n" -ForegroundColor Green
    }

    Write-Host "Returning to main menu...`n"
}

# Start the Restore System process.
function Start-RestoreSystem
{
    Write-Header -Title "Restore System Backup"

    # Validate if the backups folder exist.
    if (!(Test-Path $BackupsLocation))
    {
        Write-Host "Path '$BackupsLocation' for Backups doesn't exist." -ForegroundColor Red
        Write-Host "Returning to main menu...`n"
        return;
    }

    # Validate if there are buckups.
    $BackupFolderNames = @(Get-ChildItem -Path $BackupsLocation -Directory | Select-Object -ExpandProperty Name)
    if ($BackupFolderNames.Count -eq 0)
    {
        Write-Host "There aren't Backups in '$BackupsLocation' to recover." -ForegroundColor Red
        Write-Host "Returning to main menu...`n"
        return;
    }

    Write-Host "Select a Backup Date to Restore it:" -ForegroundColor White

    # Select the Backup to restore.
    $selectedIndex = Write-SelectionList -Options $BackupFolderNames
    $backupFolderName = $BackupFolderNames[$selectedIndex]

    Write-Host "$($UTF.Pushpin) Backup '$backupFolderName' selected to be Restored!" -ForegroundColor White

    # Define the backup location with selected date included.
    $backupsLocationWithDate = "$BackupsLocation\$backupFolderName"

    $failedBackups = 0
    foreach ($backupConfig in $BackupConfigs)
    {
        if (!$backupConfig.enabled)
        {
            continue
        }

        $name = $backupConfig.name
        $requiresAdmin = $backupConfig.'restore-requires-admin'
        $scriptPath = $backupConfig.'restore-script'
        $configParameters = $backupConfig.'extra-parameters'
        $backupLocationName = $backupConfig.'backup-location-name'

        $infoString = "'$name' Restore Backup '$backupFolderName' process will be executed."
        Write-Host $infoString -ForegroundColor White
        Write-Separator -Width $infoString.Length

        try
        {
            # Define backup file location.
            $backupLocation = "$backupsLocationWithDate\$backupLocationName"

            # Define extra parameters.
            $extraParameters = @{
                "Name" = $name
                "BackupLocation" = "$backupLocation"
            }

            if ($null -ne $configParameters)
            {
                $hashtableParameters = @{}
                foreach ($key in $configParameters.PSObject.Properties.Name)
                {
                    $hashtableParameters[$key] = $configParameters.$key
                }

                $extraParameters['ExtraParameters'] = $hashtableParameters
            }

            $exitCode = Invoke-ScriptWithCorrectPermissions -ScriptPath "$ScriptDir$scriptPath" -ExtraParameters $extraParameters -RequiresAdmin $requiresAdmin
            if ($exitCode -ne $Global:STATUS_SUCCESS)
            {
                throw "Error executing the '$name' Restore Backup '$backupFolderName' process (Exit Code: $exitCode)"
            }

            Write-Host "$($UTF.HeavyCheckMark) '$name' Restore Backup '$backupFolderName' process completed successfully." -ForegroundColor Green
        }
        catch
        {
            Write-Host "$($UTF.CrossMark) Exception occurred in '$name' Restore Backup '$backupFolderName' process script execution: $(Get-ExceptionDetails $_)" -ForegroundColor Red
            $failedBackups++
        }
    }
    if ($failedBackups -gt 0) {
        Write-Host "$($UTF.WarningSign) WARNING: $failedBackups Restore Backup '$backupFolderName' processes failed.`n" -ForegroundColor Red
    } else {
        Write-Host "$($UTF.HeavyCheckMark) All Restore Backup '$backupFolderName' processes completed successfully!`n" -ForegroundColor Green
    }

    Write-Host "Returning to main menu...`n"
}

# Export the functions.
Export-ModuleMember -Function Start-BackupSystem, Start-RestoreSystem