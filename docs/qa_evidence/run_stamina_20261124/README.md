# Toggle run and stamina — D review, 2026-11-24

Runtime directory: ae4pa-d-delivery-closeout. Branch work/member-D-run-stamina, based on main48c0b5c. Final player/lifecycle test code786a2542e8924bedbebb23a1617783300339bc88. Video and screenshots use3b1e99e code tree; later changes add the held-interaction toggle guard and new-game reset handling, no art/layout changes.

| Parameter | Value |
| --- | --- |
| Walk | Existing160px/s; no other speed bonus found |
| Run | 1.35× once,216px/s |
| Stamina | 0–100 |
| Drain | 100/3 per second of actual running movement |
| Recovery | 100/6 per second, after1 second without running |
| Exhaustion | Off at0; require30 before explicit re-enable |
| Input | toggle_run, left Shift; key comes from InputMap |

Player owns the shared session model; HUD listens to stamina_changed and does not integrate time. Static sharing preserves stamina across floor node replacement. Modal/interaction locks and non-playing states clear running; both drain and recovery freeze behind world input locks. No collision sizes, floor clamps, task durations, theft/work durations, doors, detection or camera were changed. Existing animation advances by real distance, naturally speeds up during running and keeps existing standing pose at rest.

A review: player observes task_updated AVAILABLE→ACTIVE to capture stamina at the current task acceptance boundary, and RESTORING to restore it. This is an adapter to the present checkpoint lifecycle; please include the payload in A's actual checkpoint/save transaction when that API is extended. Public capture_stamina_state()/restore_stamina_state(Dictionary) expose value/rest/exhausted; restore always clears running, missing old fields default to full/walk. Disk saves remain unimplemented upstream; no new disk state is claimed. New games are detected at LOADING with MENU/WON or reset task/manager-intro facts; ordinary legal stair travel preserves stamina.

## Actual results

Windows / Godot4.7.2.stable.official.ed1daf0bf / Compatibility NVIDIA RTX3070. APPDATA/LOCALAPPDATA isolated under hotel/outputs/run-user.

- Final run_stamina_smoke.gd -- --ui-smoke exit0: 30/60/120 delta drain/recovery, spam/threshold, old payload, modal freeze, echo and held interaction guard; actual Player._physics_process at each rate travels648px in3 seconds and exhausts; explicit floor rebuild preserves55, real task accept/failure/checkpoint restore restores acceptance value, new game refills100. Floor positioning is a disclosed API fixture, not legal stair traversal evidence.
- Import-final exit0 with isolated settings; no parse/missing-resource errors found. Initial import failed due mixed indentation and unwritable default editor settings; original log retained. Fixed before runtime validation.
- Existing foundation, staff_core, task_checkpoint and ui_test regressions exit0 on the original running implementation; later changes were restricted to toggle guard, new-game reset and added checks, with final focused test rerun.
- Actual main-scene graphical review CN1280×720 and EN960×540 exit0. Exhaustion continues walking, recovery does not restart, explicit Shift restarts in other direction, modal freezes recovery. Screenshots inspected; they are actual main scene with intro/manager completed via test fixture, not a human route or exported build.
- Non-recorded EN 1F480px probe: walk3.018s, run2.231s, gain0.787s (~26%). This is a straight corridor segment, NOT an eight-task route timing comparison. Recording wall-clock figures are distorted by encoding and are not gameplay timing evidence. Maximum extra distance per full burst is168px (~1.05 walking seconds); task timers unchanged.
- Full new-game regression with --ui-smoke exited1 while still in Floor1 and looking for Room202/ParcelCabinet2F. Existing clean a57fdeb baseline also exits1 at that stage. These remain FAIL, not PASS; no assertion disabled. Logs included.
- Initial lifecycle test exposed direct start_game not refilling; final786a254 fixes it and that check passes. Failure log retained.

## Evidence and remaining checks

run-cycle.avi: Godot Movie Maker,389frames/30fps (~12.97s), actual main fixture, scripted walking/running/exhaustion/recovery/restart. hud-zh.png and hud-en.png show scoped bottom-left160×10 bar without covering task/toolbar. No manual full-route claim.

Pending A review/manual acceptance: exact walls/stair-trigger approaches with running, physical left/right Shift/device testing, all task work/theft interactions while holding inputs, long task-route walk/run timing and difficulty sign-off, 309/CG real interruption and exported/cross-machine display. Task checkpoint API integration is reviewed above; full disk save/load is an upstream dependency. No merge authorized in this task.

## A 合并复测

任务接受时的体力现在随 GameManager 的任务检查点捕获，重试从对应检查点恢复。新局由 GameManager 明确补满，换层保留当前体力。磁盘读档可用独立的当前体力与检查点体力字段，不再依赖玩家侦听通用恢复状态。

macOS / Godot 4.7.2，`run_stamina_smoke.gd -- --ui-smoke` 输出 `RUN_STAMINA: PASS`，退出 0。覆盖 30／60／120 FPS、模态、跨层、接受与重试、新局。
