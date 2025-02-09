# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Define the path of the config json.
$ConfigPath = "$ScriptDir\app-install-config.json"

# Read JSON file and convert to PowerShell object.
$ConfigData = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json

# Start the App Install process.
function Start-AppInstall
{
    if ($null -ne $ConfigData.'winget-packages')
    {
        foreach ($wingetPackage in $ConfigData.'winget-packages')
        {
            Write-Host $wingetPackage
        }
    }

    if ($null -ne $ConfigData.'win-store-installers')
    {
        foreach ($winStoreInstaller in $ConfigData.'win-store-installers')
        {
            Write-Host $winStoreInstaller
        }
    }

    if ($null -ne $ConfigData.'standalone-installers')
    {
        foreach ($standaloneInstaller in $ConfigData.'standalone-installers')
        {
            Write-Host $standaloneInstaller
        }
    }
}

# Export the functions.
Export-ModuleMember -Function Start-AppInstall