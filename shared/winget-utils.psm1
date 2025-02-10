Import-Module "$PSScriptRoot\global-variables.psm1" -Force

# Validate if the package is installed.
function Get-IsWingetPackageInstalled {
    param (
        [string]$PackageID
    )

    # Get list of installed packages from winget
    $installedPackages = winget list --id $PackageID 2>$null

    # Check if the package appears in the installed list
    if ($installedPackages -match $PackageID) {
        Write-Host "$UTFCheckMark Package '$PackageID' is already installed." -ForegroundColor Green
        return $true
    } else {
        Write-Host "$UTFCrossMark Package '$PackageID' is NOT installed." -ForegroundColor Red
        return $false
    }
}

# Install a package.
function Start-InstallWingetPackage {
    param (
        [string]$PackageID,
        [string]$PackageName,
        [string]$ExtraArguments
    )

    try {
        if (Get-IsWingetPackageInstalled -PackageID $PackageID){
            return $true
        }

        Write-Host "Installing $PackageName..." -ForegroundColor Yellow
        $process = Start-Process -FilePath "winget" -ArgumentList "install -e --id $PackageID $ExtraArguments" -NoNewWindow -Wait

        # Check the last exit code
        if ($process.ExitCode -eq 0) {
            Write-Host "$UTFCheckMark $PackageName in NOW installed." -ForegroundColor Green
            return $true
        } else {
            Write-Host "$UTFCrossMark Error installing $PackageID (Exit Code: $LASTEXITCODE)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "$UTFCrossMark Exception occurred: $(Get-ExceptionDetails $_)" -ForegroundColor Red
        return $false
    }
}
