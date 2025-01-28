Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="Skillbrains.Lightshot"
$PackageName="Lightshot"
$ExtraArguments="--silent"

try {
    # Install Lightshot
    if (!(Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)) {
        return;
    }

    # Disable Snipping Tool from launching with Print Screen
    Write-Host "Configuring the OS to enable Lightshot..." -ForegroundColor Yellow
    # Reset before running winget
    $LASTEXITCODE = 0
    Set-ItemProperty -Path 'HKCU:\Control Panel\Keyboard' -Name 'PrintScreenKeyForSnippingEnabled' -Value 0

    # Set Lightshot to handle Print Screen key
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'Lightshot' -Value '"C:\Program Files\Skillbrains\Lightshot\Lightshot.exe" /silent'

    # Check the last exit code
    if ($LASTEXITCODE -eq 0) {
        Write-Host "$UTFCheckMark Lightshot OS config completed." -ForegroundColor Green
    } else {
        Write-Host "$UTFCrossMark Error configuring OS to use Lightshot (Exit Code: $LASTEXITCODE)" -ForegroundColor Red
    }
} catch {
    Write-Host "$UTFCrossMark Exception occurred: $_" -ForegroundColor Red
}