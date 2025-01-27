Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="Microsoft.VisualStudioCode"
$PackageName="Visual Studio Code"
$ExtraArguments="--silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)