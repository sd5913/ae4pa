extends SceneTree
## Real main-scene interaction and bidirectional movement through art-only columns.

var failures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _expect(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _settle() -> void:
	for i in range(5):
		await physics_frame
	await process_frame

func _key(pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = pressed
	Input.parse_input_event(event)
	await _settle()

func _check_art(node: Node) -> void:
	_expect(not (node is CollisionObject2D or node is CollisionShape2D or node is CollisionPolygon2D or node is Control), "Art cannot add physics bodies, areas, collision shapes or GUI input blockers")
	_expect(node.get_script() == null, "Art has no input or gameplay scripts")
	if node is Sprite2D:
		_expect(node.texture.resource_path.begins_with("res://assets/final/floor_1_layers/hd_generated/"), "Every active sprite uses an independent full-resolution generated asset, never a reference-image crop")
	for child in node.get_children():
		_check_art(child)

func _run() -> void:
	var game: Node = root.get_node("GameManager")
	var main: Node = load("res://scenes/main.tscn").instantiate()
	var cache_dir: String = OS.get_environment("TEMP")
	if cache_dir.is_empty():
		cache_dir = OS.get_cache_dir()
	var progress_path: String = cache_dir.path_join("ae4pa-floor1-art-%d.cfg" % OS.get_process_id())
	main.get_node("StoryLayer/Dialogue").set_progress_file_path_for_test(progress_path)
	root.add_child(main)
	await process_frame
	if main.has_node("MenuLayer/MainMenu"):
		main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
		await process_frame
	# Explicit opening fixture; manager dialogue below runs through production E/UI.
	main.dialogue.hide()
	main._on_dialogue_finished("V4_INTRO")
	main.dialogue.set_skip_transitions_for_test(true)
	var floor_node: Node2D = main.get_node("World").get_child(0)
	var player: Node2D = floor_node.get_node("Player")
	var art: Node2D = floor_node.get_node("Floor1Art")
	_expect(not floor_node.get_node("FloorBackground").visible and floor_node.get_node("FloorBackground").texture == null, "Old flattened background is unloaded")
	_expect(art.position == Vector2(0,106.25) and art.scale == Vector2(.9375,.9375), "Original corridor scale and walking baseline are retained")
	_expect(player.global_position == Vector2(192,560), "Spawn is unchanged")
	for pair in [["SecuritySlot",800,"SECURITY"],["CleanerSlot",1600,"CLEANER"],["ManagerSlot",2400,"MANAGER"]]:
		var slot: Node2D = floor_node.get_node("StaffRoot/" + pair[0])
		_expect(slot.global_position == Vector2(pair[1],560) and slot.get_node("Staff").card_id == pair[2], "Existing staff positions and roles are unchanged")
	_expect(floor_node.get_node("Interactions/ExitPoint").global_position == Vector2(3400,560), "Stair interaction position is unchanged")
	_check_art(art)
	_expect(player.z_index == 1 and floor_node.get_node("StaffRoot").z_index == 1 and art.get_node("Foreground").z_index == 2, "Foreground is above player and all staff")
	for pair in [["lounge_utility_column",2768],["utility_stairs_column",3374]]:
		var column: Sprite2D = art.get_node("Foreground/" + pair[0])
		var sample: Vector2 = column.to_local(art.to_global(Vector2(pair[1],430))) + column.region_rect.position
		_expect(column.texture.get_image().get_pixelv(Vector2i(sample)).a > .9, "Generated column covers the character torso at crossing")
		var center_x: float = pair[1] * .9375
		for direction in [1,-1]:
			player.global_position = Vector2(center_x - direction*75,560)
			await _settle()
			var action: String = "move_right" if direction == 1 else "move_left"
			Input.action_press(action)
			for frame in range(80):
				await physics_frame
				if (player.global_position.x-center_x)*direction > 65:
					break
			Input.action_release(action)
			_expect((player.global_position.x-center_x)*direction > 65 and is_equal_approx(player.global_position.y,560), "Real player crosses foreground column in both directions without blocking")
	player.global_position = Vector2(2400,560)
	await _settle()
	_expect(floor_node.get_interaction_target_id() == "MANAGER_TALK", "Manager remains selectable through the art")
	await _key(true)
	await _key(false)
	_expect(main._active_dialogue_id == "V4_MANAGER_TALK", "Real E still opens manager dialogue")
	for i in range(200):
		if main._active_dialogue_id.is_empty():
			break
		main.dialogue.get_node("%ContinueButton").pressed.emit()
		await process_frame
	_expect(game.has_completed_manager_intro() and game.is_world_input_allowed(), "Real manager dialogue completion unlocks stairs and releases input")
	player.global_position.x = 3400
	await _settle()
	await _key(true)
	await _key(false)
	var overlay: Control = main.get_node("TaskLayer/PlayOverlay")
	_expect(overlay.visible and not game.is_world_input_allowed(), "Real stair E opens the floor selector and its modal")
	var destination: Button
	for choice: Button in overlay.get("_choices").get_children():
		if choice.text == "2F":
			destination = choice
			break
	_expect(destination != null, "The actual floor selector offers unlocked 2F")
	if destination != null:
		destination.pressed.emit()
		await _settle()
	_expect(game.current_floor == 2 and not overlay.visible and game.is_world_input_allowed(), "Selecting 2F in the real stair UI reaches the destination and releases its modal")
	main.queue_free()
	await process_frame
	DirAccess.remove_absolute(progress_path)
	print("FLOOR_1_ART: ", "PASS" if failures == 0 else "FAIL")
	quit(0 if failures == 0 else 1)
