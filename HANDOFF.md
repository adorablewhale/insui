# insui 2.0 remake - 2026-10-08 (local, unpublished)

owner asked for the menu remade around fischhub's features in the website style (mockup: claude.ai/artifact/KnkS8d251WzRUmhxwenSy8, owner approved it). approach chosen by the owner: same library and API, new look. j5cks-2.0.0 is in insui.lua and C:/matcha/workspace/INSUI/insui.lua (local copy wins over github by version). details in PATCHES.md. backup of 1.4.9: git HEAD. NOT pushed: main is what every public FischHub/TiltLine user downloads, so publishing needs the owner's go. the owner's own config was reset to legacy once (backup INSUI/FischHub/fischhub.pre2.json) because an early test saved the old purple look under skin 2.

# menu focus and mouse hotfix - 2026-10-07

INSUI j5cks-1.4.9 supersedes the 1.4.8 keyboard fix below. Matcha's setrobloxinput(false) on menu hover caused in-game focus/AFK loss and the library then discarded its own clicks. Matcha now keeps Roblox input enabled, while real foreground guards remain in place. other executors retain the existing capture policy. IsInteracting() lets Fisch pause simulated casting/shaking and both reel buttons while the cursor/editor/popup is using the menu; real foreground focus stays intact. an open menu viewed from outside its window does not count as interaction (existing mouse-cast open-menu guard remains). synthetic releases use a polled grace deadline plus physical-up sample; Fisch reports release immediately rather than relying on task.delay. no input is sent to unfocused applications.

live: owner confirmed clicks work; actual mouse pulses changed tabs and toggled reel speed off/on, restored original true/x3.4; input true, isrbxactive true, AFK child absent. P/menu and V previously verified for the included 1.4.8 orphan-editor fix. actual-source tests cover release tail/late release/both buttons/repress, menu interaction, held dual-reel pause/resume, lost focus/owed release and hidden editor repair; old library fails release-tail case. official compile passes, 193 INSUI / 166 Fisch top-level locals. no purchases or teleports used. Matcha global input cannot selectively consume a menu click while keeping game focus: the input pass-through policy is intentional; automation yields via IsInteracting. beta2.6.5-beta.2 uses this exact reviewed dependency. loader recovery remains separate/unpublished.

# insui 1.4.8 input hotfix - 2026-10-07

live user bug: menu closed with State.Focus still the reel-speed Slider, suppressing P/menu and every feature bind. clearing it immediately restored P. source close/minimize/Toggle/SetOpen cleanup plus per-frame orphan repair now cancel hidden edits/captures while preserving active modal/spotlight editors. test_hidden_edit_focus.py fails original1.4.7 and passes fix; overlay/loader suites still pass, compile/193locals. patched live library reproduced stale-slider close: focus/Typing cleared, Value preserved; P opens after initial controller calibration; V started auto fish then Stop restored off. rollout: public INSUI1.4.8 and private beta2.6.5-beta.2 matching library. loader.lua recovery remains local/unpublished. older checkpoints below are historical.

# insui local checkpoint - 2026-10-07

- local j5cks-1.4.7: validated dragged keybind overlay position in PackConfig/ApplyConfig; legacy/malformed input ignored, drag cancelled on load. actual-source regression fails old copy and passes new; isolated live save/load round-trip passed. original config restored. post-reload saved config also restored 430,620/hidden and original config restored; visual drag check pending. source/runtime copies match; compile/193 locals pass.
- loader sources (this repo and kit Matcha/loader) match: disabled autoexec has actionable gear message, MatchaLoader.Run() one-session recovery and Enable() preserving saved scripts. eight source scenarios pass; existing disabled choice respected. real restart/root trigger not verified. installed candidate C:/matcha/autoexec/insui_loader.lua (directory previously empty); two live runs chose local Fisch2.6.5/INSUI1.4.7 and finished. actual game restart remains unverified. no public release; current public1.4.6.
- owner authorized graph refresh; local new work supersedes historical candidate references below. Fisch feature continuation: HANDOFF_FEATURES_2026-10-07.md.

# insui handoff - 2026-10-06

- j5cks-1.4.6 published at 1480449; anonymous public bytes match the release commit.
- normal cloud sync 60 seconds; watched sync remains 5 seconds. quiet deferral stays
  capped at 45 seconds (normal maximum gap 105 seconds plus network time).
- tests/test_cloud_cadence.lua is an isolated Matcha scheduler regression, no network
  or consent writes. new code passes, old code fails. compile and 193 locals pass.
- candidate copied to C:/matcha/workspace/INSUI/insui.lua and loaded by FischHub
  2.6.3 in the live game. online (60-second sync), auto fish off.
- website migration 0013 and INSUI-only version notice deployed, Worker
  bcc3056f-577b-438e-a39b-3051e2722c69. FischHub public version stays 2.6.2.
  direct D1 metadata confirms one heartbeat write instead of two; live sessions recovered.
- context: website hit D1's 100k daily write limit; direct API returned 7500 and
  normal live reporting resumed at 00:00 UTC (7 pm Chicago, Oct 6). see the kit's
  HANDOFF_V2.md. graph is stale; refresh only on owner approval.
