# Get full script path even if $PSScriptRoot is't set.
$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# Import modules.
Import-Module "$ScriptDir\..\..\..\Constants.psm1"
Import-Module "$ScriptDir\..\..\..\Core.psm1"

# Define paths
$7zLocation = "C:\Program Files\7-Zip"
$RegPath = "HKCU:\Software\Classes\"
$FileExtensRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts"

# List of file extensions to associate with 7-Zip.
$ExtensionsWithIconIndex= @{
    "7z"  = 0
    "zip" = 1
    "rar" = 3
    "tar" = 4
    "gz"  = 5
    "bz2" = 6
    "xz"  = 7
    "cab" = 2
    "lzh" = 9
    "arj" = 10
    "z"   = 11
    "001" = 12
}

try
{
    # Track failed 7-Zip associations.
    $FailedAssociations = @()

    # Assign file types to 7-Zip.
    Write-Host "Setting file associations..." -ForegroundColor Yellow
    foreach ($ext in $ExtensionsWithIconIndex.Keys)
    {
        $iconIndex = $ExtensionsWithIconIndex[$ext]
        $fileType = "7-Zip.$ext"

        $defaultExtKey = "$RegPath\.$ext"
        $default7ZipExtKey = "$RegPath\$fileType"
        $defaultIconKey = "$default7ZipExtKey\DefaultIcon"
        $defaultShell = "$default7ZipExtKey\shell"
        $defaultOpen = "$defaultShell\open"
        $defaultCommand = "$defaultOpen\command"
        $openWithProgIdsKey = "$FileExtensRegPath\.$ext\OpenWithProgids"

        # Check if the registry key exists, if not, create it.
        if (-not (Test-Path $defaultExtKey)) {
            New-Item -Path $defaultExtKey -Force | Out-Null
        }
        if (-not (Test-Path $default7ZipExtKey)) {
            New-Item -Path $default7ZipExtKey -Force | Out-Null
            New-Item -Path $defaultIconKey -Force | Out-Null
            New-Item -Path $defaultCommand -Force | Out-Null
        }
        if (-not (Test-Path $openWithProgIdsKey)) {
            New-Item -Path $openWithProgIdsKey -Force | Out-Null
        }
        New-ItemProperty -Path $openWithProgIdsKey -Name "$fileType" -Value '' -PropertyType String -Force | Out-Null

        # Associate the extension.
        $output += Set-ItemProperty -Path $defaultExtKey -Name "(Default)" -Value $fileType -Force
        $output += Set-ItemProperty -Path $default7ZipExtKey -Name "(Default)" -Value "$ext Archive" -Force
        $output += Set-ItemProperty -Path $defaultIconKey -Name "(Default)" -Value "$($7zLocation)\7z.dll,$iconIndex" -Force
        $output += Set-ItemProperty -Path $defaultShell -Name "(Default)" -Value '' -Force
        $output += Set-ItemProperty -Path $defaultOpen -Name "(Default)" -Value '' -Force
        $output += Set-ItemProperty -Path $defaultCommand -Name "(Default)" -Value "`"$($7zLocation)\7zFM.exe`" `"%1`"" -Force

        # Check the last exit code.
        if (!$output)
        {
            Write-Host "$( $UTF.CheckMark ) File ext '$ext' associations updated successfully!" -ForegroundColor Green
        }
        else
        {
            Write-Host "$( $UTF.CrossMark ) Error setting file ext '$ext' asosiation to 7-Zip (Output: $output)" -ForegroundColor Red
            $FailedAssociations += $ext
        }
    }

    if ($FailedAssociations.Count -gt 0)
    {
        throw "Some extension associations failed: $( $FailedAssociations -join ', ' )"
    }

    Write-Host "$( $UTF.CheckMark ) 7-Zip setup completed." -ForegroundColor Green
    Write-Host "$( $UTF.WarningSign ) For secury reasons, the Default App to 'Open With' a file extension can't be modified by script," -ForegroundColor Yellow
    Write-Host "but the config was made, so the correct icon and path will be used when you open the files after assing the Default App to the extension." -ForegroundColor Yellow
    return $Global:STATUS_SUCCESS
}
catch
{
    Write-Host "$( $UTF.CrossMark ) Exception occurred in 7Zip setup: $( Get-ExceptionDetails $_ )" -ForegroundColor Red
    return $Global:STATUS_FAILURE
}