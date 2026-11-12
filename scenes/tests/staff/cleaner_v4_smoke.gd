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
	player.global_position = cleaner.global_position + Vector2(30.0, 0.0)
	await get_tree().physics_frame
	_expect(not cleaner.begin_steal(), "Front cleaner interaction should fail.")
	_expect(GameManager.game_state == "FAILED" and GameManager.fail_reason == "STAFF_CAUGHT", "Front cleaner interaction did not report STAFF_CAUGHT.")
	GameManager.start_game()
	cleaner.set_task_eligible(true)

	player.global_position = cleaner.global_position - Vector2(30.0, 0.0)
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

	if _failed:
		get_tree().quit(1)
		return
	print("PASS: cleaner eligibility, stealing, snapshot restore, 201 cleaning gates, and one-shot reports.")
	get_tree().quit(0)


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
	_expect(spot.get_node("Stain").visible, "B component must not own A's stain state.")
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
