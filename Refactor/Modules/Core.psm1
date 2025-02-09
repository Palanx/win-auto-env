# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\Constants.psm1"

# ------------------------------------------------------------------------------------------------------------- #
# Functions                                                                                                     #
# ------------------------------------------------------------------------------------------------------------- #

# Restart explorer service.
function Restart-Explorer
{
    Write-Host "Restarting explorer service." -ForegroundColor Yellow
    # Stop Explorer
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue

    # Start Explorer and Wait for Initialization
    Start-Process -FilePath explorer.exe

    # Wait for Explorer to be fully initialized
    do {
        Start-Sleep -Milliseconds 500
        $explorerRunning = Get-Process -Name explorer -ErrorAction SilentlyContinue
    } while (-not $explorerRunning)

    Write-Host "$($UTF.CheckMark)Explorer restarted successfully." -ForegroundColor Green
}

# Invoke a Scripts that are in a Path or multiple Paths.
function Invoke-Scripts
{
    # Define a Parameter Set to act as Method Overload.
    [CmdletBinding(DefaultParameterSetName = 'ByScriptPath')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'ByScriptPath')]
        [string]$ScriptsFolderPath,

        [Parameter(Mandatory, ParameterSetName = 'ByScriptPaths')]
        [string[]]$ScriptsFolderPaths
    )

    # Get the ScriptFiles depending on the Parameter Set provided.
    switch ($PSCmdlet.ParameterSetName)
    {
        'ByScriptPath' {
            # Get all .ps1 scripts in the folders.
            $ScriptFiles = Get-ChildItem -Path $ScriptsFolderPath -Filter '*.ps1' | Sort-Object Name
        }
        'ByScriptPaths' {
            # Declare an empty collection.
            $ScriptFiles = @()

            foreach ($ScriptsFolderPath in $ScriptsFolderPaths)
            {
                # Get all .ps1 scripts in the folders.
                $CurrentScriptFiles = Get-ChildItem -Path $ScriptsFolderPath -Filter '*.ps1' | Sort-Object Name
                $ScriptFiles += $CurrentScriptFiles;
            }
        }
    }

    # Check if any scripts were found.
    if ($ScriptFiles.Count -eq 0)
    {
        throw "No PowerShell scripts found in $ScriptsFolderPath."
    } else {
        Write-Host "Found $( $ScriptFiles.Count ) scripts. Executing in sequence...`n"
    }

    # Track failed scripts.
    $FailedScripts = @()

    # Loop through each script and execute it sequentially
    foreach ($Script in $ScriptFiles)
    {
        Write-Host "${StartBold}Executing:$EndBold $StartUnderline$( $Script.Name )$EndUnderline"

        try
        {
            # Start the script and wait for it to finish
            # -ExecutionPolicy Bypass   : To bypass the restriction to prevent malware execution.
            # -ErrorAction Stop         : To stop the script execution on exception and propagate the exception to
            #                             the caller.
            $exitCode = & "${Script.FullName}" -ExecutionPolicy Bypass -ErrorAction Stop

            # Check exit code
            if ($exitCode -ne $Global:STATUS_SUCCESS)
            {
                throw "Script $( $Script.Name ) failed with exit code $( $exitCode )."
            }
        }
        catch
        {
            Write-Host "$UTFCrossMark Error executing ${Script.Name}: $_" -ForegroundColor Red
            $FailedScripts += $Script.Name
        }

        Write-Host "${StartBold}Completed:$EndBold $StartUnderline$( $Script.Name )$EndUnderline`n"
    }

    # Display final status
    if ($FailedScripts.Count -eq 0)
    {
        Write-Host "$UTFCheckMark All scripts executed successfully!" -ForegroundColor Green
        return $Global:STATUS_SUCCESS;
    }
    else
    {
        Write-Host "$UTFWarningSign Some scripts failed: $( $FailedScripts -join ', ' )" -ForegroundColor Red
        return $Global:STATUS_FAILURE;
    }
}

# Export the functions.
Export-ModuleMember -Function Invoke-Scripts, Restart-Explorer