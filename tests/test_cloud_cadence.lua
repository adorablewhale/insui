-- isolated scheduler regression; run through Matcha after copying INSUI/insui.lua. no network or consent writes.
local text = readfile("INSUI/insui.lua")
local part = text:match("(function Fix%.CloudStep%(%)%s.-)%sfunction InsUi:FlushCloud")
assert(part, "cloud scheduler source unavailable")
assert(loadstring("_G.cloudCadenceInstall = function(Fix, State, HttpService, InsUi, task, os) " .. part .. " end"))()
local install = _G.cloudCadenceInstall
_G.cloudCadenceInstall = nil
local clock, calls, quiet, fast = 0, 0, true, false
local h = {name = "Fixture", quiet = function() return quiet end}
local F = {AccessAccepted=true, CloudNext=0, Helpers={Fixture=h},
  AccessRead=function() return {cloud=true, reporting=true} end,
  CloudReady=function() return {cloud=true, reporting=true} end,
  CloudSync=function() calls=calls+1 return {fast=fast} end, CloudLaunch=function() end}
install(F, {Alive=true}, {GenerateGUID=function() return "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" end}, {},
  {spawn=function(fn) fn() end}, {clock=function() return clock end, time=function() return 1791327600+clock end})
F.CloudStep()
assert(calls==1 and F.CloudNext==60, "normal cadence must be 60 seconds")
clock=59; F.CloudStep(); assert(calls==1, "no premature heartbeat")
clock=60; quiet=false; F.CloudStep(); assert(calls==1 and F.CloudForceAt==105, "quiet delay must stay bounded")
clock=104; F.CloudStep(); assert(calls==1, "quiet deferral should not freeze an active reel early")
clock=105; F.CloudStep(); assert(calls==2 and F.CloudNext==165, "worst healthy heartbeat gap stays below 120 seconds")
clock=165; quiet=true; fast=true; F.CloudStep(); assert(calls==3 and F.CloudNext==170, "watched dashboard keeps 5-second controls")
clock=170; F.CloudStep(); assert(calls==4, "watched heartbeat arrives")
print("cloud cadence: normal, early gate, bounded quiet delay, liveness margin and fast dashboard passed")
