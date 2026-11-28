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
	var selector: MenuButton = menu.get_node("%LanguageSelector")
	_check(TranslationServer.get_locale() == "zh_CN", "A fresh profile defaults to Simplified Chinese")
	_choose(selector, 1)
	_check(TranslationServer.get_locale() == "en" and main == current_scene and menu.visible,
		"Main-menu switch updates the locale in place")
	_check(tr("返回%s按E交付") % "403" == "Return to Room 403 and press E to deliver.",
		"Late-task delivery template is translated and formatted")
	_check(tr("403已交付；前往5F501办理并交付离店单。") ==
		"Room 403 is complete. Go to Room 501 on 5F to approve and deliver the exit form.",
		"Late-task story objective is translated")
	_check(tr("巡房记录已取得，返回403按E交付；交付前仍会计时。") ==
		"Record collected. Return to Room 403 to deliver.",
		"403 live HUD notice is translated")
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

	menu.call("_finish_opening") # This test covers locale changes; menu motion has its own smoke.
	menu.get_node("%StartButton").pressed.emit()
	var dialogue: Control = main.get_node("StoryLayer/Dialogue")
	var story_progress_path := "user://localization_smoke_progress.cfg"
	dialogue.set_progress_file_path_for_test(story_progress_path)
	dialogue.set_skip_transitions_for_test(true)
	var story_index: int = dialogue.get("_line_index")
	var story_text: String = dialogue.get_node("%Line").text
	_choose(selector, 1)
	await process_frame
	_check(dialogue.get("_line_index") == story_index and dialogue.get_node("%Line").text == story_text,
		"Language refresh preserves the current authored story beat")
	_choose(selector, 0)
	for _beat in range(80):
		if not dialogue.visible:
			break
		dialogue.call("_advance")
	_check(not dialogue.visible, "Prologue ends normally after live switching")

	var game := root.get_node("GameManager")
	main.call("_show_story_dialogue", "V4_MANAGER_TALK")
	for _beat in range(65):
		if not dialogue.visible:
			break
		dialogue.call("_advance")
	_check(game.has_completed_manager_intro(), "The actual manager scene unlocks the next floor")
	var story_progress := FileAccess.get_file_as_bytes(story_progress_path)
	_check(not story_progress.is_empty(), "Completed dialogue writes to the separate story file")
	var floor_node: Node = main.get_node("World").get_child(0)
	floor_node.player.position.x = floor_node.get_stair_interaction_center(true)
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
	_check(pause.find_child("LanguageSelector", true, false) == null, "Language selection is only on the main menu")
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
	_choose(selector, 1)
	await process_frame
	_check(task_layer.get_node("HUD").get_node("%RemainingTime").text.contains("Time left"),
		"Already visible HUD updates behind the pause menu")
	_check(main.notice_label.text == "Collected the Housekeeper's ID",
		"The current formatted notice updates in English")
	_choose(selector, 0)
	await process_frame
	_check(main.notice_label.text == "获得保洁 ID", "The current formatted notice returns to Chinese")
	_check(pause.visible and not game.is_world_input_allowed()
		and game.get_task_view() == task and game.remaining_time == remaining
		and game.get("_task_checkpoint") == checkpoint and game.get_world_flags() == flags
		and cards.export_snapshot() == card_state
		and main.get_node("World").get_child(0) == active_floor and player.global_position == position,
		"Locale switches during pause preserve the floor, player, task, checkpoint, cards and paused clock")
	if "--write-english" in args:
		_choose(selector, 1)
	_check(FileAccess.get_file_as_bytes(story_progress_path) == story_progress,
		"Locale changes leave the story progress file intact")
	DirAccess.remove_absolute(story_progress_path)
	# Release the real scene while the engine is still running so pending SMS
	# layout callbacks and the looping audio player finish before process exit.
	var music: AudioStreamPlayer = main.get_node("BackgroundMusic")
	var music_playback: WeakRef
	if music.playing:
		music_playback = weakref(music.get_stream_playback())
	main.queue_free()
	for frame in range(4):
		await process_frame
	# Headless Linux can run four frames before the audio thread's next mix.
	# Observe the actual playback release rather than assuming frame count is time.
	var release_deadline := Time.get_ticks_msec() + 1000
	while music_playback != null and music_playback.get_ref() != null and Time.get_ticks_msec() < release_deadline:
		await create_timer(0.01).timeout
	_check(music_playback == null or music_playback.get_ref() == null,
		"Background music playback releases after unloading the real main scene")
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


func _choose(selector: MenuButton, index: int) -> void:
	selector.select(index)
	selector.get_popup().id_pressed.emit(index)


func _check(condition: bool, description: String) -> void:
	if not condition:
		_failures += 1
		push_error(description)


func _finish() -> void:
	if _failures == 0:
		print("LOCALIZATION_SMOKE: PASS")
	quit(0 if _failures == 0 else 1)
