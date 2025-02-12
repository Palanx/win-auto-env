# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\..\..\..\Constants.psm1"
Import-Module "$ScriptDir\..\..\..\Core.psm1"

# Define the Toolbox settings file path.
$ToolboxSettingsPath = "$env:LOCALAPPDATA\JetBrains\Toolbox\.settings.json"
$CustomInstallPath = "D:\Program Files\JetBrains\Toolbox"

try {
    # Run the Toolbox for first time to generate the settings file.
    Start-Process -FilePath "$env:LOCALAPPDATA\JetBrains\Toolbox\bin\jetbrains-toolbox.exe"

    # Ensure Toolbox settings file exists.
    if (!(Test-Path $ToolboxSettingsPath)) {
        throw "Toolbox settings file not found. Ensure Toolbox has been opened at least once."
        return $Global:STATUS_FAILURE
    } else {
        # Ensure the directory exists.
        if (!(Test-Path $CustomInstallPath)) {
            New-Item -ItemType Directory -Path $CustomInstallPath -Force
        }

        # Read the existing settings file.
        $settings = Get-Content -Path $ToolboxSettingsPath | ConvertFrom-Json

        # Modify the install location.
        $settings | Add-Member -MemberType NoteProperty -Name "install_location" -Value $CustomInstallPath -Force

        # Save the updated settings file.
        $settings | ConvertTo-Json -Depth 10 | Set-Content -Path $ToolboxSettingsPath

        Write-Host "Toolbox settings updated! Apps will now install to $CustomInstallPath" -ForegroundColor DarkMagenta

        # Restart JetBrains Toolbox to apply changes.
        Write-Host "Restarting JetBrains Toolbox..." -ForegroundColor DarkMagenta
        Start-Process -FilePath "$env:LOCALAPPDATA\JetBrains\Toolbox\bin\jetbrains-toolbox.exe"

        Write-Host "$($UTF.CheckMark) JetBrains Toolbox setup completed successfully!" -ForegroundColor Green
        return $Global:STATUS_SUCCESS
    }
} catch {
    Write-Host "$($UTF.CrossMark) Exception occurred in JetBrains Toolbox setup: $(Get-ExceptionDetails $_)" -ForegroundColor Red
    return $Global:STATUS_FAILURE
}