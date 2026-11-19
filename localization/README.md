# Localization

Game text uses the original Simplified Chinese strings as message IDs. Add English in [en.po](en.po) and preserve each format token, including width and precision. Translate whole templates before substituting values. Translate any named arguments separately at the display boundary. The prologue and manager conversation use the same catalog with the source text kept in [intro_script.tsv](../scenes/ui/intro_script.tsv). Speaker identifiers, task and card IDs, and game state stay in the source data.

Godot updates ordinary label and button text when the locale changes. Screens with composed text use the translation notification to refresh their display. `user://language.cfg` stores the locale separately from the story-read flag and task state.

The bundled `hotel_staff_cjk.otf` is a renamed Simplified Chinese subset of Noto Sans CJK SC Regular, derived from version 2.004. It supplements the engine font with the currently used CJK glyphs. When adding Chinese text, check glyph coverage and extend this subset if needed. Font copyright © 2014–2021 Adobe. [SIL Open Font License](../assets/final/fonts/ofl.txt). [Upstream font project](https://github.com/notofonts/noto-cjk).

## Art and current game scope

The title on the cover and in the prologue uses the original bilingual texture in Simplified Chinese and an English text treatment in English. Floor and room numbers, the existing `EXIT` sign in `assets/backgrounds/floor_5.png`, and decorative ledger/certificate marks use the original artwork. The dropdown shows both language names in their own language.

The playable story on this base ends at the Room 201 task. The catalog also covers the existing later-task names, the Room 309 dialogue and rescue placeholder, and the standalone victory screen. The non-201 encounter follow-ups, Room 309 rescue, and exit sequence still need gameplay integration.

## Smoke test

Use an isolated Godot user-data directory or a clean profile. Import the project first. The first invocation checks defaults, translations, and retained story and task state. Subsequent invocations check saved preferences across real process restarts.

```sh
godot --headless --path . --editor --import
godot --headless --path . --script res://scenes/tests/core/localization_smoke.gd -- --write-english
godot --headless --path . --script res://scenes/tests/core/localization_smoke.gd -- --expect-english
godot --headless --path . --script res://scenes/tests/core/localization_smoke.gd -- --set-chinese
godot --headless --path . --script res://scenes/tests/core/localization_smoke.gd -- --expect-chinese
```
