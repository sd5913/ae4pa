extends SceneTree

var failures: Array[String] = []
var game: Node


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	game = root.get_node("GameManager")
	game.start_game()
	var manual: Control = load("res://scenes/ui/help.tscn").instantiate()
	var codex_path := "user://help_refinement_%d.cfg" % OS.get_process_id()
	manual.set_codex_path_for_test(codex_path)
	root.add_child(manual)
	manual.open_help()
	_check(manual.get_node("%PageIndicator").text == "1 / 10", "Handbook contains controls, three cards, equipment rules and five monster pages")
	manual.call("_show_page", 0)
	_check(manual.get_node("%WorkCardPage").visible and manual.get_node("%PageTitle").text == "夜班操作",
		"First page shows the actual control guide")
	for page: int in [1, 2, 3]:
		manual.call("_show_page", page)
		var row: HBoxContainer = manual.get_node("%WorkCardPage").get_child(0)
		var identity: Label = row.get_child(1).get_child(0)
		_check(identity.text == ["SECURITY", "CLEANER", "MANAGER"][page - 1],
			"Card page %d uses the correct card ID and artwork" % (page + 1))
	manual.call("_show_page", 4)
	_check(manual.get_node("%PageTitle").text == "佩戴与任务", "Equipment page explains two slots, Q and task delivery")
	manual.call("_show_page", 6)
	var monster_page: VBoxContainer = manual.get_node("%MonsterPage")
	_check(manual.get_node("%PageTitle").text == "未知住客"
		and monster_page.get_child(1).text.begins_with("尚未遇见")
		and monster_page.get_child(0).modulate.r < 0.1,
		"Unencountered monster uses a silhouette and hides its name and rule")
	manual.close_help()
	_check(game.request_monster_encounter("201", "NOSE", "FIRST_ENCOUNTER"), "Real encounter API accepts the test encounter")
	manual.open_help()
	manual.call("_show_page", 6)
	_check(manual.get_node("%PageTitle").text == "长鼻客"
		and monster_page.get_child(1).text.contains("CLEANER")
		and monster_page.get_child(0).modulate.r > 0.9,
		"First real encounter reveals its actual identity and rule")
	var saved := ConfigFile.new()
	_check(saved.load(codex_path) == OK and bool(saved.get_value("seen", "NOSE", false)),
		"Only a GameManager encounter is persisted as an unlocked monster")
	manual.close_help()
	game.start_game()
	manual.set_codex_path_for_test(codex_path)
	manual.open_help()
	manual.call("_show_page", 6)
	_check(manual.get_node("%PageTitle").text == "长鼻客", "Encountered monster remains unlocked in a later run")
	_check(not game.is_world_input_allowed(), "Open manual registers the GameManager modal")
	manual.close_help()
	_check(game.is_world_input_allowed(), "Closing manual releases its GameManager modal")
	manual.reset_codex_file_for_test()
	manual.queue_free()
	for failure: String in failures:
		push_error(failure)
	if failures.is_empty():
		print("PASS: 10-page handbook, cards, encounter-gated silhouettes, persistence, and modal lifecycle.")
	quit(0 if failures.is_empty() else 1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error("FAIL: " + message)
