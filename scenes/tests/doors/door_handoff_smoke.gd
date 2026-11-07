extends SceneTree

var failures: Array[String] = []
var failure_events: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: Node = load("res://scenes/tests/doors/multi_doors_test.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var doors: Array[Node] = scene.get_node("DoorSlot").get_children()
	var player = scene.get_node("Corridor/Player")
	var manager = root.get_node("GameManager")
	player.set_physics_process(false)
	for door: Node in doors:
		door.set_process(false)
		door.set_physics_process(false)
	var exposed: Array[String] = []
	for prop: Dictionary in doors[0].get_property_list():
		if prop.usage & PROPERTY_USAGE_EDITOR:
			exposed.append(prop.name)
	for field: String in ["room_id", "monster_type", "radius", "closed_time", "warning_time", "open_time", "offset"]:
		_expect(field in exposed, "Inspector exports " + field)
	var door = doors[0]
	for phase: float in [0.0, 5.6, 7.0, 26.4, -2.7]:
		door.offset = phase
		door.reset_cycle()
		var expected: String = "CLOSED" if phase == 0.0 else ("WARNING" if phase == 5.6 else "OPEN")
		_expect(door.door_state == expected, "Normalized offset selects phase")
		door._process(1.0)
		door.reset_cycle()
		_expect(door.door_state == expected, "Reset reproduces configured phase")
	door.offset = 0.0
	door.closed_time = 1.0
	door.warning_time = 0.5
	door.open_time = 0.75
	door.offset = 1.6
	door.reset_cycle()
	_expect(door.door_state == "OPEN", "Custom timings define offset period")
	door.closed_time = 5.5
	door.warning_time = 1.4
	door.open_time = 2.8
	door.offset = 0.0
	# All gaps exceed the design's 120px minimum with no overlapping danger zones.
	for index: int in range(doors.size() - 1):
		var gap: float = doors[index + 1].global_position.x - doors[index].global_position.x - doors[index].radius - doors[index + 1].radius
		_expect(gap >= 120.0, "Safe waiting gap >= 120px")
	manager.start_game()
	for item: Node in doors:
		item.reset_cycle()
		item._process(2.0)
	_expect(doors[0].door_state == "CLOSED" and doors[1].door_state == "CLOSED" and doors[2].door_state == "WARNING", "Three phases diverge")
	# Walk the actual shared Player through all three doors without granting cards.
	# Wait outside each radius until CLOSED; 180px crossing takes 1.125s at 160px/s.
	for start_time: float in [0.0, 1.0, 4.0, 6.0, 9.0]:
		manager.start_game()
		player.global_position.x = 192.0
		for item: Node in doors:
			item.reset_cycle()
			item._process(start_time)
		var target_index: int = 0
		var crossing: bool = false
		for tick: int in range(6000):
			var target = doors[target_index]
			var approach: float = target.global_position.x - target.radius - 12.0
			if player.global_position.x < approach or crossing:
				Input.action_press("move_right")
			elif target.door_state == "CLOSED":
				crossing = true
				Input.action_press("move_right")
			else:
				Input.action_release("move_right")
			for item: Node in doors:
				item._process(1.0 / 60.0)
			player._physics_process(1.0 / 60.0)
			for item: Node in doors:
				item._physics_process(1.0 / 60.0)
			if manager.game_state == "FAILED":
				break
			if player.global_position.x > target.global_position.x + target.radius + 12.0:
				target_index += 1
				crossing = false
				if target_index == doors.size():
					break
		Input.action_release("move_right")
		_expect(target_index == 3 and manager.game_state == "PLAYING", "Wait-and-walk route succeeds from start " + str(start_time))
	# Failure notification is synchronous and accepted just once per attempt.
	manager.game_failed.connect(_on_failed)
	for kind: String in ["EYE", "EAR", "CHECKER"]:
		manager.start_game()
		failure_events = 0
		door.monster_type = kind
		door.offset = 7.0
		door.reset_cycle()
		player.global_position.x = door.global_position.x
		player.is_moving = true
		if kind == "CHECKER":
			root.get_node("CardManager").switch_active()
		else:
			door._physics_process(0.0)
		door._physics_process(0.0)
		root.get_node("CardManager").switch_active()
		_expect(failure_events == 1, "One unified failure event for " + kind)
	manager.game_failed.disconnect(_on_failed)
	scene.queue_free()
	await process_frame
	# Compatibility probe only: instantiate the same component at A's 20 markers.
	# This does not alter A's saved floor scenes or claim a playable main flow.
	for floor_number: int in range(2, 6):
		manager.start_game()
		var floor_scene: Node = load("res://scenes/levels/floor_%d.tscn" % floor_number).instantiate()
		root.add_child(floor_scene)
		var slots: Array[Node] = floor_scene.get_node("DoorRoot").get_children()
		_expect(slots.size() == 5, "Floor provides five room markers")
		for index: int in range(slots.size()):
			var slot = slots[index]
			var instance = load("res://scenes/doors/monster_door.tscn").instantiate()
			instance.room_id = str(slot.get_meta("room_number"))
			instance.monster_type = slot.get_meta("monster_type")
			instance.offset = float(index) * 0.8
			slot.add_child(instance)
			instance.setup(floor_scene.get_node("Player"))
			_expect(instance.global_position == slot.global_position, "Door aligns to floor marker")
			_expect(instance.get_node("RoomNumber").text == instance.room_id, "Room number matches marker")
			if index > 0:
				_expect(slot.global_position.x - slots[index - 1].global_position.x - 180.0 >= 120.0, "Floor marker gap is safe")
		floor_scene.queue_free()
		await process_frame
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS C-09~13: inspector fields, signed/wrapped offsets, reset, custom periods, 520px gaps, five no-card wait-and-walk routes, failure event deduplication, 20 floor-marker placements.")
	quit(0 if failures.is_empty() else 1)


func _on_failed(_reason: String) -> void:
	failure_events += 1


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
