# D → A: Memory UI integration, 2026-11-23

This delivery implements the UI and session dialogue history. **It does not implement disk saves or full-state restore.** No complete save service exists in this code baseline; the UI explicitly disables save/load and displays that dependency. The six slots are UI positions, not evidence that disk files were scanned. No HTML example progress was imported.

## Runtime entry and ownership

- Start `scenes/main.tscn` in `ae4pa-d-delivery-closeout`. Cover order: Start / Load Memory / Language. Load remains disabled until an authoritative service reports a valid record.
- `MenuLayer/MainMenu/MemoryUI` is created by `main_menu.gd`. Dialogue rail: Load / Save / History, with supplied SVG icons. Pause has the three text-only entries. Floor selection does not show them.
- `scenes/ui/memory_ui.gd`: view, confirmation and request adapter. Its `MEMORY_UI` modal is separate from story/pause/task modals. Closing releases only its own modal and restores prior focus. Pages consume world shortcuts and underlying D dialogue handlers do not advance while the page is open.
- `scenes/ui/memory_history.gd`: displayed-line session history, source translation text/key, speaker, chapter and interpolation parameters. `export_ui_history()` / `restore_ui_history(Dictionary) -> bool` are D payload APIs for A's transaction, not file persistence.
- `scenes/ui/carol_ui_flow.gd`: `capture_memory_ui_state()` / `restore_memory_ui_state(Dictionary) -> bool`, version 1, `tutorial_seen`. Restore only while its presentation is closed. Preserve the existing lifecycle for new game and checkpoint retries.
- `scenes/interaction_onboarding.gd`: only the old exact two-equipped-slots rectangle branch was removed. Card observation, other errors and hints remain. The real 2/2 Carol dialogue remains in `carol_ui_flow.gd`. A should review this minimal cross-owner presentation change.

## Proposed provider contract for A review

These names are **new adapter expectations**, not existing GameManager methods. A may implement a persistence service node and attach it once the runtime is ready:

```gdscript
var memory = main.get_node("MenuLayer/MainMenu/MemoryUI")
memory.configure_backend(persistence_service)
```

| Method | Result / responsibility |
| --- | --- |
| `list_memory_slots() -> Array[Dictionary]` | Real validated on-disk metadata; no world mutation. `slot_id`: 0–5 manual, -1 automatic. `status`: `VALID`, `EMPTY`, `CORRUPT` or `INCOMPATIBLE`. |
| `can_save_memory() -> Dictionary` | `{allowed: bool, reason: translation_key}`; authoritative stable-node eligibility. D additionally blocks visible standard story surfaces. |
| `save_memory(slot_id: int) -> Dictionary` | `{ok: bool, error: translation_key}` only after atomic persistence succeeded. Reject -1 from manual requests. |
| `load_memory(slot_id: int) -> Dictionary` | `{ok: bool, error: translation_key}` only after complete validation and authoritative restore; preserve the current game on preflight errors. |

Valid metadata: `saved_at` (real timestamp), `location` (localized floor/room summary), `task_name` (source translation key), `play_time` (real in-game duration), `has_friend` (settled rescue/companion fact). The current project has no authoritative elapsed-playtime API; A must supply one rather than infer it from wall time. Thumbnail is optional: this UI uses the supplied common panel and text slots without fabricated screenshots.

Cover availability is refreshed from the provider. The provider must revalidate the requested slot before executing; metadata and eligibility may have changed since opening the page. Do not expose raw Node/Resource objects in serialized data. UI calls are synchronous request/result in this proposal; if A needs asynchronous I/O, add an explicit busy/result handshake and block duplicate requests before enabling the provider.

## Required full-state transaction (A, with B/C)

| Owner | Persisted facts / restore obligation |
| --- | --- |
| A | Schema/build compatibility, safe restore node, floor, safe player position and facing, all eight tasks and distinct work/hand-in steps, remaining seconds, completed/approved/encounter flags, mainline/EXIT eligibility, notebook clues, elapsed active time, global-read vs session-history semantics. |
| B | Card collection, both equipment slots, active identity using existing validated CardManager snapshot; employee theft state, work-point state and stable IDs. UI cards must match actual permissions. |
| C + A | Door lifecycle and approved/completed states synchronized from authoritative task/world facts. No room-number guessing. |
| A (309) | Rescue only after the full CG settles; Terese following restored once, never a duplicate follower. Reject saves mid-CG unless A implements a legal resumable node without repeated callbacks. |
| D | Session history plus tutorial-seen payload; no task/card/follower truth stored independently. |

Suggested order: validate the entire document/version and B/C payloads first → freeze through the existing restore/modal lifecycle → clear old CG/input/Tweens and old world objects → restore A task/world + B card data → rebuild the floor and apply B/C local state → establish safe player transform → spawn zero or one follower from settled A facts → restore D/read/notebook data → resume only legal timers and release restore locks. A must coordinate page closure and cover/pause/old-story modals so load cannot resume an obsolete presentation. Failed validation must not destroy the current world.

Use a separate `user://` memory directory, temporary-file write + validation + replacement and a recoverable previous backup. Keep checkpoint retry separate. Do not delete corrupt/incompatible user records automatically. Restore remaining seconds exactly; neither reset the timer nor deduct offline wall time.

Automatic slot: A alone writes after a fully committed accepted task, successful hand-in, completed floor load, or completed 309 rescue with follower established. Generic `task_updated` and transition-start signals are not sufficient stable nodes. Never autosave failure, rollback or CG intermediates.

## Dialogue-history integration still needed from A

D currently records displayed standard story/SMS, task dialogue, non-preview monster dialogue, Carol tutorial/timeout and theft presentation. Rerender, filtering, language switches and opening history do not unlock or append unread content. Source text is translated again on viewing; callers must provide original source keys and parameters, not already translated English.

The A-owned full-screen 309 CG is **not instrumented** in this delivery. Please emit a once-per-displayed-complete-beat event with stable token, speaker ID, source key, interpolation parameters and chapter, then call `MemoryHistory.record(...)`. Likewise ensure A's restart-from-success entry clears the session and restore uses the saved session rather than calling the new-game reset. D did not modify rescue/follower settlement or main-scene routing.

## Acceptance outstanding

- Actual empty-slot write → fully terminate process → restart → valid load: **blocked by missing A service, not executed, not passed**.
- Both card combinations and active card, mid-task timer, completed-work/unsubmitted state, pre/post-309 single follower, 403/501 hand-in and true EXIT: same blocker.
- Atomic overwrite cancellation/confirmation, write failure + backup, corrupt/incompatible slots, new game preserving files, authoritative autosave nodes and old-world cleanup: require A implementation and end-to-end tests.
- Physical keyboard/mouse acceptance, cross-machine/export and real save/restart video remain pending. UI automation/screenshots do not replace these.

Keep this PR as review/integration work until the above backend contract is agreed and implemented. Do not label full saves complete based on the three rendered pages.
