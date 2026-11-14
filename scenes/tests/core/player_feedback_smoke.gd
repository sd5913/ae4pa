extends SceneTree
## Regression for the reported manager reachability and silent 201 task offer.

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game: Node = root.get_node("GameManager")
	var host := Node2D.new()
	root.add_child(host)
	game.call("set_floor_host", host)
	game.call("start_game")
	var floor_node: Node = host.get_child(0)
	var player: Node2D = floor_node.get_node("Player")
	var manager: Node2D = floor_node.get_node("StaffRoot/ManagerSlot/Staff")
	manager.get_node("TurnTimer").stop()
	var requests: Array[int] = []
	floor_node.connect("manager_talk_requested", func() -> void: requests.append(1))
	for facing: int in [-1, 1]:
		manager.set("facing_direction", facing)
		for side: int in [-1, 1]:
			player.global_position.x = manager.global_position.x + side * 85.0
			await _settle()
			_expect(not manager.call("is_player_in_range"), "Talk regression is outside B's theft Area")
			_expect(floor_node.call("get_interaction_target_id") == "MANAGER_TALK", "Both sides and both facings offer talk at a normal talking distance")
			await _action(true)
			await _action(false)
	_expect(requests.size() == 4, "Each E dispatches talk once without waiting for a turn")
	_expect(root.get_node("CardManager").call("get_owned_cards").is_empty(), "Talking on either side never grants an ID")
	player.global_position.x = manager.global_position.x + 130.0
	await _settle()
	_expect(floor_node.call("get_interaction_target_id") != "MANAGER_TALK", "Distant manager cannot be talked to")
	game.call("complete_manager_intro")
	player.global_position.x = manager.global_position.x - 85.0
	await _settle()
	var notices: Array[String] = []
	floor_node.connect("notice_requested", func(message: String) -> void: notices.append(message))
	await _action(true)
	await _action(false)
	_expect(notices.size() == 1 and "201" in notices[0] and "2F" in notices[0], "After the conversation the manager gives a useful route instead of a theft hint")
	host.queue_free()
	await process_frame

	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	var dialogue: Control = main.get_node("StoryLayer/Dialogue")
	await create_timer(0.6).timeout
	dialogue.set_skip_transitions_for_test(true)
	var guard: int = 0
	while dialogue.visible and guard < 200:
		dialogue.get_node("%ContinueButton").emit_signal("pressed")
		guard += 1
	_expect(guard < 200, "Real prologue completes")
	# Story fixture isolates main's manager-completion -> objective connection.
	game.call("complete_manager_intro")
	main.call("_on_dialogue_finished", "WRONG_ID")
	player = main.get_node("World").get_child(0).get_node("Player")
	player.global_position.x = 3400.0
	game.call("request_floor_travel", 2)
	player = main.get_node("World").get_child(0).get_node("Player")
	player.global_position.x = 580.0
	await _settle()
	_expect(game.get("task_status") == "AVAILABLE" and game.get("remaining_time") == 0.0, "Real 201 offers without silently accepting or timing")
	var objective: Label = main.get_node_or_null("DeveloperOverlay/Margin/Info/Objective")
	_expect(objective != null, "Main exposes a persistent current objective")
	if objective != null:
		_expect("201" in objective.text and "接受" in objective.text, "Objective directs the player to accept the real 201 offer")
	var notice: Label = main.get_node("DeveloperOverlay/Margin/Info/Notice")
	_expect("201" in notice.text and "接受" in notice.text, "A connects the actual task-offered signal to visible feedback")
	_expect(main.get_node("TaskLayer/MissionBoard").visible and not game.call("is_world_input_allowed"), "Real offer is visible and owns the task modal")
	_expect(root.get_node("CardManager").call("get_owned_cards").is_empty(), "Guidance grants no cards or fake work")
	main.queue_free()
	await process_frame
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS: manager talk independent of theft/facing, route reminders and visible 201 boundary.")
	quit(0 if failures.is_empty() else 1)


func _settle() -> void:
	for frame: int in range(4):
		await physics_frame
	await process_frame


func _action(pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = pressed
	Input.parse_input_event(event)
	await process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
