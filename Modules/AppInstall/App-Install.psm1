# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Remove modules (to unload outdated modules), required for Dev workflow.
Remove-Module Winget-Install -ErrorAction SilentlyContinue

# Import modules.
Import-Module "$ScriptDir\Winget-Install.psm1"
Import-Module "$ScriptDir\..\Constants.psm1"
Import-Module "$ScriptDir\..\Core.psm1"

# Define the path of the config json.
$ConfigPath = "$ScriptDir\app-install-config.json"

# Read JSON file and convert to PowerShell object.
$ConfigData = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json

# Define installation categories.
$installCategories = @("dev", "os", "personal")

# Define installer types.
$WingetInstallationType = "WingetInstallation"
$WinStoreInstallationType = "WinStoreInstallation"
$StandaloneInstallationType = "StandaloneInstallation"
$InstallationTypes = @($WingetInstallationType, $WinStoreInstallationType, $StandaloneInstallationType)

# Initialize categorized configurations.
$categorizedConfigs = @{ }
foreach ($category in $installCategories)
{
    $categorizedConfigs[$category] = @{
        $WingetInstallationType = [System.Collections.ArrayList]@()
        $WinStoreInstallationType = [System.Collections.ArrayList]@()
        $StandaloneInstallationType = [System.Collections.ArrayList]@()
    }
}

# Function to categorize the configuration items.
function Categorize-Installers
{
    param (
        [string]$InstallerType,
        [array]$Installers
    )

    if ($null -ne $Installers)
    {
        foreach ($installer in $Installers)
        {
            if (!$installer.enabled)
            {
                continue
            }
            $category = $installer.category
            if ($installCategories -contains $category)
            {
                $categorizedConfigs[$category][$InstallerType].Add($installer)
            }
        }
    }
}

# Categorize all installers.
Categorize-Installers -installerType $WingetInstallationType -installers $ConfigData.'winget-packages'
Categorize-Installers -installerType $WinStoreInstallationType -installers $ConfigData.'win-store-installers'
Categorize-Installers -installerType $StandaloneInstallationType -installers $ConfigData.'standalone-installers'

# Start the App Install process.
function Start-AppInstall
{
    foreach ($category in $installCategories)
    {
        Write-Header -Title "'$category' Apps installation"

        $failedInstallations = 0
        foreach ($installerType in $InstallationTypes)
        {
            $installers = $categorizedConfigs[$category][$installerType]

            if ($installers.Count -gt 0)
            {
                $infoString = "There are $( $installers.Count ) '$category' Apps to install via $installerType."
                Write-Host $infoString -ForegroundColor White
                Write-Separator -Width $infoString.Length

                foreach ($config in $installers)
                {
                    $installFunction = Get-Command -Name "Start-$installerType" -ErrorAction SilentlyContinue
                    if ($null -ne $installFunction)
                    {
                        try
                        {
                            $exitCode = & $installFunction -Config $config -ErrorAction Stop
                            if ($exitCode -ne $Global:STATUS_SUCCESS)
                            {
                                $failedInstallations++
                            }
                        }
                        catch
                        {
                            Write-Host "$( $UTF.CrossMark ) Exception thrown while processing Installer config: $( Get-ExceptionDetails $_ )" -ForegroundColor Red
                            $failedInstallations++
                        }
                    }
                }
                Write-Host ""
            }
            else
            {
                $infoString = "Nothing to install via $installerType for '$category'."
                Write-Host $infoString -ForegroundColor White
                Write-Separator -Width $infoString.Length
            }
        }

        if ($failedInstallations -gt 0)
        {
            Write-Host "$( $UTF.WarningSign ) WARNING: $failedInstallations installations failed in the category '$category'.`n" -ForegroundColor Red
        }
        else
        {
            Write-Host "$( $UTF.HeavyCheckMark ) All apps in category '$category' installed successfully!`n" -ForegroundColor Green
        }
    }
    Write-Host "Returning to main menu...`n"
}

# Start a standalone installation process.
function Start-StandaloneInstallation
{
    param (
        [PSCustomObject]$Config
    )

    try
    {
        [string]$appAlias = $Config.'app-alias'
        [string]$scriptPath = $Config.'script-path'
        [string]$installationPath = $Config.'installation-path'
        [bool]$requiresAdmin = $Config.'requires-admin'
        $extraParameters = @{ }
        if ($null -ne $installationPath -and ($installationPath.Length -gt 0))
        {
            $extraParameters["InstallationPath"] = $installationPath;
        }

        Write-Host "$( $UTF.HourGlass ) Starting app '$appAlias' standalone installation script..." -ForegroundColor Yellow
        $exitCode = Invoke-ScriptWithCorrectPermissions -ScriptPath "$ScriptDir$scriptPath" -ExtraParameters $extraParameters -RequiresAdmin $requiresAdmin

        # Check the last exit code.
        if ($exitCode -eq $Global:STATUS_SUCCESS)
        {
            Write-Host "$( $UTF.HeavyCheckMark ) App '$appAlias' standalone installation script completed successfully." -ForegroundColor Green
            return $Global:STATUS_SUCCESS
        }

        Write-Host "$( $UTF.CrossMark ) Error executing app '$appAlias' standalone installation script (Exit Code: $exitCode)" -ForegroundColor Red
        return $exitCode
    }
    catch
    {
        Write-Host "$( $UTF.CrossMark ) Exception occurred in app '$appAlias' standalone installation script execution: $( Get-ExceptionDetails $_ )" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    }
}

# Export the functions.
Export-ModuleMember -Function Start-AppInstall