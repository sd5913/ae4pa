# Localization

Game text uses the original Simplified Chinese strings as message IDs. Add English in [en.po](en.po) and preserve each format token, including width and precision. Translate whole templates before substituting values. Translate any named arguments separately at the display boundary. The prologue and manager conversation use the same catalog with the source text kept in [intro_script.tsv](../scenes/ui/intro_script.tsv). Speaker identifiers, task and card IDs, and game state stay in the source data.

Godot updates ordinary label and button text when the locale changes. Screens with composed text use the translation notification to refresh their display. `user://language.cfg` stores the locale separately from the story-read flag and task state.

The bundled `hotel_staff_cjk.otf` is a renamed Simplified Chinese subset of Noto Sans CJK SC Regular, derived from version 2.004. It supplements the engine font with the currently used CJK glyphs. The 202 integration extends the original 580-codepoint subset to 582 by adding 柜 (U+67DC) and 带 (U+5E26); all original codepoints and horizontal metrics are retained. When adding Chinese text, check glyph coverage and extend this subset if needed. Font copyright © 2014–2021 Adobe. [SIL Open Font License](../assets/final/fonts/ofl.txt). [Upstream font project](https://github.com/notofonts/noto-cjk).

## Art and current game scope

The title on the cover and in the prologue uses the original bilingual texture in Simplified Chinese and an English text treatment in English. Floor and room numbers, the existing `EXIT` sign in `assets/backgrounds/floor_5.png`, and decorative ledger/certificate marks use the original artwork. The dropdown shows both language names in their own language.

The current A integration includes the Room 201 cleaning task and Room 202 parcel task, ending at the 3F entrance. The catalog also covers the existing later-task names, the Room 309 dialogue and rescue placeholder, and the standalone victory screen. The full five-monster tutorial, later encounter follow-ups, Room 309 rescue, and exit sequence still need gameplay integration.

The added glyphs use the same [official Sans 2.004 source](https://raw.githubusercontent.com/notofonts/noto-cjk/Sans2.004/Sans/OTF/SimplifiedChinese/NotoSansCJKsc-Regular.otf), SHA-256 `2c76254f6fc379fddfce0a7e84fb5385bb135d3e399294f6eeb6680d0365b74b`. The subset retains the existing Hotel Staff CJK naming and OFL notice. FontTools was used only as a temporary build tool; it is not a runtime dependency.

## Smoke test

Use an isolated Godot user-data directory or a clean profile. Import the project first. For an isolated project copy, set `application/config/use_custom_user_dir=true` and `application/config/custom_user_dir_name` to a unique test profile name. Do not change the production project settings or run persistence tests against a player profile. On macOS, that separate profile still needs write access under Application Support. The first invocation checks defaults, translations, and retained story and task state. Subsequent invocations check saved preferences across real process restarts.

```sh
godot --headless --path . --editor --import
godot --headless --path . --script res://scenes/tests/core/localization_smoke.gd -- --write-english
godot --headless --path . --script res://scenes/tests/core/localization_smoke.gd -- --expect-english
godot --headless --path . --script res://scenes/tests/core/localization_smoke.gd -- --set-chinese
godot --headless --path . --script res://scenes/tests/core/localization_smoke.gd -- --expect-chinese
godot --headless --path . --script res://scenes/tests/core/task_02_localization_smoke.gd
```

The 202 test uses explicit 201 completion and direct-dialogue fixtures, then the real task/UI APIs. It checks translated dialogue, an open offer, current/standby Security guidance, parcel return, timeout/retry and completion; locale changes must preserve task state, clock, checkpoint, cards and dialogue position. It also checks bundled Chinese glyph coverage. This does not replace human route, real-time timeout, layout or platform acceptance.

Task03 adds manager-approval dialogue and feedback using the same catalog. The font subset is now584 codepoints: 表 (U+8868) and 附 (U+9644) were added from the same Sans2.004 source, retaining all582 prior codepoints and horizontal metrics. The playable scope now includes the302 approval task; formal309 rescue and following remain gated pending the complete story.
