extends SceneTree
var main: Node
var dialogue: Control
var failures: Array[String] = []
var folder := OS.get_environment("AE4PA_POLISH_EVIDENCE")
func _initialize() -> void: run.call_deferred()
func check(ok: bool, label: String) -> void:
	print(("PASS: " if ok else "FAIL: ") + label)
	if not ok: failures.append(label)
func settle(count: int = 6) -> void:
	for tick in range(count): await process_frame
func shot(name: String) -> void:
	await settle()
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(folder.path_join(name + ".png")) == OK, "capture " + name)
func run() -> void:
	var english := "--english" in OS.get_cmdline_user_args()
	root.size = Vector2i(960, 540) if english else Vector2i(1920, 1080) if "--large" in OS.get_cmdline_user_args() else Vector2i(1280, 720)
	root.get_node("Localization").set_language("en" if english else "zh_CN")
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	dialogue = main.get_node("StoryLayer/Dialogue")
	dialogue.set_progress_file_path_for_test("user://polish_progress.cfg")
	await create_timer(4.1).timeout
	await shot("cover")
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	dialogue.set_skip_transitions_for_test(true)
	dialogue.call("_finish_phone_animation")
	# Real phone opening click then original story advancement; no injected text.
	var pointer: Vector2 = dialogue.get_node("%PhoneScreen").get_global_rect().get_center()
	for pressed in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.position = pointer
		e.pressed = pressed
		dialogue._input(e)
	for beat in range(17):
		dialogue.call("_advance")
		await settle(6)
		if beat == 12: await shot("sms")
		var history: VBoxContainer = dialogue.get_node("%SMSHistory")
		if history.get_child_count() > 0:
			var latest: Control = history.get_child(-1)
			var scroll: ScrollContainer = dialogue.get_node("%SMSScroll")
			check(latest.get_global_rect().end.y <= scroll.get_global_rect().end.y + 2, "latest SMS fully visible " + str(beat))
	await shot("narration")
	while dialogue.visible and dialogue.get("_line_index") < 27: dialogue.call("_advance")
	# Presentation-only expression exercise in the actual scene. No rescue or task mutation.
	for step in range(90):
		var beat: Dictionary = dialogue.get("_beats")[dialogue.get("_line_index")]
		if beat.get("speaker") in ["Carol", "女主", "安"] and beat.get("mode") == "dialogue": break
		dialogue.call("_advance")
	dialogue.call("_display_portrait", "Carol", "neutral")
	await shot("carol")
	var carol_rect: Rect2 = dialogue.get_node("%Portrait").get_global_rect()
	dialogue.call("_display_portrait", "Carol", "worried")
	await settle()
	check(dialogue.get_node("%Portrait").get_global_rect().is_equal_approx(carol_rect), "Carol expression geometry stable")
	for step in range(40):
		dialogue.call("_advance")
		var beat: Dictionary = dialogue.get("_beats")[dialogue.get("_line_index")]
		if beat.get("speaker") in ["闺蜜", "Terese", "friend", "Persica"] and beat.get("mode") == "dialogue": break
	dialogue.call("_display_portrait", "friend", "neutral")
	await shot("terese")
	var friend_rect: Rect2 = dialogue.get_node("%Portrait").get_global_rect()
	dialogue.call("_display_portrait", "friend", "worried")
	await settle()
	check(dialogue.get_node("%Portrait").get_global_rect().is_equal_approx(friend_rect), "Terese expression geometry stable")
	dialogue.call("_finish")
	var game: Node = root.get_node("GameManager")
	var screen: Control = main.get_node("TaskLayer/MonsterDialogue")
	var facts: Array = game.get_completed_task_ids().duplicate()
	for role in ["NOSE", "EYE", "HAT", "EAR", "CHECKER"]:
		check(screen.preview_dialogue(role + ":INTRO"), "formal-scene portrait review " + role)
		await settle()
		var surface: Control = screen.get("_surface")
		check(surface.get_node("%Portrait").texture != null, "approved portrait " + role)
		check(absf(surface.get_node("%Portrait").get_global_rect().end.y - surface.get_node("%DialogueFrame").get_global_rect().end.y) < 2.0, "shared bottom baseline " + role)
		await shot("monster_" + role.to_lower())
		var rect: Rect2 = surface.get_node("%Portrait").get_global_rect()
		screen.advance()
		screen.advance()
		await settle()
		check(surface.get_node("%Portrait").get_global_rect().is_equal_approx(rect), "repeat role geometry stable " + role)
		screen.cancel_dialogue()
	check(game.get_completed_task_ids() == facts, "portrait review never settles tasks")
	var notebook: Control = main.get_node("MenuLayer/Notebook")
	for cycle in range(10):
		notebook.open_help()
		notebook.call("_show_page", 1 if cycle % 2 == 0 else 6)
		await settle()
		var panel: Control = notebook.get_node("Center/Panel")
		check(notebook.get_global_rect().encloses(panel.get_global_rect()), "notebook inside viewport " + str(cycle))
		var e := InputEventAction.new()
		e.action = "pause" if cycle % 2 == 0 else "open_help"
		e.pressed = true
		notebook._input(e)
		check(not notebook.visible, "notebook key close " + str(cycle))
		check(not game.get("_open_modals").has("help"), "notebook releases its modal")
	notebook.open_help()
	notebook.call("_show_page", 1)
	await shot("notebook_card")
	notebook.next_page()
	await shot("notebook_next")
	notebook.close_help()
	notebook.open_help()
	notebook.call("_show_page", 6)
	await shot("notebook_unknown")
	notebook.get_node("%CloseButton").pressed.emit()
	check(not notebook.visible, "notebook close button")
	await shot("hud")
	main.get_node("TaskLayer/HUD/%BagButton").pressed.emit()
	await shot("bag")
	main.get_node("MenuLayer/Bag").close_bag()
	main.get_node("TaskLayer/HUD/%PauseButton").pressed.emit()
	await shot("pause")
	main.get_node("TaskLayer/PlayOverlay").close_page()
	main.get_node("TaskLayer/HUD/%TaskButton").pressed.emit()
	await shot("task_details")
	main.get_node("TaskLayer/MissionBoard").hide()
	main.call("_show_menu")
	main.get_node("MenuLayer/MainMenu").call("_finish_opening")
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	dialogue.call("_finish")
	notebook.open_help()
	check(notebook.visible, "notebook opens after returning to menu and new session")
	notebook.close_help()
	main.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
