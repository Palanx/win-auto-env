# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\Constants.psm1"

# Write a CLI GUI Header.
function Write-Header
{
    param (
        [string]$Title,
        [System.ConsoleColor]$Color = "White",
        [int]$Width = 40
    )

    $AvailableSpace = $Width - 2
    if ($AvailableSpace -lt $Title.Length)
    {
        throw "The available space is $AvailableSpace, but the title has $( $Title.Length ) characters."
    }

    $ReaningSpaceUsingTitle = $AvailableSpace - $Title.Length;
    $TitleAvailableLeftSpace = [math]::Floor($ReaningSpaceUsingTitle / 2)
    # Ensure balance of 1 unit was lose in previous step.
    $TitleAvailableRightSpace = $ReaningSpaceUsingTitle - $TitleAvailableLeftSpace

    Write-Host "╔$( -join ('═' * $AvailableSpace) )╗" -ForegroundColor $Color
    Write-Host "║$( -join (' ' * $TitleAvailableLeftSpace) )$( $UTF.StartBold )$Title$( $UTF.StopStyles )$( -join (' ' * $TitleAvailableRightSpace) )║" -ForegroundColor $Color
    Write-Host "╚$( -join ('═' * $AvailableSpace) )╝" -ForegroundColor $Color
    Write-Host ""
}

function Write-SelectionList
{
    param (
        [string[]]$Options,
        [System.ConsoleColor]$InfoColor = "White",
        [System.ConsoleColor]$OptionsColor = "White",
        [System.ConsoleColor]$SelectedOptionsColor = "Yellow"
    )

    # Write a CLI GUI List with selected value.
    function Write-List {
        param (
            [bool]$MustResetCursorPosition = $false
        )

        if ($MustResetCursorPosition)
        {
            # Move cursor back to the original position without clearing.
            [System.Console]::SetCursorPosition(0, [System.Console]::CursorTop - $Options.Length)
        }

        for ($i = 0; $i -lt $Options.Length; $i++) {
            if ($i -eq $selectedIndex) {
                Write-Host "> $($Options[$i])" -ForegroundColor $SelectedOptionsColor
            } else {
                Write-Host "  $($Options[$i])" -ForegroundColor $OptionsColor
            }
        }
    }

    # Write the title.
    $infoString = "Use ↑ and ↓ to navigate, Enter to select";
    Write-Host $infoString -ForegroundColor $InfoColor
    Write-Host $( -join ('═' * $infoString.Length) ) -ForegroundColor $InfoColor

    # Define an index for the current selection.
    $selectedIndex = 0

    # Main loop to handle input.
    $mustExit = $false
    Write-List
    do {
        # Capture key press.
        $keyInfo = [System.Console]::ReadKey($true)
        switch ($keyInfo.Key)
        {
            $([System.ConsoleKey]::UpArrow)
            {
                if ($selectedIndex -gt 0)
                {
                    $selectedIndex--
                }
                Write-List -MustResetCursorPosition $true
            }
            $([System.ConsoleKey]::DownArrow)
            {
                if ($selectedIndex -lt ($Options.Length - 1))
                {
                    $selectedIndex++
                }
                Write-List -MustResetCursorPosition $true
            }
            $([System.ConsoleKey]::Enter) { $mustExit = $true }
        }
    } while (!$mustExit)

    Write-Host ''
    return $selectedIndex
}

Export-ModuleMember -Function Write-Header, Write-SelectionList
