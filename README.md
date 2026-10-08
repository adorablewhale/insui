<div align="center">

<img src="assets/logo.png" width="72" alt="">

# insui

**a clean drawing-based ui library for matcha.**

<img src="assets/preview.png" width="640" alt="insui preview">

</div>

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/adorablewhale/insui/main/insui.lua"))()
local lib = _G.INSUI
```

### what you get

- **real menus** — tabs, sections, toggles, sliders, dropdowns, color pickers, keybinds, search
- **settings that save** — configs, autosave and autoload per script
- **a hud** — floating boxes for live stats
- **autoexec** — pick which scripts run in which games from the gear tab
- **cloud dashboard** — check and change your script from your phone at adorablewhale.world; scripts can place it on their own online tab
- **update notices** — waits until you open the menu; closed-menu macros stay undisturbed
- **one clear agreement** — users see exactly what's shared before anything loads
- **clean unload** — reinject as often as you like, nothing is left behind

### start

```lua
local win = lib:CreateWindow({ title = "my hub", menuKey = "p", autoSave = true })
win:AddSettingsTab("gear")

local main = win:Tab("main", "crosshair"):Section("aim", "Left")
main:Toggle("enabled", false, function(on) end):AddKeybind("f1", "Toggle")
main:Slider("fov", 120, 1, 10, 500, "px", function(v) end)
```

**p** opens the menu. full example in [showcase.lua](showcase.lua).

### more

- [docs/api.md](docs/api.md) — every function and option
- [PATCHES.md](PATCHES.md) — what this fork fixes and adds
- [helper/](helper/) — the optional windows helper

### something broke?

message me on [discord](https://discord.com/users/599705734002769920), it works way better than issues here. tell me what you were doing and what happened.

<sub>fork of [neaxusxgod-png/INS-ui](https://github.com/neaxusxgod-png/INS-ui) · made for matcha</sub>

---

<div align="center"><sub>🐳 <b>adorablewhale</b> · <a href="https://adorablewhale.world/me">website</a> · <a href="https://discord.com/users/599705734002769920">discord</a> · <a href="https://github.com/adorablewhale">other projects</a></sub></div>
