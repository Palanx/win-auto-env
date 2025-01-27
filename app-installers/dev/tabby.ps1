Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="Eugeny.Tabby"
$PackageName="Tabby"
$ExtraArguments="--silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)