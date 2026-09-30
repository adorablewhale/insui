# What this fork changes

Base: [neaxusxgod-png/INS-ui](https://github.com/neaxusxgod-png/INS-ui) at `506859d`
(`uilib.min.lua`, its only commit). The patched library is `insui.lua`.

These fixes were first made inside two Matcha scripts, TiltLine (vendored copy) and
FischHub (find/replace patches before `loadstring`, plus workarounds in the script).
They now live here, so a script can `HttpGet` this file and use it as is.

The fork's own changes are marked `-- FIX:` in `insui.lua`. Every one was checked live
in Matcha on 2026-09-30.

## From TiltLine (vendored copy)

| # | Problem | Fix |
|---|---|---|
| 1 | A custom accent colour was never the one saved. `PackConfig` writes `State.BaseAccentA/B`, but the colour pickers only called `ApplyAccents()`. | `PickFirst` / `PickSecond` also set the base colour. |
| 2 | Same bug in `PickPreset`, for both the "Default" branch and the preset branch. | Both set the base colour. |
| 3 | `ListConfigs` couldn't split a Windows path, because `"([^/\]+)"` unescapes to `[^/]+`. Every config came back as its full path, and `_autoload` / `_autosave` showed up in the list. | The pattern is now `"([^/\\]+)"`. |
| 4 | `Drawing.Fonts` keys (SystemBold, Minecraft, Pixel, Fortnite) are nil on some executors, which gave `table index is nil` in `FontWidth`. | They fall back to System/UI/Mono. |
| 5 | `httpget` errors crashed avatar and picture loading. | `Fix.HttpGet` tries `game:HttpGet`, then `httpget`, then `request`, all under pcall. |
| 6 | `ismouse1pressed`, `ismouse2pressed` and `iskeypressed` could be missing or throw. | `Fix.Mouse1Down` / `Fix.Mouse2Down` and `ReadKeys` fall back to `UserInputService`. |
| 7 | Matcha can't read the mouse wheel, so long tabs could only be scrolled with the bar. | Hold the middle mouse button over the list and drag. The arrow and page keys still work. |
| 8 | `setrobloxinput` could be missing. | It's called under pcall. |

## From FischHub (runtime source patches)

| # | Problem | Fix |
|---|---|---|
| 9 | The script couldn't reach INSUI's private `State`. | Exposed as `lib._state`. |
| 10 | Keys are registered as `F1`, `Enter`, `Space`... but binds are looked up lowercase, so only letter and digit binds ever fired. | Lowercase aliases for every key. |
| 11 | The keybind overlay listed a toggle only when it had a key bound. | It lists every enabled toggle with a bind slot, showing `on` when there's no key. |
| 12 | Ctrl+Space opened search, and Ctrl and Space are game keys. | The hotkey is gone; the search bar still opens with a click. The Ctrl+Space hints are gone too. |
| 13 | Minimize shrank the window to a draggable 3-line bubble. | Minimize hides the window, and the menu key brings it back. |

## From FischHub (script workarounds, now fixed in the library)

| # | Problem | Fix |
|---|---|---|
| 14 | `row:SetVisible(false)` only set `Row.Hidden`, which the layout never read. FischHub rebuilt `section.Rows` by hand instead. | Section height and row drawing skip hidden rows (`Fix.VisibleRows`). |
| 15 | `autoSave` / the **Auto-save** toggle set a flag that nothing read, so nothing was saved. | `Fix.AutoSaveStep`: every 2 s, starting 3 s after `CreateWindow` so autoload lands first, the config is written when it changed. The first write happens only if the file doesn't exist yet. `Destroy()` saves once more. |
| 16 | `Destroy()` left the avatar, logo, icon, backdrop, settings gear and sub-tab icons frozen on screen. An avatar download that finished after Destroy stayed there too. | `Fix.DropPictures` removes them all, and a late avatar is dropped as soon as it lands. |

## Found while building this fork

| # | Problem | Fix |
|---|---|---|
| 17 | `SectionClass:Paragraph`, `:Progressbar` and `:Space` called `AddRow` before it was declared, so all three errored. The `Progress` and `Space` row kinds also had no height and no drawer. | They are defined after `AddRow`. `Paragraph` is an Info row. `Progressbar(name, v)` is a live text bar on a Label row (`row:Set(0..1)` moves it). `Space(h)` is an empty row. |
| 18 | The README says box lines accept a function, but the function itself got printed as text ("function: 0x..."). | `Fix.BoxValue` calls it every frame, for Text, Stat and Bar lines. |

## Added by the fork

| # | What | How |
|---|---|---|
| 19 | Everything INSUI writes was scattered over the workspace root (`INSui_<title>/`, `INSui_av_*.dat`, `INSui_img_*.dat`). | It all lives under `INSUI/`: `INSUI/<title or configFolder>/` for configs, `INSUI/cache/` for pictures. `configFolder` may be nested (`"INSUI/MyHub"`), and each part is cleaned on its own. Parent folders are created as needed. |
| 20 | No way to control which scripts auto-execute. | `lib:RegisterAutoexec{ name, label, games, places, source, url }` writes `INSUI/autoexec.json`. The settings tab gets an **Auto-execute** section with a master switch and one toggle per registered script. `loader.lua` goes in Matcha's autoexec folder and runs the enabled scripts whose universe id (`games`) or place id (`places`) matches the game you join. |

## Housekeeping

- The fork's helpers live on one `Fix` table. Matcha refuses a chunk with more than
  200 top-level locals; upstream has 192 and this file has 193.
- `InsUi.Version = "j5cks-1.1.1"`. Bump it with every change.

## Not in the upstream README's code

`sec:Image`, `win:Unload` and `win:autoloadConfig` are listed in upstream's README, but
they don't exist in the library. Use `lib:Destroy()` and `lib:SetAutoLoad(name)`.

## Checking a change

```bash
luau-compile --null insui.lua     # must compile (github.com/luau-lang/luau releases)
```

Then count top-level locals with `luau-ast` (keep them under 200), load the file in
Matcha, build a window, and take a full-desktop screenshot. Matcha's overlay doesn't
show up in a Roblox-window capture.
