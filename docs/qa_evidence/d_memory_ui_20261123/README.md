# Memory UI review — 2026-11-23

This is D UI/session-history evidence. **Full disk saves, cross-process restore and the requested save → exit → restart → load video remain blocked by A's missing authoritative persistence implementation.** No test double or HTML sample is presented as a working game save.

## Code and environment

- Working directory: `C:\Users\lenovo\Documents\ChatGPT\hotel\ae4pa-d-delivery-closeout`.
- Delivery branch: `work/member-D-memory-ui-review`. Initial branch/HEAD `work/member-D-ui-polish-v4@e9ac69a`; previous local commits preserved. PR #64 was already merged, so this delivery does not overwrite its later remote head.
- Latest fetched main: `ac58302b29499a4243dd302876a8f24e84be013a`. Merge commit `a57fdeb78f24b363aeed07962bcdcfdcc6164a53` preserves A's retry/focus fix, all translations and both sides' progress/QA. No task, card or main-scene rules were edited.
- Final focused test code: `3f2972359338f00d427f8a9c2e0c606feffd300b`. Earlier merged integration regressions below ran at `a57fdeb`; later changes only affect memory focus, source speaker IDs, scoped font and the language button's flat property.
- Windows 11, Godot `4.7.2.stable.official.ed1daf0bf`, Compatibility / OpenGL 3.3, NVIDIA driver 546.92 / RTX 3070 Laptop. Console executable: `C:\Users\lenovo\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`.
- Separate APPDATA/LOCALAPPDATA under `hotel\outputs\memory_ui_user_20261123`; no user production save was overwritten. Clean tracked-files-only import used detached worktree `hotel\outputs\memory_ui_clean_a57fdeb`, no original untracked files copied or removed.

## Commands and actual results

Run the following with the installed console executable and `--path` set to the directory described above. Log files accompany this record under `logs/`.

| Check | Entry / arguments | Observed result |
| --- | --- | --- |
| Clean import, a57fdeb | `--headless --editor --import --quit` in clean worktree | Exit 0; no script/parse/missing-resource errors found. |
| Localization, a57fdeb | `--headless --script res://scenes/tests/core/localization_smoke.gd -- --ui-smoke` | Exit 0. Fresh isolated language settings. |
| Intro, a57fdeb | `--headless --script res://scenes/tests/core/intro_flow_smoke.gd -- --ui-smoke` | Exit 0. |
| Third card / bag, a57fdeb | `--headless --script res://scenes/tests/staff/third_card_bag_smoke.gd -- --ui-smoke` | Exit 0. |
| Checkpoint, a57fdeb | `--headless --script res://scenes/tests/core/task_checkpoint_smoke.gd -- --ui-smoke` | Exit 0, theft/work/hand-in rollback and failure/modal checks. |
| Theft, a57fdeb | `--headless res://scenes/tests/ui/theft_failure_smoke.tscn` | Exit 0, three roles retain configured checkpoint retry and single completion. |
| Existing UI, a57fdeb | `--headless res://scenes/tests/ui/ui_test.tscn -- --ui-smoke` | Exit 0; the standalone fixture intentionally has no retry provider. This does not imply main lacks its existing checkpoint API. |
| Story surfaces, a57fdeb | `--script res://scenes/tests/ui/story_surface_smoke.gd` in Compatibility window, **no `--ui-smoke`** | Exit 0, real notification/phone input, drag/echo/emulated pointer, 3 sizes and menu replay. |
| Carol teaching / timeout, a57fdeb | `--script res://scenes/tests/ui/narrative_ui_smoke.gd` in Compatibility window | Exit 0; real two-slot condition, delayed teaching, active/ready timeout lines, retry and cleanup. Public API/accelerated clock fixtures, not a human playthrough. |
| Memory UI, final code | `--script res://scenes/tests/ui/memory_ui_smoke.gd`; repeat with `-- --english`, `-- --large` | Compatibility windows: Chinese 1280×720, English 960×540, Chinese 1920×1080. All three exited 0; individual outputs recorded in final logs. |
| Whitespace | `git diff --check`, staged diff check | No whitespace errors at code commit. |

Final memory tests check: no invented backend; disabled cover load; source speaker mapping; actual rail GUI click; focus transferred into modal; raw physical Escape matching despite legacy device=16 mappings; underlying story unchanged; repeated refresh/language switches do not append history; six manual positions + independent automatic position; no manual auto-write; missing services cannot produce success or mutate cards; exact panel aspect; new-game session reset; invalid history payload preserves records.

## Failures retained, not reported as passes

- `initial-autoload-error.log`: initial independent memory test incorrectly preloaded an autoload-dependent UI from a SceneTree script; corrected the test to instantiate the real main scene dynamically.
- `story-surface-with-ui-smoke.log` / `story-surface-graphical-with-ui-smoke.log`: actual failed runs. The flag skips the phone animation/notification that this test explicitly waits for; the normal no-flag command passed without weakening assertions.
- `theft-wrong-script-entry.log`: launching a Node scene script through `--script` produced a GameManager compile error and was stopped (exit 1). Correct `.tscn` entry passed. No production code was changed to mask it.
- Desktop-injected Escape initially did not close the memory page. Found project InputMap keys pinned to keyboard device 16; D memory shortcuts now match configured key/modifiers across devices as existing StoryPointer does. Final raw-event regression is separate from physical keyboard acceptance. Project settings/A input rules were not changed.

## Graphical evidence and actual window operation

`zh1280/`, `en960/`, `zh1920/`: `cover.png`, `save.png`, `load.png`, `history.png`. These are real Compatibility renders of instantiated `scenes/main.tscn`, driven by the documented UI smoke. A current real SMS is opened; no HTML progress/cards are injected. They are not F6 standalone panel previews or export-build screenshots.

Inspected panel proportions, close/footer safe margins, readable Chinese sans-serif and English text, six slots, disabled backend actions and cover button surfaces. Only these locale/size pairs were checked; English 1280/1920 and Chinese 960 remain unverified.

Also launched normal `scenes/main.tscn` from the same work directory with **no test skip flags**. Computer-use mouse operation verified cover → vibration notification → history empty before reading → close leaves notification → open first SMS “你睡了吗?” → history contains exactly Terese/that SMS → close returns to that same SMS. Game window title observed: `Monster Hotel (DEBUG)`. The final keyboard-device fix was checked via Godot raw events; hardware keyboard confirmation remains pending.

## Pending, never marked complete

All real save/overwrite/write-failure/corrupt-file/autosave/full-world-load cases, offline timer restoration, card permissions after restart, 309/one follower/403/501/EXIT restore, A-owned 309 history events, and save/restart recording. Export and cross-machine checks were not run. Manual task routes/multiplayer timing from earlier QA remain pending.

See [A integration contract and field ownership](../../memory_ui_handoff_20261123.md). Full-state serialization is an A dependency; D UI does not substitute private task or card state.

QA log copies have trailing whitespace removed for Git hygiene; original unmodified logs remain under hotel/outputs/memory_ui_user_20261123. No result lines were removed.
