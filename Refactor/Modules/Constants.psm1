# Define Global variables.
[int]$Global:STATUS_SUCCESS = 0
[int]$Global:STATUS_FAILURE = 1

# Define the UTF characters and styles inside a hashtable.
$UTF = @{
# Emogis
    HeavyCheckMark  = [char]::ConvertFromUtf32(0x00002705) # ✅
    CheckMark       = [char]::ConvertFromUtf32(0x00002714) # ✔
    CrossMark       = [char]::ConvertFromUtf32(0x0000274C) # ❌
    WarningSign     = [char]::ConvertFromUtf32(0x000026A0) # ⚠
    HourGlass       = [char]::ConvertFromUtf32(0x0000231B) # ⌛
    JapaneseGoblin  = [char]::ConvertFromUtf32(0x0001F47A) # 👺
    AngerSymbol     = [char]::ConvertFromUtf32(0x0001F4A2) # 💢
    MagnifyingGlass = [char]::ConvertFromUtf32(0x0001F50D) # 🔍
    OpenFileFolder  = [char]::ConvertFromUtf32(0x0001F4C2) # 📂
    Pushpin         = [char]::ConvertFromUtf32(0x0001F4CC) # 📌

    # Font Styles
    StartBold       = "$([char]27)[1m"
    StartUnderline  = "$([char]27)[4m"
    StopStyles      = "$([char]27)[0m"
}

$null = $UTF  # This tricks PowerShell into thinking the variable is used.

# Export the UTF hash table.
Export-ModuleMember -Variable UTF