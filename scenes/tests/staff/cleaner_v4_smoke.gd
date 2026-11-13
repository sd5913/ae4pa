extends Node

var _failed: bool = false
var _card_signals: int = 0
var _identity_signals: int = 0
var _cleaning_signals: int = 0


func _ready() -> void:
	var test_scene: Node = load("res://scenes/tests/staff/staff_test.tscn").instantiate()
	add_child(test_scene)
	await get_tree().process_frame
	await get_tree().physics_frame

	var player: HotelPlayer = test_scene.get_node("Corridor/Player")
	var cleaner: Node = test_scene.get_node("StaffMembers/Cleaner")
	cleaner.get_node("TurnTimer").stop()
	cleaner.get_node("TurnWarningTimer").stop()
	var cleaner_home: Vector2 = cleaner.position
	_expect(cleaner.get_cleaner_behavior_state() == "CLEANING", "Cleaner should begin at the cleaning area.")
	cleaner._on_behavior_timer_timeout()
	_expect(cleaner.get_cleaner_behavior_state() == "TURN_TO_CART", "Cleaner should pause before walking to the cart.")
	_expect(not cleaner.get_node("TurnWarning").visible, "Normal Cleaner turn preparation must not show an icon.")
	_expect(absf(cleaner.get_node("Eye").position.x) == 4.0, "Cleaner turn preparation did not use the subtle look pose.")
	cleaner._on_behavior_timer_timeout()
	_expect(cleaner.get_cleaner_behavior_state() == "WALK_TO_CART", "Cleaner did not begin walking to the cart.")
	cleaner._process(2.0)
	_expect(cleaner.position.x > cleaner_home.x, "Cleaner did not move toward the tool cart.")
	_expect(cleaner.get_cleaner_behavior_state() == "ORGANIZING", "Cleaner did not stop to organize tools.")
	cleaner.set_cleaner_behavior_enabled(false)
	_expect(cleaner.position == cleaner_home, "Disabling test behavior did not restore the Cleaner position.")
	cleaner.target_id = "LOBBY_CLEANER"
	cleaner.card_id = "CLEANER"
	cleaner.reward_type = "CARD"
	cleaner.requires_task_eligibility = true
	cleaner.set_task_eligible(false)
	CardManager.reset_for_new_game()
	GameManager.start_game()

	player.global_position = cleaner.global_position - Vector2(30.0, 0.0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	player.is_moving = false
	_expect(not cleaner.begin_steal(), "Ineligible cleaner should not offer CLEANER.")
	_expect(not CardManager.has_card("CLEANER"), "Ineligible cleaner granted CLEANER.")

	cleaner.set_task_eligible(true)
	cleaner.set_interaction_enabled(false)
	_expect(not cleaner.begin_steal(), "Dialogue lock should block Cleaner interaction.")
	cleaner.set_interaction_enabled(true)
	if cleaner.is_suspicious():
		cleaner._on_suspicion_timer_timeout()
	player.global_position = cleaner.global_position + Vector2(30.0 * cleaner.facing_direction, 0.0)
	await get_tree().physics_frame
	_expect(not cleaner.begin_steal(), "Front cleaner interaction should fail.")
	_expect(GameManager.game_state == "FAILED" and GameManager.fail_reason == "STAFF_CAUGHT", "Front cleaner interaction did not report STAFF_CAUGHT.")
	GameManager.start_game()
	cleaner.reset_caught_alert()
	cleaner.set_task_eligible(true)

	player.global_position = cleaner.global_position - Vector2(30.0 * cleaner.facing_direction, 0.0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	player.is_moving = false
	_expect(cleaner.begin_steal(), "Eligible rear cleaner steal did not start.")
	cleaner.cancel_steal()
	cleaner._process(1.0)
	_expect(not CardManager.has_card("CLEANER"), "Cancelled cleaner steal granted a card.")
	_expect(cleaner.begin_steal(), "Cleaner steal did not restart.")
	cleaner._process(0.8)
	_expect(CardManager.has_card("CLEANER"), "Cleaner reward was not granted.")
	_expect(not cleaner.begin_steal(), "Cleaner reward should only be available once.")

	_run_snapshot_checks()
	await _run_cleaning_spot_checks(test_scene, player)
	await _run_test_failure_recovery_checks()

	if _failed:
		get_tree().quit(1)
		return
	print("PASS: cleaner eligibility, stealing, snapshot restore, 201 cleaning gates, and one-shot reports.")
	get_tree().quit(0)


func _run_test_failure_recovery_checks() -> void:
	var work_test: Node = load("res://scenes/tests/staff/cleaner_work_test.tscn").instantiate()
	add_child(work_test)
	await get_tree().process_frame
	var work_player: HotelPlayer = work_test.get_node("Corridor/Player")
	var work_cleaner: Node = work_test.get_node("Cleaner")
	var start_position: Vector2 = work_player.global_position

	work_player.global_position = work_cleaner.global_position + Vector2(30.0, 0.0)
	work_cleaner._on_steal_area_body_entered(work_player)
	_expect(work_cleaner.is_suspicious(), "Unequipped stranger approach did not trigger curiosity.")
	_expect(work_cleaner.get_node("TurnWarning").text == "?" and work_cleaner.get_node("TurnWarning").visible, "Curiosity question mark was not shown.")
	_expect(GameManager.game_state == "PLAYING", "Curiosity incorrectly failed the game.")
	work_cleaner._on_suspicion_timer_timeout()
	_expect(not work_cleaner.is_suspicious(), "Curiosity did not return to normal work.")

	for attempt in range(2):
		work_test._on_task_failure_requested("STAFF_CAUGHT", "LOBBY_CLEANER")
		_expect(GameManager.game_state == "FAILED", "Test failure did not enter FAILED state on attempt %d." % attempt)
		_expect(work_test.is_failure_recovery_pending(), "Test recovery timer was not armed on attempt %d." % attempt)
		_expect(work_cleaner.is_alerted(), "Cleaner did not hold an alert pose after catching the player.")
		_expect(work_test.get_node("FailureFeedback/Label").visible, "Caught feedback was not visible before reset.")
		work_test._on_failure_recovery_timer_timeout()
		_expect(GameManager.game_state == "PLAYING", "Test recovery did not resume PLAYING on attempt %d." % attempt)
		_expect(work_player.global_position == start_position, "Test recovery did not reset player position.")
		_expect(not work_cleaner.is_alerted(), "Cleaner alert state was not reset.")
		_expect(not work_test.get_node("FailureFeedback/Label").visible, "Caught feedback remained after reset.")
		work_cleaner._on_turn_warning_timer_timeout()
		_expect(not work_cleaner.get_node("TurnWarning").visible, "Retry incorrectly displayed a normal turn icon.")

	CardManager.collect_card("SECURITY")
	_expect(CardManager.active_card == "SECURITY", "SECURITY should remain active for the unequipped CLEANER check.")

	work_cleaner.set_cleaner_behavior_enabled(false)
	work_player.global_position = work_cleaner.global_position - Vector2(30.0 * work_cleaner.facing_direction, 0.0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	work_cleaner._on_steal_area_body_entered(work_player)
	if work_cleaner.is_suspicious():
		work_cleaner._on_suspicion_timer_timeout()
		work_player.global_position = work_cleaner.global_position - Vector2(30.0 * work_cleaner.facing_direction, 0.0)
	work_player.is_moving = false
	_expect(work_cleaner.begin_steal(), "Stealing did not recover after repeated test failures.")
	work_cleaner._process(0.8)
	_expect(CardManager.has_card("CLEANER"), "Recovered test did not grant CLEANER.")
	_expect(CardManager.active_card == "SECURITY", "Collecting CLEANER unexpectedly changed the active identity.")
	work_cleaner._on_turn_warning_timer_timeout()
	_expect(not work_cleaner.get_node("TurnWarning").visible, "Removed normal turn icon appeared after CLEANER was stolen.")
	work_cleaner._on_steal_area_body_exited(work_player)
	work_cleaner._on_steal_area_body_entered(work_player)
	_expect(work_cleaner.is_suspicious(), "Owned but unequipped CLEANER should still look like a stranger.")
	_expect(not work_cleaner.begin_steal(), "Owned CLEANER was offered a second time.")
	_expect(GameManager.game_state == "PLAYING", "Duplicate steal attempt incorrectly caused failure.")
	CardManager.switch_active()
	_expect(CardManager.active_card == "CLEANER", "CLEANER could not become the active identity.")
	_expect(not work_cleaner.is_suspicious(), "Equipping CLEANER did not clear curiosity.")
	work_cleaner._on_steal_area_body_exited(work_player)
	work_cleaner._on_steal_area_body_entered(work_player)
	_expect(not work_cleaner.is_suspicious() and not work_cleaner.is_alerted(), "Cleaner reacted to a player with active CLEANER identity.")
	var work_spot: CleaningSpot = work_test.get_node("CleaningSpot")
	work_cleaner._on_steal_area_body_exited(work_player)
	work_player.global_position = work_spot.global_position
	work_spot._on_work_area_body_entered(work_player)
	_expect(work_spot.begin_interaction(), "Active CLEANER could not begin the test-scene cleaning flow.")
	work_spot.advance_interaction(1.5)
	_expect(work_spot.is_completed() and not work_spot.get_node("Stain").visible, "Test-scene stain did not disappear after cleaning.")
	work_spot._on_work_area_body_exited(work_player)
	work_player.global_position = work_cleaner.global_position + Vector2(30.0, 0.0)
	work_cleaner._on_steal_area_body_entered(work_player)
	_expect(not work_cleaner.is_suspicious() and not work_cleaner.is_alerted(), "Cleaner reacted to an active CLEANER identity after cleaning.")
	work_test.queue_free()


func _run_snapshot_checks() -> void:
	CardManager.reset_for_new_game()
	CardManager.collect_card("CLEANER")
	CardManager.collect_card("SECURITY")
	CardManager.switch_active()
	var snapshot: Dictionary = CardManager.export_snapshot()
	_expect(CardManager.create_snapshot() == snapshot, "create_snapshot alias differs from export_snapshot.")
	var restore_copy: Dictionary = snapshot.duplicate(true)
	snapshot.owned_cards.append("MANAGER")
	snapshot.equipped_cards[0] = "MANAGER"
	_expect(CardManager.get_owned_cards() == ["CLEANER", "SECURITY"], "Snapshot owned cards are not deeply copied.")
	_expect(CardManager.get_equipped_cards() == ["CLEANER", "SECURITY"], "Snapshot slots are not deeply copied.")

	CardManager.cards_changed.connect(_on_cards_changed)
	CardManager.identity_changed.connect(_on_identity_changed)
	CardManager.equip_card("NONE", 0)
	_card_signals = 0
	_identity_signals = 0
	_expect(CardManager.restore_snapshot(restore_copy), "Valid snapshot restore failed.")
	_expect(CardManager.get_owned_cards() == ["CLEANER", "SECURITY"], "Snapshot ownership restore is incorrect.")
	_expect(CardManager.get_equipped_cards() == ["CLEANER", "SECURITY"], "Snapshot slot restore is incorrect.")
	_expect(CardManager.active_slot == 1 and CardManager.active_card == "SECURITY", "Snapshot active slot restore is incorrect.")
	_expect(_card_signals == 1, "Snapshot restore should emit cards_changed once.")
	_expect(_identity_signals == 0, "Snapshot restore must not emit identity_changed.")
	var invalid_snapshot: Dictionary = restore_copy.duplicate(true)
	invalid_snapshot.equipped_cards[0] = "MANAGER"
	_expect(not CardManager.restore_snapshot(invalid_snapshot), "Invalid snapshot should be rejected.")
	_expect(_card_signals == 1 and _identity_signals == 0, "Rejected snapshot emitted a signal.")


func _run_cleaning_spot_checks(test_scene: Node, player: HotelPlayer) -> void:
	var spot: CleaningSpot = load("res://scenes/work/cleaning_spot.tscn").instantiate()
	test_scene.add_child(spot)
	spot.global_position = Vector2(1000.0, 560.0)
	spot.setup(player)
	_expect(spot.target_id == "STAIN_201", "201 stain target ID is not normalized.")
	spot.cleaning_completed.connect(_on_cleaning_completed)
	player.global_position = spot.global_position
	await get_tree().physics_frame
	await get_tree().physics_frame

	spot.set_task_active(false)
	_expect(not spot.begin_interaction(), "Inactive 201 task should reject cleaning.")
	spot.set_task_active(true)
	_expect(CardManager.has_card("CLEANER"), "Cleaner ownership precondition is missing.")
	_expect(CardManager.active_card == "SECURITY", "CLEANER should be in the standby slot for this check.")
	_expect(not spot.begin_interaction(), "Standby CLEANER should not satisfy cleaning.")
	CardManager.switch_active()
	_expect(CardManager.active_card == "CLEANER", "CLEANER could not become active.")
	_expect(spot.begin_interaction(), "Valid 201 cleaning did not start.")
	spot.advance_interaction(0.75)
	spot.cancel_interaction()
	_expect(_cleaning_signals == 0, "Cancelled cleaning reported completion.")
	_expect(spot.begin_interaction(), "201 cleaning did not restart after cancellation.")
	spot.advance_interaction(1.5)
	_expect(_cleaning_signals == 1, "201 cleaning completion was not reported once.")
	_expect(spot.is_completed(), "Cleaning spot did not retain its completed state.")
	_expect(not spot.get_node("Stain").visible, "Completed stain visual remained visible.")
	_expect(not spot.get_node("Hint").visible, "Completed stain interaction hint remained visible.")
	_expect(not spot.begin_interaction(), "Completed work point should not report repeatedly.")
	spot.advance_interaction(2.0)
	_expect(_cleaning_signals == 1, "201 cleaning completion repeated.")


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)


func _on_cards_changed() -> void:
	_card_signals += 1


func _on_identity_changed(_action: String) -> void:
	_identity_signals += 1


func _on_cleaning_completed(_target_id: String) -> void:
	_cleaning_signals += 1
