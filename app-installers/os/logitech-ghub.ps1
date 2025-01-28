Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="Logitech.GHUB"
$PackageName="LogitechGHUB"
$ExtraArguments="--silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)