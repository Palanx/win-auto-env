# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Define Global variables.
$Global:BACKUP_LOG_PATH = "$ScriptDir\..\Logs\backup_log.txt"
$Global:RESTORE_LOG_PATH = "$ScriptDir\..\Logs\restore_log.txt"
$Global:APPINSTALL_LOG_PATH = "$ScriptDir\..\Logs\app_install_log.txt"
$Global:STATUS_SUCCESS = 0
$Global:STATUS_FAILURE = 1

# Define the UTF characters and styles inside a hashtable.
$UTF = @{
# Emogis
    HeavyCheckMark  = [char]::ConvertFromUtf32(0x00002705)
    CheckMark       = [char]::ConvertFromUtf32(0x00002714)
    CrossMark       = [char]::ConvertFromUtf32(0x0000274C)
    WarningSign     = [char]::ConvertFromUtf32(0x000026A0)
    HourGlass       = [char]::ConvertFromUtf32(0x0000231B)

    # Font Styles
    StartBold       = "$([char]27)[1m"
    StartUnderline  = "$([char]27)[4m"
    StopStyles      = "$([char]27)[0m"
}

$null = $UTF  # This tricks PowerShell into thinking the variable is used.

# Export the UTF hash table.
Export-ModuleMember -Variable UTF