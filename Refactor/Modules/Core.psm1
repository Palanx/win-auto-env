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

    Write-Host "Executing script as Admin using PsExec..." -ForegroundColor DarkMagenta

    # Validate if PsExec is available in PATH
    if (-Not (Get-Command psexec -ErrorAction SilentlyContinue)) {
        Write-Host "❌ PsExec not found in PATH. Please install it or add it to your environment variables." -ForegroundColor Red
        exit 1
    }

    # Convert hashtable to a formatted string for PowerShell.
    $extraParamsString = ($ExtraParameters.GetEnumerator() | ForEach-Object { "$($_.Key) `"$($_.Value)`"" }) -join " "

    # Run the script using PsExec with SYSTEM privileges
    $process = Start-Process psexec -ArgumentList "-accepteula -s powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`" $extraParamsString" -PassThru
    $process.WaitForExit()
    $exitCode = $process.ExitCode

    Write-Host "Closed Admin Shell via PsExec. Exit Code: $exitCode" -ForegroundColor DarkMagenta

    return $exitCode
}

# Run a script as user.
function Invoke-ScriptAsUser {
    param (
        [string]$ScriptPath,
        [hashtable]$ExtraParameters = @{}
    )

    Write-Host "Executing script as User in another shell..." -ForegroundColor DarkMagenta

    # Read the script content
    $scriptContent = Get-Content -Path $ScriptPath -Raw

    # Convert hashtable to a formatted string for PowerShell.
    $extraParamsString = ($ExtraParameters.GetEnumerator() | ForEach-Object { "$($_.Key) `"$($_.Value)`"" }) -join " "

    # Construct the full command
    $command = "& { $scriptContent } $extraParamsString"

    # Start a user PowerShell process using -Command
    $process = Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command $command" -PassThru
    $process.WaitForExit()

    # Capture and return the real exit code
    $exitCode = $process.ExitCode

    Write-Host "Closed User shell Exit Code: $exitCode" -ForegroundColor DarkMagenta

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
    $stackTrace = $ErrorRecord.ScriptStackTrace

    # Format the error message
    $errorDetails = @"
$($UTF.AngerSymbol) ERROR: $errorMessage
$($UTF.OpenFileFolder) Script Name: $scriptName
$($UTF.MagnifyingGlass) Error at Line: $lineNumber
$($UTF.Pushpin) Stack Trace:
$stackTrace
"@

    return $errorDetails
}

# Export the functions.
Export-ModuleMember -Function Restart-Explorer, Get-IsAdmin, Invoke-ScriptWithCorrectPermissions, Get-ExceptionDetails