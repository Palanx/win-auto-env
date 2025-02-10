Import-Module "$PSScriptRoot\global-variables.psm1" -Force
function Invoke-Scripts {
    [CmdletBinding(DefaultParameterSetName = 'ByScriptPath')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'ByScriptPath')]
        [string]$ScriptsFolderPath,

        [Parameter(Mandatory, ParameterSetName = 'ByScriptPaths')]
        [string[]]$ScriptsFolderPaths
    )

    switch ($PSCmdlet.ParameterSetName) {
        'ByScriptPath' {
            # Get all .ps1 scripts in the folders
            $ScriptFiles = Get-ChildItem -Path $ScriptsFolderPath -Filter "*.ps1" | Sort-Object Name

            # Check if any scripts were found
            if ($ScriptFiles.Count -eq 0) {
                throw "No PowerShell scripts found in $ScriptsFolderPath."
            }
        }
        'ByScriptPaths' {
            $ScriptFiles = @()

            foreach ($ScriptsFolderPath in $ScriptsFolderPaths) {
                # Get all .ps1 scripts in the folders
                $CurrentScriptFiles = Get-ChildItem -Path $ScriptsFolderPath -Filter "*.ps1" | Sort-Object Name

                # Check if any scripts were found
                if ($CurrentScriptFiles.Count -eq 0) {
                    throw "No PowerShell scripts found in $ScriptsFolderPath."
                }

                $ScriptFiles += $CurrentScriptFiles;
            }
        }
    }

    Write-Host "Found $($ScriptFiles.Count) scripts. Executing in sequence...`n"

    # Track failed scripts
    $FailedScripts = @()

    # Loop through each script and execute it sequentially
    foreach ($Script in $ScriptFiles) {
        Write-Host "${StartBold}Executing:$EndBold $StartUnderline$($Script.Name)$EndUnderline"

        try {
            # Start the script and wait for it to finish
            $process = Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$($Script.FullName)`"" -NoNewWindow -Wait -PassThru

            # Check exit code
            if ($process.ExitCode -ne 0) {
                throw "Script $($Script.Name) failed with exit code $($process.ExitCode)."
            }
        }
        catch {
            Write-Host "$UTFCrossMark Error executing $($Script.Name): $(Get-ExceptionDetails $_)" -ForegroundColor Red
            $FailedScripts += $Script.Name
        }

        Write-Host "${StartBold}Completed:$EndBold $StartUnderline$($Script.Name)$EndUnderline`n"
    }

    # Display final status
    if ($FailedScripts.Count -eq 0) {
        Write-Host "$UTFCheckMark All scripts executed successfully!" -ForegroundColor Green
    } else {
        Write-Host "$UTFWarningSign Some scripts failed: $($FailedScripts -join ', ')" -ForegroundColor Red
    }
}