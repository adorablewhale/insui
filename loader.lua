-- Matcha loader source. Public release is generated from this file.
task.spawn(function()
  local HttpService = game:GetService("HttpService")
  local Players = game:GetService("Players")
  local function say(s) print("[Matcha loader] " .. s) end
  local started = os.clock()
  while (game.PlaceId == 0 or game.GameId == 0 or not Players.LocalPlayer) and os.clock() - started < 120 do task.wait(0.5) end
  if game.PlaceId == 0 or not Players.LocalPlayer then say("game not ready; no scripts run") return end
  local user = tonumber(Players.LocalPlayer.UserId)
  local catalog = {
    FischHub = {name = "FischHub", label = "Fisch", games = {"5750914919"}, places = {"16732694052"},
      source = "Fisch/FischHub/fisch.lua", url = "https://raw.githubusercontent.com/adorablewhale/fischhub/main/fischhub.lua"},
  }
  if user == 4654017802 then
    catalog.TiltLine = {name = "TiltLine", label = "Volleyball Legends", games = {"6931042565"}, users = {"4654017802"},
      source = "Volleyball Legends/TiltLine5.lua", url = "https://raw.githubusercontent.com/adorablewhale/tiltline-access/main/TiltLine.lua"}
  end
  local function matches(list, value)
    for _, id in ipairs(type(list) == "table" and list or {}) do if tonumber(id) == tonumber(value) then return true end end
    return false
  end
  local function permitted(name, entry)
    if tostring(name):lower() == "tiltline" and user ~= 4654017802 then return false end
    return not (type(entry.users) == "table" and #entry.users > 0) or matches(entry.users,user)
  end
  local ok, cfg = pcall(function() return HttpService:JSONDecode(readfile("INSUI/autoexec.json")) end)
  if not ok or type(cfg) ~= "table" then cfg = {enabled = true, scripts = {}} end
  if cfg.enabled == false then say("auto-execute is off") return end
  local saved = type(cfg.scripts) == "table" and cfg.scripts or {}
  for name, entry in pairs(catalog) do if type(saved[name]) == "table" then entry.enabled = saved[name].enabled ~= false end end
  -- A registered future script can extend the catalog; built-in release URLs and
  -- access rules cannot be replaced by stale registration metadata.
  for name, entry in pairs(saved) do if not catalog[name] and type(entry) == "table" and permitted(name,entry) then catalog[name] = entry end end
  local selected = {}
  for name, entry in pairs(catalog) do
    if permitted(name,entry) and entry.enabled ~= false and (matches(entry.games,game.GameId) or matches(entry.places,game.PlaceId)) then selected[#selected+1]=entry end
  end
  if #selected == 0 then say("no enabled script for this game") return end
  local source
  pcall(function() source=httpget("https://raw.githubusercontent.com/adorablewhale/insui/main/insui.lua") end)
  if type(source) ~= "string" or not source:find("function InsUi:RequireTerms",1,true) then pcall(function() source=readfile("INSUI/insui.lua") end) end
  if type(source) ~= "string" or not source:find("function InsUi:RequireTerms",1,true) then say("terms gate unavailable; no scripts run") return end
  local chunk = loadstring(source)
  if not chunk then say("terms gate failed to compile") return end
  local loaded, lib = pcall(chunk)
  lib = type(lib) == "table" and lib or rawget(_G,"INSUI")
  if not loaded or type(lib) ~= "table" or type(lib.RequireTerms) ~= "function" then say("terms gate unavailable") return end
  local accepted, why = lib:RequireTerms()
  if not accepted then say(why or "terms declined") lib:Destroy() return end
  cfg.scripts = saved
  for name, entry in pairs(catalog) do if permitted(name,entry) and lib.RegisterAutoexec then lib:RegisterAutoexec(entry) end end
  lib:Destroy()
  for _, entry in ipairs(selected) do
    local script
    -- Fetch the newest release first. Offline source is an explicit local fallback.
    if type(entry.url) == "string" and entry.url:match("^https://raw%.githubusercontent%.com/adorablewhale/") then
      pcall(function() script=httpget(entry.url) end)
    end
    if type(script) ~= "string" or #script < 100 then
      if type(entry.source) == "string" and not entry.source:find("..",1,true) and not entry.source:find(":",1,true) then
        pcall(function() if isfile(entry.source) then script=readfile(entry.source) end end)
      end
    end
    if type(script) ~= "string" or #script < 100 then say(entry.name .. ": release unavailable")
    else
      local fn, err = loadstring(script)
      if fn then say("running " .. entry.name) task.spawn(fn) else say(entry.name .. ": " .. tostring(err)) end
    end
  end
end)
