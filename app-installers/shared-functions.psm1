# Emogis
Set-Variable -Name "UTFCheckMark" -Value $([char]::ConvertFromUtf32(0x00002705)) -Scope Script
Set-Variable -Name "UTFCrossMark" -Value $([char]::ConvertFromUtf32(0x0000274C)) -Scope Script
Set-Variable -Name "UTFWarningSign" -Value $([char]::ConvertFromUtf32(0x000026A0)) -Scope Script

# Enable styles 
$esc = [char]27

# Font Styles
Set-Variable -Name "StartBold" -Value "$esc[1m" -Scope Script
Set-Variable -Name "EndBold" -Value "$esc[0m" -Scope Script
Set-Variable -Name "StartUnderline" -Value "$esc[4m" -Scope Script
Set-Variable -Name "EndUnderline" -Value "$esc[0m" -Scope Script

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

        # Reset before running winget
        $LASTEXITCODE = 0
        Write-Host "Installing $PackageName..." -ForegroundColor Yellow
        Start-Process -FilePath "winget" -ArgumentList "install -e --id $PackageID $ExtraArguments" -NoNewWindow -Wait

        # Check the last exit code
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$UTFCheckMark $PackageName in NOW installed." -ForegroundColor Green
            return $true
        } else {
            Write-Host "$UTFCrossMark Error installing $PackageID (Exit Code: $LASTEXITCODE)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "$UTFCrossMark Exception occurred: $_" -ForegroundColor Red
        return $false
    }
}

# Validate if path exist
function Get-IsPathExistent {
    param (
        [string]$Path
    )
    return Test-Path "$Path"
}