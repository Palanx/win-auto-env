# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\..\Constants.psm1"
Import-Module "$ScriptDir\..\Core.psm1"

# Start a winget package installation process.
function Start-WingetInstallation
{
    param (
        [PSCustomObject]$Config
    )

    [string]$packageId = $Config.'package-id'
    [string]$packageAlias = $Config.'package-alias'
    [string]$extraParameters = $Config.'package-extra-parameters'
    [bool]$silent = $Config.'silent'

    [int]$wingetInstallationExitCode = Start-InstallWingetPackage -PackageID $packageId -PackageAlias $packageAlias -ExtraParameters $extraParameters -Silent $silent

    if ($wingetInstallationExitCode -eq $Global:STATUS_FAILURE)
    {
        return $Global:STATUS_FAILURE
    }

    [string]$postInstallScriptPath = $Config.'post-install-script-path'
    [bool]$postInstallScriptRequiresAdmin = $Config.'post-install-script-requires-admin'
    if ( $null -eq $postInstallScriptPath -or $postInstallScriptPath.Length -eq 0 )
    {
        return $Global:STATUS_SUCCESS
    }

    Write-Host "Package '$PackageAlias' requires to run a post install script to setup it."
    [int]$postInstallScriptExitCode = Start-PostInstallationScript -PackageAlias $packageAlias -ScriptPath $postInstallScriptPath -RequiresAdmin $postInstallScriptRequiresAdmin
    return $postInstallScriptExitCode
}

# Start a windows store package installation process.
function Start-WinStoreInstallation
{
    param (
        [PSCustomObject]$Config
    )

    [string]$appID = $Config.'app-id'
    [string]$appAlias = $Config.'app-alias'

    [int]$wingetInstallationExitCode = Start-InstallWinStorePackage -PackageID $appID -PackageAlias $appAlias

    if ($wingetInstallationExitCode -eq $Global:STATUS_FAILURE)
    {
        return $Global:STATUS_FAILURE
    }

    [string]$postInstallScriptPath = $Config.'post-install-script-path'
    [bool]$postInstallScriptRequiresAdmin = $Config.'post-install-script-requires-admin'
    if ( $null -eq $postInstallScriptPath -or $postInstallScriptPath.Length -eq 0 )
    {
        return $Global:STATUS_SUCCESS
    }

    Write-Host "Package '$appAlias' requires to run a post install script to setup it."
    [int]$postInstallScriptExitCode = Start-PostInstallationScript -PackageAlias $appAlias -ScriptPath $postInstallScriptPath -RequiresAdmin $postInstallScriptRequiresAdmin
    return $postInstallScriptExitCode
}

# Validate if the package is installed.
function Get-IsWingetPackageInstalled {
    param (
        [string]$PackageID,
        [string]$PackageAlias
    )

    # Get list of installed packages from winget.
    $installedPackages = winget list --id $PackageID 2>$null

    # Check if the package appears in the installed list.
    if ($installedPackages -match $PackageID) {
        Write-Host "$($UTF.CheckMark) Package '$PackageAlias' of ID '$PackageID' is already installed." -ForegroundColor Green
        return $true
    } else {
        Write-Host "$($UTF.CrossMark) Package '$PackageAlias' of ID '$PackageID' is NOT installed." -ForegroundColor DarkMagenta
        return $false
    }
}

# Install a winget package.
function Start-InstallWingetPackage {
    param (
        [string]$PackageID,
        [string]$PackageAlias,
        [string]$ExtraParameters,
        [bool]$Silent
    )

    try {
        Write-Host "Validating if '$PackageAlias' is already installed..."
        if (Get-IsWingetPackageInstalled -PackageID $PackageID){
            return $Global:STATUS_SUCCESS
        }

        Write-Host "$($UTF.HourGlass) Installing package '$PackageAlias'..." -ForegroundColor Yellow
        [string]$silentParameter = if ($Silent) { "--silent" } else { "--silent" }
        $process = Start-Process -FilePath "winget" -ArgumentList "install -e --id $PackageID $silentParameter $ExtraParameters" -NoNewWindow -PassThru
        $process.WaitForExit()

        # Check the last exit code.
        if ($process.ExitCode -eq 0) {
            Write-Host "$($UTF.HeavyCheckMark) Package '$PackageAlias' of ID '$PackageID' in NOW installed." -ForegroundColor Green
            return $Global:STATUS_SUCCESS
        }

        Write-Host "$($UTF.CrossMark) Error installing '$PackageAlias' by winget (Exit Code: $($process.ExitCode))" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    } catch {
        Write-Host "$($UTF.CrossMark) Exception occurred in '$PackageAlias' winget installation: $_" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    }
}

# Install a windows store package by winget.
function Start-InstallWinStorePackage {
    param (
        [string]$PackageID,
        [string]$PackageAlias
    )

    try {
        Write-Host "Validating if '$PackageAlias' is already installed..."
        if (Get-IsWingetPackageInstalled -PackageID $PackageID){
            return $Global:STATUS_SUCCESS
        }

        Write-Host "$($UTF.HourGlass) Installing windoes store package '$PackageAlias'..." -ForegroundColor Yellow
        $process = Start-Process -FilePath "winget" -ArgumentList "install --id $PackageID --source msstore --accept-package-agreements" -NoNewWindow -PassThru
        $process.WaitForExit()

        # Check the last exit code.
        if ($process.ExitCode -eq 0) {
            Write-Host "$($UTF.HeavyCheckMark) Package '$PackageAlias' of ID '$PackageID' in NOW installed." -ForegroundColor Green
            return $Global:STATUS_SUCCESS
        }

        Write-Host "$($UTF.CrossMark) Error installing windows store package '$PackageAlias' by winget (Exit Code: $($process.ExitCode))" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    } catch {
        Write-Host "$($UTF.CrossMark) Exception occurred in '$PackageAlias' windows store installation by winget: $_" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    }
}

# Run a post winget package installation script.
function Start-PostInstallationScript
{
    param (
        [string]$PackageAlias,
        [string]$ScriptPath,
        [bool]$RequiresAdmin
    )

    try {
        Write-Host "$($UTF.HourGlass) Starting package '$PackageAlias' post install script..." -ForegroundColor Yellow
        [int]$exitCode = Run-ScriptWithCorrectPermissions -ScriptPath $ScriptPath -RequiresAdmin $RequiresAdmin

        # Check the last exit code.
        if ($exitCode -eq $Global:STATUS_SUCCESS) {
            Write-Host "$($UTF.HeavyCheckMark) Package '$PackageAlias' post install script completed successfully." -ForegroundColor Green
            return $Global:STATUS_SUCCESS
        }

        Write-Host "$($UTF.CrossMark) Error executing package '$PackageAlias' post install script (Exit Code: $exitCode)" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    } catch {
        Write-Host "$($UTF.CrossMark) Exception occurred in package '$PackageAlias' post install script execution: $_" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    }
}

# Export the functions.
Export-ModuleMember -Function Start-WingetInstallation, Start-WinStoreInstallation