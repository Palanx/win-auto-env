# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Define the path of the config json.
$ConfigPath = "$ScriptDir\backup-system-config.json"

# Read JSON file and convert to PowerShell object.
$ConfigData = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json

# Start the Backup System process.
function Start-BackupSystem
{

}

# Export the functions.
Export-ModuleMember -Function Start-BackupSystem