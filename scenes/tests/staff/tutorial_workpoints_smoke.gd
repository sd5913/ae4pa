extends SceneTree
## Exercises real B work-point identity, hold, range and one-shot behavior.

var failures: Array[String] = []
var _work_events: Array[String] = []
var _clean_events: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var cases: Array[Dictionary] = [
		{"scene": "room_service_203", "target": "ROOM_SERVICE_203", "right": "MANAGER", "wrong": "SECURITY", "type": "AUTHORIZE", "hold": false},
		{"scene": "stain_204", "target": "STAIN_204", "right": "CLEANER", "wrong": "SECURITY", "type": "CLEAN", "hold": true},
		{"scene": "patrol_cabinet_204", "target": "PATROL_CABINET_204", "right": "SECURITY", "wrong": "MANAGER", "type": "PICKUP", "hold": false},
		{"scene": "transit_pickup_205", "target": "TRANSIT_PICKUP_205", "right": "SECURITY", "wrong": "MANAGER", "type": "PICKUP", "hold": false},
		{"scene": "transit_register_205", "target": "TRANSIT_REGISTER_205", "right": "MANAGER", "wrong": "SECURITY", "type": "AUTHORIZE", "hold": false},
	]
	for work_case: Dictionary in cases:
		var path: String = "res://scenes/work/%s.tscn" % work_case.scene
		if not ResourceLoader.exists(path):
			_expect(false, "Missing tutorial work point: " + path)
			continue
		await _check_work_point(path, work_case)
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS: five tutorial work points reject wrong identity/inactive/range, hold cleaning, and emit each real result once.")
	quit(0 if failures.is_empty() else 1)


func _check_work_point(path: String, work_case: Dictionary) -> void:
	var game: Node = root.get_node("GameManager")
	var cards: Node = root.get_node("CardManager")
	game.call("start_game")
	cards.call("collect_card", work_case.wrong)
	cards.call("collect_card", work_case.right)
	var player: Node2D = load("res://scenes/player/player.tscn").instantiate()
	root.add_child(player)
	player.global_position = Vector2(800, 560)
	var point: Node2D = load(path).instantiate()
	root.add_child(point)
	point.global_position = Vector2(800, 560)
	point.call("setup", player)
	var state: Dictionary = point.call("get_interaction_state")
	_expect(state.interaction_type == work_case.type, "%s must expose the correct work type to UI" % work_case.target)
	point.connect("work_requested", func(target: String) -> void: _work_events.append(target))
	point.connect("cleaning_completed", func(target: String) -> void: _clean_events.append(target))
	_work_events.clear()
	_clean_events.clear()
	await _wait_for_range(point, true)
	_expect(point.call("is_player_in_range"), "%s must detect the real player body" % work_case.target)
	_expect(not point.call("begin_interaction"), "%s must reject inactive task" % work_case.target)
	point.call("set_task_active", true)
	_expect(not point.call("begin_interaction"), "%s must reject active wrong identity" % work_case.target)
	_expect(_work_events.is_empty(), "%s wrong identity emitted a result" % work_case.target)
	cards.call("switch_active")
	point.call("set_task_active", false)
	_expect(not point.call("begin_interaction"), "%s must reject inactive task even with the required identity" % work_case.target)
	point.call("set_task_active", true)
	player.global_position.x = 1200
	await _wait_for_range(point, false)
	_expect(not point.call("begin_interaction"), "%s must reject out-of-range interaction" % work_case.target)
	player.global_position.x = 800
	await _wait_for_range(point, true)
	player.set("is_moving", false)
	_expect(point.call("begin_interaction"), "%s must accept the required active identity" % work_case.target)
	if work_case.hold:
		point.call("advance_interaction", 0.75)
		_expect(_work_events.is_empty() and not point.call("is_completed"), "STAIN_204 must not complete after a half hold")
		point.call("cancel_interaction")
		point.call("advance_interaction", 1.5)
		_expect(_work_events.is_empty(), "STAIN_204 cancelled hold must not report completion")
		_expect(point.call("begin_interaction"), "STAIN_204 must restart after cancellation")
		point.call("advance_interaction", 1.5)
	_expect(point.call("is_completed"), "%s must retain completed state" % work_case.target)
	_expect(_work_events == [work_case.target], "%s must emit its target exactly once" % work_case.target)
	_expect(_clean_events == (["STAIN_204"] if work_case.hold else []), "%s cleaning event must match actual CLEAN completion" % work_case.target)
	_expect(not point.call("begin_interaction"), "%s completed point must reject repeated interaction" % work_case.target)
	point.call("advance_interaction", 2.0)
	_expect(_work_events == [work_case.target], "%s completion result repeated" % work_case.target)
	_expect(not point.get_node("Hint").visible, "%s completed point must hide its hint" % work_case.target)
	point.queue_free()
	player.queue_free()
	await process_frame


func _wait_for_range(point: Node, expected: bool) -> void:
	# PhysicsServer publishes body entered/exited after the physics-frame signal.
	for frame: int in range(10):
		await physics_frame
		await process_frame
		if point.call("is_player_in_range") == expected:
			return


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
