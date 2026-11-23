extends SceneTree
const History = preload("res://scenes/ui/memory_history.gd")
var failures: Array[String] = []
var folder := OS.get_environment("AE4PA_MEMORY_EVIDENCE")
func _initialize() -> void: run.call_deferred()
func check(ok: bool, label: String) -> void:
	print(("PASS: " if ok else "FAIL: ") + label)
	if not ok: failures.append(label)
func settle() -> void:
	for i in range(8): await process_frame
func shot(name: String) -> void:
	await settle()
	await RenderingServer.frame_post_draw
	if not folder.is_empty(): root.get_texture().get_image().save_png(folder.path_join(name+".png"))
func run() -> void:
	root.size = Vector2i(960,540) if "--english" in OS.get_cmdline_user_args() else Vector2i(1920,1080) if "--large" in OS.get_cmdline_user_args() else Vector2i(1280,720)
	root.get_node("Localization").set_language("en" if "--english" in OS.get_cmdline_user_args() else "zh_CN")
	check(History.name_for("NOSE") != "NOSE" and History.name_for("CAROL") == "Carol", "history resolves stable monster/player IDs through existing localized role names")
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	await create_timer(4.5).timeout
	var memory: Node = main.get_node("MenuLayer/MainMenu/MemoryUI")
	check(memory != null and memory.backend == null, "no invented persistence backend is attached")
	check(main.get_node("MenuLayer/MainMenu/%LoadMemory").disabled, "cover load is disabled without a real readable save")
	check(not main.get_node("MenuLayer/MainMenu/%LanguageSelector").flat, "language control retains the same visible button surface")
	await shot("cover")
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	var story: Control = main.get_node("StoryLayer/Dialogue")
	story.set_progress_file_path_for_test("user://memory_smoke_intro.cfg")
	story.set_skip_transitions_for_test(true)
	story._finish_phone_animation()
	story._advance()
	await settle()
	check(not History.entries.is_empty(), "history records actual displayed story text")
	var original_index: int = story._line_index
	var original_count := History.entries.size()
	var history_button: Button = story.get_node("MemoryRail").get_child(2)
	# Send real viewport events through _input and GUI dispatch, not pressed.emit().
	var click_position := history_button.get_global_rect().get_center()
	for pressed in [true,false]:
		var mouse := InputEventMouseButton.new()
		mouse.button_index = MOUSE_BUTTON_LEFT
		mouse.position = click_position
		mouse.pressed = pressed
		root.push_input(mouse, true)
		await process_frame
	check(memory._root.visible and memory._mode == "history", "dialogue rail receives a real GUI click without advancing underneath")
	check(memory._board.is_ancestor_of(root.gui_get_focus_owner()), "opening a page transfers keyboard focus away from the underlying story")
	await shot("history")
	check(root.get_node("GameManager").has_method("set_modal_open") and not root.get_node("GameManager").is_world_input_allowed(), "memory page preserves the underlying story modal")
	var e := InputEventKey.new()
	e.physical_keycode = KEY_E
	e.keycode = KEY_E
	e.pressed = true
	story._input(e)
	check(story._line_index == original_index, "history input cannot advance the story underneath")
	memory.refresh()
	memory.refresh()
	check(History.entries.size() == original_count, "history rerender does not create entries")
	var before := History.export_ui_history()
	root.get_node("Localization").set_language("en")
	memory.refresh()
	check(History.export_ui_history() == before, "locale switch leaves source keys and reading order intact")
	root.get_node("Localization").set_language("en" if "--english" in OS.get_cmdline_user_args() else "zh_CN")
	memory.close_page()
	check(story._line_index == original_index, "close returns to the same story beat")
	check(not root.get_node("GameManager").is_world_input_allowed(), "close releases only MEMORY_UI, not the active story modal")
	for mode in ["save","load"]:
		memory.open(mode)
		await shot(mode)
		check(memory._grid.get_child_count() == 6, mode+" shows six manual slots")
		check(memory._action.disabled, mode+" cannot claim success without A's full-state service")
		var state: Dictionary = root.get_node("CardManager").export_snapshot()
		memory._request_action()
		check(root.get_node("CardManager").export_snapshot() == state, mode+" does not alter real card state")
		memory._auto.pressed.emit()
		check(memory._grid.get_child_count() == 1, "independent automatic slot")
		if mode == "save": check(memory._action.disabled, "automatic slot cannot be written manually")
		memory.close_page()
	var fake := Node.new()
	check(not memory.configure_backend(fake), "incomplete save services are rejected")
	fake.free()
	var ratio: float = memory._board.size.x / memory._board.size.y
	check(absf(ratio - 1586.0/992.0) < 0.001, "entire source panel keeps its exact aspect ratio")
	check(History.export_ui_history() == before, "page navigation never unlocks unseen story")
	check(not History.restore_ui_history({"version":99,"entries":[]}), "invalid history version is rejected without replacing session")
	check(History.export_ui_history() == before, "invalid history import preserves existing records")
	main._show_menu()
	main.get_node("MenuLayer/MainMenu")._finish_opening()
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	check(History.entries.is_empty(), "new game clears only session history")
	print("CROSS_PROCESS_GAME_STATE: BLOCKED - no A full-state disk save/validation/restore implementation")
	print("MEMORY_UI_SMOKE: ", "PASS" if failures.is_empty() else "FAIL")
	quit(0 if failures.is_empty() else 1)
