﻿# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\..\..\..\Constants.psm1"
Import-Module "$ScriptDir\..\..\..\Core.psm1"

# Define paths
$ProgID = "7zFM.exe"
$7zLocation = "C:\Program Files\7-Zip\7zFM.exe"
$SetUserFTA = "$env:USERPROFILE\Downloads\SetUserFTA.exe"

# List of file extensions to associate with 7-Zip.
$Extensions = @(".7z", ".zip", ".rar", ".tar", ".gz", ".bz2", ".xz", ".cab", ".lzh", ".arj", ".z", ".001")

try {
    # Download SetUserFTA.exe if not found.
    if (!(Test-Path $SetUserFTA)) {
        Write-Host "Downloading SetUserFTA..." -ForegroundColor Yellow
        $response = Invoke-WebRequest -Uri "https://github.com/qis/windows/raw/refs/heads/master/setup/SetUserFTA/SetUserFTA.exe" -OutFile $SetUserFTA -UseBasicParsing
        $statusCode = $response.StatusCode

        # Check the status code.
        if ($statusCode -ne 200) {
            Write-Host "$($UTF.CheckMark) SetUserFTA in NOW downloaded." -ForegroundColor DarkMagenta
        } else {
            Write-Host "$($UTF.CrossMark) 7-Zip setup incomplete!" -ForegroundColor Red
            throw "Error downloading SetUserFTA (Status Code: $statusCode)"
        }
    }
    else {
        Write-Host "$($UTF.CheckMark) SetUserFTA already downloaded." -ForegroundColor Green
    }

    # Register the 7Zip ProgID.
    $registerExitCode = Register-ProgID -ProgID $ProgID -ProgramName "7-Zip File Manager" -AppPath $7zLocation
    if ($registerExitCode -ne $Global:STATUS_SUCCESS)
    {
        return $registerExitCode;
    }

    # Track failed 7-Zip associations.
    $FailedAssociations = @()

    # Assign file types to 7-Zip.
    Write-Host "Setting file associations..." -ForegroundColor Yellow
    foreach ($ext in $extensions) {
        $output = & $SetUserFTA $ext $ProgID 2>&1

        # Check the last exit code.
        if (!$output) {
            Write-Host "$($UTF.CheckMark) File ext '$ext' associations updated successfully!" -ForegroundColor Green
        } else {
            Write-Host "$($UTF.CrossMark) Error setting file ext '$ext' asosiation to 7-Zip (Output: $output)" -ForegroundColor Red
            $FailedAssociations += $ext
        }
    }

    if ($FailedAssociations.Count -gt 0)
    {
        throw "Some extension associations failed: $( $FailedAssociations -join ', ' )"
    }

    Write-Host "$($UTF.CheckMark) 7-Zip setup completed." -ForegroundColor Green
    return $Global:STATUS_SUCCESS
} catch {
    Write-Host "$($UTF.CrossMark) Exception occurred in 7Zip setup: $(Get-ExceptionDetails $_)" -ForegroundColor Red
    return $Global:STATUS_FAILURE
}