extends SceneTree
## Actual F5/D buttons plus real B/C work. Only clock/phase and player travel use fixtures.

var failures: Array[String] = []
var main: Node
var game: Node
var cards: Node
var board: Control
var failure: Control


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	game = root.get_node("GameManager")
	cards = root.get_node("CardManager")
	await _check_components()
	main = load("res://scenes/main.tscn").instantiate()
	if not main.has_node("MenuLayer/MainMenu") or not main.has_node("MenuLayer/Notebook"):
		main.free()
		printerr("FAIL: F5 must provide a normal menu and progressive notebook")
		quit(1)
		return
	var dialogue: Control = main.get_node("StoryLayer/Dialogue")
	var progress_path: String = "/private/tmp/ae4pa-task-ui-%d.cfg" % OS.get_process_id()
	dialogue.set_progress_file_path_for_test(progress_path)
	root.add_child(main)
	var menu: Control = main.get_node("MenuLayer/MainMenu")
	var notebook: Control = main.get_node("MenuLayer/Notebook")
	var bag: Control = main.get_node("MenuLayer/Bag")
	_expect(menu.visible and game.get("game_state") == "MENU" and not dialogue.visible, "F5 opens the real D menu before the prologue")
	menu.get_node("%HelpButton").pressed.emit()
	for reverse: bool in [false, true]:
		for step: int in range(6):
			var tab := InputEventKey.new()
			tab.keycode = KEY_TAB
			tab.physical_keycode = KEY_TAB
			tab.shift_pressed = reverse
			tab.pressed = true
			Input.parse_input_event(tab)
			await process_frame
			var focused: Control = main.get_viewport().gui_get_focus_owner()
			_expect(focused != null and notebook.is_ancestor_of(focused), "Tab and Shift-Tab stay inside the visible notebook")
	_expect(notebook.visible and game.get("game_state") == "MENU", "Menu help opens controls without starting the game")
	notebook.get_node("%NextButton").pressed.emit()
	_expect(notebook.get_node("%MonsterPage/NoseRule").text == "尚未取得线索。", "Menu notebook keeps undiscovered monster rules unknown")
	await _action("open_help", true)
	await _action("open_help", false)
	menu.get_node("%StartButton").pressed.emit()
	await create_timer(0.6).timeout
	dialogue.set_skip_transitions_for_test(true)
	board = main.get_node("TaskLayer/MissionBoard")
	failure = main.get_node("TaskLayer/Failure")
	var hud: Control = main.get_node("TaskLayer/HUD")
	_expect(not board.visible and not failure.visible and not hud.is_visible_in_tree(), "Story starts without task/failure/HUD leaking through")
	await _drain(dialogue)
	var manager: Node2D = _floor().get_node("StaffRoot/ManagerSlot/Staff")
	_player().global_position = manager.global_position + Vector2(85, 0)
	await _settle()
	await _action("interact", true)
	await _action("interact", false)
	await _drain(dialogue)
	_expect(game.call("has_completed_manager_intro"), "Real manager dialogue unlocks task route")
	await _action("open_help", true)
	await _action("open_help", false)
	notebook.get_node("%NextButton").pressed.emit()
	_expect(notebook.get_node("%MonsterPage/NoseRule").text == "有些住客对气味敏感。", "Actual manager completion exposes only the vague nose clue")
	await _action("open_help", true)
	await _action("open_help", false)
	await _travel(2)
	_player().global_position.x = 580.0
	await _settle()
	_expect(board.visible and game.get("task_status") == "AVAILABLE", "Real 201 intercept opens D task offer")
	_expect(not game.call("is_world_input_allowed"), "Task offer registers its modal")
	game.call("_process", 10.0)
	_expect(game.get("remaining_time") == 0.0, "Reading an offer never starts the task clock")
	_expect("210" in str(board.get("_hint").text) and "CLEANER" in str(board.get("_hint").text), "Offer explains required identity and the full limit")
	var waiting_position: Vector2 = _player().global_position
	Input.action_press("move_right")
	await _settle()
	Input.action_release("move_right")
	_expect(_player().global_position == waiting_position, "Reading the task offer locks player movement")
	var active_slot: int = cards.get("active_slot")
	await _action("switch_id", true)
	await _action("switch_id", false)
	await _action("interact", true)
	await _action("interact", false)
	_expect(board.visible and game.get("task_status") == "AVAILABLE" and cards.get("active_slot") == active_slot, "World E/Q over an offer neither accept nor switch identity")
	_button(board, "关闭").pressed.emit()
	_expect(not board.visible and game.call("is_world_input_allowed"), "Closing unaccepted offer releases only its input lock")
	await _action("interact", true)
	_expect(board.visible and game.get("task_status") == "AVAILABLE", "At 201, E reopens an offer closed without accepting")
	game.call("set_modal_open", "OTHER_PAGE", true)
	_accept()
	_expect(not game.call("is_world_input_allowed"), "Accepting an offer preserves another page's modal")
	game.call("_process", 10.0)
	_expect(game.get("remaining_time") == 210.0, "Accepted task stays frozen until all modals close")
	game.call("set_modal_open", "OTHER_PAGE", false)
	game.set_process(false) # Explicit task-clock fixture from here onward.
	_player().global_position.x = 192.0
	await _settle()
	await _action("interact", true)
	_expect(game.get("current_floor") == 2, "Held E from opening/accepting UI cannot also use the stairs")
	await _action("interact", false)
	await process_frame
	_expect("3:30" in hud.get_node("%RemainingTime").text, "D HUD reads the actual task time")
	_expect("STAIN_201" not in hud.get_node("%Objective").text and "ACTIVE" not in hud.get_node("%RemainingTime").text, "F5 HUD uses player-facing objectives and status names")
	await _travel(1)
	await _steal()
	_expect(cards.call("has_card", "CLEANER"), "Real rear E theft grants the task card")
	var before_bag: float = game.get("remaining_time")
	await _action("open_bag", true)
	await _action("open_bag", false)
	_expect(bag.visible and bag.get_node("%OwnedCards").item_count == 1, "Real I opens D bag with the actually stolen card")
	_expect("尚未获得" not in bag.get_node("%Status").text, "A populated bag clears stale empty-inventory feedback")
	game.call("_process", 5.0)
	_expect(game.get("remaining_time") == before_bag, "Bag reads and equipment keep the task clock stopped")
	bag.get_node("%OwnedCards").select(0)
	bag.get_node("%OwnedCards").item_selected.emit(0)
	bag.get_node("%EquipSlotB").pressed.emit()
	_expect(cards.call("get_equipped_cards") == ["NONE", "CLEANER"], "D equipment button calls real CardManager slot replacement")
	await _action("open_bag", true)
	await _action("open_bag", false)
	await _action("switch_id", true)
	await _action("switch_id", false)
	_expect(not bag.visible and cards.get("active_card") == "CLEANER", "Closing bag resumes world Q into the selected cleaner slot")
	await _travel(2)
	_player().global_position.x = 980.0
	await _settle()
	await _action("interact", true)
	await create_timer(1.6).timeout
	await _action("interact", false)
	_expect(game.get("task_status") == "READY_TO_SUBMIT", "Real cleaning reaches delivery, not settlement")
	game.call("_process", 210.0)
	_expect(failure.visible and not board.visible, "Timeout opens one failure page, not overlapping task/failure panels")
	_expect("超时" in failure.get_node("%Reason").text and "超时" in failure.get_node("Center/Panel/Content/Title").text, "Timeout heading and reason describe timeout, not a catch")
	_expect(not failure.get_node("%RetryButton").disabled, "A enables D retry from the real checkpoint query")
	failure.get_node("%RetryButton").pressed.emit()
	await _settle()
	_expect(board.visible and not failure.visible, "Retry closes old failure page and opens acceptance again")
	_expect(not board.get("_retry_button").visible, "Acceptance after retry hides the board legacy failure controls")
	_expect(game.get("task_status") == "AVAILABLE" and game.get("remaining_time") == 0.0, "Retry waits at 201 before a full new limit")
	_expect(_player().global_position == Vector2(560, 560) and not cards.call("has_card", "CLEANER"), "Retry restores the real acceptance point and revokes task card")
	_expect(not game.call("get_world_flags").get("stain_201_cleaned", false), "Retry revokes task cleaning")
	var recovered_floor: Node = _floor()
	failure.get_node("%RetryButton").pressed.emit()
	_expect(_floor() == recovered_floor and board.visible, "Stale retry cannot rebuild an available task")
	_accept()
	await _travel(1)
	var cleaner: Node2D = _floor().get_node("StaffRoot/CleanerSlot/Staff")
	_player().global_position = cleaner.global_position + Vector2(30 * cleaner.facing_direction, 0)
	await _settle()
	await _action("interact", true)
	await _action("interact", false)
	_expect(failure.visible and game.get("fail_reason") == "STAFF_CAUGHT", "Actual front E shows task failure UI")
	failure.get_node("%RetryButton").pressed.emit()
	await _settle()
	_accept()
	await _travel(1)
	await _steal()
	await _travel(2)
	_player().global_position.x = 980.0
	await _settle()
	await _action("interact", true)
	await create_timer(1.6).timeout
	await _action("interact", false)
	_player().global_position.x = 700.0
	await _settle()
	await _action("interact", true)
	await _action("interact", false)
	_expect(game.get("task_status") == "COMPLETED" and not board.visible and not failure.visible, "Real 201 E settles after UI retries without stale panels")
	_expect(game.call("get_world_flags").get("passage_201_unlocked", false), "Delivery opens the actual passage")
	await _action("open_help", true)
	await _action("open_help", false)
	notebook.get_node("%NextButton").pressed.emit()
	_expect("保洁" in notebook.get_node("%MonsterPage/NoseRule").text and notebook.get_node("%MonsterPage/HatId").text == "未知住客", "Delivered 201 reveals only its earned rule in H")
	await _action("open_help", true)
	await _action("open_help", false)
	var ordinary: Node = _floor().get_node("DoorRoot/Room202/Door")
	ordinary.set_process(false)
	ordinary.set("door_state", "CLOSED")
	_player().global_position.x = 1370.0
	await _settle()
	ordinary.set("door_state", "OPEN")
	_player().global_position.x = 1530.0
	await _settle()
	_expect(_player().global_position.x == 1400.0 and game.get("task_status") == "COMPLETED" and not failure.visible and not board.visible, "Ordinary warning returns safely without opening task failure UI")
	main.get_node("DeveloperOverlay/Margin/Info/NewGame").pressed.emit()
	await _drain(dialogue)
	await _reach_offer(dialogue)
	_accept()
	game.call("_process", 210.0)
	_expect(failure.visible, "New session can reach another real task failure")
	failure.get_node("%MenuButton").pressed.emit()
	_expect(menu.visible and game.get("game_state") == "MENU" and not dialogue.visible and not board.visible and not failure.visible, "Failure menu button returns to the real menu")
	menu.get_node("%StartButton").pressed.emit()
	_expect(dialogue.visible and game.get("task_status") == "NONE" and cards.call("get_owned_cards").is_empty(), "Starting from the menu clears task/card state and replays the prologue")
	await _drain(dialogue)
	await _reach_offer(dialogue)
	_expect(board.visible and not board.get("_retry_button").visible, "A new game's acceptance view has no stale failure control")
	_expect(not game.call("is_world_input_allowed"), "Teardown precondition has a real open offer modal")
	main.queue_free()
	await process_frame
	_expect(game.call("is_world_input_allowed"), "Unloading F5 with an open offer releases its modal")
	game.set_process(true)
	DirAccess.remove_absolute(progress_path)
	for message: String in failures:
		printerr("FAIL: ", message)
	if failures.is_empty():
		print("PASS: F5 D acceptance/HUD/failure/retry, real B/C task loop, timeout/caught rollback, modal ownership and ordinary return.")
	quit(0 if failures.is_empty() else 1)


func _check_components() -> void:
	# Standalone D component verification before mounting the main scene.
	game.call("start_game")
	game.set_process(false)
	var standalone_board: Control = load("res://scenes/ui/mission_board.tscn").instantiate()
	var standalone_hud: Control = load("res://scenes/ui/hud.tscn").instantiate()
	var standalone_failure: Control = load("res://scenes/ui/failure.tscn").instantiate()
	root.add_child(standalone_board)
	root.add_child(standalone_hud)
	root.add_child(standalone_failure)
	game.call("complete_manager_intro")
	game.set("current_floor", 2) # No physical host in the standalone UI check.
	game.call("offer_task", "TASK_01_CLEAN")
	standalone_board.open_board()
	_expect(not standalone_board.get("_accept_button").disabled, "Standalone D board reads A's offered task")
	standalone_board.get("_accept_button").pressed.emit()
	cards.call("collect_card", "CLEANER")
	await process_frame
	_expect(game.get("task_status") == "ACTIVE" and game.get("remaining_time") == 210.0, "Standalone D accept button calls the real task API")
	_expect(standalone_hud.get_node("%ActiveCardValue").text == "保洁工作证" and "3:30" in standalone_hud.get_node("%RemainingTime").text, "Standalone D HUD reads real card and clock values")
	standalone_failure.show_failure("STAFF_CAUGHT")
	_expect(standalone_failure.get_node("%Reason").text == "偷窃被发现" and standalone_failure.get_node("%RetryButton").disabled, "Standalone D failure scene displays caught feedback; retry awaits A's adapter")
	standalone_board.queue_free()
	standalone_hud.queue_free()
	standalone_failure.queue_free()
	await process_frame
	game.set_process(true)


func _reach_offer(dialogue: Control) -> void:
	var manager: Node2D = _floor().get_node("StaffRoot/ManagerSlot/Staff")
	_player().global_position = manager.global_position + Vector2(85, 0)
	await _settle()
	await _action("interact", true)
	await _action("interact", false)
	await _drain(dialogue)
	await _travel(2)
	_player().global_position.x = 580.0
	await _settle()


func _floor() -> Node:
	return main.get_node("World").get_child(0)


func _player() -> Node2D:
	return _floor().get_node("Player")


func _accept() -> void:
	var button: Button = board.get("_accept_button")
	button.pressed.emit()
	_expect(game.get("task_status") == "ACTIVE" and not board.visible, "D accept button starts the real task and closes its own page")


func _steal() -> void:
	var cleaner: Node2D = _floor().get_node("StaffRoot/CleanerSlot/Staff")
	_player().global_position = cleaner.global_position + Vector2(30 * cleaner.facing_direction, 0)
	await _settle()
	if cleaner.is_suspicious():
		await cleaner.get_node("SuspicionTimer").timeout
	for timer_name: String in ["TurnTimer", "TurnWarningTimer", "BehaviorTimer"]:
		cleaner.get_node(timer_name).stop()
	_player().global_position = cleaner.global_position - Vector2(30 * cleaner.facing_direction, 0)
	await _settle()
	await _action("interact", true)
	await create_timer(0.9).timeout
	await _action("interact", false)


func _travel(destination: int) -> void:
	_player().global_position.x = 3400.0 if destination > game.get("current_floor") else 192.0
	await _settle()
	await _action("interact", true)
	await _action("interact", false)
	_expect(game.get("current_floor") == destination, "Real E stairs reach %dF" % destination)
	await _settle()


func _drain(dialogue: Control) -> void:
	for index: int in range(300):
		if not dialogue.visible:
			return
		dialogue.get_node("%ContinueButton").pressed.emit()
		await process_frame
	_expect(false, "Actual D dialogue completes")


func _button(node: Node, text: String) -> Button:
	for child: Node in node.get_children():
		if child is Button and child.text == text:
			return child
		var found: Button = _button(child, text)
		if found != null:
			return found
	return null


func _settle() -> void:
	for frame: int in range(4):
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
