Import-Module "$PSScriptRoot\..\..\shared\winget-utils.psm1" -Force
Import-Module "$PSScriptRoot\..\..\shared\global-variables.psm1" -Force

$PackageID="Apple.iCloud"
$PackageName="iCloud"
$ExtraArguments=""

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)