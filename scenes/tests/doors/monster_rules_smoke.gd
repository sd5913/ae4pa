extends SceneTree

var failures: Array[String] = []
var cases: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: Node = load("res://scenes/tests/doors/doors_test.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var door = scene.get_node("DoorSlot/Door201")
	var player = scene.get_node("Corridor/Player")
	var manager = root.get_node("GameManager")
	var cards = root.get_node("CardManager")
	for instance: Node in scene.get_node("DoorSlot").get_children():
		instance.set_process(false)
		instance.set_physics_process(false)
	player.set_physics_process(false)
	scene.get_node("DoorSlot").position.x += 200.0
	var required: Dictionary = {"EYE": "SECURITY", "NOSE": "CLEANER", "HAT": "MANAGER"}
	for kind: String in ["EYE", "NOSE", "HAT", "EAR", "CHECKER"]:
		door.monster_type = kind
		for state: String in ["CLOSED", "WARNING", "OPEN"]:
			for distance: float in [-90.1, -90.0, 0.0, 90.0, 90.1]:
				for card: String in ["NONE", "SECURITY", "CLEANER", "MANAGER"]:
					for moving: bool in [false, true]:
						manager.start_game()
						door.reset_cycle()
						if card != "NONE":
							cards.collect_card(card)
						player.global_position.x = door.global_position.x + distance
						player.is_moving = moving
						if state == "WARNING":
							door._process(5.6)
						elif state == "OPEN":
							door._process(7.0)
						door._physics_process(0.0)
						var active: bool = state == "OPEN" and absf(distance) <= 90.0
						var danger: bool = active and ((required.has(kind) and card != required[kind]) or (kind == "EAR" and moving))
						_expect((manager.game_state == "FAILED") == danger, "Rule matrix %s %s %s %s %s" % [kind, state, distance, card, moving])
						if danger:
							_expect(manager.fail_reason == ("MOVED_NEAR_EAR" if kind == "EAR" else "WRONG_CARD"), "Correct failure reason")
						cases += 1
	# CHECKER is event-driven: use real B operations in each state and range.
	door.monster_type = "CHECKER"
	for state: String in ["CLOSED", "WARNING", "OPEN"]:
		for distance: float in [-90.1, -90.0, 0.0, 90.0, 90.1]:
			for operation: String in ["SWITCH_ACTIVE", "EQUIP_CARD"]:
				manager.start_game()
				door.reset_cycle()
				cards.collect_card("SECURITY")
				cards.collect_card("CLEANER")
				cards.collect_card("MANAGER")
				player.global_position.x = door.global_position.x + distance
				if state != "CLOSED":
					door._process(5.6 if state == "WARNING" else 7.0)
				if operation == "SWITCH_ACTIVE":
					cards.switch_active()
				else:
					cards.equip_card("MANAGER", 1 - cards.active_slot)
				var danger: bool = state == "OPEN" and absf(distance) <= 90.0
				_expect((manager.game_state == "FAILED") == danger, "Checker %s %s %s" % [state, distance, operation])
				if danger:
					_expect(manager.fail_reason == "SWITCHED_NEAR_CHECKER", "Checker reason")
	# Data refresh, collection and invalid/no-op equip must not imitate identity changes.
	manager.start_game()
	door.reset_cycle()
	player.global_position.x = door.global_position.x
	door._process(7.0)
	cards.collect_card("SECURITY")
	cards.cards_changed.emit()
	cards.equip_card("SECURITY", cards.active_slot)
	cards.equip_card("INVALID", 0)
	_expect(manager.game_state == "PLAYING", "Refresh/collect/no-op equip are safe")
	for index: int in range(3):
		door.setup(player)
	var handlers: int = 0
	for connection: Dictionary in cards.identity_changed.get_connections():
		if connection.callable.get_object() == door:
			handlers += 1
	_expect(handlers == 1, "Repeated setup connects only once")
	paused = true
	cards.switch_active()
	_expect(manager.game_state == "PLAYING", "Paused checker ignores events")
	paused = false
	door.setup(null)
	cards.switch_active()
	_expect(manager.game_state == "PLAYING", "Unbound checker is safe")
	door.setup(player)
	# Read real movement after Player, not the previous frame's state.
	door.monster_type = "EAR"
	player.is_moving = false
	player.set_physics_process(true)
	door.set_physics_process(true)
	Input.action_press("move_right")
	await physics_frame
	await physics_frame
	Input.action_release("move_right")
	_expect(manager.fail_reason == "MOVED_NEAR_EAR", "Ear sees real first-frame movement")
	door.set_physics_process(false)
	player.set_physics_process(false)
	# Removing a door must detach its signal even before freeing it.
	door.monster_type = "CHECKER"
	var parent: Node = door.get_parent()
	parent.remove_child(door)
	_expect(not cards.identity_changed.is_connected(Callable(door, "_on_identity_changed")), "Exit disconnects identity handler")
	manager.start_game()
	cards.switch_active()
	_expect(manager.game_state == "PLAYING", "Removed checker cannot fail a new session")
	door.free()
	scene.queue_free()
	await process_frame
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS C-06/07/08: ", cases, " rule cases, 30 real switch/equip cases, event isolation, pause, binding, movement order, lifecycle.")
	quit(0 if failures.is_empty() else 1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
