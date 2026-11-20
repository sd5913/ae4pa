extends SceneTree

var failures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _expect(value: bool, message: String) -> void:
	if not value:
		push_error(message)
		failures += 1

func _run() -> void:
	var preview = load("res://scenes/tests/doors/floor_2_layout_preview.tscn").instantiate()
	root.add_child(preview)
	await process_frame
	var art = preview.get_node("Floor2Art")
	_expect(art.get_node("Doors/Room204").state == "WARNING" and art.get_node("Doors/Room205").state == "OPEN", "Reference pose preserves warning 204 and open 205")
	var transforms: Dictionary = {}
	for room: Node2D in art.get_node("Doors").get_children():
		transforms[room.name] = room.transform
	for state: String in ["CLOSED","WARNING","OPEN"]:
		preview._pose(state)
		for room: Node2D in art.get_node("Doors").get_children():
			_expect(room.state == state and room.transform == transforms[room.name], "Five doors switch state without transform changes")
			_expect(room.get_node("Sprite2D").texture.get_size() == Vector2(1280,1280), "All state textures retain full canvas")
	var start: float = preview.get_node("Player").position.x
	Input.action_press("move_right")
	# Wait for actual input/physics frames; cold texture loading can consume a
	# wall-clock timer before the first physics tick in headless runs.
	for i in range(12): await physics_frame
	Input.action_release("move_right")
	_expect(preview.get_node("Player").position.x > start, "Walk-through player can move without task fixtures")
	_expect(not art.has_node("Foreground/LeftRail") and not art.has_node("Foreground/RightRail"), "Detached foreground stair railings are removed")
	for side: String in ["Left", "Right"]:
		var stair: Sprite2D = art.get_node("Travel/" + side + "Stairs")
		_expect(stair.texture.resource_path.ends_with("stairs_" + side.to_lower() + "_integrated.png"), "Stairs and railing use one integrated PNG per side")
		_expect(stair.get_children().is_empty() and stair.get_script() == null, "Integrated stairs add no collision or input components")
		_expect(art.get_node("Travel").z_index < preview.get_node("Player").z_index, "Entire stairwell including railing is behind player")
	for stair_x: float in [280.0,3400.0]:
		preview.get_node("Player").position = Vector2(stair_x-45,560)
		Input.action_press("move_right")
		await create_timer(.65).timeout
		Input.action_release("move_right")
		_expect(preview.get_node("Player").position.x > stair_x+45, "Player can walk past either integrated stairwell")
		Input.action_press("move_left")
		await create_timer(.65).timeout
		Input.action_release("move_left")
		_expect(preview.get_node("Player").position.x < stair_x-30, "Player can return past either stairwell without blocking")
	preview.queue_free()
	await process_frame
	var floor_node = load("res://scenes/levels/floor_2.tscn").instantiate()
	root.add_child(floor_node)
	await process_frame
	art = floor_node.get_node("Floor2Art")
	_expect(floor_node.get_node("FloorBackground").texture == null, "Modular floor does not overlay the old baked corridor")
	for room_id: String in ["201","202"]:
		var door = floor_node.get_node("DoorRoot/Room" + room_id + "/Door")
		var visual = art.get_node("Doors/Room" + room_id)
		_expect(is_equal_approx(door.global_position.x,visual.global_position.x), "Art and actual detection centres match")
		var bottom: float = visual.global_position.y - 31.0 * visual.global_scale.y
		_expect(absf(bottom-560.0)<0.001,"Door threshold aligns with actual walking ground")
		_expect(not door.visible,"Old placeholder visuals are hidden")
		door.set_process(false)
		door.offset = 5.6
		door.reset_cycle()
		await process_frame
		await process_frame
		_expect(visual.state == "WARNING", "Real door cycle drives modular art state")
	_expect(floor_node.get_node("Player").z_index < art.get_node("Foreground").z_index,"Existing foreground columns retain their layer")
	_expect(floor_node.get_node("Interactions/ReturnPoint").position == Vector2(192,560) and floor_node.get_node("Interactions/ExitPoint").position == Vector2(3400,560), "Stair interaction anchors are unchanged")
	floor_node.queue_free()
	await process_frame
	print("FLOOR_2_LAYOUT: ","PASS" if failures == 0 else "FAIL")
	quit(0 if failures == 0 else 1)
