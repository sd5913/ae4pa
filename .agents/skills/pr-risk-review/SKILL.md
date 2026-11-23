---
name: pr-risk-review
description: Use when reviewing a pull request or change set for Godot-specific regressions, ownership boundaries, resource integrity, or integration risk.
---

# PR Risk Review

1. Establish the base and head SHAs, inspect the entire diff, and read relevant context around every changed path. Do not accept “generated noise” as a reason to skip files; inspect `.uid`, scenes, imports, presets, and project settings too.
2. Check changed paths against the ownership table in `AGENTS.md`. For cross-owner edits, trace the public interfaces in `docs/interfaces.md` and verify the change stays within the requested scope.
3. Trace affected behavior through caller, signal, state owner, and UI. For Godot changes, inspect input priority and release state, modal/focus restoration, task timer and checkpoint/snapshot rollback, scene/resource paths, UID references, localization keys, and whether tests cover success and failure paths.
4. Run or inspect the narrow relevant checks from `.github/workflows/godot-ci.yml` and `docs/qa.md`. A passing base-branch check does not validate the PR head. Treat headless results, visual evidence, and human acceptance as separate evidence.
5. If the installed `review` or `gstack-review` workflow applies, use it as an additional pass; still apply this project checklist.
6. Report only actionable findings, ordered by impact. Each finding includes severity, changed `file:line`, the affected behavior, and a concrete trigger or reproduction. If no finding is supported, state the inspected SHA range and any unverified areas rather than giving a blanket approval.

Review does not authorize edits, approval submission, merge, or release. Keep review comments focused on defects and material risks.
