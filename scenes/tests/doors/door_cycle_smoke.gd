extends SceneTree
## Run with --headless --path . --script res://scenes/tests/doors/door_cycle_smoke.gd

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: Node = load("res://scenes/tests/doors/doors_test.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var manager = root.get_node("GameManager")
	var door = scene.get_node("DoorSlot/Door201")
	var other = scene.get_node("DoorSlot/Door202")
	door.set_process(false)
	other.set_process(false)
	manager.start_game()
	door.reset_cycle()
	for cycle: int in range(20):
		_expect(door.door_state == "CLOSED", "Cycle starts closed")
		door._process(5.49)
		_expect(door.door_state == "CLOSED", "Closed lasts 5.5 seconds")
		door._process(0.02)
		_expect(door.door_state == "WARNING", "Warning begins after closed")
		_expect(not door.get_node("MonsterPlaceholder").visible, "Warning hides monster")
		door._process(1.38)
		_expect(door.door_state == "WARNING", "Warning lasts 1.4 seconds")
		door._process(0.02)
		_expect(door.door_state == "OPEN", "Open follows warning")
		_expect(door.get_node("MonsterPlaceholder").visible, "Open shows monster")
		door._process(2.78)
		_expect(door.door_state == "OPEN", "Open lasts 2.8 seconds")
		door._process(0.01)
	# Previous loop totals exactly 9.7 s; check overflow and independent instances.
	_expect(other.door_state == "CLOSED", "Each instance has independent clock")
	door.reset_cycle()
	door._process(9.7 * 100.0 + 7.0)
	_expect(door.door_state == "OPEN", "Long frame retains cycle remainder")
	manager.fail("WRONG_CARD")
	door._process(100.0)
	_expect(door.door_state == "OPEN", "Failed state freezes clock")
	door.reset_cycle()
	_expect(door.door_state == "CLOSED", "Reset restores closed visuals")
	_expect(not door.get_node("MonsterPlaceholder").visible, "Reset hides monster")
	# Verify the engine's real frame processing, not only manual advancement.
	manager.start_game()
	door.closed_time = 0.1
	door.warning_time = 0.1
	door.open_time = 0.1
	# Resource loading can make the first engine delta span multiple tiny phases.
	# Warm the real frame loop before measuring; overflow is tested above.
	await create_timer(0.2).timeout
	await process_frame
	door.reset_cycle()
	door.set_process(true)
	var observed: Array[String] = ["CLOSED"]
	var deadline: int = Time.get_ticks_msec() + 3000
	while Time.get_ticks_msec() < deadline:
		await process_frame
		if door.door_state != observed.back():
			observed.append(door.door_state)
		if observed.size() >= 7:
			break
	_expect(observed == ["CLOSED", "WARNING", "OPEN", "CLOSED", "WARNING", "OPEN", "CLOSED"], "Real frames repeat two full cycles: " + str(observed))
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS C-02: default durations, 20 cycles, overflow, independent clocks, failure freeze, reset, real frame cycles.")
	scene.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
