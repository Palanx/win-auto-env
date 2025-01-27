Import-Module "$PSScriptRoot\shared-functions.psm1" -Force

# Define the folder containing the scripts
$CommonInstallersFolder = "$PSScriptRoot\common\"
$DevInstallersFolder = "$PSScriptRoot\dev\"

# Get all .ps1 scripts in the folders
$CommonScripts = Get-ChildItem -Path $CommonInstallersFolder -Filter "*.ps1" | Sort-Object Name
$DevScripts = Get-ChildItem -Path $DevInstallersFolder -Filter "*.ps1" | Sort-Object Name
$Scripts = $CommonScripts + $DevScripts

# Check if any scripts were found
if ($Scripts.Count -eq 0) {
    Write-Host "No PowerShell scripts found in $CommonInstallersFolder and $DevInstallersFolder."
    exit
}

Write-Host "Found $($Scripts.Count) installer scripts. Executing in sequence...`n"

# Track failed scripts
$FailedScripts = @()

# Loop through each script and execute it sequentially
foreach ($Script in $Scripts) {
    Write-Host "$StartBold Executing:$EndBold $StartUnderline$($Script.Name)$EndUnderline"

    try {
        # Start the script and wait for it to finish
        $process = Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$($Script.FullName)`"" -NoNewWindow -Wait -PassThru

        # Check exit code
        if ($process.ExitCode -ne 0) {
            throw "Script $($Script.Name) failed with exit code $($process.ExitCode)."
        }
    }
    catch {
        Write-Host "$UTFCrossMark Error executing $($Script.Name): $_" -ForegroundColor Red
        $FailedScripts += $Script.Name
    }

    Write-Host "$StartBold Completed:$EndBold $StartUnderline$($Script.Name)$EndUnderline`n"
}

# Display final status
if ($FailedScripts.Count -eq 0) {
    Write-Host "$UTFCheckMark All installer scripts executed successfully!" -ForegroundColor Green
} else {
    Write-Host "$UTFWarningSign Some scripts failed: $($FailedScripts -join ', ')" -ForegroundColor Red
}

