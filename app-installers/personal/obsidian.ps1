Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="Obsidian.Obsidian"
$PackageName="Obsidian"
$ExtraArguments="--silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)