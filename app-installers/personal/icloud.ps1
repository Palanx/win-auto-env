Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="Apple.iCloud"
$PackageName="iCloud"
$ExtraArguments=""

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)