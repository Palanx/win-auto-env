Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="Postman.Postman"
$PackageName="Postman"
$ExtraArguments="--silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)