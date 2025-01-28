Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="Valve.Steam"
$PackageName="Steam"
$ExtraArguments="--location `"G:\Program Files\Steam`" --silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)