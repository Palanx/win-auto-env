# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\..\..\..\Constants.psm1"

try {
    # Disable Snipping Tool from launching with Print Screen
    Write-Host "Configuring the OS to enable Lightshot..." -ForegroundColor Yellow
    Set-ItemProperty -Path 'HKCU:\Control Panel\Keyboard' -Name 'PrintScreenKeyForSnippingEnabled' -Value 0

    # Set Lightshot to handle Print Screen key
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'Lightshot' -Value '"C:\Program Files\Skillbrains\Lightshot\Lightshot.exe" /silent'

    Write-Host "$($UTF.CheckMark) Lightshot OS config completed." -ForegroundColor Green
    return $Global:STATUS_SUCCESS
} catch {
    Write-Host "$($UTF.CrossMark) Exception occurred in Lightshot setup: $_" -ForegroundColor Red
    return $Global:STATUS_FAILURE
}