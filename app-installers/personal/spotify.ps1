Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="Spotify.Spotify"
$PackageName="Spotify"
$ExtraArguments="--silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)