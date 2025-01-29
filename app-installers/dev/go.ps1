Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="GoLang.Go"
$PackageName="Go"
$ExtraArguments="-v `"1.18.10`" --silent"

if (!(Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments))
{
    return;
}

# Ensure GOPATH\bin is in User PATH
$GoPathBin = "$env:USERPROFILE\go\bin"
$CurrentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")

if ($CurrentPath -notlike "*$GoPathBin*") {
    $NewPath = "$CurrentPath;$GoPathBin"
    [System.Environment]::SetEnvironmentVariable("Path", $NewPath, "User")
    Write-Host "`$env:GOPATH\bin added to User PATH."
} else {
    Write-Host "`$env:GOPATH\bin is already in PATH."
}