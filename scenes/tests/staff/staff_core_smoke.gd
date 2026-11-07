extends Node

var _failed: bool = false
var _cards_changed_count: int = 0
var _identity_actions: Array[String] = []


func _ready() -> void:
	var packed_scene: PackedScene = load("res://scenes/tests/staff/staff_test.tscn")
	var test_scene: Node = packed_scene.instantiate()
	add_child(test_scene)
	await get_tree().process_frame
	await get_tree().physics_frame

	var card_manager: Node = get_tree().root.get_node("CardManager")
	card_manager.cards_changed.connect(_on_cards_changed)
	card_manager.identity_changed.connect(_on_identity_changed)
	var player: HotelPlayer = test_scene.get_node("Corridor/Player")
	var staff_members: Array[Node] = [
		test_scene.get_node("StaffMembers/Security"),
		test_scene.get_node("StaffMembers/Cleaner"),
		test_scene.get_node("StaffMembers/Manager"),
	]
	var expected_cards: Array[String] = ["SECURITY", "CLEANER", "MANAGER"]

	for index: int in range(staff_members.size()):
		var staff: Node = staff_members[index]
		player.global_position = staff.global_position + Vector2(30.0, 0.0)
		await get_tree().physics_frame
		await get_tree().physics_frame
		_expect(staff.is_player_in_range(), "%s employee did not detect Player." % expected_cards[index])
		_expect(not staff.is_player_behind(), "%s front-side check is incorrect." % expected_cards[index])
		_expect(not staff.begin_steal(), "%s steal should not start from the front." % expected_cards[index])
		_expect(GameManager.game_state == "PLAYING", "%s front attempt should not fail the game." % expected_cards[index])
		_expect(not card_manager.has_card(expected_cards[index]), "%s front attempt incorrectly added a card." % expected_cards[index])
		player.global_position = staff.global_position + Vector2(-30.0, 0.0)
		await get_tree().physics_frame
		_expect(staff.is_player_behind(), "%s rear-side check is incorrect." % expected_cards[index])
		_expect(staff.begin_steal(), "%s rear hold did not start." % expected_cards[index])
		staff._process(0.4)
		_expect(not card_manager.has_card(expected_cards[index]), "%s card was granted before hold completed." % expected_cards[index])
		staff._process(0.4)
		_expect(card_manager.has_card(expected_cards[index]), "%s card missing from collection." % expected_cards[index])

	var security: Node = staff_members[0]
	var original_facing: int = security.facing_direction
	var original_eye_x: float = security.get_node("Eye").position.x
	security._on_turn_timer_timeout()
	_expect(security.facing_direction == -original_facing, "Staff did not reverse logical facing.")
	_expect(security.get_node("Eye").position.x == -original_eye_x, "Staff visual facing did not follow logic.")

	_expect(not staff_members[0].begin_steal(), "Duplicate SECURITY steal should fail.")
	_expect(card_manager.get_owned_cards().size() == 3, "Duplicate steal changed owned-card count.")

	card_manager.reset_for_new_game()
	GameManager.start_game()
	player.global_position = security.global_position + Vector2(30.0 * -security.facing_direction, 0.0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	player.is_moving = false
	_expect(security.is_player_in_range(), "Cancellation tests require Player inside StealArea.")
	_expect(security.begin_steal(), "Cancellation test could not start a steal.")
	security.cancel_steal()
	security._process(1.0)
	_expect(not card_manager.has_card("SECURITY"), "Released E should cancel the steal.")
	_expect(security.begin_steal(), "Area-exit cancellation test could not start.")
	security._on_steal_area_body_exited(player)
	security._process(1.0)
	_expect(not card_manager.has_card("SECURITY"), "Leaving StealArea should cancel the steal.")
	security._on_steal_area_body_entered(player)
	_expect(security.begin_steal(), "Movement cancellation test could not start.")
	player.is_moving = true
	security._process(0.1)
	player.is_moving = false
	_expect(not security.is_stealing(), "Player movement should cancel the steal.")
	_expect(not card_manager.has_card("SECURITY"), "Movement cancellation granted a card.")
	_expect(security.begin_steal(), "Turn detection test could not start.")
	security._on_turn_timer_timeout()
	_expect(GameManager.game_state == "FAILED", "Staff turning toward Player should use unified failure.")
	_expect(GameManager.fail_reason == "STAFF_CAUGHT", "Staff turn used the wrong failure reason.")
	_expect(not card_manager.has_card("SECURITY"), "Caught steal incorrectly granted a card.")

	GameManager.start_game()
	for index: int in range(expected_cards.size()):
		_expect(card_manager.collect_card(expected_cards[index]), "%s setup card could not be restored." % expected_cards[index])
	_expect(card_manager.get_equipped_cards() == ["SECURITY", "CLEANER"], "First two cards were not auto-equipped.")
	_expect(card_manager.active_card == "SECURITY", "Initial active identity should be SECURITY.")

	_expect(card_manager.equip_card("MANAGER", 1), "MANAGER could not be equipped in slot B.")
	_expect(card_manager.get_equipped_cards() == ["SECURITY", "MANAGER"], "MANAGER equipment state is incorrect.")
	_expect(card_manager.switch_active(), "Active slot did not switch.")
	_expect(card_manager.active_slot == 1 and card_manager.active_card == "MANAGER", "Switched identity should be MANAGER.")
	_expect(card_manager.equip_card("NONE", 1), "Active slot could not be cleared.")
	_expect(card_manager.active_card == "NONE", "Empty active slot should report NONE.")
	_expect(card_manager.equip_card("CLEANER", 1), "CLEANER could not be equipped for Q test.")

	var switch_event := InputEventAction.new()
	switch_event.action = "switch_id"
	switch_event.pressed = true
	card_manager._unhandled_input(switch_event)
	_expect(card_manager.active_slot == 0 and card_manager.active_card == "SECURITY", "Q action did not switch to slot A.")
	_expect(_cards_changed_count >= 4, "cards_changed did not cover card/equipment changes.")
	_expect(_identity_actions.has("EQUIP_CARD"), "EQUIP_CARD identity signal was not emitted.")
	_expect(_identity_actions.has("SWITCH_ACTIVE"), "SWITCH_ACTIVE identity signal was not emitted.")
	_run_card_manager_boundary_tests(card_manager)

	if _failed:
		get_tree().quit(1)
		return
	print("PASS: staff flow and CardManager boundary cases, state copies, signals, input, and reset.")
	get_tree().quit(0)


func _run_card_manager_boundary_tests(card_manager: Node) -> void:
	_cards_changed_count = 0
	_identity_actions.clear()
	card_manager.reset_for_new_game()
	_expect(_cards_changed_count == 1, "New-game reset should emit cards_changed once.")
	_expect(_identity_actions.is_empty(), "New-game reset must not emit identity_changed.")

	_expect(not card_manager.collect_card("INVALID"), "Invalid card ID should be rejected.")
	_expect(not card_manager.collect_card("NONE"), "NONE must not be collectible.")
	_expect(_cards_changed_count == 1, "Invalid collection emitted cards_changed.")
	_expect(card_manager.collect_card("SECURITY"), "Valid SECURITY collection failed.")
	_expect(not card_manager.collect_card("SECURITY"), "Duplicate collection should be rejected.")
	_expect(_cards_changed_count == 2, "Collection or duplicate collection signal count is incorrect.")

	var owned_copy: Array[String] = card_manager.get_owned_cards()
	owned_copy.append("MANAGER")
	var equipped_copy: Array[String] = card_manager.get_equipped_cards()
	equipped_copy[0] = "MANAGER"
	_expect(card_manager.get_owned_cards() == ["SECURITY"], "Owned-card query did not return a copy.")
	_expect(card_manager.get_equipped_cards() == ["SECURITY", "NONE"], "Equipped-card query did not return a copy.")

	_expect(not card_manager.equip_card("SECURITY", -1), "Negative slot should be rejected.")
	_expect(not card_manager.equip_card("SECURITY", 2), "Out-of-range slot should be rejected.")
	_expect(not card_manager.equip_card("CLEANER", 1), "Unowned card should not be equipped.")
	_expect(not card_manager.equip_card("INVALID", 1), "Invalid card should not be equipped.")
	_expect(not card_manager.equip_card("SECURITY", 0), "Repeated equipment should be rejected.")
	_expect(_cards_changed_count == 2 and _identity_actions.is_empty(), "Invalid equipment emitted a signal.")

	_expect(card_manager.collect_card("CLEANER"), "Valid CLEANER collection failed.")
	_expect(card_manager.equip_card("SECURITY", 1), "Cross-slot equipment failed.")
	_expect(card_manager.get_equipped_cards() == ["NONE", "SECURITY"], "Cross-slot equipment did not remove the duplicate.")
	_expect(_cards_changed_count == 4, "Cross-slot equipment cards_changed count is incorrect.")
	_expect(_identity_actions == ["EQUIP_CARD"], "Cross-slot equipment identity signal is incorrect.")
	_expect(not card_manager.equip_card("SECURITY", 1), "Repeated cross-slot equipment should be rejected.")

	_expect(card_manager.active_slot == 0 and card_manager.active_card == "NONE", "Active empty slot state is incorrect.")
	_expect(card_manager.switch_active(), "Switching from an empty slot should remain allowed.")
	_expect(card_manager.active_slot == 1 and card_manager.active_card == "SECURITY", "Empty-slot switch did not select slot B.")
	_expect(card_manager.switch_active(), "Switching back to the empty slot should remain allowed.")
	_expect(card_manager.active_slot == 0 and card_manager.active_card == "NONE", "Switch back did not preserve empty-slot behavior.")
	_expect(_cards_changed_count == 6, "Empty-slot switching cards_changed count is incorrect.")
	_expect(_identity_actions == ["EQUIP_CARD", "SWITCH_ACTIVE", "SWITCH_ACTIVE"], "Empty-slot switching identity signals are incorrect.")

	_expect(card_manager.equip_card("NONE", 1), "Clearing an occupied slot failed.")
	_expect(card_manager.collect_card("MANAGER"), "Valid MANAGER collection failed.")
	_expect(card_manager.has_all_cards(), "All-card query failed after collecting three cards.")
	_expect(_cards_changed_count == 8, "Clear/collection cards_changed count is incorrect.")
	_expect(_identity_actions.back() == "EQUIP_CARD", "Clearing a slot did not emit EQUIP_CARD.")

	var identity_count_before_reset: int = _identity_actions.size()
	card_manager.reset_for_new_game()
	_expect(card_manager.get_owned_cards().is_empty(), "New game did not clear owned cards.")
	_expect(card_manager.get_equipped_cards() == ["NONE", "NONE"], "New game did not clear both slots.")
	_expect(card_manager.active_slot == 0 and card_manager.active_card == "NONE", "New game did not restore slot A/NONE.")
	_expect(_cards_changed_count == 9, "Final reset cards_changed count is incorrect.")
	_expect(_identity_actions.size() == identity_count_before_reset, "Reset incorrectly emitted identity_changed.")


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)


func _on_cards_changed() -> void:
	_cards_changed_count += 1


func _on_identity_changed(action: String) -> void:
	_identity_actions.append(action)
