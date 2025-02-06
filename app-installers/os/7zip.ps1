Import-Module "$PSScriptRoot\..\..\shared\winget-utils.psm1" -Force
Import-Module "$PSScriptRoot\..\..\shared\global-variables.psm1" -Force

# Define paths
$SetUserFTA = "$env:USERPROFILE\Downloads\SetUserFTA.exe"

# List of file extensions to associate with 7-Zip
$extensions = @(".7z", ".zip", ".rar", ".tar", ".gz", ".bz2", ".xz", ".cab", ".lzh", ".arj", ".z", ".001")

# Define the intallation variables for winget
$PackageID="7zip.7zip"
$PackageName="7Zip"
$ExtraArguments="--silent"


try {
    # Install 7-Zip 
    if (!(Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)) {
        return;
    }

    # Download SetUserFTA.exe if not found
    if (!(Test-Path $SetUserFTA)) {
        # Reset before running winget
        $LASTEXITCODE = 0
        Write-Host "Downloading SetUserFTA..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri "https://github.com/qis/windows/raw/refs/heads/master/setup/SetUserFTA/SetUserFTA.exe" -OutFile $SetUserFTA

        # Check the last exit code
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$UTFCheckMark SetUserFTA in NOW downloaded." -ForegroundColor Green
        } else {
            Write-Host "$UTFCrossMark Error downloading SetUserFTA (Exit Code: $LASTEXITCODE)" -ForegroundColor Red
            Write-Host "$UTFCrossMark 7-Zip setup incomplete!" -ForegroundColor Red
            return
        }
    }
    else {
        Write-Host "$UTFCheckMark SetUserFTA already downloaded." -ForegroundColor Green
    }

    # Reset before running winget
    $LASTEXITCODE = 0

    # Assign file types to 7-Zip
    Write-Host "Setting file associations..."
    foreach ($ext in $extensions) {
        Start-Process -FilePath $SetUserFTA -ArgumentList "$ext 7zFM.exe" -Wait -NoNewWindow
    }

    # Check the last exit code
    if ($LASTEXITCODE -eq 0) {
        Write-Host "$UTFCheckMark File associations updated successfully!" -ForegroundColor Green
    } else {
        Write-Host "$UTFCrossMark Error setting file asosiation to 7-Zip (Exit Code: $LASTEXITCODE)" -ForegroundColor Red
        return;
    }

    # TODO: Required restart explorer

    Write-Host "$UTFCheckMark 7-Zip setup completed." -ForegroundColor Green
} catch {
    Write-Host "$UTFCrossMark Exception occurred: $_" -ForegroundColor Red
}