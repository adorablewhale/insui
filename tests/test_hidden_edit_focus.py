"""Reproduce closing an editor and losing menu/feature hotkeys using actual source."""
from pathlib import Path
import os
from lupa import LuaRuntime
source=Path(os.environ.get('INSUI_INPUT_SOURCE',Path(__file__).resolve().parents[1]/'insui.lua')).read_text(encoding='utf-8-sig')
lua=LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
State={Open=true,Focus={Kind='Slider',Value=1.5,Typing='2.0',Anchor=1},Capture={Listening=true,Value='v'},RepeatKey={},Tabs={}}
InsUi={};Fix={};callbacks=0
ReleaseDrags=function()State.Drag=nil;State.TextDrag=nil end
Keys={p={Click=true},v={Click=true}};State.MenuKey='p';State.RobloxFocused=true
RowLocked=function()return false end
SplitCombo=function(v)return nil,Keys[v] end
''')
if 'function Fix.ClearEditing()' in source:
    a=source.index('function Fix.ClearEditing()')
    b=source.index('local function ReadKeys()',a)
    lua.execute(source[a:b])
def method(name):
    a=source.index('function InsUi:'+name+'(')
    b=source.index('\nend',a)+len('\nend')
    return source[a:b]
lua.execute(method('SetOpen'))
lua.execute('oldFocus=State.Focus;oldCapture=State.Capture;InsUi:SetOpen(false)')
assert lua.globals().State.Focus is None,'closed slider still owns typing focus and blocks the menu key'
assert lua.globals().State.Capture is None and lua.globals().oldCapture.Listening is False
assert lua.globals().oldFocus.Value==1.5 and lua.globals().oldFocus.Typing is None
lua.execute(r'''
State.Focus={Kind='Textbox',Value='keep'};State.Capture={Listening=true,Value='v'}
Fix.RepairHiddenInput()
assert(State.Focus==nil and State.Capture==nil)
State.Open=true;State.Focus={Kind='Textbox',Value='active'}
InsUi:SetOpen(true);assert(State.Focus.Value=='active','an open active editor must keep its focus')
State.Open=false;State.SpotlightOpen=true;State.Focus={Kind='Textbox',Value='search'}
Fix.RepairHiddenInput();InsUi:SetOpen(false);assert(State.Focus.Value=='search')
State.SpotlightOpen=false;State.Dialog={};State.Focus={Kind='Textbox',Value='modal'}
Fix.RepairHiddenInput();InsUi:SetOpen(false);assert(State.Focus.Value=='modal')
State.Dialog=nil;Fix.RepairHiddenInput()
''')
a=source.index('    local MenuKey = Keys[State.MenuKey]')
b=source.index('    local Editing = State.Focus',a)
lua.execute(source[a:b])
assert lua.globals().State.Open is True,'menu press must open after an orphaned edit'
a=source.index('local function RunKeybinds()');b=source.index('\n\n\n',a)
lua.execute(source[a:b].replace('local function RunKeybinds()','function RunKeybinds()',1))
lua.execute(r'''
row={Value=false,Bind={Value='v',Mode='Toggle'},Callback=function(v)callbacks=callbacks+1;lastValue=v end}
State.Tabs={{Sections={{Rows={row}}}}}
RunKeybinds();assert(row.Value and callbacks==1,'feature toggle must receive the key after focus repair')
State.Focus={Kind='Textbox',Value='active'};RunKeybinds()
assert(callbacks==1,'typing in an open editor still blocks game hotkeys')
''')
assert 'ReadKeys()\n    Fix.RepairHiddenInput()' in source,'repair must run before key handling'
assert 'then Fix.SetOpen(false) Input.Click = false end' in source,'close button uses shared cleanup'
assert 'function InsUi:Toggle()\n  Fix.SetOpen(not State.Open)' in source
print('PASS: close/hide cancels orphaned edit/capture, pending slider value preserved, hidden recovery, menu/feature keys restored, active editors/modal/search protected')
