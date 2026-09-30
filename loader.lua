--[[
  INSUI autoexec loader (github.com/adorablewhale/insui)

  Put this file in Matcha's auto-execute folder (C:/matcha/autoexec) once.
  When you join a game it reads INSUI/autoexec.json from the workspace and runs
  every enabled script whose games (universe ids) or places (place ids) match.

  Scripts add themselves to that file with lib:RegisterAutoexec{...}, and you turn
  each one on or off in any INSUI script: gear tab > Auto-execute. The master
  switch there ("Auto-execute on join") turns the loader off entirely.

  An entry: { name, label, games = {universeId}, places = {placeId},
              source = "workspace/path.lua", url = "https://... (used if source is missing)",
              enabled = true }
]]

task.spawn(function()
  local HttpService = game:GetService("HttpService")
  local function say(msg) print("[INSUI loader] " .. msg) end

  -- auto-execute can start on the loading screen: wait until the game is known
  local t0 = os.clock()
  while (game.PlaceId == 0 or game.GameId == 0) and os.clock() - t0 < 120 do task.wait(0.5) end
  if game.PlaceId == 0 then say("no place id after 2 minutes - nothing run") return end

  local ok, cfg = pcall(function() return HttpService:JSONDecode(readfile("INSUI/autoexec.json")) end)
  if not ok or type(cfg) ~= "table" then say("no INSUI/autoexec.json yet - load a script once to register it") return end
  if cfg.enabled == false then say("auto-execute is off (gear tab > Auto-execute)") return end

  local place, universe = game.PlaceId, game.GameId
  -- ids are text in autoexec.json (Matcha's JSONDecode wraps big whole numbers without a .0), compared as text
  local function idText(v)
    local n = tonumber(v)
    return n and string.format("%.0f", n) or nil
  end
  local function matches(list, id)
    local want = idText(id)
    for _, v in ipairs(type(list) == "table" and list or {}) do
      if idText(v) == want then return true end
    end
    return false
  end

  local ran = 0
  for name, s in pairs(cfg.scripts or {}) do
    if type(s) == "table" and s.enabled ~= false and (matches(s.games, universe) or matches(s.places, place)) then
      local src
      if type(s.source) == "string" and isfile(s.source) then
        src = readfile(s.source)
      elseif type(s.url) == "string" then
        pcall(function() src = game:HttpGet(s.url) end)
      end
      if type(src) == "string" and #src > 0 then
        local fn, err = loadstring(src)
        if fn then
          say("running " .. tostring(name))
          ran = ran + 1
          task.spawn(fn)
        else
          say(tostring(name) .. " did not compile: " .. tostring(err))
        end
      else
        say(tostring(name) .. ": source not found (" .. tostring(s.source or s.url) .. ")")
      end
    end
  end
  if ran == 0 then say("nothing enabled for this game (place " .. place .. ", universe " .. universe .. ")") end
end)
