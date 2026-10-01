# Matcha helper

Download [installer.exe](https://adorablewhale.world/downloads/installer.exe) from
Account or [the stable GitHub release](https://github.com/adorablewhale/matcha-helper/releases/latest).
Open it, choose the Matcha workspace and press Install. No unzipping or administrator
rights. Search **Matcha helper** in Windows to open the status window; optional
Startup starts it in the tray. Close hides the window; tray Quit stops the backend.

Helper 1.2.0 checks signed stable GitHub releases at startup/every four hours and
applies them while sleeping. A pinned RSA key verifies metadata; the ZIP digest,
size, exact file list and binary version are checked before installation. Pause
delays updates. Turn automatic updates off or check manually in the window/tray.
Network or verification failure leaves the installed helper working. Workspace,
startup and script settings survive updates.

Canonical source is `Matcha/tools/helper` and public `adorablewhale/matcha-helper`.
This `native/` folder is a generated readable distribution copy; edit canonical
source and refresh the mirror. `source-code.txt` contains the complete app, updater,
installer and build tools. Signing material is private outside Git. See
native/README.txt for builds, tests and approved release publication.

The installed files live under `%LOCALAPPDATA%/matcha-helper`. Uninstall from the
tray or the package's uninstall.cmd. It stops only verified helper processes and
recycles managed files and Start menu/Startup shortcuts, preserving script settings
and unknown files. Shutdown validates the real EXE/backend path and creation time
even when process.json is stale. The backend accepts UTF-8 JSON with or without a BOM.

The manual BAT remains available: double-click and keep its window open. Use one
helper on localhost port 47210. Features are optional per script; `windows=false`
never wakes it. Fresh accepted local state wakes the native helper, and stale/unloaded
scripts put it to sleep. Sleep does no automatic focus/input/screenshots. Pause
stops Windows features; cloud dashboards/Discord continue without the helper.

AFK is off by default, waits for user idle time, checks focus before O/I and restores
the previous window. Generic AFK uses the configured background interval. A separately
armed local watchdog may send its one disconnect alert after a stall.

The listener binds only to 127.0.0.1 with Host/Origin checks and a per-start local
token. File writes use canonical workspace/autoexec paths and reject linked paths
and alternate streams. Screenshots capture Roblox only. Never publish token.txt,
webhook URLs or private workspace configuration. FischHub's Discord settings live
on the hosted website, with encrypted URLs never returned to the script.

`lib:Helper({name,version,windows,features})` supplies state, Log, Watch, NeedFocus,
Action, Enabled, Up, Request, Clipboard, Open and WriteFile. Up reads the heartbeat;
it does not block Matcha with an HTTP probe. INSUI writes state every two seconds,
validates commands, rejects preexisting commands and marks unload on Destroy.

Evidence: the Matcha kit's VERIFICATION.md and HANDOFF_V2.md. Future publication and
Discord announcements require the owner's respective authorization.
