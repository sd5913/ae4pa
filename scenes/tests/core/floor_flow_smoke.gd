extends SceneTree
## Checks A-07 against real scenes/managers, without inventing card data.

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game: Node = root.get_node("GameManager")
	for number: int in range(1, 6):
		_expect(ResourceLoader.exists("res://scenes/levels/floor_%d.tscn" % number), "Floor %d exists" % number)
	_expect(game.has_method("set_floor_host"), "GameManager supports a floor host")
	_expect(game.has_method("go_to_floor"), "GameManager supports normal floor transitions")
	_expect(game.has_method("preview_floor"), "GameManager supports explicit development preview")
	if not failures.is_empty():
		_finish()
		return

	var host := Node2D.new()
	root.add_child(host)
	game.call("set_floor_host", host)
	game.call("start_game")
	await process_frame
	_check_floor(host, 1)
	await _check_bounds(host.get_child(0).get_node("Player"))
	var first: Node = host.get_child(0)
	game.call("go_to_floor", 2)
	_expect(host.get_child(0) == first and game.get("current_floor") == 1, "Manager introduction and stair proximity gate 1F exit")
	game.call("preview_floor", 2)
	_expect(host.get_child(0) == first, "Normal host cannot enable preview bypass")
	for number: int in [0, 1, 3, 6]:
		game.call("go_to_floor", number)
	_expect(host.get_child(0) == first, "Invalid, same-floor and skipped requests preserve the floor")
	var cards: Node = root.get_node("CardManager")
	for card_id: String in ["SECURITY", "CLEANER", "MANAGER"]:
		_expect(cards.call("collect_card", card_id), "Real collection accepts " + card_id)
	cards.call("equip_card", "MANAGER", 1)
	var equipped: Array = cards.call("get_equipped_cards")
	host.get_child(0).get_node("Player").global_position.x = 3400.0
	game.call("go_to_floor", 2)
	_expect(game.get("current_floor") == 1, "Three cards alone no longer open 2F")
	game.call("complete_manager_intro")
	game.call("go_to_floor", 2)
	await process_frame
	_check_floor(host, 2)
	_expect(cards.call("has_all_cards"), "Normal 1F exit preserves collected cards")
	_expect(cards.call("get_equipped_cards") == equipped, "Normal transition preserves real equipped slots")
	game.call("start_game")
	await process_frame
	first = host.get_child(0)

	game.call("set_floor_host", host, true)
	var notifications: Array[int] = []
	var on_floor_changed := func(number: int) -> void:
		notifications.append(number)
		_expect(game.get("game_state") == "PLAYING", "Floor listener sees PLAYING")
		_check_floor(host, number, number == 4 and notifications.size() > 1 and notifications[-2] == 5)
	game.connect("floor_changed", on_floor_changed)
	game.call("preview_floor", 2)
	await process_frame
	_check_floor(host, 2)
	_expect(not is_instance_valid(first), "Previous floor is freed after replacement")
	_expect(root.get_node("CardManager").call("get_owned_cards").is_empty(), "Preview never invents cards")
	host.get_child(0).get_node("Player").global_position.x = 500.0
	await _press_interact()
	_expect(game.get("current_floor") == 2, "E away from both stairs cannot change floors")
	host.get_child(0).get_node("Player").global_position.x = 3400.0
	await _press_interact()
	await process_frame
	_expect(game.get("current_floor") == 2, "Incomplete 201 and 202 block 3F")
	game.call("preview_floor", 3)
	await process_frame
	_check_floor(host, 3)
	var third: Node = host.get_child(0)
	host.get_child(0).get_node("Player").global_position.x = 3400.0
	game.call("go_to_floor", 4)
	_expect(host.get_child(0) == third, "Unrescued story state blocks 3F exit")
	game.set("has_friend", true) # A-owned story fixture; rescue itself is outside A-07.
	host.get_child(0).get_node("Player").global_position.x = 3400.0
	game.call("go_to_floor", 4)
	game.call("go_to_floor", 5)
	_expect(game.get("current_floor") == 4, "Unfinished task 04 blocks 5F")
	game.call("preview_floor", 5)
	await process_frame
	_check_floor(host, 5)
	_expect(game.get("has_friend"), "4F and 5F preserve rescued story state")
	var fifth: Node = host.get_child(0)
	game.call("go_to_floor", 6)
	_expect(host.get_child(0) == fifth, "5F has no sixth floor")
	game.call("go_to_floor", 4)
	await process_frame
	_expect(game.get("current_floor") == 4 and not is_instance_valid(fifth), "Visited 4F is reachable from 5F")
	_expect(host.get_child(0).get_node("Player").global_position.x > 3200.0, "Return appears beside the upper stair")
	var fourth: Node = host.get_child(0)
	game.call("fail", "WRONG_CARD")
	game.call("go_to_floor", 5)
	game.call("preview_floor", 1)
	_expect(host.get_child(0) == fourth and game.get("game_state") == "FAILED", "Failed state blocks normal and preview requests")
	game.call("start_game")
	await process_frame
	_check_floor(host, 1)
	_expect(not game.get("has_friend") and game.get("fail_reason") == "", "Restart clears story and failure")
	_expect(notifications == [2, 3, 4, 5, 4, 1], "Each successful load emits once; rejected requests never emit")

	game.disconnect("floor_changed", on_floor_changed)
	host.queue_free()
	await process_frame
	# A freed preview host must not break B/C/D's original standalone tests.
	game.call("start_game")
	_expect(game.get("game_state") == "PLAYING", "Standalone game works after floor host is freed")
	var preview_scene: PackedScene = load("res://scenes/tests/core/floors_test.tscn")
	var preview: Node = preview_scene.instantiate()
	root.add_child(preview)
	await process_frame
	_check_floor(preview.get_node("World"), 1)
	preview.get_node("DeveloperOverlay/Margin/Info/Buttons/NextFloor").emit_signal("pressed")
	await process_frame
	_check_floor(preview.get_node("World"), 2)
	_expect(not game.get("has_friend"), "Development next-floor button does not simulate rescue")
	preview.get_node("DeveloperOverlay/Margin/Info/Buttons/Restart").emit_signal("pressed")
	await process_frame
	_check_floor(preview.get_node("World"), 1)
	preview.queue_free()
	await process_frame
	_finish()


func _press_interact() -> void:
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = InputEventAction.new()
	event.action = "interact"
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame


func _check_bounds(player: Node2D) -> void:
	player.global_position.x = 3534.0
	Input.action_press("move_right")
	for frame: int in range(4):
		await physics_frame
	Input.action_release("move_right")
	_expect(is_equal_approx(player.global_position.x, 3536.0), "Wider floor clamps movement at its right edge")
	player.global_position.x = 66.0
	Input.action_press("move_left")
	for frame: int in range(4):
		await physics_frame
	Input.action_release("move_left")
	_expect(is_equal_approx(player.global_position.x, 64.0), "Floor clamps movement at its left edge")
	await physics_frame
	player.global_position = Vector2(192, 560)


func _check_floor(host: Node, number: int, arrive_from_above: bool = false) -> void:
	_expect(host.get_child_count() == 1, "World contains one floor")
	if host.get_child_count() != 1:
		return
	var floor_node: Node = host.get_child(0)
	_expect(floor_node.get("floor_number") == number, "Loaded floor matches requested number")
	_expect(root.get_node("GameManager").get("current_floor") == number, "Manager matches loaded floor")
	var players: Array[Node] = get_nodes_in_group("player")
	_expect(players.size() == 1, "Exactly one player remains after loading")
	var player: Node2D = floor_node.get_node("Player")
	var expected_position: Vector2 = floor_node.get_node("Interactions/ExitPoint").global_position + Vector2(-60, 0) if arrive_from_above else floor_node.get_node("SpawnPoint").global_position
	_expect(player.global_position.is_equal_approx(expected_position), "Player starts at the correct floor %d stair" % number)
	var camera: Camera2D = player.get_node("Camera2D")
	_expect(camera.limit_left == 0 and camera.limit_right == 3600, "Camera matches floor width")
	_expect(camera.limit_top == 0 and camera.limit_bottom == 720, "Camera remains horizontal")
	_expect(floor_node.get_node("DoorRoot").get_child_count() == (0 if number == 1 else 5), "1F has no monster slots; upper floors have five")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS: five floors, gates, replacement, spawn, camera, preview isolation, and story retention.")
	quit(0 if failures.is_empty() else 1)
