Import-Module "$PSScriptRoot\..\shared-functions.psm1" -Force

$PackageID="Git.Git"
$PackageName="Git"
$ExtraArguments="--silent --override `"/VERYSILENT /NORESTART /COMPONENTS=\`"git,assoc,assoc_sh,curl,git_lfs,credential_manager\`" /TASKS=\`"!desktopicon,assoc,assoc_sh\`" /EDITOR=\`"VisualStudioCode\`" /SSH=OpenSSH /CURL=OpenSSL /BASHSHELL=MinTTY /GITPULLBEHAVIOR=Merge /PERFORMANCE=FSCache /CREDENTIALMANAGER=Enabled /SYMLINKS=Disabled /FSMONITOR=Disabled /CRLF=Input"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)

$PackageID="GitHub.GitLFS"
$PackageName="Git LFS"
$ExtraArguments="--silent"

[void](Start-InstallWingetPackage -PackageID $PackageID -PackageName $PackageName -ExtraArguments $ExtraArguments)