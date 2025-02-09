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

# Start the App Install process.
function Start-AppInstall
{
    $devConfigs = @{
        "WingetPackages" = @()
        "WinStoreInstallers" = @()
        "StandaloneInstallers" = @()
    }

    $osConfigs = @{
        "WingetPackages" = @()
        "WinStoreInstallers" = @()
        "StandaloneInstallers" = @()
    }

    $personalConfigs = @{
        "WingetPackages" = @()
        "WinStoreInstallers" = @()
        "StandaloneInstallers" = @()
    }

    if ($null -ne $ConfigData.'winget-packages')
    {
        foreach ($wingetPackage in $ConfigData.'winget-packages')
        {
            if (!$wingetPackage.enabled)
            {
                continue
            }

            switch ($wingetPackage.category)
            {
                "dev"
                {
                    $devConfigs["WingetPackages"].Add($wingetPackage)
                }
                "os"
                {
                    $osConfigs["WingetPackages"].Add($wingetPackage)
                }
                "personal"
                {
                    $personalConfigs["WingetPackages"].Add($wingetPackage)
                }
            }
        }
    }

    if ($null -ne $ConfigData.'win-store-installers')
    {
        foreach ($winStoreInstaller in $ConfigData.'win-store-installers')
        {
            if (!$winStoreInstaller.enabled)
            {
                continue
            }

            switch ($winStoreInstaller.category)
            {
                "dev"
                {
                    $devConfigs["WinStoreInstallers"].Add($winStoreInstaller)
                }
                "os"
                {
                    $osConfigs["WinStoreInstallers"].Add($winStoreInstaller)
                }
                "personal"
                {
                    $personalConfigs["WinStoreInstallers"].Add($winStoreInstaller)
                }
            }
        }
    }

    if ($null -ne $ConfigData.'standalone-installers')
    {
        foreach ($standaloneInstaller in $ConfigData.'standalone-installers')
        {
            if (!$standaloneInstaller.enabled)
            {
                continue
            }

            switch ($standaloneInstaller.category)
            {
                "dev"
                {
                    $devConfigs["StandaloneInstallers"].Add($standaloneInstaller)
                }
                "os"
                {
                    $osConfigs["StandaloneInstallers"].Add($standaloneInstaller)
                }
                "personal"
                {
                    $personalConfigs["StandaloneInstallers"].Add($standaloneInstaller)
                }
            }
        }
    }

    Write-Host "Starting Dev Apps installation..."
    foreach ($devWingetPackageConfig in $devConfigs["WingetPackages"])
    {
        Start-WingetInstallation -Config $devWingetPackageConfig
    }
    foreach ($devWinStoreInstallerConfig in $devConfigs["WinStoreInstallers"])
    {
        Start-WinStoreInstallation -Config $devWinStoreInstallerConfig
    }
    foreach ($devStandaloneInstallerConfig in $devConfigs["StandaloneInstallers"])
    {
        Start-StandaloneInstallation -Config $devStandaloneInstallerConfig
    }

    Write-Host "Starting OS Apps installation..."
    foreach ($osWingetPackageConfig in $osConfigs["WingetPackages"])
    {
        Start-WingetInstallation -Config $osWingetPackageConfig
    }
    foreach ($osWinStoreInstallerConfig in $osConfigs["WinStoreInstallers"])
    {
        Start-WinStoreInstallation -Config $osWinStoreInstallerConfig
    }
    foreach ($osStandaloneInstallerConfig in $osConfigs["StandaloneInstallers"])
    {
        Start-StandaloneInstallation -Config $osStandaloneInstallerConfig
    }

    Write-Host "Starting Personal Apps installation..."
    Write-Host "There are $($personalConfigs["WingetPackages"].Count) Personal Apps to install by winget."
    foreach ($personalWingetPackageConfig in $personalConfigs["WingetPackages"])
    {
        Start-WingetInstallation -Config $personalWingetPackageConfig
    }
    Write-Host "There are $($personalConfigs["WinStoreInstallers"].Count) Personal Apps to install by windows store."
    foreach ($personalWinStoreInstallerConfig in $personalConfigs["WinStoreInstallers"])
    {
        Start-WinStoreInstallation -Config $personalWinStoreInstallerConfig
    }
    Write-Host "There are $($personalConfigs["StandaloneInstallers"].Count) Personal Apps to install by standalone installer."
    foreach ($personalStandaloneInstallerConfig in $personalConfigs["StandaloneInstallers"])
    {
        Start-StandaloneInstallation -Config $personalStandaloneInstallerConfig
    }
}

# Start a standalone installation process.
function Start-StandaloneInstallation
{
    param (
        [PSCustomObject]$Config
    )

    try {
        [string]$appAlias = $Config.'app-alias'
        [string]$scriptPath = $Config.'script-path'
        [string]$installationPath = $Config.'installation-path'
        [bool]$requiresAdmin = $Config.'requires-admin'
        [string]$extraParameters = ""
        if ($null -ne $installationPath -and ($installationPath.Length -gt 0))
        {
            $extraParameters += "-InstallationPath '$installationPath'"
        }

        Write-Host "$($UTF.HourGlass) Starting app '$appAlias' standalone installation script..." -ForegroundColor Yellow
        [int]$exitCode = Run-ScriptWithCorrectPermissions -ScriptPath $scriptPath -ExtraParameters $extraParameters -RequiresAdmin $requiresAdmin

        # Check the last exit code.
        if ($exitCode -eq $Global:STATUS_SUCCESS) {
            Write-Host "$($UTF.HeavyCheckMark) App '$appAlias' standalone installation script completed successfully." -ForegroundColor Green
            return $Global:STATUS_SUCCESS
        }

        Write-Host "$($UTF.CrossMark) Error executing app '$appAlias' standalone installation script (Exit Code: $exitCode)" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    } catch {
        Write-Host "$($UTF.CrossMark) Exception occurred in app '$appAlias' standalone installation script execution: $_" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    }
}

# Export the functions.
Export-ModuleMember -Function Start-AppInstall