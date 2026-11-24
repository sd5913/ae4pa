# Memory Persistence Integration Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an authoritative, versioned disk save service and integrate D's memory UI with complete game-state capture, preflight validation, restoration, safe autosaves and 309 CG history.

**Architecture:** Add one A-owned MemoryService that stores JSON under `user://memory/`, validates all schema and module payloads before a world mutation, and delegates state truth to GameManager, CardManager, floor/work/door components and D UI payload APIs. Restore under a transaction lock, rebuild the authoritative floor, apply component state, normalize modals/CG/followers, and only return success after all restore steps succeed.

**Tech Stack:** Godot 4.7.2, GDScript, `FileAccess`, `DirAccess`, JSON, Godot headless smoke scripts and Compatibility-window/manual QA.

**Spec:** `docs/memory_ui_handoff_20261123.md`, `docs/qa_evidence/d_memory_ui_20261123/README.md`, current `docs/interfaces.md`, and the user request dated 2026-11-24.

## Global Constraints

- Use only `user://` for runtime memory files; support manual slot IDs `0..5` and automatic slot `-1`.
- Keep task retry checkpoints independent from disk memory.
- Do not mutate cards, complete tasks, or unlock EXIT through D UI.
- Validate the entire document before mutation; preserve corrupt and incompatible files.
- Resume the exact stored remaining timer and never count offline time.
- Keep PR #74 UI ownership and Chinese `1280x720` / English `960x540` layouts.

## Review Focus

- Invalid later fields must not partially mutate the active world; validate before clearing old scenes.
- Failed temp writes or replacements must retain the previous valid file and recoverable backup.
- Repeated load/CG/autosave callbacks must not duplicate followers, history beats, task settlements or EXIT.
- Stable autosave nodes exclude transition starts, failure rollback and CG intermediates.
- All current modal/input/timer states must be inert during restore and restored only after the world is coherent.

---

### Task 1: Inspect and freeze authoritative state contracts

**Files:** `scripts/game_manager.gd`, `scripts/card_manager.gd`, `scenes/levels/floor.gd`, `scenes/room309_reunion.gd`, `cg309_reunion/reunion_cg.gd`, `scenes/ui/memory_ui.gd`, `scenes/ui/memory_history.gd`, `scenes/ui/carol_ui_flow.gd`, `docs/interfaces.md`.

**Interfaces:** Consume existing module validation and restore APIs. Add narrow export/validate/restore methods only where an existing owner has truth and no current method provides the contract.

- [x] Inventory eight task step/delivery facts, timer, approvals/encounters/doors, card ownership/equipment/active slot, floor/player transform, 309 rescue/follower and EXIT, notes/playtime, D history/tutorial payloads.
- [x] Record real owners, APIs and any blocked B/C payload required; no UI-owned mirrors.
- [x] Review the full PR changes, including character standing pose, against mainline source and existing evidence.

### Task 2: Persistence codec and safe disk transaction

**Files:** Create `scripts/memory_service.gd`, `scenes/tests/core/memory_service_smoke.gd`; modify `project.godot` only if the runtime contract needs an autoload.

**Interfaces:** `list_memory_slots() -> Array[Dictionary]`, `can_save_memory() -> Dictionary`, `save_memory(slot_id: int) -> Dictionary`, `load_memory(slot_id: int) -> Dictionary`.

- [ ] Write failing smoke cases for six empty manual slots plus auto, version mismatch, malformed JSON, temp write failure, overwrite cancel, backup recovery and untouched corrupt/incompatible files.
- [ ] Run the smoke to prove these fail because the provider/transaction is missing.
- [ ] Implement schema/version/build metadata, JSON serialization, temp write/readback validation, backup+replacement and no-success-on-error semantics.
- [ ] Re-run the smoke and confirm exact disk contents and preserved backups.

### Task 3: Authoritative state capture and preflight restore

**Files:** `scripts/game_manager.gd`, `scripts/card_manager.gd`, `scenes/levels/floor.gd`, `scenes/room309_reunion.gd`, owner-local B/C state APIs as required, `scripts/memory_service.gd`, `scenes/tests/core/memory_restore_smoke.gd`.

- [ ] Write failing capture/validation/restore cases for dual cards/active identity, eight task states, remaining timer, work done but undelivered, approvals/encounters/doors, floor/safe position/facing, notes/tutorial/history, 309 before/after rescue, one Terese follower and true EXIT eligibility.
- [ ] Implement pure preflight validators first, then capture and restore using each module's true owner.
- [ ] Clear old floor/CG/input/modal/tweens before load; freeze actions until the rebuilt world and all local state are restored.
- [ ] Prove invalid data preserves current world and repeated loads preserve one-or-zero follower without re-settling rescue.

### Task 4: UI binding and stable autosave

**Files:** `scenes/main.gd`, `scenes/ui/main_menu.gd`, `scenes/ui/memory_ui.gd`, `scripts/memory_service.gd`, owner-local stable node signals, `scenes/tests/ui/memory_ui_smoke.gd`.

- [ ] Configure the real provider with `MenuLayer/MainMenu/MemoryUI.configure_backend(service)`.
- [ ] Keep actions disabled until valid backend slots and stable-node eligibility are returned; expose localized reasons and confirm overwrite.
- [ ] Add autosaves only after committed hand-in, accepted-task commit, finished floor load, and settled 309 rescue/follower creation; test no save on failure, rollback, transition-start or CG intermediate.
- [ ] Keep input/modal isolation and both requested locale layouts.

### Task 5: 309 history beat instrumentation

**Files:** `cg309_reunion/reunion_cg.gd`, `scenes/room309_reunion.gd`, `scenes/ui/memory_history.gd`, `scenes/tests/ui/reunion_309_smoke.gd`.

- [ ] Write a failing test for one history record per fully displayed beat with stable token, speaker, source key, interpolation values and chapter; partial/interrupted beats and replay must not duplicate records.
- [ ] Record display completion only; keep rescue settlement exclusively after the entire CG finished once.
- [ ] Run rescue and replay checks proving history-only viewing has no task progression side effects.

### Task 6: Cross-process acceptance and evidence

**Files:** `docs/qa_evidence/a_memory_persistence_20261124/`, `docs/progress.md`, `docs/interfaces.md`, A integration PR.

- [ ] Run automated native checks for slot/file failures, cards, timer, work/hand-in, 309, 403/501, EXIT and D payloads.
- [ ] Perform save → fully quit → restart → load on the actual local project; produce official screenshots and screen recording.
- [ ] Separate automated, manual/hardware, cross-machine and exported-build results; mark any unrun case blocked, never passed.
- [ ] Commit implementation and verification evidence, then open an A integration PR against `main` with dependency/order on #74; do not merge it.
