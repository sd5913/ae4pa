extends SceneTree
## A-05 retained with V4 task gating; three-card inventory uses explicit fixtures.

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: PackedScene = load("res://scenes/tests/core/floors_test.tscn")
	var preview: Node = scene.instantiate()
	root.add_child(preview)
	await process_frame
	var floor_node: Node = preview.get_node("World").get_child(0)
	var paths: Array[String] = ["StaffRoot/CleanerSlot/Staff", "StaffRoot/SecuritySlot/Staff", "StaffRoot/ManagerSlot/Staff"]
	for path: String in paths:
		_expect(floor_node.has_node(path), "1F contains employee: " + path)
	if not failures.is_empty():
		preview.queue_free()
		await process_frame
		_finish()
		return

	var game: Node = root.get_node("GameManager")
	var cards: Node = root.get_node("CardManager")
	var player: Node2D = floor_node.get_node("Player")
	for path: String in paths:
		floor_node.get_node(path).get_node("TurnTimer").stop()
	await _action("interact", true)
	await create_timer(0.9).timeout
	await _action("interact", false)
	_expect(cards.call("get_owned_cards").is_empty(), "Distant E does not steal a card")
	player.global_position.x = 3400.0
	await _action("interact", true)
	await _action("interact", false)
	_expect(game.get("current_floor") == 1, "Manager introduction gates the real 1F stairs")

	_accept_task_fixture(preview, game)
	floor_node = preview.get_node("World").get_child(0)
	player = floor_node.get_node("Player")
	for path: String in paths:
		floor_node.get_node(path).get_node("TurnTimer").stop()
	var card_ids: Array[String] = ["CLEANER", "SECURITY", "MANAGER"]
	for index: int in range(3):
		var staff: Node2D = floor_node.get_node(paths[index])
		player.global_position = staff.global_position + Vector2(-30, 0)
		await _physics_frames(3)
		_expect(staff.call("is_player_in_range"), "A binds the shared player to " + card_ids[index])
		if index == 0:
			await _action("interact", true)
			await create_timer(0.15).timeout
			await _action("interact", false)
			_expect(not cards.call("has_card", "CLEANER"), "Releasing E early cancels real stealing")
		else:
			await _action("interact", true)
			await create_timer(0.1).timeout
			await _action("interact", false)
			_expect(not cards.call("has_card", card_ids[index]), "Task 01 denies unrelated employee reward " + card_ids[index])
			# Keep the old two-slot/third-card checks without pretending later tasks exist.
			_expect(cards.call("collect_card", card_ids[index]), "Explicit inventory fixture grants " + card_ids[index])
		await _action("interact", true)
		var deadline: int = Time.get_ticks_msec() + 1500
		while not cards.call("has_card", card_ids[index]) and Time.get_ticks_msec() < deadline:
			await process_frame
		await _action("interact", false)
		_expect(cards.call("has_card", card_ids[index]), "Theft or explicit fixture owns " + card_ids[index])
		_expect(cards.call("get_owned_cards").size() == index + 1, "Cards are collected only once")
		if index == 0:
			_expect(preview.get_node("DeveloperOverlay/Margin/Info/Notice").text.begins_with("获得保洁 ID"), "Real theft identifies the cleaner card just earned")
		await _action("interact", true)
		await _action("interact", false)
		_expect(cards.call("get_owned_cards").size() == index + 1, "Repeated input cannot duplicate the card")

	_expect(cards.call("get_equipped_cards") == ["CLEANER", "SECURITY"], "Third card remains owned without adding a third slot")
	await _action("switch_id", true)
	await _action("switch_id", false)
	_expect(cards.get("active_card") == "SECURITY", "One Q switches the active card once")
	_expect(preview.get_node("DeveloperOverlay/Margin/Info/Status").text.ends_with("当前：SECURITY"), "Development display reflects real Q changes")
	player.global_position.x = 3400.0
	await _physics_frames(4)
	for path: String in paths:
		_expect(not floor_node.get_node(path).call("is_player_in_range"), "Stairs fixture has left every employee detection area")
	game.call("complete_manager_intro") # D's formal dialogue is not yet connected.
	await _action("interact", true)
	await _action("interact", false)
	_expect(game.get("current_floor") == 2, "Manager introduction allows E to enter 2F")
	_expect(cards.call("get_owned_cards") == card_ids, "Normal stairs preserve real and fixture cards")
	_expect(cards.call("get_equipped_cards") == ["CLEANER", "SECURITY"] and cards.get("active_card") == "SECURITY", "Stairs preserve equipped and active identities")
	_expect(get_nodes_in_group("player").size() == 1, "Stairs leave one player")
	_expect(preview.get_node("World").get_child(0).get_node("Player").global_position == Vector2(192, 560), "2F starts at its entrance")

	game.call("start_game")
	await process_frame
	_accept_task_fixture(preview, game)
	floor_node = preview.get_node("World").get_child(0)
	var security: Node2D = floor_node.get_node(paths[0])
	security.get_node("TurnTimer").stop()
	player = floor_node.get_node("Player")
	player.global_position = security.global_position + Vector2(-30, 0)
	await _physics_frames(3)
	await _action("interact", true)
	await create_timer(0.1).timeout
	security.call("_on_turn_timer_timeout")
	await _action("interact", false)
	_expect(game.get("game_state") == "FAILED" and game.get("fail_reason") == "STAFF_CAUGHT", "B's mid-steal turn failure reaches the shared game state")
	_expect(preview.get_node("DeveloperOverlay/Margin/Info/Notice").text.contains("偷窃被发现"), "Failure is visible in the temporary display")
	preview.get_node("DeveloperOverlay/Margin/Info/Buttons/Restart").emit_signal("pressed")
	await process_frame
	_expect(game.get("current_floor") == 1 and game.get("game_state") == "PLAYING", "Development new game returns to playable 1F")
	_expect(cards.call("get_owned_cards").is_empty(), "Development new game clears the previous cards")
	_expect(get_nodes_in_group("player").size() == 1, "New game does not duplicate players")
	preview.queue_free()
	await process_frame

	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	_expect(main.get_node("World").get_child(0).has_node(paths[0]), "Main entry starts the same real 1F")
	main.queue_free()
	await process_frame
	_finish()


func _accept_task_fixture(preview: Node, game: Node) -> void:
	# Formal D dialogue/C interception are not delivered; travel and task APIs are real.
	game.call("complete_manager_intro")
	preview.get_node("World").get_child(0).get_node("Player").global_position.x = 3400.0
	_expect(game.call("request_floor_travel", 2), "Task fixture uses the real 1F stair")
	_expect(game.call("offer_task", "TASK_01_CLEAN"), "Task fixture offers 201")
	_expect(game.call("accept_task", "TASK_01_CLEAN"), "Task fixture accepts 201")
	_expect(game.call("request_floor_travel", 1), "Task fixture returns to 1F")


func _action(action: String, pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = pressed
	Input.parse_input_event(event)
	await process_frame


func _physics_frames(count: int) -> void:
	for frame: int in range(count):
		await physics_frame
	# Body enter/exit notifications arrive after the physics_frame signal.
	await process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS A-05/V4: cleaner theft, task gate, card-slot fixtures, Q, retention, failure and new game.")
	quit(0 if failures.is_empty() else 1)
