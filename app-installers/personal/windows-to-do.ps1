Import-Module "$PSScriptRoot\..\..\shared\winget-utils.psm1" -Force
Import-Module "$PSScriptRoot\..\..\shared\global-variables.psm1" -Force

$PackageID="9NBLGGH5R558"
$PackageName="Windows to Do"
$ExtraArguments="--source msstore --accept-package-agreements"

try {
    if (Get-IsWingetPackageInstalled -PackageID $PackageID){
        return
    }

    # Reset before running winget
    $LASTEXITCODE = 0
    Write-Host "Installing $PackageName..." -ForegroundColor Yellow
    Start-Process -FilePath "winget" -ArgumentList "install --id $PackageID $ExtraArguments" -NoNewWindow -Wait

    # Check the last exit code
    if ($LASTEXITCODE -eq 0) {
        Write-Host "$UTFCheckMark $PackageName in NOW installed." -ForegroundColor Green
    } else {
        Write-Host "$UTFCrossMark Error installing $PackageID (Exit Code: $LASTEXITCODE)" -ForegroundColor Red
    }
} catch {
    Write-Host "$UTFCrossMark Exception occurred: $_" -ForegroundColor Red
}