# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\..\..\..\Constants.psm1"
Import-Module "$ScriptDir\..\..\..\Core.psm1"

# Define paths.
$NVIDIAAppInstallerPath = "$env:USERPROFILE\Downloads\NVIDIA_app.exe"

try {
    $NvidiaApp = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -like "NVIDIA App*" }
    if ($NvidiaApp) {
        Write-Host "$($UTF.HeavyCheckMark) NVIDIA App is already installed. Version: $($NvidiaApp.DisplayVersion)" -ForegroundColor Green
        return $Global:STATUS_SUCCESS
    }

    # Download NVIDIA App if not found.
    if (Test-Path $NVIDIAAppInstallerPath)
    {
        Write-Host "$($UTF.CheckMark) NVIDIA App already downloaded." -ForegroundColor Green
    }
    else
    {
        Write-Host "Downloading NVIDIA App..." -ForegroundColor Yellow
        $response = Invoke-WebRequest -Uri "https://us.download.nvidia.com/nvapp/client/11.0.1.189/NVIDIA_app_v11.0.1.189.exe" -OutFile $NVIDIAAppInstallerPath -UseBasicParsing
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
        return $Global:STATUS_SUCCESS
    } else {
        Write-Host "$($UTF.CrossMark) Error installing NVIDIA App (Exit Code: $($process.ExitCode))" -ForegroundColor Red
        return $process.ExitCode
    }
} catch {
    Write-Host "$($UTF.CrossMark) Exception occurred in Nvidia App installation: $(Get-ExceptionDetails $_)" -ForegroundColor Red
    return $Global:STATUS_FAILURE
}