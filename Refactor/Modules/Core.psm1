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

    Write-Host "$($UTF.CheckMark)Explorer restarted successfully." -ForegroundColor Green
}

# Get if the current PowerShell session has administrator privileges.
function Get-IsAdmin {
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Run a script with the correct permissions.
function Run-ScriptWithCorrectPermissions
{
    param (
        [string]$ScriptPath,
        [string]$ExtraParameters = "",
        [bool]$RequiresAdmin = $false
    )

    if (!(Test-Path $ScriptPath))
    {
        throw "The script path '$ScriptPath' doesn't exist."
    }

    [int]$exitCode

    # The script will run a new admin shell.
    if ($RequiresAdmin -and -not (Get-IsAdmin))
    {
        Write-Host "Executing script as Administrator in another shell..." -ForegroundColor DarkMagenta
        $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`" $ExtraParameters"
        $process = Start-Process PowerShell -ArgumentList $arguments -Verb RunAs -PassThru
        $process.WaitForExit()
        $exitCode = $process.ExitCode;
    }
    # The script will run a new non-admin shell (simulates running in the same window).
    elseif (-not $RequiresAdmin -and (Get-IsAdmin))
    {
        Write-Host "Executing script as Non-Administrator in another shell..." -ForegroundColor DarkMagenta
        $arguments = "/trustlevel:0x20000 `"powershell.exe -NoProfile -File `"$ScriptPath`" $ExtraParameters`""
        $process = Start-Process "runas.exe" -ArgumentList $arguments -PassThru
        $process.WaitForExit()
        $exitCode = $process.ExitCode;
    }
    # The script is running with correct permissions.
    else
    {
        $exitCode = & $ScriptPath @ExtraParameters -ExecutionPolicy Bypass -ErrorAction Stop
    }

    return $exitCode;
}

# Export the functions.
Export-ModuleMember -Function Restart-Explorer, Get-IsAdmin, Run-ScriptWithCorrectPermissions