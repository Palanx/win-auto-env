Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="Microsoft.WindowsSDK.10.0.26100"
$PackageName="Windows Software Developer Kit"
$ExtraArguments="--silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)

$PackageID="Microsoft.WindowsWDK.10.0.26100"
$PackageName="Windows Driver Kit"
$ExtraArguments="--silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)