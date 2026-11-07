extends PanelContainer

const CardDisplay = preload("res://scenes/ui/card_display.gd")
const ACTIVE_COLOR := Color(0.97, 0.72, 0.39)

@onready var _floor_value: Label = %FloorValue
@onready var _active_card_value: Label = %ActiveCardValue
@onready var _slot_a_value: Label = %SlotAValue
@onready var _slot_b_value: Label = %SlotBValue


func _ready() -> void:
	GameManager.state_changed.connect(_refresh_floor.unbind(1))
	# The foundation exposes the floor value before the floor transition signal.
	if GameManager.has_signal(&"floor_changed"):
		GameManager.connect(&"floor_changed", _refresh_floor.unbind(1))
	CardManager.cards_changed.connect(_refresh_cards)
	visibility_changed.connect(_on_visibility_changed)
	_refresh()


func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		_refresh()


func _refresh() -> void:
	_refresh_floor()
	_refresh_cards()


func _refresh_floor() -> void:
	_floor_value.text = "%dF" % GameManager.current_floor


func _refresh_cards() -> void:
	var active_card: String = CardManager.active_card
	var active_slot: int = CardManager.active_slot
	var equipped: Array[String] = CardManager.get_equipped_cards()
	_active_card_value.text = CardDisplay.name_for(active_card)
	_set_slot(_slot_a_value, equipped[0], active_card != "NONE" and active_slot == 0)
	_set_slot(_slot_b_value, equipped[1], active_card != "NONE" and active_slot == 1)


func _set_slot(label: Label, card_id: String, is_active: bool) -> void:
	var card_name: String = CardDisplay.name_for(card_id)
	label.text = card_name + " · 生效" if is_active else card_name
	label.self_modulate = ACTIVE_COLOR if is_active else Color.WHITE
