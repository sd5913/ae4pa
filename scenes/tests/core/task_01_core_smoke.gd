extends SceneTree
## Checks the explicit developer entry; these buttons do not replace B/C/D acceptance.

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not ResourceLoader.exists("res://scenes/tests/core/task_01_core_test.tscn"):
		_expect(false, "Task 01 must have an explicit core test scene")
		_finish()
		return
	var core: Node = load("res://scenes/tests/core/task_01_core_test.tscn").instantiate()
	var dialogue: Control = core.get_node_or_null("StoryLayer/Dialogue")
	if dialogue == null:
		core.free()
		_expect(false, "Core manager E must mount and open the real dialogue")
		_finish()
		return
	var temp_dir: String = OS.get_environment("TEMP" if OS.has_feature("windows") else "TMPDIR")
	var read_path: String = (temp_dir if not temp_dir.is_empty() else "user://").path_join("ae4pa-core-talk-%d.cfg" % OS.get_process_id())
	dialogue.set_progress_file_path_for_test(read_path)
	root.add_child(core)
	await process_frame
	dialogue.set_skip_transitions_for_test(true)
	var game: Node = root.get_node("GameManager")
	var cards: Node = root.get_node("CardManager")
	var panel: Node = core.get_node("DeveloperOverlay/Panel")
	_expect(game.get("current_floor") == 1 and cards.call("get_owned_cards").is_empty(), "Core starts the shared 1F without cards")
	_expect(panel.get_node("Row2/Retry").disabled, "A fresh session has no failed checkpoint to retry")
	_expect(not panel.has_node("Row1/Clean") and not panel.has_node("Row1/Deliver"), "Developer entry uses actual B work and C delivery rather than fake completion controls")
	var floor_node: Node = core.get_node("World").get_child(0)
	var player: Node2D = floor_node.get_node("Player")
	var manager: Node2D = floor_node.get_node("StaffRoot/ManagerSlot/Staff")
	player.global_position = manager.global_position + Vector2(30, 0)
	await _settle()
	_expect(floor_node.call("get_interaction_target_id") == "MANAGER_TALK", "Screenshot position selects manager talk")
	await _action("interact", true)
	await _action("interact", false)
	_expect(dialogue.visible and dialogue.get("_dialogue_id") == "V4_MANAGER_TALK", "Manager E opens real D dialogue in the core entry")
	_expect(not game.call("has_completed_manager_intro") and not game.call("is_world_input_allowed"), "Opening the manager conversation locks input without completing it")
	var active_slot: int = cards.get("active_slot")
	await _action("switch_id", true)
	await _action("switch_id", false)
	_expect(cards.get("active_slot") == active_slot and cards.call("get_owned_cards").is_empty(), "Talking never steals or switches a card")
	var standing: Vector2 = player.global_position
	Input.action_press("move_right")
	await _settle()
	Input.action_release("move_right")
	_expect(player.global_position == standing, "Core dialogue locks player movement")
	var beat: int = dialogue.get("_line_index")
	await _action("interact", true)
	await _action("interact", false)
	_expect(dialogue.get("_line_index") == beat + 1, "One E advances one manager beat")
	game.call("set_modal_open", "OTHER_PAGE", true)
	for index: int in range(200):
		if not dialogue.visible:
			break
		dialogue.get_node("%ContinueButton").pressed.emit()
		await process_frame
	_expect(not dialogue.visible and game.call("has_completed_manager_intro"), "Only finishing the manager conversation unlocks upstairs")
	_expect(not game.call("is_world_input_allowed"), "Dialogue completion preserves another page's modal")
	game.call("set_modal_open", "OTHER_PAGE", false)
	_expect(game.call("is_world_input_allowed"), "Last page closure restores core controls")
	panel.get_node("Row2/Restart").pressed.emit()
	_expect(not game.call("has_completed_manager_intro") and not dialogue.visible, "Core new game resets conversation state")
	# Preserve the explicit manager-completion fixture for the remaining core tests.
	panel.get_node("Row1/Intro").emit_signal("pressed")
	floor_node = core.get_node("World").get_child(0)
	floor_node.player.global_position.x = floor_node.get_stair_interaction_center(true)
	_expect(game.call("request_floor_travel", 2), "Core reuses real manager-gated floor loading")
	panel.get_node("Row1/Offer").emit_signal("pressed")
	_expect(game.get("task_status") == "AVAILABLE" and is_zero_approx(game.get("remaining_time")), "Developer offer does not begin time")
	panel.get_node("Row1/Accept").emit_signal("pressed")
	_expect(game.get("task_status") == "ACTIVE" and is_equal_approx(game.get("remaining_time"), 120.0), "Developer acceptance uses the real task limit")
	panel.get_node("Row2/Pause").emit_signal("pressed")
	var stopped: float = game.get("remaining_time")
	game.call("_process", 20.0)
	_expect(is_equal_approx(game.get("remaining_time"), stopped), "Core modal pauses the manager's timer")
	panel.get_node("Row2/Pause").emit_signal("pressed")
	panel.get_node("Row2/Timeout").emit_signal("pressed")
	await process_frame
	await process_frame
	_expect(game.get("task_status") == "FAILED" and not panel.get_node("Row2/Retry").disabled, "A real failed checkpoint enables the developer retry control")
	panel.get_node("Row2/Pause").emit_signal("pressed")
	panel.get_node("Row2/Retry").emit_signal("pressed")
	_expect(game.get("task_status") == "AVAILABLE" and game.get("remaining_time") == 0.0, "Retry returns to acceptance rather than restarting time")
	_expect(not core.get("_paused") and game.call("is_world_input_allowed"), "Retry clears developer modal state as well as manager locks")
	panel.get_node("Row2/Restart").emit_signal("pressed")
	_expect(game.get("task_status") == "NONE" and cards.call("get_owned_cards").is_empty(), "Core new game clears task and cards")
	floor_node = core.get_node("World").get_child(0)
	manager = floor_node.get_node("StaffRoot/ManagerSlot/Staff")
	floor_node.get_node("Player").global_position = manager.global_position + Vector2(30, 0)
	await _settle()
	await _action("interact", true)
	await _action("interact", false)
	_expect(dialogue.visible, "New game can start another real manager conversation")
	panel.get_node("Row2/Restart").pressed.emit()
	dialogue.emit_signal("dialogue_finished", "V4_MANAGER_TALK")
	_expect(not dialogue.visible and not game.call("has_completed_manager_intro"), "Restart cancels dialogue and rejects stale completion")
	floor_node = core.get_node("World").get_child(0)
	manager = floor_node.get_node("StaffRoot/ManagerSlot/Staff")
	floor_node.get_node("Player").global_position = manager.global_position + Vector2(30, 0)
	await _settle()
	await _action("interact", true)
	await _action("interact", false)
	_expect(not game.call("is_world_input_allowed"), "Unload precondition is a real open manager modal")
	core.queue_free()
	await process_frame
	_expect(game.call("is_world_input_allowed"), "Unloading the core entry releases its dialogue modal")
	DirAccess.remove_absolute(read_path)
	_finish()


func _settle() -> void:
	for index: int in range(4):
		await physics_frame
	await process_frame


func _action(action: String, pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = pressed
	Input.parse_input_event(event)
	await process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS: core manager E dialogue, input/modal lifecycle, task acceptance, timeout and checkpoint retry.")
	quit(0 if failures.is_empty() else 1)
