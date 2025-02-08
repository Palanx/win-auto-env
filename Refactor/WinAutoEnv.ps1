# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Remove modules (to unload outdated modules), required for Dev workflow.
Remove-Module Constants -ErrorAction SilentlyContinue
Remove-Module Core -ErrorAction SilentlyContinue
Remove-Module Gui -ErrorAction SilentlyContinue

# Import modules.
Import-Module "$ScriptDir\Modules\Constants.psm1"
Import-Module "$ScriptDir\Modules\Core.psm1"
Import-Module "$ScriptDir\Modules\Gui.psm1"

# Define Options and their Handlers.
$BuckupSystemOption = "Backup System"
$RestoreSystemOption = "Restore System"
$AppInstallOption = "AppInstall"
$ExitOption = "Exit"
$Options = @($BuckupSystemOption, $RestoreSystemOption, $AppInstallOption, $ExitOption)

# ------------------------------------------------------------------------------------------------------------- #
# Functions                                                                                                     #
# ------------------------------------------------------------------------------------------------------------- #

function Start-BackupSystem
{
    try
    {
        # Import module.
        Import-Module "$ScriptDir\Modules\BackupSystem\Backup-System.psm1"

        # TODO: Init the Backup System Process.
    }
    catch
    {
        Write-Host "$UTFCrossMark Error starting Backup-System: $_" -ForegroundColor Red
    }
    finally
    {
        # Remove the module.
        Remove-Module Backup-System -ErrorAction SilentlyContinue
    }
}

function Start-RestoreSystem
{
    try
    {
        # Import module.
        Import-Module "$ScriptDir\Modules\RecoverSystem\Recover-System.psm1"

        # TODO: Init the Restore System Process.
    }
    catch
    {
        Write-Host "$UTFCrossMark Error starting Recover-System: $_" -ForegroundColor Red
    }
    finally
    {
        # Remove the module.
        Remove-Module Recover-System -ErrorAction SilentlyContinue
    }
}

function Start-AppInstall
{
    try
    {
        # Import module.
        Import-Module "$ScriptDir\Modules\AppInstall\App-Install.psm1"

        # TODO: Init the App Install Process.
    }
    catch
    {
        Write-Host "$UTFCrossMark Error starting App-Install: $_" -ForegroundColor Red
    }
    finally
    {
        # Remove the module.
        Remove-Module App-Install -ErrorAction SilentlyContinue
    }
}

# ------------------------------------------------------------------------------------------------------------- #
# Main Loop                                                                                                     #
# ------------------------------------------------------------------------------------------------------------- #

$mustExit = $false
do
{
    Clear-Host
    Write-Header -Title "Win Auto Environment"

    $selectedIndex =Write-SelectionList -Options $Options
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