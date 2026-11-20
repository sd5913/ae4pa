extends SceneTree
func _initialize() -> void:
	var font: Font = load("res://assets/final/fonts/hotel_staff_cjk.otf")
	var text := ""
	for path in ["scenes/ui/monster_dialogues.json", "scripts/task_definitions.gd", "scripts/game_manager.gd", "scenes/task_ui.gd", "scenes/task_hud.gd", "scenes/levels/floor.gd"]:
		text += FileAccess.get_file_as_string("res://" + path)
	var missing := ""
	for i in text.length():
		var code := text.unicode_at(i)
		if code >= 0x4e00 and code <= 0x9fff and not font.has_char(code) and not missing.contains(text[i]): missing += text[i]
	if not missing.is_empty(): printerr("FAIL: monster/task text missing glyphs: " + missing)
	else: print("PASS: D monster dialogue and tutorial task text glyphs")
	quit(1 if not missing.is_empty() else 0)
