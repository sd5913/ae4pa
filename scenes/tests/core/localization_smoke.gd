extends SceneTree

var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var localization := root.get_node_or_null("Localization")
	if localization == null:
		_check(false, "Localization autoload exists")
		quit(1)
		return

	var args := OS.get_cmdline_user_args()
	if "--set-chinese" in args:
		_check(TranslationServer.get_locale() == "en", "Start with the saved English choice")
		localization.set_language("zh_CN")
		_finish()
		return
	if "--expect-english" in args or "--expect-chinese" in args:
		var expected := "en" if "--expect-english" in args else "zh_CN"
		_check(TranslationServer.get_locale() == expected, "Language survives a new Godot process")
		_finish()
		return

	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	await process_frame
	var menu := main.get_node("MenuLayer/MainMenu")
	var selector: OptionButton = menu.get_node("Actions/LanguageSelector")
	_check(TranslationServer.get_locale() == "zh_CN", "A fresh profile defaults to Simplified Chinese")
	_choose(selector, 1)
	_check(TranslationServer.get_locale() == "en" and main == current_scene and menu.visible,
		"Main-menu switch updates the locale in place")
	_check(menu.get_node("%StartButton").atr("开始游戏") == "Start Game", "Godot translates scene text")
	_check(tr("剩余时间：%d:%02d · %s") % [3, 5, tr("进行中")] == "Time left: 3:05 · In progress",
		"Formatted strings preserve arguments and padding")

	_check_catalog_formats()
	var story := FileAccess.open("res://scenes/ui/intro_script.tsv", FileAccess.READ)
	while not story.eof_reached():
		var row := story.get_line()
		if row.is_empty() or row.begins_with("#"):
			continue
		var line := row.get_slice("\t", 4)
		_check(tr(line) != line, "English catalog contains the story line: " + line)
	_choose(selector, 0)
	_check(tr("开始游戏") == "开始游戏", "Switching back returns the original source text")

	menu.get_node("%StartButton").pressed.emit()
	var dialogue: Control = main.get_node("StoryLayer/Dialogue")
	var story_progress_path := "user://localization_smoke_progress.cfg"
	dialogue.set_progress_file_path_for_test(story_progress_path)
	dialogue.set_skip_transitions_for_test(true)
	var sms: Control = dialogue.get_node("%SMSHistory")
	var history_row := sms.get_child(0)
	_choose(selector, 1)
	await process_frame
	_check(sms.get_child_count() == 1 and sms.get_child(0) == history_row and dialogue.get("_line_index") == 0,
		"Language refresh preserves the current story beat and SMS history")
	_choose(selector, 0)
	for _beat in range(80):
		if not dialogue.visible:
			break
		dialogue.call("_on_continue_pressed")
	_check(not dialogue.visible, "Prologue ends normally after live switching")

	var game := root.get_node("GameManager")
	main.call("_show_story_dialogue", "V4_MANAGER_TALK")
	for _beat in range(65):
		if not dialogue.visible:
			break
		dialogue.call("_on_continue_pressed")
	_check(game.has_completed_manager_intro(), "The actual manager scene unlocks the next floor")
	var story_progress := FileAccess.get_file_as_bytes(story_progress_path)
	_check(not story_progress.is_empty(), "Completed dialogue writes to the separate story file")
	var floor_node: Node = main.get_node("World").get_child(0)
	floor_node.get_node("Player").global_position = floor_node.exit_point.global_position
	_check(game.request_floor_travel(2), "Travel to the real task floor")
	await process_frame
	_check(game.offer_task(game.TASK_01_ID), "Offer the cleaning task")
	var monster: Control = main.get_node("TaskLayer/MonsterDialogue")
	for i in range(80):
		if not monster.visible: break
		monster.advance()
	_check(game.accept_task(game.TASK_01_ID), "Accept the real timed task and make a checkpoint")

	var task_layer := main.get_node("TaskLayer")
	task_layer.get_node("MissionBoard").hide()
	var pause: Control = task_layer.get_node("PlayOverlay")
	var event := InputEventAction.new()
	event.action = &"pause"
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	var pause_selector: OptionButton = pause.find_child("LanguageSelector", true, false)
	var active_floor: Node = main.get_node("World").get_child(0)
	var player: Node2D = active_floor.get_node("Player")
	var position := player.global_position
	var remaining: float = game.remaining_time
	var checkpoint: Dictionary = game.get("_task_checkpoint").duplicate(true)
	var flags: Dictionary = game.get_world_flags()
	var cards := root.get_node("CardManager")
	# Prepare cards before capturing state: acquiring an ID changes the task step.
	cards.collect_card("CLEANER")
	cards.equip_card("CLEANER", 1)
	var task: Dictionary = game.get_task_view()
	_check(task["step"] == "CLEAN_STAIN", "Collected cleaner advances the real task step before locale switching")
	var card_state: Dictionary = cards.export_snapshot()
	active_floor.formatted_notice_requested.emit("获得%s ID", ["保洁"])
	_check(pause.visible and not game.is_world_input_allowed() and not checkpoint.is_empty(),
		"Pause holds the world and a real checkpoint exists")
	_choose(pause_selector, 1)
	await process_frame
	_check(task_layer.get_node("HUD").get_node("%RemainingTime").text.contains("In progress"),
		"Already visible HUD updates behind the pause menu")
	_check(main.notice_label.text == "Collected the Housekeeper's ID",
		"The current formatted notice updates in English")
	_choose(pause_selector, 0)
	await process_frame
	_check(main.notice_label.text == "获得保洁 ID", "The current formatted notice returns to Chinese")
	_check(pause.visible and not game.is_world_input_allowed()
		and game.get_task_view() == task and game.remaining_time == remaining
		and game.get("_task_checkpoint") == checkpoint and game.get_world_flags() == flags
		and cards.export_snapshot() == card_state
		and main.get_node("World").get_child(0) == active_floor and player.global_position == position,
		"Both pause-menu switches preserve the floor, player, task, checkpoint, cards and paused clock")
	if "--write-english" in args:
		_choose(pause_selector, 1)
	_check(FileAccess.get_file_as_bytes(story_progress_path) == story_progress,
		"Locale changes leave the story progress file intact")
	DirAccess.remove_absolute(story_progress_path)
	_finish()


func _check_catalog_formats() -> void:
	var catalog: Translation = TranslationServer.get_translation_object("en")
	_check(catalog != null and catalog.get_message_count() >= 126, "The English catalog is loaded")
	if catalog == null:
		return
	var format_tokens := RegEx.create_from_string(r"%[0-9.]*[sdf]")
	for key: String in catalog.get_message_list():
		var parts := key.split("\u0004", true, 1)
		var message := parts[-1]
		var source_tokens := format_tokens.search_all(message)
		if source_tokens.is_empty():
			continue
		var context := parts[0] if parts.size() > 1 else ""
		var translated := catalog.get_message(message, context)
		var target_tokens := format_tokens.search_all(translated)
		_check(translated != message and _tokens(source_tokens) == _tokens(target_tokens),
			"English preserves the exact format tokens for " + message)


func _tokens(matches: Array[RegExMatch]) -> Array[String]:
	var tokens: Array[String] = []
	for item in matches:
		tokens.append(item.get_string())
	return tokens


func _choose(selector: OptionButton, index: int) -> void:
	selector.select(index)
	selector.item_selected.emit(index)


func _check(condition: bool, description: String) -> void:
	if not condition:
		_failures += 1
		push_error(description)


func _finish() -> void:
	if _failures == 0:
		print("LOCALIZATION_SMOKE: PASS")
	quit(0 if _failures == 0 else 1)
