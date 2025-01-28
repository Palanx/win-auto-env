# Windows Automatic Environment

### How to Execute
Double click the `env-builder.ps1` file and follow the instructions.

### Apps
#### Dev Apps
| App | installer | location | version | notes |
| --- | --- | --- | --- | --- |
| JetBrains.Toolbox | winget | default | latest | The custom path to install apps using this tool is automatically modified to `D:\Program Files\JetBrains\Toolbox` after install. |
| Unity Hub | standalone | `D:\Program Files\Unity Hub` | latest | |
| Windows SDK | winget | default | 10.0.26100 | |
| Windows WDK | winget | default | 10.0.26100 | |
| Visual Studio Code | winget | default | latest | |
| Tabby | winget | default | latest | |
| PowerShell | winget | default | latest | |
| Node | winget | default | latest LTS | |
| Go | winget | default | 1.18.10 | |
| Git | winget | default | latest | - **Editor Option**: VisualStudioCode<br/> - **Custom Editor Path**:<br/> - **Default Branch Option**:  <br/> - **Path Option**: Cmd<br/> - **SSH Option**: OpenSSH<br/> - **Tortoise Option**: false<br/> - **CURL Option**: OpenSSL<br/> - **CRLF Option**: Input<br/> - **CRLFCommitAsIs Bash Terminal Option**: MinTTY<br/> - **Git Pull Behavior Option**: Merge<br/> - **Use Credential Manager**: Enabled<br/> - **Performance Tweaks FSCache**: Enabled<br/> - **Enable Symlinks**: Disabled<br/> - **Enable FSMonitor**: Disabled |
| Git LFS | winget | default | latest | |
| Fork | winget | default | latest | |
| Postman | winget | default | latest | |
|  |  |  |  |


#### OS Apps
| App | command | location | version | notes |
| --- | --- | --- | --- | --- |
| Karspersky Premium | Manual | default | latest | The .exe is compiled for each account, so the cretential are included and the installer can't be automated or shared. |
| Lightshot | winget | default | latest | OS config modified to allow the app use. |
| Nvidia App | standalone | default | latest |  |
| Logitech G HUB | winget | default | latest | ??? |
| 7-zip | winget| default | latest | Download the `SetUserFTA` app to assing the file extensions `.7z`, `.zip`, `.rar`, `.tar`, `.gz`, `.bz2`, `.xz`, `.cab`, `.lzh`, `.arj`, `.z`, `.001` |
| DirectX | winget | default | latest | |
| MPV | winget | default | latest | |
| Powertoys | winget | default | latest | |
|  |  |  |  | |

#### Personal Apps
| App | command | location | version | notes |
| --- | --- | --- | --- | --- |
| Chrome | winget | default | latest | |
| Microsoft To Do | winget | default | latest | |
| Obsidian | winget  | default | latest | |
| iCloud | winget | default | latest | Config what files will be sync must by made by hand. |
| Telegram | winget | default | latest | |
| WhatsApp | winget | default | latest | |
| Spotify | winget | default | latest | |
| Steam | winget | `G:\Program Files\Steam` | latest | |
| GoG | winget | `G:\Program Files (x86)\GOG Galaxy` | latest | |
| Epic | winget | `G:\Program Files (x86)\Epic Games` | latest | |
| Discord | winget | default | latest | |
| qBittorrent | winget | default | latest | |
| VegasPro 21 | Manual | default | latest | The .exe can't be downloaded by an automated tool. [link](https://dl03.magix.com/vegasproedit21_dlm_47zge9.exe) |
|  |  |  |  |