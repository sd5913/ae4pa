extends SceneTree
## Checks imported full-canvas geometry and real inherited door transitions.

var failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1


func _run() -> void:
	var door = load("res://scenes/doors/room_201_door.tscn").instantiate()
	root.add_child(door)
	door.set_process(false)
	var art = door.get_node("Art")
	var sprite: Sprite2D = art.get_node("Sprite2D")
	var original_transform: Transform2D = sprite.global_transform
	var original_rect: Rect2 = sprite.get_rect()
	for phase: float in [0.0, 5.6, 7.0, 0.0]:
		door.offset = phase
		door.reset_cycle()
		var expected: String = "OPEN" if phase == 7.0 else ("WARNING" if phase == 5.6 else "CLOSED")
		_expect(door.door_state == expected and art.state == expected, "Cycle drives PNG state")
		_expect(sprite.texture.get_size() == Vector2(1280, 1280), "Imported texture retains canvas")
		_expect(sprite.get_rect() == original_rect and original_rect.size == Vector2(1280, 1280), "No state cropping")
		_expect(sprite.global_transform == original_transform, "Switching preserves scale and anchor")
		_expect(not sprite.region_enabled and not sprite.centered, "Full canvas sprite")
		_expect(sprite.position == Vector2(-640, -1280), "Shared canvas bottom-center anchor")
		_expect(sprite.texture.resource_path.ends_with("door_" + expected.to_lower() + ".png"), "Correct source texture")
		_expect(not door.get_node("MonsterPlaceholder").visible and not door.get_node("Frame").visible, "No placeholder overlap")
	art.set_state("INVALID")
	_expect(art.state == "CLOSED", "Invalid state preserves previous texture")
	door.queue_free()
	await process_frame
	print("ROOM_201_ART: ", "PASS" if failures == 0 else "FAIL")
	quit(0 if failures == 0 else 1)
