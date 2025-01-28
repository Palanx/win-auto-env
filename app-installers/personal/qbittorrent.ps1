Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="qBittorrent.qBittorrent"
$PackageName="qBittorrent"
$ExtraArguments="--silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)