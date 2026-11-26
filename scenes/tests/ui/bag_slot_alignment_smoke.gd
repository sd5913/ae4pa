extends SceneTree
## Production bag scene wired to the real drag adapter, with three owned cards.

var _failures: Array[String] = []

func _initialize() -> void:
	create_timer(40).timeout.connect(func(): print("FAIL: bag slot alignment timeout"); quit(1))
	_run.call_deferred()

func _check(passed: bool, message: String) -> void:
	if not passed:
		_failures.append(message)

func _mouse(at: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	event.pressed = pressed
	event.position = at
	event.global_position = at
	root.push_input(event, true)
	await process_frame

func _motion(at: Vector2, held: bool) -> void:
	var event := InputEventMouseMotion.new()
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if held else 0
	event.position = at
	event.global_position = at
	event.relative = at - root.get_mouse_position()
	root.push_input(event, true)
	await process_frame

func _run() -> void:
	var cards := root.get_node("CardManager")
	root.get_node("GameManager").start_game()
	var english := OS.get_cmdline_user_args().has("--english")
	TranslationServer.set_locale("en" if english else "zh_CN")
	var requested_size := Vector2i(960, 540) if OS.get_cmdline_user_args().has("--small") else Vector2i(1280, 720)
	if OS.get_cmdline_user_args().has("--large"):
		requested_size = Vector2i(1920, 1080)
	root.size = requested_size
	var bag: Control = load("res://scenes/ui/bag.tscn").instantiate()
	bag.set_script(load("res://scenes/bag_adapter.gd"))
	root.add_child(bag)
	cards.restore_snapshot({"owned_cards":["CLEANER", "SECURITY", "MANAGER"], "equipped_cards":["CLEANER", "SECURITY"], "active_slot":0})
	bag.open_bag()
	await process_frame
	await process_frame
	var list: ItemList = bag.get_node("%OwnedCards")
	var areas: Array[Panel] = bag.get("_owned_hit_regions")
	for index in areas.size():
		var area := areas[index]
		var rect := area.get_global_rect()
		var item_center := list.get_global_transform() * list.get_item_rect(index).get_center()
		_check(absf(item_center.x - rect.get_center().x) < 4.0, "Card %d art centered over its well (%.1f / %.1f)" % [index + 1, item_center.x, rect.get_center().x])
		# Click below the built-in icon/label rectangle, still inside the leather card well.
		var at := Vector2(rect.get_center().x, rect.end.y - 12.0)
		await _mouse(at, true)
		await _mouse(at, false)
		_check(list.is_selected(index), "Click in well %d selects that card" % (index + 1))
		_check(list.has_focus(), "Pointer selection hands focus to the keyboard list")
		_check(area.get_theme_stylebox("panel") == area.get_theme_stylebox("focused_slot"), "Focus border uses the card well")
		if index == 0:
			var next := InputEventAction.new()
			next.action = "ui_right"
			next.pressed = true
			root.push_input(next, true)
			await process_frame
			_check(list.is_selected(1), "Arrow right selects the next card")
			_check(areas[1].get_theme_stylebox("panel") == areas[1].get_theme_stylebox("focused_slot"), "Focus border follows arrow selection")
	var gap := Vector2((areas[0].get_global_rect().end.x + areas[1].get_global_rect().position.x) / 2.0, areas[0].get_global_rect().get_center().y)
	await _mouse(gap, true)
	await _mouse(gap, false)
	_check(list.is_selected(2), "Clicking between wells does not select a different card")
	var close_button: Control = bag.get_node("%CloseButton")
	close_button.grab_focus()
	await process_frame
	_check(areas[2].get_theme_stylebox("panel") == areas[2].get_theme_stylebox("selected_slot"), "Unfocused selection remains in the same well")

	if DisplayServer.get_name() != "headless":
		var third := areas[2].get_global_rect()
		var start := Vector2(third.get_center().x, third.end.y - 12.0)
		var destination: Vector2 = bag.get_node("Case/CardDropA").get_global_rect().get_center()
		Input.warp_mouse(root.get_final_transform() * start)
		await process_frame
		await _motion(start, false)
		await _mouse(start, true)
		for distance in [6, 16, 32]:
			await _motion(start + Vector2(distance, 0), true)
		await _motion(destination, true)
		_check(root.gui_is_dragging(), "Drag starts inside the same well as click")
		await _mouse(destination, false)
		_check(cards.get_equipped_cards()[0] == "MANAGER", "Drag equips the card in slot A")
		_check(cards.get_owned_cards().size() == 3, "Drag preserves all three collected cards")
		var screenshot_path := OS.get_environment("AE4PA_BAG_SCREENSHOT")
		if not screenshot_path.is_empty():
			await RenderingServer.frame_post_draw
			_check(root.get_texture().get_image().save_png(screenshot_path) == OK, "Screenshot written")
	for failure in _failures:
		print("FAIL: ", failure)
	print("BAG_SLOT_ALIGNMENT_SMOKE: ", "PASS" if _failures.is_empty() else "FAIL")
	quit(0 if _failures.is_empty() else 1)
