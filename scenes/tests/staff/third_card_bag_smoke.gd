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
	for id in ["CLEANER","SECURITY","MANAGER"]:
		cards.collect_card(id)
	_expect(cards.get_owned_cards().size() == 3 and cards.get_equipped_cards().size() == 2,"Three owned / exactly two slots")
	_expect(not cards.get_equipped_cards().has("MANAGER"),"Third card remains unequipped until UI action")
	await _tap("open_bag")
	await process_frame
	var bag = main.get_node("MenuLayer/Bag")
	_expect(bag.visible and bag.get("_owned_cards").item_count == 3,"I opens all three owned cards")
	_expect(bag._selected_card_id() == "MANAGER","Unequipped manager is clearly selected")
	bag.get("_equip_slot_b").pressed.emit()
	_expect(cards.get_equipped_cards() == ["CLEANER","MANAGER"] and cards.has_card("SECURITY"),"UI B replaces without losing security")
	bag.close_bag()
	await _tap("switch_id")
	await process_frame
	_expect(cards.active_card == "MANAGER","Q reaches manager after equipment")
	bag.open_bag()
	for index in bag.get("_owned_cards").item_count:
		if bag.get("_owned_cards").get_item_metadata(index) == "SECURITY":
			bag.get("_owned_cards").select(index)
			bag.get("_owned_cards").item_selected.emit(index)
	bag.get("_equip_slot_a").pressed.emit()
	_expect(cards.get_equipped_cards() == ["SECURITY","MANAGER"] and cards.has_card("CLEANER"),"UI A replacement preserves cleaner")
	bag.close_bag()
	var snapshot: Dictionary = cards.export_snapshot()
	game._load_floor(2)
	await process_frame
	_expect(cards.export_snapshot() == snapshot,"Floor travel preserves all cards and equipment")
	cards.equip_card("CLEANER",0)
	_expect(cards.restore_snapshot(snapshot) and cards.export_snapshot() == snapshot,"Checkpoint card restore restores exact three-card/two-slot state")
	main.queue_free()
	await process_frame
	game.set_process(true)
	for message in failures:
		printerr("FAIL: ",message)
	print("THIRD_CARD_BAG: ","PASS" if failures.is_empty() else "FAIL")
	quit(0 if failures.is_empty() else 1)
