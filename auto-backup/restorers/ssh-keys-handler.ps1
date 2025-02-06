# Define paths
$SSHPath = "$env:USERPROFILE\.ssh"
$BackupPath = "D:\AutoBackups\SSHBackup"  # Change this to your preferred backup location

if (Test-Path $BackupPath) {
    Write-Host "Restoring SSH keys..."
    robocopy $BackupPath $SSHPath /E /R:1 /W:1

    # Ensure proper permissions
    icacls "$SSHPath\*" /inheritance:r /grant:r "$env:USERNAME:(F)"
    Write-Host "Permissions set for SSH keys."

    # Enable and start OpenSSH Authentication Agent
    Write-Host "Ensuring OpenSSH Authentication Agent is enabled..."
    Get-Service ssh-agent -ErrorAction SilentlyContinue | Set-Service -StartupType Automatic
    Start-Service ssh-agent
    Write-Host "OpenSSH Authentication Agent started."

    # Identify potential private keys
    $PubKeys = Get-ChildItem -Path $SSHPath -Filter "*.pub" -File
    $PrivateKeys = @()

    foreach ($PubKey in $PubKeys) {
        # Check for corresponding private key (same name without .pub extension)
        $PrivateKeyPath = $PubKey.FullName -replace "\.pub$", ""

        if (Test-Path $PrivateKeyPath) {
            $PrivateKeys += Get-Item $PrivateKeyPath
        }
    }

    # Include standard private key files as well
    $StandardKeys = Get-ChildItem -Path $SSHPath -File | Where-Object {
        $_.Name -in @("id_rsa", "id_ecdsa", "id_ed25519") -or $_.Extension -eq ".pem"
    }
    $PrivateKeys += $StandardKeys | Where-Object { -not ($PrivateKeys -contains $_) }  # Avoid duplicates

    if ($PrivateKeys.Count -gt 0) {
        Write-Host "Adding SSH keys to OpenSSH Authentication Agent..."
        foreach ($Key in $PrivateKeys) {
            $confirmation = Read-Host "Do you want to add '$($Key.Name)' to SSH keychain? (Y/N)"
            if ($confirmation -match "^[Yy]$") {
                ssh-add $Key.FullName
                Write-Host "Added: $($Key.Name)"
            }
        }
    } else {
        Write-Host "No private SSH keys found to add."
    }

    Write-Host "Restore process completed!"
} else {
    Write-Host "Backup not found!"
}