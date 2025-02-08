# Define paths
$SSHPath = "$env:USERPROFILE\.ssh"
$BackupPath = "D:\AutoBackups\SSHBackup"  # Change this to your preferred backup location

if (Test-Path $SSHPath) {
    Write-Host "Backing up SSH keys..."
    robocopy $SSHPath $BackupPath /E /R:1 /W:1
    Write-Host "Backup completed successfully."
} else {
    Write-Host "SSH directory not found!"
}