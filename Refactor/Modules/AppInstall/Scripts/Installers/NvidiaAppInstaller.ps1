# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\..\..\..\Constants.psm1"
Import-Module "$ScriptDir\..\..\..\Core.psm1"

# Define paths.
$NVIDIAAppInstallerPath = "$env:USERPROFILE\Downloads\NVIDIA_app.exe"

# TODO: Fix this script.

try {
    # Download NVIDIA App if not found.
    if (Test-Path $NVIDIAAppInstallerPath)
    {
        Write-Host "$($UTF.CheckMark) NVIDIA App already downloaded." -ForegroundColor Green
    }
    else
    {
        Write-Host "Downloading NVIDIA App..." -ForegroundColor Yellow
        $response = Invoke-WebRequest -Uri "https://us.download.nvidia.com/nvapp/client/11.0.1.189/NVIDIA_app_v11.0.1.189.exe" -OutFile $NVIDIAAppInstallerPath
        $statusCode = $response.StatusCode

        # Check the last exit code.
        if ($statusCode -ne 200) {
            Write-Host "$($UTF.CheckMark) NVIDIA App in NOW downloaded." -ForegroundColor Green
        } else {
            Write-Host "$($UTF.CrossMark) Nvidia App installation incompleted!" -ForegroundColor Red
            throw "Error downloading Nvidia App installer (Status Code: $statusCode)"
        }
    }

    # Install the app
    Write-Host "Installing NVIDIA App..." -ForegroundColor Yellow
    $process = Start-Process -FilePath $NVIDIAAppInstallerPath -ArgumentList "/s /noreboot" -NoNewWindow -PassThru -Wait
    $process.WaitForExit()

    # Check the last exit code
    if ($process.Exitcode -eq 0) {
        Write-Host "$($UTF.HeavyCheckMark) NVIDIA App in NOW installed." -ForegroundColor Green
        Write-Host "Press any key to exit..."
        Read-Host

        return $Global:STATUS_SUCCESS
    } else {
        Write-Host "$($UTF.CrossMark) Error installing NVIDIA App (Exit Code: $($process.ExitCode))" -ForegroundColor Red
        Write-Host "Press any key to exit..."
        Read-Host

        return $Global:STATUS_FAILURE
    }
} catch {
    Write-Host "$($UTF.CrossMark) Exception occurred in Nvidia App installation: $(Get-ExceptionDetails $_)" -ForegroundColor Red
    Write-Host "Press any key to exit..."
    Read-Host

    return $Global:STATUS_FAILURE
}