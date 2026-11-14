extends SceneTree
## Real B cards/staff/work + C story door, driven through A's floor router.

var failures: Array[String] = []
var game: Node
var cards: Node
var host: Node2D


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	game = root.get_node("GameManager")
	cards = root.get_node("CardManager")
	if not game.has_method("retry_current_task"):
		printerr("FAIL: A must restore the real task checkpoint")
		quit(1)
		return
	host = Node2D.new()
	root.add_child(host)
	game.call("set_floor_host", host)
	game.call("start_game")
	game.set_process(false) # Only this test explicitly advances the task clock.
	game.call("complete_manager_intro")
	# Inventory/world fixtures represent facts that must survive a later task rollback.
	cards.call("collect_card", "SECURITY")
	game.set("_world_flags", {"prior_note": true})
	var before_cards: Dictionary = cards.call("export_snapshot")
	var before_notes: Dictionary = game.call("get_notebook_view")
	await _travel(2)
	_player().global_position.x = 580.0
	await _settle()
	_expect(game.get("task_status") == "AVAILABLE", "Real 201 offers before acceptance")
	_expect(game.call("accept_task", "TASK_01_CLEAN"), "Acceptance captures real B cards before work")
	_expect(not game.call("can_retry_current_task"), "Active task cannot be retried")
	await _travel(1)
	var previous_cleaner: Node = _floor().get_node("StaffRoot/CleanerSlot/Staff")
	_player().global_position.x = 3400.0
	await _settle()
	game.call("request_floor_travel", 2)
	previous_cleaner.emit_signal("task_failure_requested", "STAFF_CAUGHT", "STAFF_CLEANER_1F")
	_expect(game.get("task_status") == "ACTIVE", "Late event from a removed floor cannot fail the new world")
	if game.get("task_status") != "ACTIVE":
		await _finish()
		return
	await _settle()
	await _steal_cleaner()
	_expect(cards.call("has_card", "CLEANER"), "Real rear E theft grants the task card")
	_expect(cards.get("active_card") == "SECURITY", "New card does not silently change active identity")
	await _travel(2)
	var spot: Node = _floor().get_node_or_null("Interactions/Stain201Slot/CleaningSpot")
	_expect(spot != null, "2F mounts B's real cleaning point")
	if spot == null:
		await _finish()
		return
	_player().global_position.x = 980.0
	await _settle()
	await _action("interact", true)
	await _action("interact", false)
	_expect(not spot.call("is_interacting"), "Standby CLEANER cannot clean")
	await _action("switch_id", true)
	await _action("switch_id", false)
	_expect(cards.get("active_card") == "CLEANER", "Real Q selects the required identity")
	await _action("interact", true)
	await _action("switch_id", true)
	await _action("switch_id", false)
	_expect(not spot.call("is_interacting"), "Changing identity cancels work before reward")
	await _action("interact", false)
	await _action("switch_id", true)
	await _action("switch_id", false)
	await _action("interact", true)
	await create_timer(0.3).timeout
	Input.action_press("move_right")
	await process_frame
	await process_frame # Let the floor observe the held movement before release.
	Input.action_release("move_right")
	_expect(not spot.call("is_interacting"), "Movement attempt cancels real cleaning")
	await _action("interact", false)
	await _action("interact", true)
	game.call("set_modal_open", "BAG", true)
	_expect(not spot.call("is_interacting"), "Opening UI cancels the held work target immediately")
	var frozen: float = game.get("remaining_time")
	game.call("_process", 3.0)
	_expect(game.get("remaining_time") == frozen, "Work modal keeps the task clock stopped")
	await _action("switch_id", true)
	await _action("switch_id", false)
	_expect(cards.get("active_card") == "CLEANER", "World Q is blocked by a modal")
	game.call("set_modal_open", "BAG", false)
	await _action("interact", true)
	_expect(not spot.call("is_interacting"), "Closing UI requires a release before world work can restart")
	await _action("interact", false)
	await _clean()
	_expect(game.get("task_status") == "READY_TO_SUBMIT", "B's actual hold completes work but still requires delivery")
	_expect(game.call("get_world_flags").get("stain_201_cleaned", false), "A stores the accepted cleaning fact")
	_expect(not game.call("get_world_flags").get("passage_201_unlocked", false), "Cleaning does not open the passage")
	game.call("_process", 5.0)
	_expect(game.get("remaining_time") == 205.0, "Ready task still uses the same clock")
	await _travel(1)
	await _travel(2)
	spot = _floor().get_node("Interactions/Stain201Slot/CleaningSpot")
	_expect(not spot.visible, "Revisited floor rebuilds a cleaned stain from A's truth")
	await _travel(1)
	game.call("set_modal_open", "FAILURE", true)
	game.call("set_modal_open", "FAILURE", false)
	game.call("_process", 205.0)
	_expect(game.get("task_status") == "FAILED", "Timeout before delivery fails from another floor")
	var active: int = cards.get("active_slot")
	await _action("switch_id", true)
	await _action("switch_id", false)
	_expect(cards.get("active_slot") == active, "Failed world cannot switch identity via Q")
	var checkpoint: Dictionary = game.get("_task_checkpoint").duplicate(true)
	var invalid: Dictionary = checkpoint.duplicate(true)
	invalid["cards"]["equipped_cards"][0] = "UNKNOWN"
	game.set("_task_checkpoint", invalid)
	var failed_floor: Node = _floor()
	var failed_cards: Dictionary = cards.call("export_snapshot")
	_expect(not game.call("retry_current_task"), "Invalid checkpoint is rejected before altering the world")
	_expect(_floor() == failed_floor and cards.call("export_snapshot") == failed_cards, "Rejected restore preserves the failed world and inventory")
	game.set("_task_checkpoint", checkpoint)
	var unsafe: Dictionary = checkpoint.duplicate(true)
	unsafe["position"] = Vector2(700, 560)
	game.set("_task_checkpoint", unsafe)
	_expect(not game.call("retry_current_task"), "Recovery rejects a checkpoint inside the story door")
	_expect(_floor() == failed_floor and cards.call("export_snapshot") == failed_cards, "Unsafe restore keeps the original failed world")
	game.set("_task_checkpoint", checkpoint)
	var restored_events: Array[int] = [0, 0]
	var on_cards := func() -> void: restored_events[0] += 1
	var on_identity := func(_action: String) -> void: restored_events[1] += 1
	cards.connect("cards_changed", on_cards)
	cards.connect("identity_changed", on_identity)
	game.call("set_modal_open", "FAILURE", true)
	game.call("set_modal_open", "PAUSE", true)
	_expect(game.call("retry_current_task"), "Real retry restores the task's original floor")
	await _settle()
	_expect(game.get("current_floor") == 2 and _player().global_position == Vector2(560, 560), "Retry returns to the validated 201 acceptance point")
	_expect(game.get("task_status") == "AVAILABLE" and game.get("remaining_time") == 0.0, "Retry waits for another acceptance")
	_expect(cards.call("export_snapshot") == before_cards, "Retry revokes the task card and restores prior slots/active identity")
	_expect(restored_events == [1, 0], "Restore refreshes cards once without an active identity event")
	_expect(game.call("get_world_flags") == {"prior_note": true}, "Retry revokes cleaning while keeping prior world facts")
	_expect(game.call("get_notebook_view") == before_notes, "Retry restores the same manager clues without leaking the unearned rule")
	_expect(game.call("is_world_input_allowed"), "Recovery releases its modal/input locks")
	_expect(_floor().get_node("DoorRoot/Room202/Door").is_physics_processing(), "Recovery resumes actual ordinary-door detection after clearing modals")
	_expect(not game.call("retry_current_task"), "Repeated retry cannot reload an available task")
	cards.disconnect("cards_changed", on_cards)
	cards.disconnect("identity_changed", on_identity)
	_expect(_floor().get_node("Interactions/Stain201Slot/CleaningSpot").visible, "Rebuilt stain is available again after rollback")
	_expect(game.call("accept_task", "TASK_01_CLEAN") and game.get("remaining_time") == 210.0, "Reacceptance starts the full configured time")
	await _travel(1)
	var cleaner: Node2D = _floor().get_node("StaffRoot/CleanerSlot/Staff")
	_stop_turns(cleaner)
	_player().global_position = cleaner.global_position + Vector2(30, 0)
	await _settle()
	await _action("interact", true)
	await _action("interact", false)
	_expect(game.get("task_status") == "FAILED" and game.get("fail_reason") == "STAFF_CAUGHT", "B's real front-catch event reaches A's task failure")
	_expect(not cards.call("has_card", "CLEANER"), "Front catch grants no task card")
	_expect(game.call("retry_current_task"), "Caught task can recover through the same checkpoint")
	_expect(game.call("accept_task", "TASK_01_CLEAN"), "Recovered task accepts once again")
	await _travel(1)
	cleaner = _floor().get_node("StaffRoot/CleanerSlot/Staff")
	_stop_turns(cleaner)
	await _approach_cleaner_rear(cleaner)
	await _action("interact", true)
	cleaner.get_node("TurnTimer").emit_signal("timeout")
	await _action("interact", false)
	_expect(game.get("task_status") == "FAILED", "Turning during the real theft uses the same failure chain")
	_expect(game.call("retry_current_task"), "Repeated failure cycles restore cleanly")
	game.call("accept_task", "TASK_01_CLEAN")
	await _steal_cleaner()
	await _travel(2)
	await _action("switch_id", true)
	await _action("switch_id", false)
	_player().global_position.x = 980.0
	await _settle()
	await _clean()
	_player().global_position.x = 700.0
	await _settle()
	await _action("interact", true)
	await _action("interact", false)
	_expect(game.get("task_status") == "COMPLETED", "Real work and real C E delivery settle task 01")
	_expect(game.call("get_world_flags").get("passage_201_unlocked", false), "Only actual delivery unlocks the passage")
	_expect(not game.call("can_retry_current_task"), "Completed task cannot roll back")
	# Deterministic C phase fixture; detection and safe return still run on real frames.
	var ordinary: Node = _floor().get_node("DoorRoot/Room202/Door")
	ordinary.set_process(false)
	ordinary.set("door_state", "CLOSED")
	_player().global_position.x = 1370.0
	await _settle()
	ordinary.set("door_state", "OPEN")
	_player().global_position.x = 1530.0
	await _settle()
	_expect(_player().global_position.x == 1400.0 and game.get("task_status") == "COMPLETED", "After retries, actual wrong-card door detection still returns safely without rolling back delivery")
	game.call("start_game")
	_expect(not game.call("can_retry_current_task") and cards.call("get_owned_cards").is_empty(), "New game clears task checkpoint and cards")
	await _finish()


func _floor() -> Node:
	return host.get_child(0)


func _player() -> Node2D:
	return _floor().get_node("Player")


func _travel(destination: int) -> void:
	_player().global_position.x = 3400.0 if destination > game.get("current_floor") else 192.0
	await _settle()
	_expect(game.call("request_floor_travel", destination), "Legitimate stairs travel to %dF" % destination)
	await _settle()


func _steal_cleaner() -> void:
	if game.get("current_floor") != 1:
		await _travel(1)
	var cleaner: Node2D = _floor().get_node("StaffRoot/CleanerSlot/Staff")
	_stop_turns(cleaner)
	await _approach_cleaner_rear(cleaner)
	await _action("interact", true)
	await create_timer(0.9).timeout
	await _action("interact", false)


func _approach_cleaner_rear(cleaner: Node2D) -> void:
	_player().global_position = cleaner.global_position + Vector2(30 * cleaner.facing_direction, 0)
	await _settle()
	_expect(cleaner.is_suspicious(), "Unrecognized approach runs B's real CURIOUS behavior")
	_expect(game.get("task_status") == "ACTIVE" and not cards.call("has_card", "CLEANER"), "Curiosity neither fails the task nor grants its card")
	if cleaner.is_suspicious():
		await cleaner.get_node("SuspicionTimer").timeout
	_stop_turns(cleaner) # Deterministic turn/walk phase; no changes to B's behavior.
	_player().global_position = cleaner.global_position - Vector2(30 * cleaner.facing_direction, 0)
	await _settle()
	_expect(cleaner.is_player_behind() and not cleaner.is_suspicious(), "Real curiosity times out before the rear theft")


func _stop_turns(cleaner: Node) -> void:
	cleaner.get_node("TurnTimer").stop()
	cleaner.get_node("TurnWarningTimer").stop()
	cleaner.get_node("BehaviorTimer").stop()


func _clean() -> void:
	await _action("interact", true)
	await create_timer(1.6).timeout
	await _action("interact", false)


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


func _finish() -> void:
	game.set_process(true)
	host.queue_free()
	await process_frame
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS: real theft/work/delivery, checkpoint rollback, caught/timeout recovery and modal boundaries.")
	quit(0 if failures.is_empty() else 1)
