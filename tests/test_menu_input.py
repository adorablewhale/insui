"""Exercise actual mouse polling and input routing, including synthetic releases."""
from pathlib import Path
import os
from lupa import LuaRuntime
src=Path(os.environ.get('INSUI_INPUT_SOURCE',Path(__file__).resolve().parents[1]/'insui.lua')).read_text(encoding='utf-8-sig')
lua=LuaRuntime(unpack_returned_tuples=True)
lua.execute('''Input={Synthetic={},Down=false,RightDown=false};Fix={};InsUi={};Mouse={X=10,Y=20}
clock=0;left=false;right=false;os.clock=function()return clock end
Fix.Mouse1Down=function()return left end;Fix.Mouse2Down=function()return right end
''')
a=src.index('function Fix.MouseForMenu(') if 'function Fix.MouseForMenu(' in src else src.index('local function ReadInput()')
b=src.index('\n\n\nlocal function IsMouseIn',a)
lua.execute(src[a:b].replace('local function ReadInput()','function ReadInput()',1))
a=src.index('function InsUi:SyntheticMouse(');b=src.index('\nend',a)+len('\nend')
lua.execute(src[a:b])
lua.execute('''
left=true;ReadInput();assert(Input.Click and Input.Down)
ReadInput();assert(not Input.Click and Input.Down)
left=false;ReadInput();assert(Input.Up)
InsUi:SyntheticMouse('m1',true);left=true;ReadInput();assert(not Input.Click and not Input.Down)
InsUi:SyntheticMouse('m1',false);ReadInput();assert(not Input.Click,'release tail became a new click')
clock=1;ReadInput();assert(not Input.Click,'late physical release became a click')
left=false;ReadInput();left=true;ReadInput();assert(Input.Click,'real click remains blocked after release')
InsUi:SyntheticMouse('m2',true);right=true;ReadInput();assert(not Input.Right)
InsUi:SyntheticMouse('m2',false);right=false;clock=2;ReadInput();right=true;ReadInput();assert(Input.Right)
InsUi:SyntheticMouse('m1',false);InsUi:SyntheticMouse('m1',true);clock=3;left=false;ReadInput()
left=true;ReadInput();assert(not Input.Click,'old release cleared a newer simulated hold')
''')
a=src.index('do\n  -- Matcha\'s global input blocker') if "do\n  -- Matcha's global input blocker" in src else src.index('do\n  local function GameCaptures()')
b=src.index('\n\n\nlocal function DrawMenu()',a)
block=src[a:b]
for executor in ['Matcha 1.0.0','OtherExecutor']:
    lua.globals().executor=executor
    lua.execute('''State={Open=true,GameInput=true,X=0,Y=0,W=100,H=100};setCalls=0
    identifyexecutor=function()return executor end
    IsMouseIn=function()return true end
    setrobloxinput=function(v)lastInput=v;setCalls=setCalls+1 end''')
    lua.execute(block)
    lua.execute('ApplyInputState(true)')
    assert lua.globals().lastInput == (executor.startswith('Matcha')), 'Matcha hover disables Roblox input and loses focus'
    if executor.startswith('Matcha'):
        lua.execute('State.Dialog={};State.GameInput=false;ApplyInputState(true);assert(lastInput)')
    lua.execute('State.Dialog=nil;State.Open=false;ApplyInputState(true);assert(lastInput)')
print('PASS: real clicks, synthetic holds/release grace/late releases/repress, both buttons, Matcha focus preserved, other-executor capture preserved')
a=src.index('function InsUi:IsInteracting(');b=src.index('\nend',a)+len('\nend')
lua.execute(src[a:b])
lua.execute('''
inside=false;IsMouseIn=function()return inside end
State={Open=true,RobloxFocused=true};assert(not InsUi:IsInteracting())
inside=true;assert(InsUi:IsInteracting());inside=false
State.Focus={};assert(InsUi:IsInteracting());State.Focus=nil
State.Dialog={};assert(InsUi:IsInteracting());State.Dialog=nil
State.Open=false;inside=true;assert(not InsUi:IsInteracting())
State.Open=true;State.RobloxFocused=false;assert(not InsUi:IsInteracting())
''')
print('PASS: scripts yield mouse input only while using menu/editor/modal, never outside window or another application')
