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
    [bool]$requiresAdmin = $Config.'requires-admin'
    [string]$location = $Config.'location'
    if ($location.Length -gt 0)
    {
        $extraParameters += "--location `"$location`""
    }

    [int]$wingetInstallationExitCode = Start-InstallWingetPackage -PackageID $packageId -PackageAlias $packageAlias -ExtraParameters $extraParameters -Silent $silent -RequiresAdmin $requiresAdmin

    if ($wingetInstallationExitCode -eq $Global:STATUS_FAILURE)
    {
        return $Global:STATUS_FAILURE
    }

    [string]$postInstallScriptPath = $Config.'post-install-script-path'
    [bool]$postInstallScriptRequiresAdmin = $Config.'post-install-script-requires-admin'
    if ($null -eq $postInstallScriptPath -or $postInstallScriptPath.Length -eq 0)
    {
        return $Global:STATUS_SUCCESS
    }

    Write-Host "Package '$packageAlias' requires to run a post install script to setup it."
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
    [bool]$requiresAdmin = $Config.'requires-admin'

    [int]$wingetInstallationExitCode = Start-InstallWinStorePackage -PackageID $appID -PackageAlias $appAlias -RequiresAdmin $requiresAdmin

    if ($wingetInstallationExitCode -eq $Global:STATUS_FAILURE)
    {
        return $Global:STATUS_FAILURE
    }

    [string]$postInstallScriptPath = $Config.'post-install-script-path'
    [bool]$postInstallScriptRequiresAdmin = $Config.'post-install-script-requires-admin'
    if ($null -eq $postInstallScriptPath -or $postInstallScriptPath.Length -eq 0)
    {
        return $Global:STATUS_SUCCESS
    }

    Write-Host "Package '$appAlias' requires to run a post install script to setup it."
    [int]$postInstallScriptExitCode = Start-PostInstallationScript -PackageAlias $appAlias -ScriptPath $postInstallScriptPath -RequiresAdmin $postInstallScriptRequiresAdmin
    return $postInstallScriptExitCode
}

# Validate if the package is installed.
function Get-IsWingetPackageInstalled
{
    param (
        [string]$PackageID,
        [string]$PackageAlias
    )

    # Try to get the package, to know if it's installed.
    $installedPackage = winget list --disable-interactivity | Where-Object { $_ -match $PackageID }

    # Check if the package appears in the installed list.
    if ($installedPackage)
    {
        Write-Host "$( $UTF.HeavyCheckMark ) Package '$PackageAlias' of ID '$PackageID' is already installed." -ForegroundColor Green
        return $true
    }
    else
    {
        Write-Host "$( $UTF.CrossMark ) Package '$PackageAlias' of ID '$PackageID' is NOT installed." -ForegroundColor DarkMagenta
        return $false
    }
}

# Install a winget package.
function Start-InstallWingetPackage
{
    param (
        [string]$PackageID,
        [string]$PackageAlias,
        [string]$ExtraParameters,
        [bool]$Silent,
        [bool]$RequiresAdmin
    )

    try
    {
        Write-Host "Validating if '$PackageAlias' is already installed..."
        if (Get-IsWingetPackageInstalled -PackageID $PackageID -PackageAlias $PackageAlias)
        {
            return $Global:STATUS_SUCCESS
        }

        Write-Host "$( $UTF.HourGlass ) Installing package '$PackageAlias'..." -ForegroundColor Yellow
        [string]$silentParameter = if ($Silent)
        {
            "--silent"
        }
        else
        {
            "--silent"
        }

        $argumentList = "install -e --id $PackageID $silentParameter $ExtraParameters";
        Write-Host $argumentList
        # The winget install run a new admin shell.
        if ($RequiresAdmin -and -not (Get-IsAdmin))
        {
            $exitCode = Invoke-WingetInstallAs -asAdmin $true -packageID $PackageID -argumentList $argumentList
        }
        # The winget install run a new non-admin shell (simulates running in the same window).
        elseif (-not $RequiresAdmin -and (Get-IsAdmin))
        {
            $exitCode = Invoke-WingetInstallAs -asAdmin $false -packageID $PackageID -argumentList $argumentList
        }
        # The winget install is running with correct permissions.
        else
        {
            $process = Start-Process -FilePath "winget" -ArgumentList "$argumentList" -NoNewWindow -PassThru -Wait
            $process.WaitForExit()
            $exitCode = $process.ExitCode
        }

        # Check the last exit code.
        if ($exitCode -eq 0)
        {
            Write-Host "$( $UTF.HeavyCheckMark ) Package '$PackageAlias' of ID '$PackageID' in NOW installed." -ForegroundColor Green
            return $Global:STATUS_SUCCESS
        }

        Write-Host "$( $UTF.CrossMark ) Error installing '$PackageAlias' by winget (Exit Code: $( $exitCode ))" -ForegroundColor Red
        return $exitCode
    }
    catch
    {
        Write-Host "$( $UTF.CrossMark ) Exception occurred in '$PackageAlias' winget installation: $( Get-ExceptionDetails $_ )" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    }
}

# Install a windows store package by winget.
function Start-InstallWinStorePackage
{
    param (
        [string]$PackageID,
        [string]$PackageAlias,
        [bool]$RequiresAdmin
    )

    try
    {
        Write-Host "Validating if '$PackageAlias' is already installed..."
        if (Get-IsWingetPackageInstalled -PackageID $PackageID -PackageAlias $PackageAlias)
        {
            return $Global:STATUS_SUCCESS
        }

        Write-Host "$( $UTF.HourGlass ) Installing windoes store package '$PackageAlias'..." -ForegroundColor Yellow

        $argumentList = "install --id $PackageID --source msstore --accept-package-agreements";
        # The winget install run a new admin shell.
        if ($RequiresAdmin -and -not (Get-IsAdmin))
        {
            $exitCode = Invoke-WingetInstallAs -asAdmin $true -packageID $PackageID -argumentList $argumentList
        }
        # The winget install run a new non-admin shell (simulates running in the same window).
        elseif (-not $RequiresAdmin -and (Get-IsAdmin))
        {
            $exitCode = Invoke-WingetInstallAs -asAdmin $false -packageID $PackageID -argumentList $argumentList
        }
        # The winget install is running with correct permissions.
        else
        {
            $process = Start-Process -FilePath "winget" -ArgumentList "$argumentList" -NoNewWindow -PassThru -Wait
            $process.WaitForExit()
            $exitCode = $process.ExitCode
        }

        # Check the last exit code.
        if ($exitCode -eq 0)
        {
            Write-Host "$( $UTF.HeavyCheckMark ) Package '$PackageAlias' of ID '$PackageID' in NOW installed." -ForegroundColor Green
            return $Global:STATUS_SUCCESS
        }

        Write-Host "$( $UTF.CrossMark ) Error installing windows store package '$PackageAlias' by winget (Exit Code: $( $exitCode ))" -ForegroundColor Red
        return $exitCode
    }
    catch
    {
        Write-Host "$( $UTF.CrossMark ) Exception occurred in '$PackageAlias' windows store installation by winget: $( Get-ExceptionDetails $_ )" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    }
}

# Run a Winget Install as Admin or User.
function Invoke-WingetInstallAs
{
    param (
        [bool]$asAdmin,
        [string]$scriptPath,
        [string]$argumentList = ""
    )

    # Define the role text.
    if ($asAdmin)
    {
        $role = "Admin"
    }
    else
    {
        $role = "User"
    }

    Write-Host "Executing Winget Install as $role in new shell..." -ForegroundColor DarkMagenta

    # Create a temporary file to store the exit code.
    $tempFile = [System.IO.Path]::GetTempFileName()

    # Build the PowerShell command to execute and return the exit code in a shell.
    $command = @"
`$process = Start-Process -FilePath 'winget' -ArgumentList '$argumentList' -NoNewWindow -PassThru -Wait;
`$process.WaitForExit();
`$exitCode = `$process.ExitCode;
`$exitCode | Out-File -FilePath `"$tempFile`" -NoNewline;
Write-Host "Winget Installation completed as $role, Press Enter to exit..."
Read-Host
"@

    # Run the shell and execute the command.
    if ($asAdmin)
    {
        $process = Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$command`"" -Verb RunAs -PassThru -Wait
    }
    else
    {
        $process = Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$command`"" -PassThru -Wait
    }
    $process.WaitForExit()

    # Get the exit code stored in the temp file.
    $exitCode = Get-Content $tempFile -Raw
    # Fallback in cases where exit code isn't returned because of an exception.
    if (!([int]::TryParse($exitCode, [ref]$null)))
    {
        $exitCode = $Global:STATUS_FAILURE
    }

    # Remove the temp file used to store the exit code.
    Remove-Item $tempFile -Force

    Write-Host "Closed $role shell. Exit Code: $exitCode" -ForegroundColor DarkMagenta

    return $exitCode
}

# Run a post winget package installation script.
function Start-PostInstallationScript
{
    param (
        [string]$PackageAlias,
        [string]$ScriptPath,
        [bool]$RequiresAdmin
    )

    try
    {
        Write-Host "$( $UTF.HourGlass ) Starting package '$PackageAlias' post install script..." -ForegroundColor Yellow
        [int]$exitCode = Invoke-ScriptWithCorrectPermissions -ScriptPath "$ScriptDir$ScriptPath" -RequiresAdmin $RequiresAdmin

        # Check the last exit code.
        if ($exitCode -eq $Global:STATUS_SUCCESS)
        {
            Write-Host "$( $UTF.HeavyCheckMark ) Package '$PackageAlias' post install script completed successfully." -ForegroundColor Green
            return $Global:STATUS_SUCCESS
        }

        Write-Host "$( $UTF.CrossMark ) Error executing package '$PackageAlias' post install script (Exit Code: $exitCode)" -ForegroundColor Red
        return $process.ExitCode
    }
    catch
    {
        Write-Host "$( $UTF.CrossMark ) Exception occurred in package '$PackageAlias' post install script execution: $( Get-ExceptionDetails $_ )" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    }
}

# Export the functions.
Export-ModuleMember -Function Start-WingetInstallation, Start-WinStoreInstallation