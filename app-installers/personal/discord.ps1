Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="Discord.Discord"
$PackageName="Discord"
$ExtraArguments="--silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)