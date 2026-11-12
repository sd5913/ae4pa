extends SceneTree
## Real D dialogue + A main/floor routing; writes read progress only in /private/tmp.

var failures: Array[String] = []
var game: Node
var cards: Node


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	game = root.get_node("GameManager")
	cards = root.get_node("CardManager")
	var main: Node = load("res://scenes/main.tscn").instantiate()
	var dialogue: Control = main.get_node_or_null("StoryLayer/Dialogue")
	if dialogue == null:
		main.free()
		printerr("FAIL: F5 must mount D's real dialogue scene")
		quit(1)
		return
	dialogue.set_progress_file_path_for_test("/private/tmp/ae4pa-intro-flow-%d.cfg" % OS.get_process_id())
	dialogue.set_skip_transitions_for_test(true)
	root.add_child(main)
	# D owns fades; use its existing test setting after _ready initializes it.
	await create_timer(0.6).timeout
	dialogue.set_skip_transitions_for_test(true)
	await process_frame
	var player: Node2D = main.get_node("World").get_child(0).get_node("Player")
	_expect(dialogue.visible and dialogue.get("_dialogue_id") == "V4_INTRO", "F5 begins with the full real prologue")
	_expect(not game.call("is_world_input_allowed") and game.call("get_available_floors").is_empty(), "Intro cannot unlock stairs or leak world E")
	var start: Vector2 = player.global_position
	Input.action_press("move_right")
	await physics_frame
	await physics_frame
	Input.action_release("move_right")
	_expect(player.global_position == start, "Dialogue blocks player movement")
	var slot: int = cards.get("active_slot")
	await _action("switch_id", true)
	await _action("switch_id", false)
	_expect(cards.get("active_slot") == slot, "Q cannot change cards while story dialogue is open")
	var index: int = dialogue.get("_line_index")
	await _action("interact", true)
	await _action("interact", false)
	_expect(dialogue.get("_line_index") == index + 1, "A real E advances exactly one story beat")
	var mouse := InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.pressed = true
	Input.parse_input_event(mouse)
	await process_frame
	_expect(dialogue.get("_line_index") == index + 2, "A real mouse event advances the next beat")
	await _drain(dialogue)
	_expect(not dialogue.visible and game.call("is_world_input_allowed"), "Prologue completion returns control to 1F")
	_expect(game.call("get_available_floors").is_empty(), "Prologue completion alone does not finish manager talk")
	player.global_position.x = 3400.0
	_expect(not game.call("request_floor_travel", 2), "Stairs reject travel before actual manager talk")
	var floor_node: Node = main.get_node("World").get_child(0)
	var manager: Node2D = floor_node.get_node("StaffRoot/ManagerSlot/Staff")
	manager.get_node("TurnTimer").stop()
	player.global_position = manager.global_position + Vector2(30.0, 0.0)
	for frame: int in range(4):
		await physics_frame
	await process_frame
	_expect(floor_node.call("get_interaction_target_id") == "MANAGER_TALK", "Manager talk owns the unique E before theft hints")
	await _action("interact", true)
	await _action("interact", false)
	_expect(dialogue.visible and dialogue.get("_dialogue_id") == "V4_MANAGER_TALK", "E starts the actual manager dialogue")
	_expect(not manager.call("is_stealing") and cards.call("get_owned_cards").is_empty(), "One manager E never steals a card")
	game.call("set_modal_open", "OTHER_PAGE", true)
	# Reach final beat via the real UI, then close with E (held through modal release).
	while dialogue.get("_line_index") < dialogue.get("_beats").size() - 1:
		dialogue.get_node("%ContinueButton").emit_signal("pressed")
	await _action("interact", true)
	_expect(not dialogue.visible and game.call("has_completed_manager_intro"), "Only manager completion opens the upstairs story gate")
	_expect(not game.call("is_world_input_allowed"), "Closing dialogue does not close another page's modal")
	game.call("set_modal_open", "OTHER_PAGE", false)
	await _action("interact", true)
	_expect(not manager.call("is_stealing") and not dialogue.visible, "Closing E cannot also start a world action")
	await _action("interact", false)
	_expect(not game.call("complete_manager_intro"), "Manager completion is idempotent")
	player.global_position.x = 3400.0
	_expect(game.call("request_floor_travel", 2), "Real dialogue opens 2F without any card")
	_expect(cards.call("get_owned_cards").is_empty(), "Story integration grants no development cards")
	main.get_node("DeveloperOverlay/Margin/Info/NewGame").emit_signal("pressed")
	_expect(dialogue.visible and dialogue.get("_dialogue_id") == "V4_INTRO", "New game replays prologue and resets session gates")
	_expect(not game.call("has_completed_manager_intro"), "Read-skip progress is not the new session's manager gate")
	main.queue_free()
	await process_frame
	_expect(game.call("is_world_input_allowed"), "Unloading main releases its own dialogue modal")
	_expect(cards.is_processing_unhandled_input(), "Standalone B input is restored after main unload")
	dialogue = null
	DirAccess.remove_absolute("/private/tmp/ae4pa-intro-flow-%d.cfg" % OS.get_process_id())
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS: real prologue, manager E, modal/input isolation, no-card travel, new game and cleanup.")
	quit(0 if failures.is_empty() else 1)


func _drain(dialogue: Control) -> void:
	var guard: int = 0
	while dialogue.visible and guard < 200:
		dialogue.get_node("%ContinueButton").emit_signal("pressed")
		guard += 1
	await process_frame
	_expect(guard < 200, "Actual TSV story terminates")


func _action(action: String, pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = pressed
	Input.parse_input_event(event)
	await process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
