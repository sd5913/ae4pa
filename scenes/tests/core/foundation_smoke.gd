extends SceneTree

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game: Node = root.get_node_or_null("GameManager")
	var cards: Node = root.get_node_or_null("CardManager")
	_expect(game != null, "GameManager is loaded")
	_expect(cards != null, "CardManager is loaded")
	_expect(ResourceLoader.exists("res://scenes/main.tscn"), "Main scene exists")
	if not failures.is_empty():
		_finish()
		return

	game.call("start_game")
	_expect(game.get("game_state") == "PLAYING", "New game enters PLAYING")
	_expect(game.get("current_floor") == 1, "New game starts on floor 1")
	_expect(not game.get("has_friend"), "New game resets rescue progress")
	_expect(cards.get("active_card") == "NONE", "New game has no active card")
	_expect(cards.call("get_equipped_cards") == ["NONE", "NONE"], "New game has two empty slots")

	var owned: Array = cards.call("get_owned_cards")
	owned.append("SECURITY")
	_expect(cards.call("get_owned_cards").is_empty(), "Owned-card query cannot modify stored cards")
	var equipped: Array = cards.call("get_equipped_cards")
	equipped[0] = "SECURITY"
	_expect(cards.get("active_card") == "NONE", "Equipment query cannot change the active card")

	var reasons: Array[String] = []
	var observed_states: Array[String] = []
	game.connect("game_failed", func(reason: String) -> void:
		reasons.append(reason)
		observed_states.append(game.get("game_state"))
	)
	game.call("fail", "WRONG_CARD")
	game.call("fail", "MOVED_NEAR_EAR")
	_expect(reasons == ["WRONG_CARD"], "A failure is reported once")
	_expect(observed_states == ["FAILED"], "Failure listeners see FAILED state")
	_expect(game.get("fail_reason") == "WRONG_CARD", "Repeated failure preserves the original reason")
	game.set("current_floor", 4)
	game.set("has_friend", true)
	game.call("start_game")
	_expect(game.get("game_state") == "PLAYING", "New game restores PLAYING after failure")
	_expect(game.get("current_floor") == 1 and not game.get("has_friend"), "New game resets previous floor and rescue")
	_expect(game.get("fail_reason") == "", "New game clears the failure reason")

	var scene: PackedScene = load("res://scenes/main.tscn")
	var main: Node = scene.instantiate()
	root.add_child(main)
	await process_frame
	await _finish_prologue(main)
	_expect(ProjectSettings.get_setting("application/run/main_scene") == "res://scenes/main.tscn", "F5 uses the shared main scene")
	var players: Array[Node] = get_nodes_in_group("player")
	_expect(players.size() == 1, "Main scene contains one shared player")
	if players.size() == 1:
		await _check_player(players[0], 3600)
	main.queue_free()
	await process_frame
	# The original reusable corridor remains available to B/C component scenes.
	var corridor: Node = load("res://scenes/levels/test_corridor.tscn").instantiate()
	root.add_child(corridor)
	await process_frame
	await _check_player(corridor.get_node("Player"), 2800)
	corridor.queue_free()
	await process_frame
	for path: String in [
		"res://scenes/tests/core/core_test.tscn",
		"res://scenes/tests/staff/staff_test.tscn",
		"res://scenes/tests/doors/doors_test.tscn",
		"res://scenes/tests/ui/ui_test.tscn",
	]:
		_expect(ResourceLoader.exists(path), "Independent test scene exists: " + path)
		if not ResourceLoader.exists(path):
			continue
		var test_scene: PackedScene = load(path)
		var instance: Node = test_scene.instantiate()
		root.add_child(instance)
		await process_frame
		_expect(get_nodes_in_group("player").size() == 1, "Test scene has one shared player: " + path)
		instance.queue_free()
		await process_frame
	_finish()


func _finish_prologue(main: Node) -> void:
	# Movement is checked after the actual opening yields control, never through it.
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	var opening: Control = main.get_node("StoryLayer/Dialogue")
	await create_timer(0.6).timeout
	opening.set_skip_transitions_for_test(true)
	var guard: int = 0
	while opening.visible and guard < 200:
		opening.get_node("%ContinueButton").emit_signal("pressed")
		guard += 1
	_expect(guard < 200, "Main's real prologue returns control before movement checks")
	await process_frame


func _check_player(player: Node2D, corridor_width: int) -> void:
	player.global_position = Vector2(192.0, 560.0)
	Input.action_press("move_right")
	await _physics_frames(6)
	Input.action_release("move_right")
	await _physics_frames(2)
	_expect(player.global_position.x > 192.0, "Right input moves the player right")
	_expect(is_equal_approx(player.global_position.y, 560.0), "Movement stays on the horizontal line")
	var stopped_x: float = player.global_position.x
	await _physics_frames(3)
	_expect(is_equal_approx(player.global_position.x, stopped_x), "Releasing movement stops without drift")
	_expect(not player.get("is_moving"), "Moving state clears after release")
	Input.action_press("move_left")
	await _physics_frames(6)
	Input.action_release("move_left")
	await _physics_frames(2)
	_expect(player.global_position.x < stopped_x, "Left input moves the player left")

	stopped_x = player.global_position.x
	Input.action_press("move_left")
	Input.action_press("move_right")
	await _physics_frames(4)
	Input.action_release("move_left")
	Input.action_release("move_right")
	_expect(is_equal_approx(player.global_position.x, stopped_x), "Opposite inputs cancel in the movement prototype")

	player.call("set_movement_locked", true)
	Input.action_press("move_right")
	await _physics_frames(4)
	Input.action_release("move_right")
	_expect(is_equal_approx(player.global_position.x, stopped_x), "A movement lock prevents walking")
	player.call("set_movement_locked", false)

	player.global_position.x = float(corridor_width - 66)
	Input.action_press("move_right")
	await _physics_frames(4)
	Input.action_release("move_right")
	_expect(is_equal_approx(player.global_position.x, float(corridor_width - 64)), "Right edge prevents leaving the corridor")
	player.global_position.x = 66.0
	Input.action_press("move_left")
	await _physics_frames(4)
	Input.action_release("move_left")
	_expect(is_equal_approx(player.global_position.x, 64.0), "Left edge prevents leaving the corridor")

	var game: Node = root.get_node("GameManager")
	game.call("fail", "WRONG_CARD")
	player.call("set_movement_locked", false)
	Input.action_press("move_right")
	await _physics_frames(4)
	Input.action_release("move_right")
	_expect(is_equal_approx(player.global_position.x, 64.0), "Unlocking does not bypass FAILED state")
	game.call("start_game")
	await process_frame
	# Main reloads the floor on a new game; component corridors keep their player.
	player = get_nodes_in_group("player")[0]
	stopped_x = player.global_position.x
	Input.action_press("move_right")
	await _physics_frames(4)
	Input.action_release("move_right")
	_expect(player.global_position.x > stopped_x, "Starting a new session restores movement")

	var camera: Camera2D = player.get_node_or_null("Camera2D")
	_expect(camera != null, "Player provides the shared horizontal camera")
	if camera != null:
		_expect(camera.limit_left == 0 and camera.limit_right == corridor_width, "Camera uses corridor boundaries")
		_expect(camera.limit_top == 0 and camera.limit_bottom == 720, "Camera stays within the fixed-height corridor")


func _physics_frames(count: int) -> void:
	for frame: int in range(count):
		await physics_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS: startup, managers, card isolation, failure lifecycle, movement, bounds, and camera.")
	quit(0 if failures.is_empty() else 1)
