Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

# Define the installation path for JetBrains Toolbox apps
$CustomInstallPath = "D:\Program Files\JetBrains\Toolbox"

# Define the intallation variables for winget
$PackageID="JetBrains.Toolbox"
$PackageName="JetBrain Toolbox"
$ExtraArguments="--silent"

# Define the Toolbox settings file path
$ToolboxSettingsPath = "$env:LOCALAPPDATA\JetBrains\Toolbox\.settings.json"

try {
    # Install JetBrains Toolbox
    if (!(Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)) {
        return;
    }

    # Run the Toolbox for first time to generate the settings file
    Start-Process -FilePath "$env:LOCALAPPDATA\JetBrains\Toolbox\bin\jetbrains-toolbox.exe"

    # Ensure Toolbox settings file exists
    if (!(Get-IsPathExistent -Path $ToolboxSettingsPath)) {
        Write-Host "Toolbox settings file not found. Ensure Toolbox has been opened at least once." -ForegroundColor Red
        return;
    } else {
        # Ensure the directory exists
        if (!(Get-IsPathExistent -Path $CustomInstallPath)) {
            New-Item -ItemType Directory -Path $CustomInstallPath -Force
        }

        # Read the existing settings file
        $settings = Get-Content -Path $ToolboxSettingsPath | ConvertFrom-Json

        # Modify the install location
        $settings | Add-Member -MemberType NoteProperty -Name "install_location" -Value $CustomInstallPath -Force

        # Save the updated settings file
        $settings | ConvertTo-Json -Depth 10 | Set-Content -Path $ToolboxSettingsPath

        Write-Host "Toolbox settings updated! Apps will now install to $CustomInstallPath"

        # Restart JetBrains Toolbox to apply changes
        Write-Host "Restarting JetBrains Toolbox..."
        Start-Process -FilePath "$env:LOCALAPPDATA\JetBrains\Toolbox\bin\jetbrains-toolbox.exe"

        Write-Host "$UTFCheckMark JetBrains Toolbox setup completed successfully!" -ForegroundColor Green
    }
} catch {
    Write-Host "$UTFCrossMark Exception occurred: $_" -ForegroundColor Red
}