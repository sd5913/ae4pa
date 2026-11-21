extends SceneTree
var main: Node
var dialogue: Control
var failures: Array[String] = []
var completed: Array[String] = []
var evidence := OS.get_environment("AE4PA_STORY_EVIDENCE")
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	print(("PASS: " if ok else "FAIL: ") + message)
	if not ok: failures.append(message)
func settle() -> void:
	for i in range(4): await process_frame
func mouse(point: Vector2, pressed: bool, button: int = MOUSE_BUTTON_LEFT) -> void:
	var event := InputEventMouseButton.new()
	event.position = point
	event.button_index = button
	event.pressed = pressed
	dialogue._input(event)
func click(point: Vector2) -> void:
	mouse(point, true)
	mouse(point, false)
func shot(id: String) -> void:
	if evidence.is_empty() or DisplayServer.get_name() == "headless": return
	await settle()
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(evidence.path_join(id + ".png")) == OK, "capture " + id)
func run() -> void:
	root.get_node("Localization").set_language("zh_CN")
	main = load("res://scenes/main.tscn").instantiate()
	dialogue = main.get_node("StoryLayer/Dialogue")
	dialogue.set_progress_file_path_for_test(OS.get_environment("TEMP").path_join("ae4pa-story-surface-%d.cfg" % OS.get_process_id()))
	root.add_child(main)
	await settle()
	var menu: Control = main.get_node("MenuLayer/MainMenu")
	if not "--ui-smoke" in OS.get_cmdline_user_args():
		check(not menu.get("_ready_for_input"), "normal main opening starts with input disabled")
		await create_timer(4.0).timeout
	check(menu.get("_ready_for_input"), "cover opening finishes with interactive buttons")
	await shot("menu")
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	await create_timer(0.9).timeout
	dialogue.set_skip_transitions_for_test(true)
	check(dialogue.visible and dialogue.get("_line_index") == 0, "normal start enters real SMS with no auto advance")
	check(dialogue.get_node_or_null("%ContinueButton") == null, "continue button and its focus target removed")
	check(not dialogue.get_node("%SkipButton").visible, "first reading cannot skip")
	click(Vector2(30, 300))
	click(dialogue.get_node("SMSPanel/PhoneFrame").get_global_rect().position + Vector2(10, 200))
	check(dialogue.get("_line_index") == 0, "room and phone frame clicks do not advance")
	var chat: Rect2 = dialogue.get_node("%SMSScroll").get_global_rect()
	var point := chat.get_center()
	mouse(point, true)
	var drag := InputEventMouseMotion.new()
	drag.position = point + Vector2(0, 45)
	dialogue._input(drag)
	mouse(drag.position, false)
	mouse(point, true, MOUSE_BUTTON_WHEEL_UP)
	check(dialogue.get("_line_index") == 0, "drag and wheel do not advance SMS")
	click(point)
	check(dialogue.get("_line_index") == 1, "chat click release advances exactly once")
	var echo := InputEventKey.new()
	echo.physical_keycode = KEY_E
	echo.pressed = true
	echo.echo = true
	dialogue._input(echo)
	check(dialogue.get("_line_index") == 1, "held E echo is consumed")
	var touch := InputEventScreenTouch.new()
	touch.position = point
	touch.pressed = true
	dialogue._input(touch)
	touch.pressed = false
	dialogue._input(touch)
	var emulated := InputEventMouseButton.new()
	emulated.device = InputEvent.DEVICE_ID_EMULATION
	emulated.position = point
	emulated.button_index = MOUSE_BUTTON_LEFT
	emulated.pressed = true
	dialogue._input(emulated)
	emulated.pressed = false
	dialogue._input(emulated)
	check(dialogue.get("_line_index") == 2, "touch and emulated mouse advance once together")
	for i in range(12): dialogue._advance()
	await shot("phone")
	for viewport_size in [Vector2i(1280,720), Vector2i(1920,1080), Vector2i(960,540)]:
		root.size = viewport_size
		if DisplayServer.get_name() != "headless": DisplayServer.window_set_size(viewport_size)
		await settle()
		var skip: Control = dialogue.get_node("%SkipButton")
		check(is_equal_approx(dialogue.size.x - skip.get_rect().end.x, 24.0) and is_equal_approx(dialogue.size.y - skip.get_rect().end.y, 24.0), "24px skip margins " + str(viewport_size))
		while dialogue.get("_beats")[dialogue.get("_line_index")].mode != "dialogue": dialogue._advance()
		await settle()
		var portrait: Control = dialogue.get_node("%Portrait")
		var frame: Control = dialogue.get_node("%DialogueFrame")
		var text: Label = dialogue.get_node("%Line")
		check(absf(portrait.get_rect().end.y - frame.get_rect().end.y) < 1.0, "visible portrait bottom aligned " + str(viewport_size))
		check(frame.get_global_rect().encloses(text.get_global_rect()), "text inside panel " + str(viewport_size))
		var before: int = dialogue.get("_line_index")
		click(Vector2(20,20))
		check(dialogue.get("_line_index") == before, "dialogue background does not advance")
		click(frame.get_global_rect().get_center())
		check(dialogue.get("_line_index") == before + 1, "panel click advances one beat")
		await shot("dialogue-%d" % viewport_size.x)
	# Interruption does not save progress; complete both real sections for replay.
	check(not dialogue.has_completed_intro(), "interrupted intro still unread")
	while dialogue.visible: dialogue._advance()
	dialogue.dialogue_finished.connect(func(id: String): completed.append(id))
	dialogue.show_dialogue("V4_MANAGER_TALK")
	await settle()
	await shot("manager")
	var physical := InputEventKey.new()
	physical.physical_keycode = KEY_E
	physical.pressed = true
	dialogue._input(physical)
	check(dialogue.get("_line_index") == 1, "configured physical E advances once despite legacy device binding")
	while dialogue.visible: dialogue._advance()
	check(completed == ["V4_MANAGER_TALK"] and dialogue.has_completed_intro(), "manager completion emitted once and saves read state")
	dialogue._advance()
	check(completed.size() == 1, "extra advance cannot repeat completion")
	dialogue.show_dialogue("V4_INTRO")
	check(dialogue.get_node("%SkipButton").visible, "read replay offers skip")
	var skip: Control = dialogue.get_node("%SkipButton")
	click(skip.get_global_rect().get_center())
	check(dialogue.get("_line_index") == 0, "skip pointer cannot advance underlying SMS")
	dialogue.get_node("%SkipButton").pressed.emit()
	check(completed == ["V4_MANAGER_TALK", "V4_INTRO"], "skip emits only one completion")
	dialogue.show_dialogue("V4_INTRO")
	while dialogue.get("_beats")[dialogue.get("_line_index")].mode != "cue": dialogue._advance()
	var cue_index: int = dialogue.get("_line_index")
	await shot("narration")
	click(Vector2(30,300))
	check(dialogue.get("_line_index") == cue_index + 1, "narration blank click advances one beat")
	dialogue.reset_progress_file_for_test()
	main._show_menu()
	await settle()
	if not "--ui-smoke" in OS.get_cmdline_user_args():
		check(not menu.get("_ready_for_input"), "return to menu restarts one opening tween")
		await create_timer(4.0).timeout
	check(menu.get("_ready_for_input") and not menu.get_node("%StartButton").disabled, "return menu restores buttons")
	check(menu.get_node("Center/Content/TitleSlot/Title").offset_top == 0.0, "return menu has no title drift")
	main.queue_free()
	await process_frame
	print("STORY_SURFACES: PASS" if failures.is_empty() else "STORY_SURFACES: FAIL")
	quit(0 if failures.is_empty() else 1)
