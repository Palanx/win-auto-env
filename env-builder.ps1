# Define script paths (Change these to your actual script locations)
$BackupScript = "$PSScriptRoot\auto-backup\backups-handler.ps1"
$RestoreScript = "$PSScriptRoot\auto-backup\restorers-handler.ps1"
$InstallScript = "$PSScriptRoot\app-installers\apps-installer.ps1"

# Function to run a script if it exists
function Invoke-Script {
    param (
        [string]$ScriptPath
    )
    if (Test-Path $ScriptPath) {
        Write-Host "Executing: $ScriptPath"
        Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$ScriptPath`"" -NoNewWindow -Wait
    } else {
        Write-Host "Error: Script not found -> $ScriptPath"
    }
}

$exit = $false
do {
    # User input for action selection
    $choice = Read-Host "Enter 'B' to Backup, 'R' to Restore, 'I' to Install Missing Programs or 'E' to exit"

    switch ($choice.ToUpper()) {
        "B" { Invoke-Script -ScriptPath $BackupScript}
        "R" {
            Invoke-Script -ScriptPath $RestoreScript

            # Restart Explorer to apply changes
            Write-Host "Restarting Windows Explorer..."
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c taskkill /f /im explorer.exe & start explorer.exe" -WindowStyle Hidden
        }
        "I" {
            Invoke-Script -ScriptPath $InstallScript

            # Restart Explorer to apply changes
            Write-Host "Restarting Windows Explorer..."
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c taskkill /f /im explorer.exe & start explorer.exe" -WindowStyle Hidden
        }
        "E" { $exit = $true }
        Default {
            $exit = $true
            Write-Host "Invalid choice. Exiting..."
        }
    }
} while (!$exit)


Write-Host "`nPress any key to exit..."
Read-Host