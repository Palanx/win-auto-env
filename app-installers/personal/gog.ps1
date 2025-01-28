Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="GOG.Galaxy"
$PackageName="GoG"
$ExtraArguments="--location `"G:\Program Files (x86)\GOG Galaxy`" --silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)