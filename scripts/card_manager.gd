extends Node
## B owns the three-card collection, equipment, and active-identity state.

signal cards_changed()
signal identity_changed(action: String)

const VALID_CARDS: Array[String] = ["SECURITY", "CLEANER", "MANAGER"]

var _owned_cards: Array[String] = []
var _equipped_cards: Array[String] = ["NONE", "NONE"]
var _active_slot: int = 0

var active_slot: int:
	get:
		return _active_slot

var active_card: String:
	get:
		return _equipped_cards[_active_slot]


func reset_for_new_game() -> void:
	_owned_cards.clear()
	_equipped_cards = ["NONE", "NONE"]
	_active_slot = 0
	cards_changed.emit()


func get_owned_cards() -> Array[String]:
	return _owned_cards.duplicate()


func get_equipped_cards() -> Array[String]:
	return _equipped_cards.duplicate()


func has_card(card_id: String) -> bool:
	return _owned_cards.has(card_id)


func has_all_cards() -> bool:
	return has_card("SECURITY") and has_card("CLEANER") and has_card("MANAGER")


func export_snapshot() -> Dictionary:
	return {
		"owned_cards": _owned_cards.duplicate(true),
		"equipped_cards": _equipped_cards.duplicate(true),
		"active_slot": _active_slot,
	}


func create_snapshot() -> Dictionary:
	return export_snapshot()


func validate_snapshot(snapshot: Dictionary) -> bool:
	if not snapshot.has_all(["owned_cards", "equipped_cards", "active_slot"]):
		return false
	if not snapshot.owned_cards is Array or not snapshot.equipped_cards is Array:
		return false
	var owned: Array = snapshot.owned_cards
	var equipped: Array = snapshot.equipped_cards
	var slot: Variant = snapshot.active_slot
	if not slot is int or slot < 0 or slot > 1 or equipped.size() != 2:
		return false
	var unique_owned: Array[String] = []
	for card: Variant in owned:
		if not card is String or not VALID_CARDS.has(card) or unique_owned.has(card):
			return false
		unique_owned.append(card)
	var equipped_cards: Array[String] = []
	for card: Variant in equipped:
		if not card is String or (card != "NONE" and not unique_owned.has(card)):
			return false
		if card != "NONE" and equipped_cards.has(card):
			return false
		equipped_cards.append(card)
	return true


func restore_snapshot(snapshot: Dictionary) -> bool:
	if not validate_snapshot(snapshot):
		return false
	_owned_cards.assign(snapshot.owned_cards.duplicate(true))
	_equipped_cards.assign(snapshot.equipped_cards.duplicate(true))
	_active_slot = snapshot.active_slot
	cards_changed.emit()
	return true


func collect_card(card_id: String) -> bool:
	if not VALID_CARDS.has(card_id) or has_card(card_id):
		return false
	_owned_cards.append(card_id)
	for slot_index: int in range(_equipped_cards.size()):
		if _equipped_cards[slot_index] == "NONE":
			_equipped_cards[slot_index] = card_id
			break
	cards_changed.emit()
	return true


func switch_active() -> bool:
	_active_slot = 1 - _active_slot
	cards_changed.emit()
	identity_changed.emit("SWITCH_ACTIVE")
	return true


func equip_card(card_id: String, slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= _equipped_cards.size():
		return false
	if card_id != "NONE" and (not VALID_CARDS.has(card_id) or not has_card(card_id)):
		return false
	if _equipped_cards[slot_index] == card_id:
		return false

	if card_id != "NONE":
		var other_slot: int = 1 - slot_index
		if _equipped_cards[other_slot] == card_id:
			_equipped_cards[other_slot] = "NONE"
	_equipped_cards[slot_index] = card_id
	cards_changed.emit()
	identity_changed.emit("EQUIP_CARD")
	return true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_id") and not event.is_echo():
		switch_active()
		get_viewport().set_input_as_handled()
