Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="WhatsApp.WhatsApp"
$PackageName="WhatsApp"
$ExtraArguments="--silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)