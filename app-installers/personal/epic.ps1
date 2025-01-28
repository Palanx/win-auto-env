Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="EpicGames.EpicGamesLauncher"
$PackageName="Epic"
$ExtraArguments="--location `"G:\Program Files (x86)\Epic Games`" --silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)