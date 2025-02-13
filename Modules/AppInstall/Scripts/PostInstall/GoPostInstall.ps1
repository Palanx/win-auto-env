# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\..\..\..\Constants.psm1"
Import-Module "$ScriptDir\..\..\..\Core.psm1"

# Ensure GOPATH\bin is in User PATH.
$GoPathBin = "$env:USERPROFILE\go\bin"
$CurrentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")

try
{
    Write-Host "Validating if `$env:GOPATH\bin was added to User PATH." -ForegroundColor Yellow

    if ($CurrentPath -notlike "*$GoPathBin*")
    {
        $NewPath = "$CurrentPath;$GoPathBin"
        [System.Environment]::SetEnvironmentVariable("Path", $NewPath, "User")
        Write-Host "$( $UFT.CheckMark )`$env:GOPATH\bin added to User PATH." -ForegroundColor DarkMagenta
    }
    else
    {
        Write-Host "$( $UFT.CheckMark )`$env:GOPATH\bin is already in PATH." -ForegroundColor Green
    }

    return $Global:STATUS_SUCCESS
}
catch
{
    Write-Host "$( $UTF.CrossMark ) Exception occurred in Go setup: $( Get-ExceptionDetails $_ )" -ForegroundColor Red
    return $Global:STATUS_FAILURE
}