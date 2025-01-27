Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="GoLang.Go"
$PackageName="Go"
$ExtraArguments="-v `"1.18.10`" --silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)