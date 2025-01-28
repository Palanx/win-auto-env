Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="Microsoft.PowerToys"
$PackageName="Power Toys"
$ExtraArguments="--silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)