# D button, HUD and standing-pose fixes — 2026-11-23

Workspace: `ae4pa-d-delivery-closeout`, branch `work/member-D-ui-polish-v4`. Tested code tree: UI `1e817cc0e33e7f9263d49be9dc0914d583b99d1c`, including independent visual-only staff fix `e36e3cc`. Windows, Godot `4.7.2.stable.official.ed1daf0bf`, Compatibility, isolated user configuration.

## Causes and changes

- Cover StartButton minimum height was 56, OptionButton 42. Both now measure 280×56 at logical resolution with 14px separation. The native language popup and keyboard behavior remain; a mouse-ignoring centered caption reserves symmetric 32px side margins so the right arrow cannot displace the text.
- `button_motion.gd` scaled hovered/pressed/focused controls. It now restores unit scale and uses one cancellable 0.12s color tween. Hidden/disabled buttons restore normal color. Geometry never animates.
- Toolbar PNGs were limited to 16px and contained visual padding. Four original vector icons now render at 28px with 8px text separation and identical button minimum sizes. Source SVGs were drawn as part of this patch; no external font-symbol dependency.
- `main.gd` supplies the story notice and `hud.gd` displayed it above the separate task objective. Only duplicate story/target presentation is suppressed; warnings and source interfaces remain. TaskPlate is first in the stack at 24px. Empty interaction containers hide. The old decorative raster's incompatible nine-slice margins were replaced by a scalable brass outline with a stable center plate and 24/16px text padding; floor artwork retains its aspect-preserving texture.
- Shared `character_visual.gd` looped security/manager expression cells 6/7/8 as an idle cycle. Their ordinary standing pose now holds approved cell 6. Walk cells, cleaner work animation, turning/suspicious/caught poses, feet offsets, collisions, movement and interaction code remain unchanged. This one-line shared visual change is separate for A/B review.

## Evidence

- `before/cover.png`: previous committed UI polish cover. `before/user-toolbar.png` and `before/user-task-plate.png`: supplied user crops, not new captures.
- `zh1280/cover.png`, `hud.png`, `idle.png`: actual instantiated production `scenes/main.tscn`, Chinese 1280×720.
- `en960/cover.png`, `hud.png`, `idle.png`: same production scene, English 960×540.
- `idle_start_stop.avi`: actual Godot Movie Maker capture, 505 frames at 30FPS (16.8 seconds). Includes normal cover, explicit QA dialogue completion setup, stationary frames and mapped left/right movement with stops. Staff behavior runs normally. This is automated main-scene evidence, not a human new-game playthrough.

## Actual results

All final commands exited 0:

- Godot resource import.
- Graphical `--script res://scenes/tests/ui/button_idle_review.gd` (Chinese and `-- --english`): exact cover sizes/spacing, repeated hover/press geometry, duplicate target suppression, task safe margin, toolbar icon sizes, valid stationary security poses, player stop/last facing/speed. The movie run also used `--write-movie ... --fixed-fps 30`.
- Graphical existing `hud_layout_smoke.gd -- --after`: no-task, active, long text, completed and other existing HUD cases.
- Headless `foundation_smoke.gd`, `final_visual_integration_smoke.gd`, `localization_smoke.gd`, `ui_test.tscn -- --ui-smoke`.
- Headless existing `staff_core_smoke.tscn`, `cleaner_v4_smoke.tscn`.
- `git diff --check`.

Final stdout logs are under `logs/`. Initial failures are retained: staff Node scripts were initially invoked incorrectly with `--script` instead of their `.tscn` wrappers; localization initially used a profile already switched to English; first review incorrectly included actual staff walking in a stationary assertion and found an empty-container margin. Correct entry points, a fresh profile and a stationary-only assertion were used for the passing runs; gameplay assertions were not removed.

Screenshots were visually inspected for alignment, readable Chinese/English toolbar and absence of duplicate objective. The 16.8-second recording is provided for A/B to examine the face over time; this session did not perform physical-keyboard or exported-build acceptance. Underlying employee labels and patrol/turn behavior remain B's responsibility. No task, checkpoint, card or camera rules changed.
