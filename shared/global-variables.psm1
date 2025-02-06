# Emogis
Set-Variable -Name "UTFCheckMark" -Value $([char]::ConvertFromUtf32(0x00002705)) -Scope Global
Set-Variable -Name "UTFCrossMark" -Value $([char]::ConvertFromUtf32(0x0000274C)) -Scope Global
Set-Variable -Name "UTFWarningSign" -Value $([char]::ConvertFromUtf32(0x000026A0)) -Scope Global
Set-Variable -Name "UTFHourglassNotDone" -Value $([char]::ConvertFromUtf32(0x0000231B)) -Scope Global

# Enable styles 
$esc = [char]27

# Font Styles
Set-Variable -Name "StartBold" -Value "$esc[1m" -Scope Global
Set-Variable -Name "EndBold" -Value "$esc[0m" -Scope Global
Set-Variable -Name "StartUnderline" -Value "$esc[4m" -Scope Global
Set-Variable -Name "EndUnderline" -Value "$esc[0m" -Scope Global
