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
		player.global_position = staff.global_position
		await get_tree().physics_frame
		await get_tree().physics_frame
		_expect(staff.is_player_in_range(), "%s employee did not detect Player." % expected_cards[index])
		_expect(staff.try_steal(), "%s card was not collected." % expected_cards[index])
		_expect(card_manager.has_card(expected_cards[index]), "%s card missing from collection." % expected_cards[index])

	_expect(not staff_members[0].try_steal(), "Duplicate SECURITY steal should fail.")
	_expect(card_manager.get_owned_cards().size() == 3, "Duplicate steal changed owned-card count.")
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

	if _failed:
		get_tree().quit(1)
		return
	print("PASS: three staff cards, duplicate protection, two slots, equipment, NONE, Q switching, and signals.")
	get_tree().quit(0)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)


func _on_cards_changed() -> void:
	_cards_changed_count += 1


func _on_identity_changed(action: String) -> void:
	_identity_actions.append(action)
