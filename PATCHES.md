# What this fork changes

## j5cks-2.0.0 local candidate (2026-10-08)

new default look, matching the website (adorablewhale.world): ink on black, Geist-style hierarchy with Matcha fonts, mono labels. same API: every 1.x script runs unchanged.

- window: full-width top bar (title, version, live status, search, minimize/close), text tab list with a 2px ink marker and an optional mono meta, sub-tabs as an indented list, a footer line (script text + menu key). the sidebar stays open by default; "collapse sidebar" still gives the icon rail.
- sections: mono label + hairline, description under it, no cards. rows are separated by hairlines and show their tooltip as a description under the row (up to 3 lines); `SetDescriptions(false)` restores hover tooltips.
- controls: 30x16 pill switch, flat 16px checkbox with a tick, 1px slider track with an ink fill and rectangular thumb (value in mono, click to type), outlined buttons, raised fields, kbd-style key chips (a dot marks toggle/always), "risk" tag on risky toggles, flat notifications / tooltip / dialog (ink confirm button), thin scrollbar.
- performance: gradients, fade lines, glows and halos are gone (each fade line was 10-26 draw objects per frame).
- additive API: `lib:SetStatus(text|fn)`, `lib:SetFooter(text|fn)`, `lib:SetDescriptions(on)`, `tab:SetMeta(text)`.
- configs: saved with `skin = 2`. a pre-2.0 config still loads its rows, keys, size and menu key, but not its old accent / background / card alphas / sidebar switch, so the new look shows once; after that, presets and colours save as before.
- tests: the five existing suites pass; compile passes, 193 top-level locals. live: FischHub 2.6.5 loads it from INSUI/insui.lua.

## j5cks-1.4.9 (2026-10-07)

Matcha menu hover preserves Roblox input/focus instead of entering AFK and dropping clicks. other executors retain input capture. IsInteracting() exposes active menu use so gameplay scripts yield simulated input without focus loss. synthetic releases expire through frame polling after a grace period and physical-up sample, avoiding release-tail clicks and stuck suppression. owner confirmed live clicks work; mouse tabs and reel-speed checkbox off/on verified with focus true/AFK absent. source regressions cover both buttons, delayed physical release, repress, interaction and legacy executor capture.

## j5cks-1.4.8 (2026-10-07)

closing a menu while typing a slider/textbox or capturing a bind could leave edit focus behind. the menu key and all feature hotkeys then stayed blocked while the hud kept running. close/minimize/toggle/SetOpen share input cleanup; the frame loop repairs hidden orphaned editors/captures, preserving modal/spotlight editing. unfinished slider edits are cancelled without invoking their callback. the actual-source regression fails the old version and passes the fix; live P opens and V activates auto fish after reproducing a closed slider, then auto fish restored off. published library also includes the prior overlay-position and SyntheticMouse additions. loader recovery source remains a separate local candidate.

## j5cks-1.4.7 local candidate (2026-10-07)

keybind overlay dragged position round-trips through configs, validates finite coordinates and cancels dragging on load. existing configs remain compatible. isolated live save/load and actual-source regression pass; post-reload config restores position/visibility; visual drag check pending. loader recovery exposes explicit one-session run and persistent enable without deleting files. public stays1.4.6.

also in the 1.4.7 candidate: `lib:SyntheticMouse("m1"|"m2", held)`. menus read the physical button state, so a script's own simulated clicks (auto casting, reel control) could toggle whatever row was under the cursor. while a script says it holds a button, the menu ignores that button. FischHub 2.6.5 local calls it from its Input layer. compile passes, 193 locals; not live-click-tested yet.

## j5cks-1.4.6 (2026-10-06)

unwatched cloud sessions sync every 60 seconds instead of 30. watched dashboards
keep five-second controls. the existing 45-second quiet deferral bounds the normal
heartbeat gap to 105 seconds before request time, inside the server's 120-second
live window. fewer requests and database writes; consent and unload stay unchanged.
isolated scheduler regression passes in Matcha and fails on 1.4.5; compile passes,
193 top-level locals. live FischHub loads this local copy and reports online.
pair with dashboard migration 0013, which removes the frequently
updated heartbeat index; the combined normal heartbeat cost drops from two writes
per 30 seconds to one per 60 seconds.

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

## j5cks-1.2.0 (local candidate, 2026-09-30)

Universal lib:Helper client and helper/matcha-helper.bat: per-script dashboard/commands, heartbeat availability, relay edits/screenshots, watchdog, checked AFK focus, HTTP/clipboard/files/loader tools. All new library internals live on Fix; 193 top-level locals. See helper/README.md. Not committed or published.

## j5cks-1.4.1 (2026-10-01)

Window stuck off-screen on autoexec. INSUI captured `workspace.CurrentCamera` once at load and
centred the window on its `ViewportSize`. Under autoexec, right after joining, the viewport can
read ~0 (the camera isn't ready, or Roblox swaps in a new one), so the window landed at about
`(-W/2, -H/2)`. Its drag bar was off-screen, and `ClampWindow` only ran while dragging, so it
couldn't be moved until the VM was reset.
- `Camera.ViewportSize` is read live from the current camera. A size under 320x240 falls back
  to the last good one (1920x1080 before any).
- `ClampWindow()` runs every frame, so a window placed against a bad viewport, or a saved
  off-screen position, comes back on screen.
Still 193 top-level locals.

One agreement (terms `2026-10-01.1`). The separate terms, cloud and reporting prompts are now a
single agreement. It lists everything kept for 30 days: Roblox name/ID, script/version, game,
launch time, whether a script is running and session length, and dashboard status/counters/
settings. It says the owner sees this on an admin page.
- "Disagree" is shown in red ("If you disagree, the script will not load."). The dialog is modal:
  only the buttons or Esc decide.
- `lib:Dialog` gained `warning` (red bold lines) and `modal`.
- Turning data sharing off (Cloud tab), deleting your data (Cloud tab or website), or turning it
  off on the website calls `Fix.AccessRevoke`. It forgets the agreement, shows a red notice,
  unloads every helper's `_G[name].Unload()` and destroys the UI. The next load asks again.
- The server accepts the old version so older copies keep syncing; live/session data only appears
  for launches under the new wording.

## j5cks-1.4.2 (2026-10-01)

Update notices. A minute after load and then every 15 minutes, INSUI downloads
`adorablewhale.world/versions.json` (no-store, so it doesn't share GitHub's raw-cache lag). If INSUI
or a running script (`lib:Helper` name/version) is older than the list, it shows one notice and
offers "Reload now", which runs the script's registered autoexec URL. It waits until 6 minutes after
the list's `published` time so GitHub's raw copy has caught up. Nothing is uploaded.
Release step: `python Matcha/tools/versions.py`, then deploy the dashboard.

## j5cks-1.4.3 (2026-10-01)

- `H:Rejoin(target)` asks the matcha helper (1.3.0+) to relaunch Roblox into your private server, or any public
  server when only a place id is given. `H:Shot()` asks it to upload a picture of the Roblox window to the dashboard.
- `H:Notify("update", ...)` refreshes that picture first, so the Discord stats message shows the game.
- Dashboard / Discord actions return their own message (`return ok, "why"`) instead of a bare "done".
- `loader.lua`: a local INSUI or script whose version is higher than the published one wins (dev PCs);
  everyone else keeps getting the release.
