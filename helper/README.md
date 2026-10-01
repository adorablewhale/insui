# Matcha helper

Install once with `install.ps1` beside `matcha-helper.bat` (or the website download's
`install.cmd`). It copies the helper into `%LOCALAPPDATA%/matcha-helper`, creates a
per-user Startup shortcut, and starts hidden now and at login. No administrator
rights or system-wide changes. A different workspace can be supplied with
`-Workspace "path"`. The website's Account tab shows the helper's heartbeat.

Uninstall with `powershell -NoProfile -ExecutionPolicy Bypass -File
"%LOCALAPPDATA%/matcha-helper/install.ps1" -Uninstall`, or `uninstall.cmd` from the
download. It stops only the matching installed process (checks command line and
creation time), removes its startup shortcut, and moves managed files to the Recycle
Bin. Unknown files and Matcha settings remain. Close a legacy helper before installing.

The manual BAT remains available: double-click it and keep its window open.
One helper instance serves every INSUI script on localhost port 47210.
FischHub's Discord webhook is now configured only on the hosted website; local
FischHub mode has no webhook. Cloud controls/Discord do not need this helper.
Windows focus, clipboard, local files and screenshots are its optional capabilities.

Features are optional per script. Legacy integrations can still use local webhook
configuration; new FischHub uses website Discord settings instead. The watchdog sends one alert after two minutes without updates while armed;
unloading suppresses it. AFK is off by default and waits for three seconds of user idle time.
It checks Roblox really has focus, taps O/I at most once a minute, and restores the prior window.
Generic AFK activates after the background interval on the page (default ten minutes).

The helper binds only to 127.0.0.1. Host/Origin checks and a random per-start token protect tools
and commands. Files can be written only under C:/matcha/workspace or C:/matcha/autoexec, with
canonical path checks and no symlinks/junctions or alternate data streams. Roblox screenshots
capture its window only. Feature switches/config and protocol files stay in INSUI/helper under
Matcha's workspace. Webhook URLs and token.txt are local secrets; never publish them.

Developers: lib:Helper({name,version,features}) supplies state, Log, Watch, NeedFocus, Action,
Enabled, Up, Webhook, Request, Clipboard, Open and WriteFile. Up reads helper.json's heartbeat,
so a stopped helper does not stall Matcha with an HTTP probe. INSUI writes state every two seconds,
checks commands every half second, skips preexisting commands, validates menu values and marks
unloaded on Destroy. FischHub's legacy /ping and webhook relay endpoints remain compatible.
FischHub retains its legacy Dash files; its old helper filename now launches this helper.

Local acceptance tests and screenshots: the Matcha kit's VERIFICATION.md. Changes are unreleased
until the owner approves commits and publication.
