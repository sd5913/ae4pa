# Confirmed dialogue portraits — 2026-11-26

Code: `3daaa314976eb4343e327470aa176357e407bf3d`, based on
`main@230521d96d9d97eb05f1ab142eaa48650f6471c3` (approved source archive PR #80).
The tests below ran on the same code/assets before the code commit; this evidence
and handoff are a separate documentation commit. Source hashes: 27/27 match the
archive manifest. New texture import descriptors: 37/37 have matching source paths
and distinct UIDs. No unrelated existing untracked imports were staged.

Windows, Godot `4.7.2.stable.official.ed1daf0bf`, Compatibility/OpenGL 3.3,
NVIDIA GeForce RTX 3070 Laptop GPU. Local evidence was collected across midnight
November 25–26, Asia/Shanghai. APPDATA was isolated under the task work directory;
engine logs used explicit absolute paths.

## Results and reproduction

Run from the repository root, using Godot 4.7.2. Replace `godot` with the local
console executable. Supply an absolute `--log-file` path if the default user data
folder is not writable.

| Command | Exit | Evidence |
| --- | --- | --- |
| `godot --headless --path . --editor --import --quit` | 0 | [Import log](portrait_final_import.log) |
| `godot --headless --path . --script res://scenes/tests/ui/confirmed_portraits_smoke.gd` | 0 | [Portrait mapping / formal scene](confirmed_portraits_smoke_final.log) |
| `godot --headless --path . --script res://scenes/tests/ui/story_surface_smoke.gd` | 0 | [Story surfaces](story_surface_smoke_final.log) |
| `godot --headless --path . --script res://scenes/tests/core/intro_flow_smoke.gd` | 0 | [Actual intro / manager flow](intro_flow_smoke_final.log) |
| `godot --headless --path . --script res://scenes/tests/core/localization_smoke.gd` | 0 | [Localization](localization_smoke_final.log) |
| `godot --path . --script res://scenes/tests/ui/confirmed_portraits_review.gd` | 0 | [Rendered fixture, 60 captures](portrait_final_visual.log) |

The import log contains an editor safe-save diagnostic before scanning, with exit
0 and completed asset import. Final runtime tests and the final graphical run have
no engine errors. This editor diagnostic is recorded, not represented as a clean
editor-settings save or as a game failure.

The functional checks verify all 10 textures, Carol aliases, manager neutral
fallback for every expression, 16 approved Terese cafe assignments (4/4/6/2), and
actual texture selection inside the formal main scene. Existing story/intro checks
exercise normal cover opening, phone gestures, dialogue advancement, manager E,
input isolation, completion, replay skip, return to menu and cleanup. No task,
timer, checkpoint, scene movement or save rules changed.

## Rendered fixture and inspected screenshots

The graphical fixture instantiates `scenes/main.tscn`, hides its menu, starts the
real dialogue component, and injects one clearly documented cafe dialogue beat
per expression. Every beat uses the same long, translated Terese line to stress
text wrapping; manager/Carol speaking this line in the fixture is not a story edit.
It captures all 10 portraits in zh_CN/en at 960×540, 1280×720 and 1920×1080.
For each capture it asserts visible portrait, exact approved texture and bounds
inside the dialogue control. `AE4PA_PORTRAIT_EVIDENCE` can select an absolute output
folder; otherwise the fixture writes under `user://confirmed_portraits_review`.

All 60 captures were generated; six representative full screenshots are retained:

- [Chinese 960, Carol smile](zh_CN_960x540_carol_smile.png)
- [Chinese 1280, Carol thinking](zh_CN_1280x720_carol_thinking.png)
- [Chinese 1920, Terese teasing](zh_CN_1920x1080_terese_teasing.png)
- [English 960, Terese playful](en_960x540_terese_playful.png)
- [English 1280, Terese playful](en_1280x720_terese_playful.png)
- [English 1920, manager neutral](en_1920x1080_manager_neutral.png)

These views and the ten-expression crop comparison were inspected for transparency,
baseline, clipping, portrait/text overlap and long-line readability. Playful Terese
was adjusted from a shorter supplied source crop to the shared bottom baseline.
The original images remain byte-for-byte intact in the approved archive.

## Earlier failed attempts and limits

[Initial visual fixture log](initial_visual_fixture_failed.log) reported 20 bounds
failures; its untyped Array setter had not replaced the typed beat list and its
bounds compared unlike coordinate spaces. It showed SMS instead of portraits.
The fixture now assigns into the typed array, checks visible/exact textures and
compares control bounds; the final 60-state run passed. The initial run is not
counted as visual validation.

[Initial story invocation](initial_story_invocation_failed.log) used `--ui-smoke`,
which bypassed the normal phone opening expected by that test and failed six
assertions. Running its normal invocation without that flag passed. The failed
attempts are preserved separately from the final logs.

No physical keyboard/mouse human playthrough, exported build, macOS run, or new
chibi animation integration was performed. The rendered fixture and automated
interaction tests are not a claim of human acceptance or complete game QA.

## Integration with newer main (same date)

While PR #81 was being opened, main advanced to `4d86f95` via PRs #73 and #79.
Merge code `000940b6c53eb3b93dec1eacf5de5dddc4516b0d` retains their onboarding,
world chibi animation, avatars, cover and CG updates. The overlapping dialogue
selection uses the user's confirmed Carol/Terese images and manager neutral.
`DialogueRoles.portrait("CAROL")` also resolves the confirmed portrait.

Repeated import (exit 0, same editor safe-save diagnostic), all four focused
functional tests (exit 0), and the new main's character_art_v2 test (exit 0).
Repeated the 60-state Compatibility fixture without focus, positioned offscreen
so it did not interrupt the user's separately running main game. Exit 0.
These tests verify the merge code above, not just the original implementation.

Logs: [import](portrait_merge_import.log), [mapping](confirmed_portraits_smoke_merge.log),
[story](story_surface_smoke_merge.log), [intro](intro_flow_smoke_merge.log),
[localization](localization_smoke_merge.log), [existing character integration](character_art_v2_smoke_merge.log),
[60 rendered states](portrait_merge_visual.log).

Representative captures from the merged code:
[zh 960](merged_zh_CN_960x540_carol_smile.png),
[zh 1280](merged_zh_CN_1280x720_carol_thinking.png),
[zh 1920](merged_zh_CN_1920x1080_terese_teasing.png),
[en 960](merged_en_960x540_terese_playful.png),
[en 1280](merged_en_1280x720_terese_playful.png),
[en 1920](merged_en_1920x1080_manager_neutral.png).
The prior screenshot evidence and failed fixture attempts remain preserved.

## Final integration with main@4e6405a

Main also merged PR #76 while this PR was open. Code `3563072f82340c30f111446bcd36047f78c15c4a`
retains the new persistence integration, dialogue cancellation and tween cleanup;
the only merge conflict was appended progress documentation, with both entries
preserved. No confirmed portrait selection or canvas changed.

[Import](portrait_memory_import.log) exits 0, with the same editor-settings diagnostic.
[Portraits](confirmed_portraits_smoke_memory.log), [story surfaces](story_surface_smoke_memory.log),
[intro flow](intro_flow_smoke_memory.log), and [localization](localization_smoke_memory.log)
all exit 0 on this code. [Memory UI in Compatibility](memory_ui_portraits_graphical.log)
also exits 0. Its first [headless attempt](memory_ui_smoke_memory.log) was stopped:
that fixture waits for frame_post_draw and requires a renderer. This stopped
invocation is not a game regression or a passing test.

The final [60-state Compatibility portrait fixture](portrait_memory_visual.log)
exits 0. It runs without focus and offscreen; the user's game remains on its
separate main@4d86f95 checkout. Latest Terese evidence:
[neutral, Chinese 1280](latest_terese_neutral_zh1280.png),
[playful, English 960](latest_terese_playful_en960.png).
The approved four original Terese images remain the sources, as the user
reaffirmed during testing. The earlier scope limits continue to apply.
