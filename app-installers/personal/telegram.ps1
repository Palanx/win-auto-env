Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="Telegram.TelegramDesktop"
$PackageName="Telegram"
$ExtraArguments="--silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)