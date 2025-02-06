Import-Module "$PSScriptRoot\..\..\shared\winget-utils.psm1" -Force
Import-Module "$PSScriptRoot\..\..\shared\global-variables.psm1" -Force

# Define paths
$NVIDIAAppInstallerPath = "$env:USERPROFILE\Downloads\NVIDIA_app.exe"

try {
    # Download NVIDIA App if not found
    if (!(Test-Path $NVIDIAAppInstallerPath)) {
        # Reset before running winget
        $LASTEXITCODE = 0
        Write-Host "Downloading NVIDIA App..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri "https://us.download.nvidia.com/nvapp/client/11.0.1.189/NVIDIA_app_v11.0.1.189.exe" -OutFile $NVIDIAAppInstallerPath

        # Check the last exit code
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$UTFCheckMark NVIDIA App in NOW downloaded." -ForegroundColor Green
        } else {
            Write-Host "$UTFCrossMark Error downloading NVIDIA App (Exit Code: $LASTEXITCODE)" -ForegroundColor Red
            Write-Host "$UTFCrossMark NVIDIA App setup incomplete!" -ForegroundColor Red
            return
        }
    }
    else {
        Write-Host "$UTFCheckMark NVIDIA App already downloaded." -ForegroundColor Green
    }


    # Install the app
    Write-Host "Installing NVIDIA App..." -ForegroundColor Yellow
    # Reset before running winget
    $LASTEXITCODE = 0
    Start-Process -FilePath $NVIDIAAppInstallerPath -ArgumentList "/s /noreboot" -NoNewWindow -Wait

    # Check the last exit code
    if ($LASTEXITCODE -eq 0) {
        Write-Host "$UTFCheckMark NVIDIA App in NOW installed." -ForegroundColor Green
    } else {
        Write-Host "$UTFCrossMark Error installing NVIDIA App (Exit Code: $LASTEXITCODE)" -ForegroundColor Red
    }
} catch {
    Write-Host "$UTFCrossMark Exception occurred: $_" -ForegroundColor Red
}
