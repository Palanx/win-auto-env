# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Define the path of the config json.
$ConfigPath = "$ScriptDir\restore-system-config.json"

# Read JSON file and convert to PowerShell object.
$ConfigData = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json

# Start the Restore System process.
function Start-RestoreSystem
{

}

# Export the functions.
Export-ModuleMember -Function Start-RestoreSystem