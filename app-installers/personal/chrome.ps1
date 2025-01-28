Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="Google.Chrome"
$PackageName="Chrome"
$ExtraArguments="--silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)