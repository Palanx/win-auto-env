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
        return Invoke-ScriptAs -asAdmin $true -ScriptPath $ScriptPath -ExtraParameters $ExtraParameters
    }
    # The script will run a new non-admin shell (simulates running in the same window).
    elseif (-not $RequiresAdmin -and (Get-IsAdmin))
    {
        return Invoke-ScriptAs -asAdmin $false -ScriptPath $ScriptPath -ExtraParameters $ExtraParameters
    }
    # The script is running with correct permissions.
    else
    {
        return & $ScriptPath @ExtraParameters -ExecutionPolicy Bypass -ErrorAction Stop
    }
}

# Run a script as Admin or User.
function Invoke-ScriptAs {
    param (
        [bool]$asAdmin,
        [string]$ScriptPath,
        [hashtable]$ExtraParameters = @{}
    )

    # Define the role text.
    if ($asAdmin) {$role = "Admin" } else {$role = "User" }

    Write-Host "Executing script as $role in new shell..." -ForegroundColor DarkMagenta

    # Create a temporary file to store the exit code.
    $tempFile = [System.IO.Path]::GetTempFileName()

    # Convert hashtable to a formatted string for PowerShell.
    $extraParamsString = ($ExtraParameters.GetEnumerator() | ForEach-Object { "-$($_.Key) '$($_.Value)'" }) -join " "

    # Build the PowerShell command to execute and return the exit code in a shell.
    $command = @"
`$exitCode = & `"$ScriptPath`" $extraParamsString -ExecutionPolicy Bypass -ErrorAction Stop;
`$exitCode | Out-File -FilePath `"$tempFile`" -NoNewline;
Write-Host "Script completed as $role, Press Enter to exit..."
Read-Host
"@

    # Run the shell and execute the command.
    if ($asAdmin)
    {
        $process = Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$command`"" -Verb RunAs -PassThru -Wait
    }
    else
    {
        $process = Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$command`"" -PassThru -Wait
    }
    $process.WaitForExit()

    # Get the exit code stored in the temp file.
    $exitCode = Get-Content $tempFile -Raw
    # Fallback in cases where exit code isn't returned because of an exception.
    if (!([int]::TryParse($exitCode, [ref]$null))){
        $exitCode = $Global:STATUS_FAILURE
    }

    # Remove the temp file used to store the exit code.
    Remove-Item $tempFile -Force

    Write-Host "Closed $role shell. Exit Code: $exitCode" -ForegroundColor DarkMagenta

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

# Register a ProgID.
function Register-ProgID {
    param (
        [string]$ProgID,        # e.g. "MyApp.Document.1"
        [string]$ProgramName,   # e.g. "My App"
        [string]$AppPath        # e.g. "C:\Path\To\YourApp.exe"
    )

    # Define paths.
    $registryPath = "HKCU:\Software\Classes\$ProgID"

    try
    {
        # Ensure the path exists.
        if (Test-Path $registryPath) {
            Write-Host "$($UTF.CheckMark) ProgID '$ProgID' is already registered. Skipping registration." -ForegroundColor Green
            return $Global:STATUS_SUCCESS
        }

        # Create ProgID entry.
        New-Item -Path $registryPath -Force | Out-Null
        # Set the default value.
        Set-ItemProperty -Path $registryPath -Name "(Default)" -Value "$ProgramName"

        # Add the shell command for file association
        $commandPath = "$registryPath\shell\open\command"
        New-Item -Path $commandPath -Force | Out-Null
        Set-ItemProperty -Path $commandPath -Name "(Default)" -Value "`"$AppPath`" `%1"

        Write-Host "ProgID '$ProgID' registered successfully under HKCU."
        return $Global:STATUS_SUCCESS
    }
    catch
    {
        Write-Host "$($UTF.CrossMark) Exception occurred registering the ProgID '$ProgID': $(Get-ExceptionDetails $_)" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    }
}

# Export the functions.
Export-ModuleMember -Function Restart-Explorer, Get-IsAdmin, Invoke-ScriptWithCorrectPermissions, Get-ExceptionDetails, Register-ProgID