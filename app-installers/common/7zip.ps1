# Define paths
$SetUserFTA = "$env:USERPROFILE\Downloads\SetUserFTA.exe"
$SevenZipPath = "C:\Program Files\7-Zip\7zFM.exe"

# List of file extensions to associate with 7-Zip
$extensions = @(".7z", ".zip", ".rar", ".tar", ".gz", ".bz2", ".xz", ".cab", ".lzh", ".arj", ".z", ".001")

# Function to check if 7-Zip is installed
function Is-7ZipInstalled {
    return Test-Path "$SevenZipPath"
}

# Install 7-Zip if not found
if (!(Is-7ZipInstalled)) {
    Write-Host "7-Zip not found. Installing..."
    Start-Process -FilePath "winget" -ArgumentList "install -e --id 7zip.7zip --silent" -NoNewWindow -Wait
}
else {
    Write-Host "7-Zip already Installed."
}

# Download SetUserFTA.exe if not found
if (!(Test-Path $SetUserFTA)) {
    Write-Host "Downloading SetUserFTA..."
    Invoke-WebRequest -Uri "https://github.com/qis/windows/raw/refs/heads/master/setup/SetUserFTA/SetUserFTA.exe" -OutFile $SetUserFTA
}
else {
    Write-Host "SetUserFTA already downloaded."
}

# Assign file types to 7-Zip
Write-Host "Setting file associations..."
foreach ($ext in $extensions) {
    Start-Process -FilePath $SetUserFTA -ArgumentList "$ext 7zFM.exe" -Wait -NoNewWindow
}

Write-Host "File associations updated successfully!"

# Restart Explorer to apply changes
Write-Host "Restarting Windows Explorer..."
Stop-Process -Name explorer -Force
Start-Process explorer

Write-Host "7-Zip setup completed!"

#TODO: Implement this in a good way.