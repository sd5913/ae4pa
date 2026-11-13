extends SceneTree
## Real F5 scene/intro/manager/201. No fake cleaning, acceptance UI or completion.
var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	var dialogue: Control = main.get_node("StoryLayer/Dialogue")
	dialogue.set_progress_file_path_for_test("res://.godot/c_v4_main_read.cfg")
	dialogue.set_skip_transitions_for_test(true)
	root.add_child(main)
	await create_timer(0.7).timeout
	dialogue.set_skip_transitions_for_test(true)
	var game: Node = root.get_node("GameManager")
	var cards: Node = root.get_node("CardManager")
	_expect(dialogue.visible, "Real F5 intro is visible")
	await _drain(dialogue)
	var floor_node: Node = main.get_node("World").get_child(0)
	var player: Node2D = floor_node.get_node("Player")
	var manager: Node2D = floor_node.get_node("StaffRoot/ManagerSlot/Staff")
	manager.get_node("TurnTimer").stop()
	player.global_position = manager.global_position + Vector2(30, 0)
	for frame: int in range(4):
		await physics_frame
	await _e(true)
	await _e(false)
	_expect(dialogue.visible, "Real E opens manager dialogue")
	await _drain(dialogue)
	_expect(game.has_completed_manager_intro(), "Real dialogue completion unlocks 2F")
	player.position.x = 3400
	for frame: int in range(4):
		await physics_frame
	await _e(false) # Explicit release after closing manager UI, as a player must do.
	await _e(true)
	await _e(false)
	_expect(game.current_floor == 2 and cards.get_owned_cards().is_empty(), "Real E enters 2F without cards")
	if game.current_floor != 2:
		for failure: String in failures:
			printerr("FAIL: ", failure)
		main.queue_free()
		await process_frame
		quit(1)
		return
	floor_node = main.get_node("World").get_child(0)
	player = floor_node.get_node("Player")
	var story: Node = floor_node.get_node("DoorRoot/Room201/Door")
	player.position.x = 575
	Input.action_press("move_right")
	for frame: int in range(12):
		await physics_frame
	Input.action_release("move_right")
	_expect(game.task_status == "AVAILABLE", "Walking to real 201 offers task at pre-accept bound")
	_expect(player.position.x <= 580.0, "Pre-accept route remains locked")
	var initial: float = game.remaining_time
	story._physics_process(0.0)
	_expect(game.task_status == "AVAILABLE" and game.remaining_time == initial, "Reapproach does not accept or start timer")
	# No task acceptance UI exists in this main; explicit API verifies A/C route contract only.
	_expect(game.accept_task("TASK_01_CLEAN"), "Explicit A API accepts; not a claim of real task UI")
	for target: float in [192.0, 980.0]:
		player.position.x = target
		await physics_frame
		_expect(player.position.x == target, "Accepted route reaches stairs/work marker")
	story.offset = 0.0
	story.reset_cycle()
	player.position.x = 1225
	Input.action_press("move_right")
	for frame: int in range(12):
		await physics_frame
	Input.action_release("move_right")
	_expect(player.position.x <= 1226.0 and not game.get_world_flags().get("passage_201_unlocked", false), "Closed story door cannot bypass task barrier")
	_expect(floor_node.get_node("Interactions/Stain201Slot").get_child_count() == 1, "Work slot still only has placeholder label; full loop not claimed")
	main.queue_free()
	await process_frame
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS: real F5 intro/manager/E/201 approach and route locks; accept API fixture only. Work/task UI/retry and human walkthrough pending.")
	quit(0 if failures.is_empty() else 1)


func _drain(dialogue: Control) -> void:
	for index: int in range(300):
		if not dialogue.visible:
			return
		dialogue.get_node("%ContinueButton").pressed.emit()
		await process_frame
	_expect(false, "Dialogue completes within its real script")


func _e(pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = pressed
	Input.parse_input_event(event)
	await process_frame


func _expect(value: bool, message: String) -> void:
	if not value:
		failures.append(message)
