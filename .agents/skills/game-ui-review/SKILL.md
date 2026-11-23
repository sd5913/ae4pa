---
name: game-ui-review
description: Use when reviewing Godot game UI layout, readability, or input behavior in a rendered Compatibility window, especially after UI, localization, or viewport changes.
---

# Game UI Review

1. Use the project’s Godot 4.7.2 Compatibility renderer and the real `scenes/main.tscn` flow or a documented fixture. Record the commit, renderer, window size, locale, and fixture state before judging screenshots.
2. Check Chinese and English at 960×540, 1280×720, and 1920×1080. Include long dialogue and labels. Look for clipping, overlap, unreadable scaling, safe-area issues, and changes in alignment or hierarchy.
3. Exercise relevant states in the running window: open, typing, advance, choices, completion, modal focus, close, and return to gameplay. Verify keyboard and pointer input, focus order, and that text, input, HUD, and timer behavior restore correctly after closing.
4. Capture and inspect screenshots for each materially different locale, size, and state. Label evidence with commit, renderer, resolution, locale, and state; store useful evidence under the matching `docs/qa_evidence/` entry and note the exact fixture/preconditions.
5. A headless smoke can support functional behavior but cannot establish visual quality. If a size, locale, state, or actual rendered view was unavailable, list it as unverified and do not mark full visual QA complete.

Follow `docs/qa.md#现行主线验收口径` for current graphical review expectations. Keep rendering evidence distinct from automated smoke and human playthrough results.
