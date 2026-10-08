"""Execute the real notifier with controlled menu state and async downloads."""
from pathlib import Path
import os
from lupa import LuaRuntime
source = Path(os.environ.get('INSUI_UPDATE_SOURCE', Path(__file__).resolve().parents[1] / 'insui.lua')).read_text(encoding='utf-8-sig')
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r"""
clock=1000
os={clock=function()return clock end,time=function()return 10000 end}
State={Open=false,RobloxFocused=true}
Fix={CloudOrigin='fixture',AutoexecFile='fixture',Helpers={FischHub={version='2.7.0'}}}
Fix.HelperRead=function()return {scripts={FischHub={url='fixture-script'}}}end
queued={};task={spawn=function(f)table.insert(queued,f)end}
flush=function()local jobs=queued;queued={};for _,f in ipairs(jobs)do f()end end
fetches=0;notifications=0;dialogs=0;reloads=0
InsUi={Version='j5cks-2.0.0',Notify=function()notifications=notifications+1 end,
Dialog=function(_,d)dialogs=dialogs+1;State.Dialog=d end}
game={HttpGet=function(_,url)fetches=fetches+1;return url end}
HttpService={JSONDecode=function()return {published=100,scripts={FischHub={version='2.7.1'}}}end}
loadstring=function()return function()reloads=reloads+1 end end
""")
a=source.index('Fix.UpdateNext,');b=source.index('-- tab: put the section',a)
lua.execute(source[a:b])
lua.execute(r"""
clock=2000;Fix.UpdateStep();flush()
assert(not State.Dialog and notifications==0,'closed menu update must not interrupt a macro')
assert(not Fix.UpdateSeen['FischHub@2.7.1'],'queued update must not be consumed while hidden')
assert(fetches==1 and reloads==0)
State.Open=true;State.Rolled=true;Fix.UpdateStep();assert(dialogs==0,'minimized menu must stay quiet')
State.Rolled=false;State.RobloxFocused=false;Fix.UpdateStep();assert(dialogs==0,'unfocused menu must stay quiet')
State.RobloxFocused=true;State.Dialog={other=true};Fix.UpdateStep();assert(State.Dialog.other,'preserve other dialogs')
State.Dialog=nil;State.Focus={};Fix.UpdateStep();assert(dialogs==0,'wait for the active editor')
State.Focus=nil;Fix.UpdateStep();assert(dialogs==1 and State.Dialog.UpdateNotice,'show pending on opening without waiting for the next network poll')
assert(Fix.UpdateSeen['FischHub@2.7.1'] and notifications==0 and reloads==0)
State.Open=false;Fix.UpdateStep();assert(not State.Dialog,'closing the menu must dismiss its update dialog')
State.Open=true;Fix.UpdateOffer('FischHub','2.7.1','2.7.0','fixture-script');Fix.UpdateStep();assert(dialogs==1,'one offer per version')
-- A request may finish after the user has already closed the menu.
clock=3000;Fix.UpdateNext=0;HttpService.JSONDecode=function()return {scripts={FischHub={version='2.7.2'}}}end
Fix.UpdateStep();State.Open=false;flush();assert(not State.Dialog and notifications==0)
State.Open=true;Fix.UpdateStep();assert(dialogs==2 and reloads==0)
State.Dialog.onConfirm();flush();assert(reloads==1,'only the explicit reload button executes an update')
State.Dialog=nil;Fix.UpdateOffer('INSUI','2.0.1','2.0.0',nil);Fix.UpdateStep()
assert(State.Dialog and State.Dialog.text:find('reinject'),'no-url updates still explain reinjection')
State.Dialog=nil;State.Open=false;Fix.UpdateOffer('FischHub','2.7.3','2.7.0','fixture-script')
Fix.UpdateOffer('FischHub','2.7.4','2.7.0','fixture-script');State.Open=true;Fix.UpdateStep()
assert(State.Dialog.text:find('2.7.4'),'only keep the latest pending offer for a script')
""")
print('PASS: closed/rolled/unfocused silence, delayed request race, pending delivery, duplicate suppression, editor/modal protection, explicit reload, no-url notice')
