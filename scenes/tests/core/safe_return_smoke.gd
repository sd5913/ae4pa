extends SceneTree
## Requires C's real V4 component (1379a16 or later); never substitutes a fake door.

var failures: Array[String] = []
var game: Node
var cards: Node
var host: Node2D


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	game = root.get_node("GameManager")
	cards = root.get_node("CardManager")
	if not game.has_method("request_safe_return"):
		printerr("FAIL: A must implement request_safe_return")
		quit(1)
		return
	var probe: Node = load("res://scenes/doors/monster_door.tscn").instantiate()
	var has_v4: bool = probe.has_method("finish_safe_return")
	probe.free()
	if not has_v4:
		printerr("BLOCKED: sync C PR #12 before running the real-door integration check")
		quit(2)
		return
	host = Node2D.new()
	root.add_child(host)
	game.call("set_floor_host", host)
	game.call("start_game")
	game.call("complete_manager_intro")
	host.get_child(0).get_node("Player").global_position.x = 3400.0
	game.call("request_floor_travel", 2)
	var floor_node: Node = host.get_child(0)
	var player: Node2D = floor_node.get_node("Player")
	var story: Node = floor_node.get_node_or_null("DoorRoot/Room201/Door")
	var normal: Node = floor_node.get_node_or_null("DoorRoot/Room202/Door")
	if story == null or normal == null:
		_expect(false, "A instantiates real 201 and one ordinary door")
		await _finish()
		return
	game.set_process(false) # Advance the real task timer explicitly for deterministic checks.
	player.global_position.x = 700.0
	await physics_frame
	await physics_frame
	_expect(game.get("task_status") == "AVAILABLE" and game.get("remaining_time") == 0.0, "Real story interception offers without starting time")
	game.call("accept_task", "TASK_01_CLEAN")
	cards.call("collect_card", "CLEANER")
	game.call("record_work_result", "STAIN_201") # B work component remains undelivered.
	await _action(true)
	await _action(false)
	_expect(game.get("task_status") == "COMPLETED", "Unique E submits through the real 201 request")
	_expect(game.call("get_world_flags").get("passage_201_unlocked", false), "Delivery opens the route before ordinary-door tests")
	var flags: Dictionary = game.call("get_world_flags")
	var inventory: Array = cards.call("get_owned_cards")
	var time_before: float = game.get("remaining_time")
	# A stale/unregistered source or unknown direction must not move the player.
	var foreign := Node2D.new()
	root.add_child(foreign)
	player.global_position.x = 1300.0
	game.call("request_safe_return", foreign, "WRONG_CARD", -1)
	game.call("request_safe_return", normal, "WRONG_CARD", 0)
	_expect(player.global_position.x == 1300.0, "Invalid sources and unknown approach sides cannot teleport")
	foreign.queue_free()
	# Real C records entry from outside, then reports wrong identity inside OPEN.
	for side: int in [-1, 1]:
		player.global_position.x = 1550.0 + side * 180.0
		normal.set("door_state", "CLOSED")
		await physics_frame
		await physics_frame
		normal.set_process(false)
		normal.set("door_state", "OPEN")
		# Cross the door centre in one frame; entry evidence, not facing/current side, wins.
		player.global_position.x = 1550.0 - side * 20.0
		await physics_frame
		await process_frame
		await process_frame
		_expect(player.global_position.x == (1400.0 if side == -1 else 1700.0), "Real ordinary violation returns to its approach side")
		_expect(game.get("game_state") == "PLAYING", "Safe return resumes play without task failure")
		_expect(not player.is_moving, "Teleport does not count as EAR movement")
	_expect(game.call("get_world_flags") == flags and cards.call("get_owned_cards") == inventory, "Safe return preserves world and card truth")
	_expect(game.get("remaining_time") == time_before, "Safe return never resets task time")
	# A-state fixture isolates a running task from the still unavailable task-02 gameplay.
	game.set("task_status", "ACTIVE")
	game.set("remaining_time", 37.5)
	normal.set("door_state", "CLOSED")
	await physics_frame
	player.global_position.x = 1530.0
	game.call("request_safe_return", normal, "WRONG_CARD", -1)
	game.call("_process", 5.0)
	_expect(game.get("remaining_time") == 37.5 and game.get("task_status") == "ACTIVE", "Return locks preserve a running task and stop only the return interval")
	await process_frame
	await process_frame
	game.call("_process", 1.0)
	_expect(game.get("remaining_time") == 36.5, "The same task clock continues after return")
	await physics_frame
	# Registered points are revalidated after layout/radius changes.
	var left_point: Node2D = floor_node.get_node("Interactions/Room202LeftSafe")
	left_point.position.x = 700.0
	player.global_position.x = 1530.0
	game.call("request_safe_return", normal, "WRONG_CARD", -1)
	_expect(player.global_position.x == 1530.0, "A rejects a safe point inside the story region")
	left_point.position.x = 1400.0
	game.set("_world_flags", {}) # Locked-route fixture: returning across x1250 is forbidden.
	floor_node.call("_apply_task_route")
	left_point.position.x = 1120.0
	player.global_position.x = 1530.0
	game.call("request_safe_return", normal, "WRONG_CARD", -1)
	_expect(player.global_position.x == 1530.0, "Safe return cannot cross the undelivered route lock")
	game.set("_world_flags", flags)
	floor_node.call("_apply_task_route")
	left_point.position.x = 1400.0
	# One synchronous batch cannot cause two returns, and new-floor sources stay isolated.
	await physics_frame
	normal.set("door_state", "CLOSED")
	player.global_position.x = 1530.0
	game.call("request_safe_return", normal, "WRONG_CARD", -1)
	game.call("request_safe_return", normal, "WRONG_CARD", 1)
	_expect(player.global_position.x == 1400.0, "Same-frame requests cannot return twice")
	await process_frame
	await process_frame
	player.global_position.x = 192.0
	_expect(game.call("request_floor_travel", 1), "Return releases movement and stair input")
	var new_player: Node2D = host.get_child(0).get_node("Player")
	var arrival: Vector2 = new_player.global_position
	game.call("request_safe_return", normal, "WRONG_CARD", -1)
	_expect(new_player.global_position == arrival, "Removed-floor source cannot move the new player")
	await _finish()


func _action(pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = pressed
	Input.parse_input_event(event)
	await process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	game.set_process(true)
	host.queue_free()
	await process_frame
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS: real C story/E integration, dual-side safe returns, guards and persistence.")
	quit(0 if failures.is_empty() else 1)
