Import-Module "$PSScriptRoot\..\..\shared\winget-utils.psm1" -Force
Import-Module "$PSScriptRoot\..\..\shared\global-variables.psm1" -Force

$PackageID="Microsoft.VisualStudioCode"
$PackageName="Visual Studio Code"
$ExtraArguments="--silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)