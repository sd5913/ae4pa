# Approved checker idle redesign (2026-11-22)

- `approved_model.png`: approved standing model with lighter warm-brown hair outline.
- `hair_outline_edit_prompt.json`: built-in image_gen local edit instructions for the model.
- `frames.json`: original built-in image_gen animation prompt, frame regions, durations, alpha checks and original sheet SHA256.
- Runtime sheet: `assets/final/monster_idle/checker_idle_sheet.png` (1448x1086, 4x2 equal362x543 cells). Original PNG bytes copied without re-encoding.
- Runtime foot anchor494 aligns visible local shoe bottoms493/494. Preserve full cells and existing actor scale. The one-pixel frame-edge variation is retained; frames are not individually trimmed or rescaled.
- Inspection loop durations400/150/170/230/160/180/180/350ms. Restores the approved starting pose; pause/modal freezes and open/closed visibility use the existing adapter.

This change does not include the pending C audit PR65 or change door, task, input, movement or dialogue behavior.
