# INSUI (adorablewhale fork)

![preview](assets/preview.png)

A Drawing-based UI library for the **Matcha** executor. This is a fork of
[neaxusxgod-png/INS-ui](https://github.com/neaxusxgod-png/INS-ui) with the fixes from
TiltLine and FischHub built in: keybinds for F-keys, saving that actually saves,
`SetVisible`, a clean `Destroy`, working `Paragraph`/`Progressbar`/`Space`, live box
lines, and more. See **[PATCHES.md](PATCHES.md)** for the full list.

## Load

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/adorablewhale/insui/main/insui.lua"))()
local Lib = _G.INSUI
```

Matcha's `loadstring` drops a chunk's return value, so read the library from
`_G.INSUI` (also `_G.INSui`). `Lib.Version` is `"j5cks-..."`.

## Start

```lua
local win = Lib:CreateWindow({ title = "My Hub", size = Vector2.new(700, 540), menuKey = "p",
    configFolder = "MyHub_ui", configName = "myhub", autoSave = true, gameInput = true })
win:AddSettingsTab("gear")

local tab = win:Tab("Combat", "crosshair")
local sec = tab:Section("Aimbot", "Left")

sec:Toggle("Enabled", false, function(on) end):AddKeybind("f1", "Toggle")
sec:Slider("FOV", 120, 1, 10, 500, "px", function(v) end)
```

P opens and closes the menu. Full example: [showcase.lua](showcase.lua)

## Window

```lua
Lib:CreateWindow({
    title       = "My Hub",
    subtitle    = "v1",                 -- or "auto" for the game name
    size        = Vector2.new(700, 540),
    position    = Vector2.new(40, 40),  -- default centred
    menuKey     = "p",
    theme       = { accent = Color3.fromRGB(255, 120, 160) },
    accentA     = Color3.fromRGB(122, 134, 255),
    accentB     = Color3.fromRGB(189, 130, 255),
    font        = "Proxima",
    logo        = "https://site.com/logo.png",
    logoSize    = 30,
    icon        = "https://site.com/icon.png",
    opacity     = 0.95,
    rounding    = 1,
    rowLines    = true,
    checkboxStyle = true,
    keybindOverlay = true,
    backgroundEffect = "Rain",
    backgroundEffectColor = Color3.fromRGB(160, 90, 255),
    spotlight   = true,               -- false turns search off entirely (no Ctrl+Space hotkey in this fork)
    configName  = "myhub",
    configFolder = "myhub",
    autoSave    = true,               -- works in this fork: saves within ~2 s of a change
    smartFps    = true,
    gameInput   = true,               -- see "Game input" below
    startOpen   = true,
})
```

`win:AddSettingsTab("gear")` adds the built-in settings tab. `win:SettingsSection("Mine", "Right")`
puts your own card in it.

Callable on `win` or `Lib`:

```lua
win:SetOpen(false)   win:IsOpen()      win:SetSize(800, 560)   win:SetPos(40, 40)
win:Center()         win:SetTitle("X") win:SetMenuKey("rightshift")
win:Destroy()        Lib:SetAutoLoad("myhub")   Lib:GetAutoLoad()
```

## Tabs and sections

```lua
Lib:Category("VISUALS")
local tab = win:Tab("Visuals", "eye")
local left = tab:Section("Player ESP", "Left", "see players through walls")
local full = tab:Section("Notes", "Full")

local world = win:Tab("World", "globe")
world:Sub("Players", "users"):Section("List", "Left"):Toggle("Names", true)
```

Sides are `Left`, `Right`, `Full`. Click a section header to fold it. `Lib:SetLayout("top")`
moves the tabs to the top.

## Widgets

```lua
sec:Toggle("God mode", false, function(on) end, "tooltip")
sec:Slider("Walk speed", 16, 1, 16, 250, "", function(v) end, "tooltip")
sec:RangeSlider("Distance", 25, 75, 1, 0, 100, "m", function(lo, hi) end)
sec:Dropdown("Mode", {"Closest"}, {"Closest", "Random"}, false, function(v) end)  -- v is a list: v[1]
sec:Colorpicker("ESP color", Color3.fromRGB(122, 134, 255), function(c, a) end, 0.5)
sec:Textbox("Name", "", function(text) end)
sec:Keybind("Panic", "k", function(key) end)          -- fires on rebind only, not on press
sec:Button("Rejoin", function() end):AddButton("Hop", function() end)
sec:Label("Status: idle")
sec:Label(function() return "live: " .. os.clock() end)  -- re-read every frame
sec:Info("longer help text that wraps")
sec:Paragraph("Title", "body text")
sec:Progressbar("Loading", 0.3)                        -- :Set(0..1) moves it
sec:Space(10)
sec:Divider("Advanced")
```

`Checkbox` is the same as `Toggle`. Dropdowns take `multi`, `tooltip`, `searchable` and
`maxSelections` as the 4th to 8th arguments. Pass a function instead of a list for a
dropdown that refreshes itself:

```lua
sec:Dropdown("Player", {}, function() return getNames() end, false, function(v) end)
```

## Handles

```lua
local aim = sec:Toggle("Aimbot", false, function(on) end)
aim:AddKeybind("e", "Hold")                 -- key drives the toggle (Hold / Toggle / Always)
aim:AddKeybind("e", "Hold", function(on) end)  -- with a callback: its own hotkey, the toggle is untouched
aim:AddColorpicker("FOV color", Color3.fromRGB(120, 255, 140), function(c, a) end)
aim:SetRisk()

local wall = sec:Toggle("Wall check", true)
sec:Toggle("Visible only", false):DependsOn(wall)
```

```lua
h:Set(v)   h:Get()      h:Reset()      h:IsActivated()
h:SetText("New")        h:Tooltip("info")
h:SetColor(color)       h:SetRisk(true)   h:SetLocked(true)
h:SetVisible(false)     -- works in this fork
h.NoSave = true         -- keep a row out of INSUI's config (your script saves it itself)
```

Dropdown handles also take `UpdateChoices`, `AddChoice`, `RemoveChoice`, `ClearChoices`,
`SetSearchable`, `SetMaxSelections`, `SetRefresh` and `Refresh`. Set `h.Value = { "x" }`
to change the selection without firing the callback.

Keybind chips: left-click to rebind (Esc clears), right-click for the mode. The key names
are lowercase: `"f1"`, `"enter"`, `"space"`, `"a"`, `"leftshift"` and so on.

## Values

```lua
Lib:GetValue("Combat.Aimbot.Enabled")      -- "Tab.Section.Row"
Lib:SetValue("Combat.Aimbot.FOV", 90)      -- sets and fires the callback
```

## Notifications and dialogs

```lua
Lib:Notify("Aimbot", "enabled", 3, "success")    -- success / warning / error / info (shown lowercase)

Lib:Dialog({
    title = "Unload?",
    text = "Remove the menu?",
    confirm = "Unload",
    onConfirm = function() Lib:Destroy() end,
})
```

## Floating boxes (HUD)

```lua
local box = Lib:CreateBox({ title = "Stats", position = Vector2.new(20, 140), width = 200 })
local kills = box:Text("kills: 0")
box:Stat("State | FARMING")      -- "Label | value" is drawn as two columns
box:Bar(0.5)
box:Text(function() return "fps: " .. getFps() end)   -- live, works in this fork
kills.Value = "kills: 3"          -- lines are tables: change .Value / .Color
box:SetTitle("Session")   box:SetVisible(false)   box:Clear()   box:Remove()
```

The box can be dragged by its title while the menu is open, and `box.X` / `box.Y` hold
its position.

## Look

```lua
Lib:ApplyThemePreset("Indigo")
Lib:SetAccent(Color3.fromRGB(122, 134, 255), Color3.fromRGB(189, 130, 255))
Lib:SetTheme({ accent = Color3.fromRGB(255, 120, 160) })
Lib:SetFont("Minecraft")
Lib:SetLayout("top")
Lib:SetOpacity(0.9)      Lib:SetRounding(1.5)     Lib:SetRowLines(true)
Lib:SetPerformance(true) Lib:SetCheckboxStyle(true)
Lib:SetKeybindOverlay(false)
Lib:SetBackgroundEffect("Snow")
Lib:SetBackgroundEffectColor(Color3.fromRGB(120, 200, 255))
Lib:SetBackgroundImage("https://site.com/pic.png", 0.5)
Lib:OpenSettings()       Lib:OpenSpotlight()
Lib:SetSpotlight(false)  Lib:SetGameInput(true)
```

Presets: Indigo NeverBlox Lemon Mono Sunset Mint Rose Gold Crimson Ocean Toxic Lavender Aqua
Ember Cyber Bubblegum Forest Slate Cherry Aurora Sky Magma Grape Steel Peach Neon Waifu.

Fonts: Default Bold Proxima Proggy Minecraft JetBrains Pixel Fortnite.

Effects: Off Snow Matrix Rain.

## Configs

```lua
Lib:SaveConfig("pvp")   Lib:LoadConfig("pvp")   Lib:DeleteConfig("pvp")
Lib:ListConfigs()       Lib:ExportConfig()      Lib:ImportConfig(code)
Lib:SetAutoLoad("pvp")  -- load this config at every launch (writes <folder>/_autoload.json)
```

Everything with a value is saved: widgets, keybinds, theme, font, layout and appearance.
Configs go in `<configFolder>/<name>.json`, or `INSUI/<title>/` without a `configFolder`.
Keys are `"Tab.Section.Row"`, so renaming a row loses its saved value.

## Game input

While the cursor is over the menu, INSUI calls `setrobloxinput(false)`, which also swallows
**simulated** `keypress` / `mouse1press` from your script. Before sending input, do this:

```lua
local function toGame(fn)
    pcall(setrobloxinput, true)
    local ok, err = pcall(fn)
    pcall(function() Lib:SetGameInput(true) end)   -- let INSUI re-apply its own state
    return ok, err
end
toGame(function() keypress(0x45) end)
```

`gameInput = false` holds input back the whole time the menu is open. `true` releases it
whenever the cursor leaves the window and no popup is open. `"always"` never holds it back.

## Search

Click the box in the title bar and type to jump to any widget in any tab. This fork has no
Ctrl+Space hotkey. `Lib:SetSpotlight(false)` turns search off entirely.

## Icons

Names only, all built in:

```
alert bell book book-closed box bug calendar camera cart check chevron-large-left
chevron-large-right chevron-small-down chevron-small-up circle-i circle-question clock close
cloud code cog compass controller crosshair crosshairs crown delete discord edit email envelope
eye fire flag flame folder gamepad gauge gear gift-box globe globe-simplified grid hash hashtag
headphones heart home house image info key layers leaf lightning lightning-bolt location-pin
location-pin-map lock lock-closed magnifying-glass mail map menu mic microphone minus minus-small
monitor moon notification pause pause-small pencil pencil-square people person phone photo-camera
pin play play-small plus plus-small question robux rocket search settings shield shield-check
shopping-cart skull sliders sound speaker speed speedometer star stop stop-small sun sword swords
tag target three-bars-horizontal three-dots-horizontal three-sliders-horizontal time trash
trash-can triangle-exclamation trophy two-people two-stacked-squares user users volume wallet
warning world x zap
```

`logo`, `icon` and the background take a URL, a file from the workspace folder, or raw PNG bytes.

## Auto-execute (loader)

Put [loader.lua](loader.lua) in Matcha's auto-execute folder (`C:/matcha/autoexec`) once. Then, in each
script, after the window is built:

```lua
Lib:RegisterAutoexec({
    name   = "MyHub",
    label  = "Some Game",                  -- shown next to the toggle
    games  = { 1234567890 },               -- universe ids (game.GameId): every place of the game
    places = { 9876543210 },               -- and/or exact place ids
    source = "Some Game/MyHub/myhub.lua",  -- workspace path the loader reads
    url    = "https://raw.githubusercontent.com/you/myhub-loader/main/MyHub.lua",  -- used when source is missing
})
```

The list lives in `INSUI/autoexec.json`. Every INSUI script's settings tab shows an **Auto-execute** section
with a master switch and one toggle per script, and a new entry starts on. The loader waits for the game to
load, then runs each enabled script whose `games` or `places` match.

## Files

Everything INSUI writes is under `INSUI/` in the workspace: `INSUI/<configFolder or title>/` for configs
(pass `configFolder = "INSUI/MyHub"`), `INSUI/cache/` for pictures, and `INSUI/autoexec.json`.

## Unload cleanly

```lua
Lib:Destroy()   -- removes every drawing and picture, saves the config if autoSave is on,
                -- calls setrobloxinput(true) and clears _G.INSUI
```

Upstream's README also lists `sec:Image`, `win:Unload` and `win:autoloadConfig`, but they
don't exist in the library.

## Credit

The original library is by [neaxusxgod-png](https://github.com/neaxusxgod-png/INS-ui). This fork
only adds fixes, and each one is listed in [PATCHES.md](PATCHES.md).
