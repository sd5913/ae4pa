extends Control

const CardDisplay = preload("res://scenes/ui/card_display.gd")
const MODAL_ID := "bag"

var _previous_focus: Control

@onready var _owned_cards: ItemList = %OwnedCards
@onready var _slot_a: Label = %SlotAValue
@onready var _slot_b: Label = %SlotBValue
@onready var _close_button: Button = %CloseButton
@onready var _equip_slot_a: Button = %EquipSlotA
@onready var _equip_slot_b: Button = %EquipSlotB
@onready var _status: Label = %Status


func _ready() -> void:
	visibility_changed.connect(_sync_modal_state)
	CardManager.cards_changed.connect(_refresh_cards)
	_owned_cards.item_selected.connect(_on_card_selected)
	_equip_slot_a.pressed.connect(_equip_selected.bind(0))
	_equip_slot_b.pressed.connect(_equip_selected.bind(1))
	_refresh_cards()
	_sync_modal_state()


func _sync_modal_state() -> void:
	if GameManager.has_method("set_modal_open"):
		GameManager.set_modal_open(MODAL_ID, visible)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("open_bag"):
		return
	if visible:
		close_bag()
	else:
		open_bag()
	get_viewport().set_input_as_handled()


func open_bag() -> void:
	if visible:
		return
	_previous_focus = get_viewport().gui_get_focus_owner()
	_refresh_cards()
	show()
	_close_button.grab_focus()


func close_bag() -> void:
	hide()
	if is_instance_valid(_previous_focus) and _previous_focus.is_visible_in_tree():
		_previous_focus.grab_focus()
	_previous_focus = null


func _refresh_cards() -> void:
	var previously_selected := _selected_card_id()
	_owned_cards.clear()
	var card_ids := CardManager.get_owned_cards()
	for card_id: String in card_ids:
		_owned_cards.add_item(CardDisplay.name_for(card_id))
		_owned_cards.set_item_metadata(_owned_cards.item_count - 1, card_id)
		if card_id == previously_selected:
			_owned_cards.select(_owned_cards.item_count - 1)

	var equipped: Array[String] = CardManager.get_equipped_cards()
	_slot_a.text = _slot_text(equipped[0], 0)
	_slot_b.text = _slot_text(equipped[1], 1)
	if card_ids.is_empty():
		_status.text = "尚未获得工作证"
	_equip_slot_a.disabled = _selected_card_id().is_empty()
	_equip_slot_b.disabled = _selected_card_id().is_empty()


func _on_card_selected(_index: int) -> void:
	_equip_slot_a.disabled = false
	_equip_slot_b.disabled = false
	_status.text = "选择佩戴槽后装备工作证"


func _equip_selected(slot_index: int) -> void:
	var card_id := _selected_card_id()
	if card_id.is_empty():
		_status.text = "请先选择已获得的工作证"
		return
	if slot_index < 0 or slot_index > 1:
		_status.text = "无效的佩戴槽"
		return
	if not CardManager.equip_card(card_id, slot_index):
		_status.text = "装备失败：该工作证可能已在目标槽或请求无效"
		return
	_status.text = "已装备到槽 %s" % ("A" if slot_index == 0 else "B")
	_refresh_cards()


func _selected_card_id() -> String:
	var selected := _owned_cards.get_selected_items()
	if selected.is_empty():
		return ""
	return str(_owned_cards.get_item_metadata(selected[0]))


func _slot_text(card_id: String, slot_index: int) -> String:
	var card_name: String = CardDisplay.name_for(card_id)
	if card_id == "NONE":
		return card_name
	if CardManager.active_card == card_id and CardManager.active_slot == slot_index:
		return card_name + " · 生效"
	return card_name
