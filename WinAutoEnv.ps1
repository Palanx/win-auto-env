# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Remove modules (to unload outdated modules), required for Dev workflow.
Remove-Module Constants -ErrorAction SilentlyContinue
Remove-Module Core -ErrorAction SilentlyContinue
Remove-Module Gui -ErrorAction SilentlyContinue
Remove-Module Backup-System -ErrorAction SilentlyContinue
Remove-Module App-Install -ErrorAction SilentlyContinue

# Import modules.
Import-Module "$ScriptDir\Modules\Constants.psm1"
Import-Module "$ScriptDir\Modules\Core.psm1"
Import-Module "$ScriptDir\Modules\Gui.psm1"
Import-Module "$ScriptDir\Modules\BackupSystem\Backup-System.psm1"
Import-Module "$ScriptDir\Modules\AppInstall\App-Install.psm1"

# Define the path of the config json.
$SystemConfigPath = "$ScriptDir\system-config.json"

# Read JSON file and convert to PowerShell object.
$SystemConfigData = Get-Content -Path $SystemConfigPath -Raw | ConvertFrom-Json
$OwnerName = $SystemConfigData.owner
$DeviceName = $SystemConfigData.device

# Define Options and their Handlers.
$BuckupSystemOption = "Backup System"
$RestoreSystemOption = "Restore System Buckup"
$AppInstallOption = "App Install"
$ExitOption = "Exit"
$Options = @($BuckupSystemOption, $RestoreSystemOption, $AppInstallOption, $ExitOption)

# Main loop.
$mustExit = $false
do
{
    Write-Header -Title "Win Auto Environment"

    Write-Host "$($UTF.StartBold)$($UTF.Red)$($UTF.Death)$($UTF.ResetColor) $($UTF.StartBold)Environment Owner:$($UTF.StopStyles) $OwnerName"
    Write-Host "$($UTF.StartBold)$($UTF.Red)$($UTF.Death)$($UTF.ResetColor) $($UTF.StartBold)Environment Device:$($UTF.StopStyles) $DeviceName`n"

    $selectedIndex = Write-SelectionList -Options $Options
    switch ($Options[$selectedIndex])
    {
        $BuckupSystemOption { Start-BackupSystem }
        $RestoreSystemOption { Start-RestoreSystem }
        $AppInstallOption { Start-AppInstall }
        $ExitOption { $mustExit = $true }
    }
} while (!$mustExit)

Write-Host "Press any key to exit..."
Read-Host