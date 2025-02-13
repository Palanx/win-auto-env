param (
    [string]$BackupLocation,
    [string]$Name
)

# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\..\..\..\Constants.psm1"
Import-Module "$ScriptDir\..\..\..\Core.psm1"

# Define paths
$SSHPath = "$env:USERPROFILE\.ssh"

try
{
    # Ensure the backup directory exists.
    if (!(Test-Path $BackupLocation)) {
        Write-Host "Backup not found in path '$BackupLocation'!" -ForegroundColor Red
        return $Global:STATUS_FAILURE
    }

    Write-Host "Restoring '$Name'..."

    robocopy $BackupLocation $SSHPath /E /R:1 /W:1

    # Ensure proper permissions
    icacls "$SSHPath\*" /inheritance:r /grant:r "$($env:USERNAME):(F)"
    Write-Host "Permissions set for SSH keys."

    # Enable and start OpenSSH Authentication Agent.
    Write-Host "Ensuring OpenSSH Authentication Agent is enabled..."
    Get-Service ssh-agent -ErrorAction SilentlyContinue | Set-Service -StartupType Automatic
    Start-Service ssh-agent
    Write-Host "OpenSSH Authentication Agent started."

    # Identify potential private keys.
    $pubKeys = Get-ChildItem -Path $SSHPath -Filter "*.pub" -File
    $privateKeys = @()

    foreach ($pubKey in $pubKeys) {
        # Check for corresponding private key (same name without .pub extension).
        $privateKeyPath = $pubKey.FullName -replace "\.pub$", ""

        if (Test-Path $privateKeyPath) {
            $privateKeys += Get-Item $privateKeyPath
        }
    }

    # Include standard private key files as well
    $standardKeys = Get-ChildItem -Path $SSHPath -File | Where-Object {
        $_.Name -in @("id_rsa", "id_ecdsa", "id_ed25519") -or $_.Extension -eq ".pem"
    }
    $privateKeys += $standardKeys | Where-Object { -not ($privateKeys -contains $_) }  # Avoid duplicates.

    if ($privateKeys.Count -gt 0) {
        Write-Host "Adding SSH keys to OpenSSH Authentication Agent..."
        foreach ($Key in $privateKeys) {
            $confirmation = Read-Host "Do you want to add '$($Key.Name)' to SSH keychain? (Y/N)"
            if ($confirmation -match "^[Yy]$") {
                ssh-add $Key.FullName
                Write-Host "Added: $($Key.Name)"
            }
        }

        Write-Host "$($UTF.CheckMark) '$Name' Backup Restore completed!" -ForegroundColor Green
    } else {
        Write-Host "$($UTF.WarningSign) No private SSH keys found to add." -ForegroundColor Green
    }
    return $Global:STATUS_SUCCESS
}
catch
{
    Write-Host "$($UTF.CrossMark) Exception occurred Recovering the '$Name' Backup: $(Get-ExceptionDetails $_)" -ForegroundColor Red
    return $Global:STATUS_FAILURE
}