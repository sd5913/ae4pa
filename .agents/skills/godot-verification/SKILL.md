---
name: godot-verification
description: Use when Godot scripts, scenes, resources, localization, or export settings change and you need to choose or report relevant verification.
---

# Godot Verification

1. Read `git status --short --branch`, identify the exact diff and target commit, and confirm the installed Godot version. Do not use a green base-branch run as evidence for changed code.
2. Import a clean checkout before running tests:

   ```sh
   godot --headless --path . --editor --import --quit
   ```

   Record import errors and the exact Godot build. Do not treat unrelated OS/editor diagnostics as game failures without checking their source.
3. Select checks from the changed behavior. The CI baseline is in `.github/workflows/godot-ci.yml`: `foundation_smoke.gd`, `task_checkpoint_smoke.gd`, `staff_core_smoke.tscn`, `work_items_smoke.tscn`, `known_monster_rules_smoke.gd`, `task_door_lifecycle_smoke.gd`, `localization_smoke.gd`, and `late_mainline_main_flow_smoke.gd -- --ui-smoke`. Follow that file for exact invocation syntax. Add the relevant focused UI or module check from `docs/qa.md`; do not run every smoke test by default.
4. If changes affect the full route or EXIT, run `full_mainline_escape_smoke.gd` separately and preserve its result. The current status records prior final EXIT assertion failures; do not remove or weaken that assertion to get a green run. A fixture-based late-mainline test does not prove a clean new-game playthrough.
5. Keep headless functional checks separate from Compatibility-window visual checks, Windows export checks, and human playtests. A pass in one category cannot stand in for another.
6. Report commit SHA, OS, Godot version, each command and exit code, fixture/precondition, log or screenshot location, known failures, and untested scope. Say “not verified” where evidence is missing.

Use `docs/qa.md#现行主线验收口径` for current routes and evidence categories, and update QA records only with results actually observed.
