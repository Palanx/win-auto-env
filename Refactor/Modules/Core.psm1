# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\Constants.psm1"

# ------------------------------------------------------------------------------------------------------------- #
# Functions                                                                                                     #
# ------------------------------------------------------------------------------------------------------------- #

# Restart explorer service.
function Restart-Explorer
{
    Write-Host "Restarting explorer service." -ForegroundColor Yellow
    # Stop Explorer
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue

    # Start Explorer and Wait for Initialization
    Start-Process -FilePath explorer.exe

    # Wait for Explorer to be fully initialized
    do {
        Start-Sleep -Milliseconds 500
        $explorerRunning = Get-Process -Name explorer -ErrorAction SilentlyContinue
    } while (-not $explorerRunning)

    Write-Host "$($UTF.CheckMark) Explorer restarted successfully." -ForegroundColor Green
}

# Get if the current PowerShell session has administrator privileges.
function Get-IsAdmin {
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Run a script with the correct permissions.
function Invoke-ScriptWithCorrectPermissions
{
    param (
        [string]$ScriptPath,
        [hashtable]$ExtraParameters = @{},
        [bool]$RequiresAdmin = $false
    )

    if (!(Test-Path $ScriptPath))
    {
        throw "The script path '$ScriptPath' doesn't exist."
    }

    # The script will run a new admin shell.
    if ($RequiresAdmin -and -not (Get-IsAdmin))
    {
        return Invoke-ScriptAsAdmin -ScriptPath $ScriptPath -ExtraParameters $ExtraParameters
    }
    # The script will run a new non-admin shell (simulates running in the same window).
    elseif (-not $RequiresAdmin -and (Get-IsAdmin))
    {
        return Invoke-ScriptAsUser -ScriptPath $ScriptPath -ExtraParameters $ExtraParameters
    }
    # The script is running with correct permissions.
    else
    {
        return & $ScriptPath @ExtraParameters -ExecutionPolicy Bypass -ErrorAction Stop
    }
}

# Run a script as admin.
function Invoke-ScriptAsAdmin {
    param (
        [string]$ScriptPath,
        [hashtable]$ExtraParameters = @{}
    )

    Write-Host "Executing script as Admin in new shell..." -ForegroundColor DarkMagenta

    # Create a temporary file to store the exit code.
    $tempFile = [System.IO.Path]::GetTempFileName()

    # Convert hashtable to a formatted string for PowerShell.
    $extraParamsString = ($ExtraParameters.GetEnumerator() | ForEach-Object { "-$($_.Key) `"$($_.Value)`"" }) -join " "

    # Build the PowerShell command to execute and return the exit code in a Admin shell.
    $command = @"
`$exitCode = & `"$ScriptPath`" $extraParamsString -ExecutionPolicy Bypass -ErrorAction Stop;
`$exitCode | Out-File -FilePath `"$tempFile`" -NoNewline;
Write-Host "Script completed, Press Enter to exit..."
Read-Host
"@

    # Run the admin shell and execute the command.
    $process = Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$command`"" -Verb RunAs -PassThru -Wait
    $process.WaitForExit()

    # Get the exit code stored in the temp file.
    $exitCode = Get-Content $tempFile -Raw
    # Fallback in cases where exit code isn't returned because of an exception.
    if ($exitCode -isnot [int]){
        $exitCode = $Global:STATUS_FAILURE
    }

    # Remove the temp file used to store the exit code.
    Remove-Item $tempFile -Force

    Write-Host "Closed Admin shell. Exit Code: $exitCode" -ForegroundColor DarkMagenta

    return $exitCode
}

# Run a script as user.
function Invoke-ScriptAsUser {
    param (
        [string]$ScriptPath,
        [hashtable]$ExtraParameters = @{}
    )

    Write-Host "Executing script as User in new shell..." -ForegroundColor DarkMagenta

    # Create a temporary file to store the exit code.
    $tempFile = [System.IO.Path]::GetTempFileName()

    # Convert hashtable to a formatted string for PowerShell.
    $extraParamsString = ($ExtraParameters.GetEnumerator() | ForEach-Object { "-$($_.Key) `'$($_.Value)`'" }) -join " "

    # Build the PowerShell command to execute and return the exit code in a Admin shell.
    $command = @"
`$exitCode = & `"$ScriptPath`" $extraParamsString -ExecutionPolicy Bypass -ErrorAction Stop;
`$exitCode | Out-File -FilePath `"$tempFile`" -NoNewline;
Write-Host "Script completed, Press Enter to exit..."
Read-Host
"@

    # Run the admin shell and execute the command.
    $process = Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$command`"" -PassThru -Wait
    $process.WaitForExit()

    # Get the exit code stored in the temp file.
    $exitCode = Get-Content $tempFile -Raw
    # Fallback in cases where exit code isn't returned because of an exception.
    if ($exitCode -isnot [int]){
        $exitCode = $Global:STATUS_FAILURE
    }

    # Remove the temp file used to store the exit code.
    Remove-Item $tempFile -Force

    Write-Host "Closed User shell. Exit Code: $exitCode" -ForegroundColor DarkMagenta

    return $exitCode
}

function Get-ExceptionDetails {
    param (
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord
    )

    # Capture error details
    $errorMessage = $ErrorRecord.Exception.Message
    $lineNumber = $ErrorRecord.InvocationInfo.ScriptLineNumber
    $scriptName = $ErrorRecord.InvocationInfo.ScriptName
    $scriptStackTrace = $ErrorRecord.ScriptStackTrace

    # Format the error message
    $errorDetails = @"
$($UTF.AngerSymbol) ERROR: $errorMessage
$($UTF.OpenFileFolder) Script Name: $scriptName
$($UTF.MagnifyingGlass) Error at Line: $lineNumber
$($UTF.Pushpin) Stack Trace:
$scriptStackTrace
"@

    return $errorDetails
}

# Export the functions.
Export-ModuleMember -Function Restart-Explorer, Get-IsAdmin, Invoke-ScriptWithCorrectPermissions, Get-ExceptionDetails