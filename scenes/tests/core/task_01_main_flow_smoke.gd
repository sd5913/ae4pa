extends SceneTree

var failures: int = 0
var game: Node
var cards: Node

func _initialize() -> void:
	call_deferred("_run")

func _expect(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _settle() -> void:
	for i in range(5):
		await physics_frame
	await process_frame

func _key(pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = pressed
	Input.parse_input_event(event)
	await _settle()

func _run() -> void:
	game = root.get_node("GameManager")
	cards = root.get_node("CardManager")
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main.get_node("MenuLayer/MainMenu").get_node("%StartButton").pressed.emit()
	# Opening / manager dialogue already has its own real-input regression.
	main.dialogue.hide()
	main._on_dialogue_finished("V4_INTRO")
	game.complete_manager_intro()
	main.get_node("World").get_child(0).get_node("Player").position.x = 3400
	game.request_floor_travel(2)
	var floor_node = main.get_node("World").get_child(0)
	var player = floor_node.get_node("Player")
	Input.action_press("move_right")
	await create_timer(2.8).timeout
	Input.action_release("move_right")
	await _settle()
	await _read_monster_dialogue(main)
	var board = main.get_node("TaskLayer/MissionBoard")
	_expect(game.task_status == "AVAILABLE" and board.visible,"Walking to actual 201 boundary opens real mission UI")
	_expect(not game.is_world_input_allowed(),"Task offer modal blocks movement until closed")
	board._accept_button.emit_signal("pressed")
	await _settle()
	_expect(game.task_status == "ACTIVE" and not board.visible and game.is_world_input_allowed(),"Actual accept button accepts and releases modal")
	board.open_board()
	board.hide()
	await _settle()
	var spot = floor_node.get_node("Interactions/Stain201Slot/CleaningSpot")
	_expect(spot.is_visible_in_tree(),"Cleaning prompt is not hidden by art assembly")
	_expect(absf(spot.global_position.x-852.0)<1.0,"Cleaning hotspot matches the broom position")
	cards.collect_card("CLEANER") # Business fixture; real theft has world_interaction coverage.
	player.position.x = spot.global_position.x
	await _settle()
	await _key(true)
	await create_timer(1.65).timeout
	await _key(false)
	_expect(game.task_status == "READY_TO_SUBMIT" and spot.is_completed(),"Real E hold cleans through B component and floor signal")
	player.position.x = floor_node.get_node("DoorRoot/Room201").position.x
	await _settle()
	await _key(true)
	await _key(false)
	_expect(game.task_status == "COMPLETED" and game.get_world_flags().get("passage_201_unlocked",false),"Return E delivery unlocks the passage")
	await _read_monster_dialogue(main)
	player.position.x = 1400
	await _settle()
	_expect(player.position.x > 1250,"Completed task can pass the former barrier")
	main.queue_free()
	await process_frame
	print("TASK_01_MAIN_FLOW: ","PASS" if failures == 0 else "FAIL")
	quit(0 if failures == 0 else 1)

func _read_monster_dialogue(main: Node) -> void:
	var screen: Control = main.get_node("TaskLayer/MonsterDialogue")
	for i in range(80):
		if not screen.visible: return
		await _key(true)
		await _key(false)
	_expect(false, "Monster dialogue closes after real E input")
