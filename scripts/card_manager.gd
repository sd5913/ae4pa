extends Node
## Shared card-data skeleton. B owns collection, switching, and equipment logic.

signal cards_changed()
# B emits this once active switching and equipment are implemented.
@warning_ignore("unused_signal")
signal identity_changed(action: String)

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
