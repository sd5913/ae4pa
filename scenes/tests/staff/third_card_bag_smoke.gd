extends SceneTree
var failures: Array[String] = []
func _initialize() -> void:
	call_deferred("_run")
func _expect(ok: bool,message: String) -> void:
	if not ok:
		failures.append(message)
func _tap(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = InputEventAction.new()
	event.action = action
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame
func _run() -> void:
	var game = root.get_node("GameManager")
	var cards = root.get_node("CardManager")
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	main.dialogue._finish()
	game.complete_manager_intro()
	game.set_process(false)
	# Exercise reward presentation only; theft timing is covered separately.
	var floor_node: Node = main.get_node("World").get_child(0)
	var staff_members: Array[Node] = []
	for slot in ["CleanerSlot", "SecuritySlot", "ManagerSlot"]:
		var staff: Node = floor_node.get_node("StaffRoot/" + slot + "/Staff")
		staff_members.append(staff)
		_expect(staff._complete_steal(), "Reward presentation fixture grants one real card")
		_expect("已收藏" in staff.feedback_label.text, "Reward feedback must distinguish collection")
		_expect("当前生效：保洁" in staff.feedback_label.text, "Reward feedback must read the actual active identity")
	_expect("已装备A槽" in staff_members[0].feedback_label.text, "First reward identifies its equipped slot")
	_expect("已装备B槽" in staff_members[1].feedback_label.text, "Second reward is equipped but does not activate itself")
	_expect("未装备" in staff_members[2].feedback_label.text and "I" in staff_members[2].feedback_label.text, "Third reward explains collection without equipment")
	_expect(cards.get_owned_cards().size() == 3 and cards.get_equipped_cards().size() == 2,"Three owned / exactly two slots")
	_expect(not cards.get_equipped_cards().has("MANAGER"),"Third card remains unequipped until UI action")
	# Read the new first-2/2 Carol tutorial before issuing gameplay requests.
	await process_frame
	await process_frame
	var flow: Node = main.get_node("MenuLayer/Bag/CarolUIFlow")
	if flow.get("_mode") == "equipment":
		await create_timer(0.2).timeout
		for beat in range(4): await _tap("interact")
	await _tap("open_bag")
	await process_frame
	var bag = main.get_node("MenuLayer/Bag")
	_expect(bag.visible and bag.get("_owned_cards").item_count == 3,"I opens all three owned cards")
	_expect(bag._selected_card_id() == "MANAGER","Unequipped manager is clearly selected")
	bag.get("_equip_slot_b").pressed.emit()
	_expect(cards.get_equipped_cards() == ["CLEANER","MANAGER"] and cards.has_card("SECURITY"),"UI B replaces without losing security")
	_expect("备用槽B" in bag.get("_status").text and "当前生效：保洁" in bag.get("_status").text, "Reserve equip prompt reads the actual current identity")
	bag.close_bag()
	# If acquisition/equipment happened inside the bag, tutorial intentionally waits for this close.
	for frame in range(4): await process_frame
	if flow.get("_mode") == "equipment":
		await create_timer(0.2).timeout
		for beat in range(4): await _tap("interact")
	await _tap("switch_id")
	await process_frame
	_expect(cards.active_card == "MANAGER","Q reaches manager after equipment")
	_expect("已装备B槽" in staff_members[2].feedback_label.text and "当前生效：经理" in staff_members[2].feedback_label.text, "Reward feedback follows subsequent slot replacement and Q")
	var hud: Node = main.get_node("TaskLayer/HUD")
	_expect(hud.get("_active_card_value").text == "经理工作证" and hud.get("_active_markers")[1].visible, "HUD reads manager in active B")
	var outfit: Node = floor_node.player.get_node("Visual/Artwork/IdentityOutfit")
	_expect(outfit.card_id == cards.active_card, "Identity accessory reads the same actual active card")
	bag.open_bag()
	for index in bag.get("_owned_cards").item_count:
		if bag.get("_owned_cards").get_item_metadata(index) == "SECURITY":
			bag.get("_owned_cards").select(index)
			bag.get("_owned_cards").item_selected.emit(index)
	bag.get("_equip_slot_a").pressed.emit()
	_expect(cards.get_equipped_cards() == ["SECURITY","MANAGER"] and cards.has_card("CLEANER"),"UI A replacement preserves cleaner")
	bag.close_bag()
	await _tap("switch_id")
	bag.open_bag()
	for index in bag.get("_owned_cards").item_count:
		if bag.get("_owned_cards").get_item_metadata(index) == "CLEANER":
			bag.get("_owned_cards").select(index)
			bag.get("_owned_cards").item_selected.emit(index)
	bag.get("_equip_slot_a").pressed.emit()
	_expect(cards.active_slot == 0 and cards.active_card == "CLEANER", "Replacing the active A slot takes effect without another Q")
	_expect("当前已生效" in bag.get("_status").text and "按Q" not in bag.get("_status").text, "Active-slot equip must not require Q")
	bag.get("_equip_slot_a").pressed.emit()
	_expect("无需重复装备" in bag.get("_status").text, "Already equipped is a no-op, not a failure")
	_expect(hud.get("_active_card_value").text == "保洁工作证" and outfit.card_id == "CLEANER", "Current-slot replacement immediately updates HUD and outfit")
	_expect("当前生效：保洁" in staff_members[0].feedback_label.text, "Reward presentation matches direct active-slot replacement")
	bag.close_bag()
	var snapshot: Dictionary = cards.export_snapshot()
	cards.reset_for_new_game()
	_expect(not staff_members[2].feedback_label.visible, "New game must clear stale collected-card feedback")
	cards.restore_snapshot(snapshot)
	game._load_floor(2)
	await process_frame
	_expect(cards.export_snapshot() == snapshot,"Floor travel preserves all cards and equipment")
	cards.equip_card("SECURITY",0)
	_expect(cards.restore_snapshot(snapshot) and cards.export_snapshot() == snapshot,"Checkpoint card restore restores exact three-card/two-slot state")
	main.queue_free()
	await process_frame
	game.set_process(true)
	for message in failures:
		printerr("FAIL: ",message)
	print("THIRD_CARD_BAG: ","PASS" if failures.is_empty() else "FAIL")
	quit(0 if failures.is_empty() else 1)
