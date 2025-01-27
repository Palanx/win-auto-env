Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="Microsoft.PowerShell"
$PackageName="PowerShell 7"
$ExtraArguments="--silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)