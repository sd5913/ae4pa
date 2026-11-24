# PR #74 merge verification, 2026-11-24

Code: 481cd5c15aad150033ecfc86663b3c26c94d8716. Windows, Godot 4.7.2.stable.official.ed1daf0bf, headless; separate APPDATA/LOCALAPPDATA in hotel/outputs/pr74-merge-check-20261124. Main was ac58302. Only independent test code changed.

Commands: Godot --headless --path ae4pa-d-delivery-closeout --script res://scenes/tests/core/late_mainline_main_flow_smoke.gd -- --ui-smoke; repeat with --english. Both final runs exited 0. No fresh visual or human results are claimed.

- late.log: first attempt, teaching drain fixed; timeout flow not yet drained, multiple failures, exit1.
- late-fixed.log / late-fixed-en.log: teaching/timeout flow fixed; only old duplicate return501 notice expectation failed, exit1.
- late-final-zh.log / late-final-en.log: final code, both exit0.
- Original cloud failure: https://github.com/sd5913/ae4pa/actions/runs/45362472145 — missing Floor4Art because the actual teaching modal blocked stair travel. Seven other checks and import passed.

Final assertions read the real teaching/timeout through input before travel/retry; retry must be visible. The former duplicate-notice assertion now requires text and tooltip empty, while the existing live task-plate return501 assertion remains. Rules and production UI unchanged. Fixture-based earlier task/rescue state is disclosed; this is not a human new-game run or persistence test. Full save/restore remains absent.
