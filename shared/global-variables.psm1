# Define the UTF characters and styles inside a hashtable
$UTF = @{
    # Emogis
    CheckMark       = [char]::ConvertFromUtf32(0x00002705)
    CrossMark       = [char]::ConvertFromUtf32(0x0000274C)
    WarningSign     = [char]::ConvertFromUtf32(0x000026A0)
    Hourglass       = [char]::ConvertFromUtf32(0x0000231B)

    # Font Styles
    StartBold       = "$([char]27)[1m"
    StartUnderline  = "$([char]27)[4m"
    StopStyle       = "$([char]27)[0m"
}

$null = $UTF  # This tricks PowerShell into thinking the variable is used

# Export the UTF hash table
Export-ModuleMember -Variable UTF
