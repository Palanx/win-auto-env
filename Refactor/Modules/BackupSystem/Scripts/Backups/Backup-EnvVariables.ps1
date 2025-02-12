param (
    [string]$BackupLocation,
    [string]$Name,
    [hashtable]$ExtraParameters = @{}
)

# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\..\..\..\Constants.psm1"
Import-Module "$ScriptDir\..\..\..\Core.psm1"

try
{
    # List of specific environment variables to backup.
    $envVars = $ExtraParameters['env-vars']

    # Clear the backup file.
    Clear-Content -Path $BackupLocation -ErrorAction SilentlyContinue

    Write-Host "Backing up specified '$Name'..."

    # Ensure backup file exists.
    if (Test-Path $BackupLocation)
    {
        Remove-Item $BackupLocation -Force
    }

    # Backup each variable
    foreach ($var in $envVars)
    {
        $value = [System.Environment]::GetEnvironmentVariable($var, "User")
        if ($value)
        {
            "$var=$value" | Out-File -Append -FilePath $BackupLocation
            Write-Host "Var Backed up: $var"
        }
        else
        {
            Write-Host "Skipping Var: $var (Not found)"
        }
    }

    Write-Host "$($UTF.CheckMark) '$Name' Backup completed! Saved to: '$BackupLocation'" -ForegroundColor Green
    return $Global:STATUS_SUCCESS
}
catch
{
    Write-Host "$($UTF.CrossMark) Exception occurred generating the '$Name' Backup: $(Get-ExceptionDetails $_)" -ForegroundColor Red
    return $Global:STATUS_FAILURE
}