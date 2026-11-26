extends SceneTree
var failures: Array[String] = []
var folder := OS.get_environment("AE4PA_EDGE_EVIDENCE")
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	print(("PASS: " if ok else "FAIL: ") + message)
	if not ok: failures.append(message)
func settle() -> void:
	for i in range(8): await process_frame
func move_pointer(point: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = point
	root.push_input(event, true)
	await settle()
func click_control(control: Control) -> void:
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = control.get_global_rect().get_center()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		root.push_input(event, true)
		await process_frame
func shot(name: String) -> void:
	if folder.is_empty() or DisplayServer.get_name() == "headless": return
	await settle()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(folder.path_join(name+".png"))
func run() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	current_scene = main
	main.get_node("MemoryService").storage_root = "user://edge_layout_%d" % Time.get_ticks_usec()
	await settle()
	main.menu._finish_opening()
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	main.dialogue.hide()
	main._on_dialogue_finished("V4_INTRO")
	main._show_story_dialogue("V4_MANAGER_TALK")
	main.dialogue._finish()
	var hud: Control = main.get_node("TaskLayer/HUD")
	var memory: Node = main.get_node("MenuLayer/MainMenu/MemoryUI")
	for locale in ["zh_CN", "en"]:
		root.get_node("Localization").set_language(locale)
		for dimensions in [Vector2i(960,540), Vector2i(1280,720), Vector2i(1920,1080)]:
			root.size = dimensions
			if DisplayServer.get_name() != "headless": DisplayServer.window_set_size(dimensions)
			await settle()
			var suffix: String = locale+"_%d" % dimensions.x
			var button: Button = hud.get_node("%BagButton")
			button.release_focus()
			button.set_expanded(false, true)
			await settle()
			check(not hud.get_node("%FloorValue").is_visible_in_tree(), "floor plaque removed " + suffix)
			check(button.text.is_empty() and button.size.x <= 54, "icon drawer collapsed " + suffix)
			check(hud.get_node("%SlotAFrame").size.y >= 110, "equipment enlarged " + suffix)
			await shot("hud_"+suffix)
			await move_pointer(Vector2(20, 300))
			await move_pointer(button.get_global_rect().get_center())
			await create_timer(0.18).timeout
			check(not button.text.is_empty() and button.size.x >= 180, "hover expands without activation " + suffix)
			check(not main.bag.visible, "hover does not open bag")
			await shot("hover_"+suffix)
			await click_control(button)
			await settle()
			check(main.bag.visible, "original bag request still works")
			var close: Button = main.bag.get_node("%CloseButton")
			var case: Control = main.bag.get_node("Case")
			check(close.get_global_rect().position.x >= case.get_global_rect().end.x - 1, "bag X outside artwork " + suffix)
			check(main.bag.get_viewport_rect().encloses(close.get_global_rect()), "outside X stays on screen")
			await shot("bag_"+suffix)
			await click_control(close)
			check(not main.bag.visible, "outside X closes bag")
			for mode in ["save", "load", "history"]:
				memory.open(mode)
				await settle()
				if mode != "history":
					check(memory._grid.columns == 3 and memory._grid.get_child_count() == 6, "six aligned slots " + suffix)
					var a: Control = memory._grid.get_child(0)
					var b: Control = memory._grid.get_child(5)
					check(a.size.is_equal_approx(b.size), "equal save card sizes")
					check(memory._scroll.get_global_rect().encloses(b.get_global_rect()), "all six cards fit without cutoff " + suffix)
				await shot(mode+"_"+suffix)
				memory.close_page()
	print("EDGE_MEMORY_LAYOUT: ", "PASS" if failures.is_empty() else "FAIL")
	quit(0 if failures.is_empty() else 1)
