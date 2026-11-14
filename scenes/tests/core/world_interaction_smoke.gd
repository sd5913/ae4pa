extends SceneTree
## Real shared floors and B employees; checks A's E dispatch, not B's future reward gate.

var failures: Array[String] = []
var game: Node
var cards: Node


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	game = root.get_node("GameManager")
	cards = root.get_node("CardManager")
	var host := Node2D.new()
	root.add_child(host)
	game.call("set_floor_host", host)
	game.call("start_game")
	var floor_node: Node = host.get_child(0)
	if not floor_node.has_method("get_interaction_target_id"):
		_expect(false, "A floor must expose its unique E target")
		host.queue_free()
		await process_frame
		_finish()
		return
	var player: Node2D = floor_node.get_node("Player")
	var cleaner: Node2D = floor_node.get_node("StaffRoot/CleanerSlot/Staff")
	_stop_turns(floor_node)
	player.global_position = cleaner.global_position + Vector2(30, 0)
	await _settle()
	await _action("interact", true)
	await create_timer(0.9).timeout
	await _action("interact", false)
	_expect(not cleaner.call("is_stealing") and game.get("game_state") == "PLAYING", "Unaccepted front E is a hint, never a theft or catch")
	_expect(cards.call("get_owned_cards").is_empty(), "Unaccepted E cannot grant cards")
	game.call("complete_manager_intro")
	player.global_position.x = 3400.0
	await _settle()
	_expect(game.call("request_floor_travel", 2), "Real stairs reach 2F without cards")
	_expect(game.call("offer_task", "TASK_01_CLEAN"), "Real task can be offered")
	_expect(game.call("accept_task", "TASK_01_CLEAN"), "Task acceptance starts eligibility")
	_expect(game.call("request_floor_travel", 1), "Return to 1F preserves the task")
	floor_node = host.get_child(0)
	player = floor_node.get_node("Player")
	cleaner = floor_node.get_node("StaffRoot/CleanerSlot/Staff")
	_stop_turns(floor_node)
	await _approach_cleaner_rear(cleaner, player)
	# Put the stair in the same range: eligible employee has priority over stairs.
	floor_node.get_node("Interactions/ExitPoint").global_position = cleaner.global_position
	_expect(floor_node.call("get_interaction_target_id") == "STAFF_CLEANER_1F", "Eligible work wins over overlapping stairs")
	await _action("interact", true)
	_expect(cleaner.call("is_stealing") and game.get("current_floor") == 1, "One E begins one theft without traveling")
	await _action("interact", false)
	_expect(not cleaner.call("is_stealing"), "Release cancels the locked target")
	_expect(cards.call("get_owned_cards").is_empty(), "Cancelled theft has no reward")
	await _action("interact", true)
	game.call("set_modal_open", "BAG", true)
	_expect(not cleaner.call("is_stealing"), "Opening a modal immediately cancels the held target")
	game.call("set_modal_open", "BAG", false)
	await _action("interact", true)
	_expect(not cleaner.call("is_stealing"), "Closing UI while holding E cannot restart world input")
	await _action("interact", false)
	await _action("interact", true)
	_expect(cleaner.call("is_stealing"), "Release then press can acquire a new target")
	Input.action_press("move_right")
	await process_frame
	Input.action_release("move_right")
	_expect(not cleaner.call("is_stealing"), "Attempting movement cancels the long press")
	await _action("interact", false)
	await _settle()
	await _action("interact", true)
	cards.call("switch_active")
	_expect(not cleaner.call("is_stealing"), "Identity change immediately cancels the long press")
	await _action("interact", false)
	await _approach_cleaner_rear(cleaner, player)
	await _action("interact", true)
	player.global_position.x = cleaner.global_position.x - 100.0 * cleaner.facing_direction
	await _settle()
	_expect(not cleaner.call("is_stealing"), "Leaving the detection range cancels the locked target")
	await _action("interact", false)
	await _approach_cleaner_rear(cleaner, player)
	await _action("interact", true)
	_expect(game.call("request_floor_travel", 2), "Overlapping stair fixture can load while a target is held")
	_expect(not cleaner.call("is_stealing"), "Loading cancels the old employee before removing its floor")
	await _action("interact", false)
	await create_timer(0.9).timeout
	_expect(cards.call("get_owned_cards").is_empty(), "Unloaded employee cannot grant a delayed reward")
	_expect(game.call("request_floor_travel", 1), "Return after cancellation preserves the active task")
	floor_node = host.get_child(0)
	player = floor_node.get_node("Player")
	cleaner = floor_node.get_node("StaffRoot/CleanerSlot/Staff")
	_stop_turns(floor_node)
	# Moving the stair back avoids accidental travel after card collection.
	floor_node.get_node("Interactions/ExitPoint").global_position.x = 3400.0
	await _approach_cleaner_rear(cleaner, player)
	await _action("interact", true)
	await create_timer(0.9).timeout
	await _action("interact", false)
	_expect(cards.call("has_card", "CLEANER"), "Accepted task still uses real B theft and card collection")
	var time_before: float = game.get("remaining_time")
	player.global_position.x = 3400.0
	await _settle()
	game.call("set_modal_open", "PAUSE", true)
	_expect(not game.call("request_floor_travel", 2), "A modal blocks direct stair requests too")
	game.call("set_modal_open", "PAUSE", false)
	_expect(game.call("request_floor_travel", 2), "Closing the modal permits valid stairs")
	_expect(game.get("remaining_time") <= time_before and game.get("remaining_time") > time_before - 1.0, "Input routing and travel preserve remaining time")
	floor_node = host.get_child(0)
	player = floor_node.get_node("Player")
	player.global_position.x = 1500.0
	await _settle()
	_expect(player.global_position.x < 1250.0, "Undelivered task cannot cross the 201 barrier")
	# Querying work from a modal must not advance the task even with the right card.
	cards.call("switch_active") # The earlier cancellation check selected the empty slot.
	game.call("set_modal_open", "BAG", true)
	_expect(not game.call("record_work_result", "STAIN_201"), "Modal work cannot advance world state")
	game.call("set_modal_open", "BAG", false)
	var cleaning_spot: Node = floor_node.get_node("Interactions/Stain201Slot/CleaningSpot")
	player.global_position = cleaning_spot.global_position
	await _settle()
	_expect(floor_node.call("get_interaction_target_id") == "STAIN_201", "Unique E selects the formal 201 cleaning spot")
	await _action("interact", true)
	await create_timer(1.6).timeout
	await _action("interact", false)
	_expect(cleaning_spot.is_completed() and game.get("task_status") == "READY_TO_SUBMIT", "Formal CleaningSpot signal reaches ready-to-submit")
	_expect(not game.call("get_world_flags").get("passage_201_unlocked", false), "Cleaning alone leaves the passage locked")
	player.global_position.x = 192.0
	_expect(game.call("request_floor_travel", 1), "Cleaned task can return downstairs before delivery")
	host.get_child(0).get_node("Player").global_position.x = 3400.0
	_expect(game.call("request_floor_travel", 2), "Ready-to-submit task can revisit 2F")
	floor_node = host.get_child(0)
	player = floor_node.get_node("Player")
	cleaning_spot = floor_node.get_node("Interactions/Stain201Slot/CleaningSpot")
	_expect(cleaning_spot.is_completed() and not cleaning_spot.get_node("Stain").visible, "Reloaded 2F restores the completed stain visual")
	game.call("set_modal_open", "DIALOGUE", true)
	_expect(not game.call("submit_task", "TASK_01_CLEAN"), "Modal world delivery cannot settle")
	game.call("set_modal_open", "DIALOGUE", false)
	_expect(game.call("submit_task", "TASK_01_CLEAN"), "201 delivery settles once")
	_expect(game.call("get_world_flags").get("passage_201_unlocked", false), "Only delivery records the permanent passage permission")
	player.global_position.x = 1500.0
	await _settle()
	_expect(player.global_position.x > 1250.0, "Delivery releases the actual player bounds")
	player.global_position.x = 192.0
	_expect(game.call("request_floor_travel", 1), "Completed task can return downstairs")
	host.get_child(0).get_node("Player").global_position.x = 3400.0
	_expect(game.call("request_floor_travel", 2), "Completed task can revisit 2F")
	player = host.get_child(0).get_node("Player")
	player.global_position.x = 1500.0
	await _settle()
	_expect(player.global_position.x > 1250.0, "Reloaded floor derives its unlocked bounds from A state")
	_expect(not game.call("request_floor_travel", 3), "Task 01 does not implement or bypass task 02")
	player.global_position.x = 192.0
	await _action("interact", true)
	_expect(game.get("current_floor") == 1, "One E returns to 1F")
	await _action("interact", true)
	_expect(game.get("current_floor") == 1, "Held E cannot bounce through the newly loaded stair")
	await _action("interact", false)
	floor_node = host.get_child(0)
	_stop_turns(floor_node)
	player = floor_node.get_node("Player")
	player.global_position.x = 2000.0
	var security: Node2D = floor_node.get_node("StaffRoot/SecuritySlot/Staff")
	var manager: Node2D = floor_node.get_node("StaffRoot/ManagerSlot/Staff")
	security.global_position.x = 1990.0
	manager.global_position.x = 2010.0
	await _settle()
	_expect(floor_node.call("get_interaction_target_id") == "MANAGER_TALK", "Equal-priority equal-distance targets use fixed ID order, including manager guidance")
	security.global_position.x = 1995.0
	await _settle()
	_expect(floor_node.call("get_interaction_target_id") == "STAFF_SECURITY_1F", "Equal-priority targets prefer the nearest distance")
	host.queue_free()
	await process_frame
	_finish()


func _stop_turns(floor_node: Node) -> void:
	for slot: Node in floor_node.get_node("StaffRoot").get_children():
		for timer_name: String in ["TurnTimer", "TurnWarningTimer", "BehaviorTimer"]:
			slot.get_node("Staff/" + timer_name).stop()


func _approach_cleaner_rear(cleaner: Node2D, player: Node2D) -> void:
	player.global_position = cleaner.global_position + Vector2(30 * cleaner.facing_direction, 0)
	await _settle()
	if cleaner.is_suspicious():
		_expect(game.get("game_state") == "PLAYING", "Curiosity alone never fails the accepted task")
		await cleaner.get_node("SuspicionTimer").timeout
	# Isolate A's routing/cancellation checks from B's random walk/turn schedule.
	for timer_name: String in ["TurnTimer", "TurnWarningTimer", "BehaviorTimer"]:
		cleaner.get_node(timer_name).stop()
	player.global_position = cleaner.global_position - Vector2(30 * cleaner.facing_direction, 0)
	await _settle()
	_expect(cleaner.is_player_behind() and not cleaner.is_suspicious(), "Theft setup waits for curiosity and moves behind the actual facing")


func _action(action: String, pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = pressed
	Input.parse_input_event(event)
	await process_frame


func _settle() -> void:
	for frame: int in range(4):
		await physics_frame
	await process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS: unique E dispatch, task gate, cancellation, modal guards, passage and revisit.")
	quit(0 if failures.is_empty() else 1)
