Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="mpv.net"
$PackageName="MPV"
$ExtraArguments="--silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)