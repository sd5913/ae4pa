extends SceneTree

var failures: Array[String] = []


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
	# Shift the parent to catch accidental local/global coordinate comparisons.
	scene.get_node("DoorSlot").position.x += 200.0
	for state: String in ["CLOSED", "WARNING", "OPEN"]:
		for distance: float in [-90.1, -90.0, 0.0, 90.0, 90.1]:
			for card: String in ["NONE", "SECURITY", "CLEANER", "MANAGER"]:
				manager.start_game()
				if card != "NONE":
					cards.collect_card(card)
				player.global_position.x = door.global_position.x + distance
				door.reset_cycle()
				if state == "WARNING":
					door._process(5.6)
				elif state == "OPEN":
					door._process(7.0)
				_expect(door.get_node("WarningLabel").visible == (state == "WARNING"), "Warning text matches state")
				_expect(door.get_node("MonsterPlaceholder").visible == (state == "OPEN"), "Monster visibility matches state")
				door._physics_process(0.0)
				var danger: bool = state == "OPEN" and absf(distance) <= 90.0 and card != "SECURITY"
				_expect((manager.game_state == "FAILED") == danger, "%s %s %s" % [state, distance, card])
				if danger:
					_expect(manager.fail_reason == "WRONG_CARD", "Uses unified failure reason")
	manager.start_game()
	door.setup(null)
	door._process(0.0)
	door._physics_process(0.0)
	_expect(manager.game_state == "PLAYING", "Unbound door is safe")
	door.setup(player)
	door.setup(player)
	door.reset_cycle()
	door._process(5.6)
	var first_color: Color = door.get_node("Frame").modulate
	door._process(0.2)
	_expect(first_color != door.get_node("Frame").modulate, "Warning border alternates")
	door.reset_cycle()
	_expect(not door.get_node("WarningLabel").visible, "Reset clears warning")
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS C-03/04/05: 60 state/range/card cases, global coordinates, warning flash, visibility, unbound/rebound player.")
	scene.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
