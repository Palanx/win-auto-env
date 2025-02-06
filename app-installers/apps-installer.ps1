Import-Module "$PSScriptRoot\..\shared\start-process-utils.psm1" -Force
Import-Module "$PSScriptRoot\..\shared\global-variables.psm1" -Force

# Define the folder containing the scripts
$OSInstallersFolder = "$PSScriptRoot\os\"
$DevInstallersFolder = "$PSScriptRoot\dev\"
$PersonalInstallersFolder = "$PSScriptRoot\personal\"

$ScriptsFolderPaths = @($OSInstallersFolder, $DevInstallersFolder, $PersonalInstallersFolder)

Write-Host "$UTFHourglassNotDone Apps Installer process started." -ForegroundColor Magenta
Invoke-Scripts -ScriptsFolderPaths $ScriptsFolderPaths
