Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="Microsoft.PowerShell"
$PackageName="PowerShell"
$ExtraArguments="--silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)