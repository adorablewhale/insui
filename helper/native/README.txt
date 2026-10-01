MATCHA HELPER 1.1.1

Open matcha-helper.exe, then choose "install and start". No administrator rights.
You can also choose "run once" without adding a login shortcut.
The installed app starts in the system tray at Windows login.

Double-click the mint whale icon to open its status window. Right-click to pause,
resume, view the source, open your dashboard, quit, or uninstall. Closing the
status window leaves the tray app running. Quit stops the helper immediately.

It wakes automatically while an accepted script is sending fresh local state.
When every script unloads or stops checking in, it sleeps: no automatic focus,
keyboard input or screenshots. The lightweight localhost service stays available.
Local watchdog delivery can send its one configured disconnect alert after a stall.
Pause stops all helper features; scripts and cloud dashboards can continue.

Only the features enabled in your script/helper settings are used. Screenshots
capture the Roblox window. The helper uses localhost port 47210 and a local token.
It does not upload usage tracking, credentials, school data or hardware IDs.
Cloud dashboards and reporting are controlled separately in the scripts.

source-code.txt contains the complete C# app, PowerShell backend and installer.
The ZIP also includes buildable source and build.ps1. Nothing is obfuscated.
Build with the Windows .NET Framework compiler; no third-party packer is used.
File SHA-256 hashes are in SHA256SUMS.txt. Source transparency lets you inspect
the program's behavior; it is not a guarantee from an antivirus provider.

Installed location: %LOCALAPPDATA%\matcha-helper
Uninstall from the tray menu, or run uninstall.cmd beside this README.
Managed files go to the Recycle Bin. Script settings remain in your workspace.
Windows 10/11 with .NET Framework 4.8 and Windows PowerShell 5.1.
