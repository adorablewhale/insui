"""Exercise the actual INSUI config pack/apply functions, without a game or files."""
from pathlib import Path
import os
from lupa import LuaRuntime
source=Path(os.environ.get('INSUI_TEST_SOURCE',Path(__file__).resolve().parents[1]/'insui.lua')).read_text(encoding='utf-8-sig')
lua=LuaRuntime(unpack_returned_tuples=True)
lua.execute("""
State={Tabs={},HotkeyShown=false,HotkeyPos={X=723.5,Y=381.25},FontName='Default'}
Theme={AccentA={R=1,G=1,B=1},AccentB={R=1,G=1,B=1},Background={R=0,G=0,B=0},Text={R=1,G=1,B=1}}
Alpha={};RoundScale=1;SettingsTab={Sections={{Rows={{Kind='Toggle',Name='Keybind overlay',Value=true}}}}}
CopyList=function(t)local c={}for k,v in pairs(t)do c[k]=v end return c end
Color3={new=function(r,g,b)return{R=r,G=g,B=b}end}
ApplyAccents=function()end
InsUi=setmetatable({}, {__index=function()return function()end end})
""")
start=source.index('  local function EachSavedRow(')
end=source.index('\nlocal ArrowTabs',start)
block=source[start:end].rsplit('\nend',1)[0]
lua.execute(block)
lua.execute("""
local cfg=PackConfig()
assert(cfg.settings.hotkeyPos and cfg.settings.hotkeyPos[1]==723.5 and cfg.settings.hotkeyPos[2]==381.25,'dragged overlay position missing from config')
assert(cfg.settings.hotkeyEnabled==false,'hidden overlay must save')
State.HotkeyPos.X=4
assert(cfg.settings.hotkeyPos[1]==723.5,'snapshot must not alias the dragged state')
State.HotkeyShown=true;State.HotkeyDrag={X=1,Y=1}
ApplyConfig(cfg)
assert(State.HotkeyPos.X==723.5 and State.HotkeyPos.Y==381.25 and not State.HotkeyShown,'position and visibility must restore together')
assert(State.HotkeyDrag==nil,'loading config cancels an old drag')
assert(SettingsTab.Sections[1].Rows[1].Value==false,'settings toggle mirrors hidden overlay')
ApplyConfig({settings={hotkeyEnabled=true}})
assert(State.HotkeyShown and State.HotkeyPos.X==723.5,'old configs preserve existing position')
for _,bad in ipairs({{0/0,1},{1,math.huge},{'oops',1},{1},{false,1}})do
 ApplyConfig({settings={hotkeyPos=bad}})
 assert(State.HotkeyPos.X==723.5 and State.HotkeyPos.Y==381.25,'invalid saved position cannot corrupt render state')
end
ApplyConfig({settings={hotkeyPos={120,240}}})
assert(State.HotkeyPos.X==120 and State.HotkeyPos.Y==240,'another config has its own position')
""")
print('overlay config: position/visibility round-trip, independent snapshots, legacy configs, malformed values and drag cancellation passed')
