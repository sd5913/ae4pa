extends SceneTree
const Catalog = preload("res://scenes/doors/v4_door_catalog.gd")
var failures: Array[String] = []
var events: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var rows: Array[Dictionary] = Catalog.get_rows()
	_expect(rows.size() == 20, "20 room configurations")
	var tasks := ["TASK_01_CLEAN", "TASK_02_PARCEL", "TASK_03_AUTHORIZE", "TASK_04_PATROL", "TASK_05_EXIT"]
	var found: Array[String] = []
	var game: Node = root.get_node("GameManager")
	game.start_game()
	var player: Node2D = load("res://scenes/player/player.tscn").instantiate()
	root.add_child(player)
	player.set_physics_process(false)
	for row: Dictionary in rows:
		var door: Node2D = load("res://scenes/doors/monster_door.tscn").instantiate()
		_expect(Catalog.configure(door, row.room), "Configure " + row.room)
		_expect(door.monster_type == row.monster and door.room_id == row.room, "Room and monster preserved")
		if not row.task.is_empty():
			found.append(row.task)
			var definition: Dictionary = root.get_node("GameManager").get_task_definition(row.task)
			_expect(definition.get("room_id") == row.room and definition.get("offer_floor") == row.floor, "A task IDs match")
			_expect(door.door_mode == "STORY" and door.story_radius == 120.0, "Story override excludes ordinary detection")
		else:
			_expect(door.door_mode == "NORMAL", "Ordinary room has no task")
		_expect(door.closed_time == 5.0 and door.warning_time == 1.5 and door.open_time == 3.0, "New trial timing")
		root.add_child(door)
		door.set_process(false)
		door.set_physics_process(false)
		door.setup(player)
		if not row.task.is_empty():
			door.story_intercept_requested.connect(func(_task: String, _room: String): events.append("INTRO"))
			door.task_submit_requested.connect(func(_task: String): events.append("SUBMIT"))
			door.rule_violated.connect(func(_reason: String, _side: int): events.append("VIOLATION"))
			for phase: float in [0.0, 5.1, 6.6]:
				door.set_story_state("FAILED")
				door.set_story_state("NONE")
				door.offset = phase
				door.reset_cycle()
				events.clear()
				player.position = Vector2(-200, 0)
				door._physics_process(0.0)
				player.position = Vector2.ZERO
				door._physics_process(0.0)
				door._physics_process(0.0)
				_expect(events == ["INTRO"], "Five story types intercept once regardless of phase: " + row.room)
				door.set_story_state("ACTIVE")
				_expect(not door.request_interaction(), "Work not ready cannot submit")
				door.set_story_state("READY_TO_SUBMIT")
				_expect(door.request_interaction() and not door.request_interaction(), "Exactly one E request, not task truth")
				_expect(events == ["INTRO", "SUBMIT"], "Story and ordinary rules remain exclusive")
		for phase: float in [0.0, 5.1, 6.6, -1.0]:
			door.offset = phase
			door.reset_cycle()
			var first: String = door.door_state
			door._process(0.0)
			door.reset_cycle()
			_expect(door.door_state == first, "Configured phase reset stable")
		Catalog.configure(door, row.room, false)
		_expect(door.closed_time == 5.5 and door.warning_time == 1.4 and door.open_time == 2.8, "Historical comparison timing preserved")
		_expect(not Catalog.configure(door, "999"), "Unknown room rejected")
		door.free()
	_expect(found == tasks, "Five task doors in order")
	player.queue_free()
	var copied: Array[Dictionary] = Catalog.get_rows(5)
	copied[0].monster = "INVALID"
	_expect(Catalog.get_rows(5)[0].monster == "HAT", "Configuration copies cannot mutate catalog")
	var preview: Node = load("res://scenes/tests/doors/v4_catalog_preview.tscn").instantiate()
	root.add_child(preview)
	await process_frame
	_expect(preview.get_child_count() == 7, "F6 mounts corridor, label and five real doors")
	preview.queue_free()
	await process_frame
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS C-V4-05: 20 rooms, five task IDs, trial/historical timings, reset phases, independent five-door F6. Production routes and unconfirmed policies remain pending.")
	quit(0 if failures.is_empty() else 1)


func _expect(value: bool, message: String) -> void:
	if not value:
		failures.append(message)
