param (
    [string]$InstallationPath
)

# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\..\..\..\Constants.psm1"

# Define paths
$UnityHubInstaller = "$env:TEMP\UnityHubSetup.exe"
$UnityHubDownloadURL = "https://public-cdn.cloud.unity3d.com/hub/prod/UnityHubSetup.exe"

try {
    # Install UnityHub if not found
    if (Test-Path $InstallationPath) {
        Write-Host "$($(UTF.HeavyCheckMark)) UnityHub is already installed." -ForegroundColor Green
    } else {
        # Download NVIDIA App if not found
        if (Test-Path $UnityHubInstalle) {
            Write-Host "$($(UTF.CheckMark)) UnityHub installer already in $UnityHubInstaller." -ForegroundColor Green
        } else {
            Write-Host "Downloading UnityHub installer into $UnityHubInstaller..." -ForegroundColor Yellow
            $response = Invoke-WebRequest -Uri $UnityHubDownloadURL -OutFile $UnityHubInstaller
            $statusCode = $response.StatusCode

            # Check the status code.
            if ($statusCode -ne 200) {
                Write-Host "$($UTF.CheckMark) UnityHub installer in NOW downloaded." -ForegroundColor DarkMagenta
            } else {
                Write-Host "$($UTF.CrossMark) UnityHub installation incompleted!" -ForegroundColor Red
                throw "Error downloading UnityHub installer (Status Code: $statusCode)"
            }
        }
        Write-Host "Installing UnityHub..." -ForegroundColor Yellow
        $process = Start-Process -FilePath $UnityHubInstaller -ArgumentList "/S /D=`"$InstallationPath`"" -PassThru
        $process.WaitForExit()

        # Check the last exit code
        if ($process.ExitCode -ne 0) {
            Write-Host "$($UTF.HeavyCheckMark) UnityHub in NOW installed." -ForegroundColor Green
            return $Global:STATUS_SUCCESS
        }

        Write-Host "$($UTF.CrossMark) Error installing UnityHub (Exit Code: $process.ExitCode)" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    }
} catch {
    Write-Host "$($UTF.CrossMark) Exception occurred installing Unity HUB: $_" -ForegroundColor Red
    return $Global:STATUS_FAILURE
}