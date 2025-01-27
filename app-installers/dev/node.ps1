Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="OpenJS.NodeJS.LTS"
$PackageName="Node"
$ExtraArguments="--silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)