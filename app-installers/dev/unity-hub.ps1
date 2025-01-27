Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

# Define paths
$UnityHubInstaller = "$env:TEMP\UnityHubSetup.exe"
$UnityHubPath = "D:\Program Files\Unity Hub\Unity Hub.exe"
$UnityHubDownloadURL = "https://public-cdn.cloud.unity3d.com/hub/prod/UnityHubSetup.exe"

try {
    # Install UnityHub if not found
    if (Get-IsPathExistent -Path $UnityHubPath) {
        Write-Host "$UTFCheckMark UnityHub is already installed." -ForegroundColor Green
    } else {
        # Download NVIDIA App if not found
        if (Get-IsPathExistent -Path $UnityHubInstalle) {
            Write-Host "UnityHub already in $UnityHubInstaller."
        } else {
            Write-Host "Downloading UnityHub installer into $UnityHubInstaller..."
            Invoke-WebRequest -Uri $UnityHubDownloadURL -OutFile $UnityHubInstaller
        }

        # Reset before running winget
        $LASTEXITCODE = 0
        Write-Host "Installing UnityHub..." -ForegroundColor Yellow
        Start-Process -FilePath $UnityHubInstaller -ArgumentList "/S /D=`"D:\Program Files\Unity Hub`"" -Wait

        # Check the last exit code
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$UTFCheckMark UnityHub in NOW installed." -ForegroundColor Green
        } else {
            Write-Host "$UTFCrossMark Error installing UnityHub (Exit Code: $LASTEXITCODE)" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "$UTFCrossMark Exception occurred: $_" -ForegroundColor Red
}