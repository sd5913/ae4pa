extends Control

const CardDisplay = preload("res://scenes/ui/card_display.gd")
const MODAL_ID := "bag"

var _previous_focus: Control
var _tutorial_card_id := ""
var _tutorial_slot_index := -1
var _hovered_owned_index := -1

@onready var _owned_cards: ItemList = %OwnedCards
@onready var _owned_hit_regions: Array[Panel] = [
	$Case/OwnedHitRegions/First, $Case/OwnedHitRegions/Second, $Case/OwnedHitRegions/Third,
]
@onready var _slot_a: Label = %SlotAValue
@onready var _slot_b: Label = %SlotBValue
@onready var _close_button: Button = %CloseButton
@onready var _equip_slot_a: Button = %EquipSlotA
@onready var _equip_slot_b: Button = %EquipSlotB
@onready var _status: Label = %Status
@onready var _owned_heading: Label = %OwnedHeading
@onready var _equipped_heading: Label = %EquippedHeading
@onready var _empty_owned: Array[Label] = [$Case/EmptyOwned1, $Case/EmptyOwned2, $Case/EmptyOwned3]
@onready var _slot_art: Array[TextureRect] = [%SlotAArt, %SlotBArt]


func _ready() -> void:
	resized.connect(_fit_case)
	_fit_case()
	visibility_changed.connect(_sync_modal_state)
	CardManager.cards_changed.connect(_refresh_cards)
	_owned_cards.item_selected.connect(_on_card_selected)
	_owned_cards.focus_entered.connect(_refresh_owned_highlights)
	_owned_cards.focus_exited.connect(_refresh_owned_highlights)
	_owned_cards.draw.connect(_refresh_owned_highlights)
	for index in _owned_hit_regions.size():
		var region := _owned_hit_regions[index]
		region.gui_input.connect(_on_owned_slot_input.bind(index))
		region.mouse_entered.connect(_set_hovered_owned_slot.bind(index))
		region.mouse_exited.connect(_set_hovered_owned_slot.bind(-1))
	_equip_slot_a.pressed.connect(_equip_selected.bind(0))
	_equip_slot_b.pressed.connect(_equip_selected.bind(1))
	_refresh_cards()
	_sync_modal_state()
	var flow := preload("res://scenes/ui/carol_ui_flow.gd").new()
	flow.name = "CarolUIFlow"
	add_child(flow)

func _fit_case() -> void:
	# Scale the entire existing case uniformly, reserving space for the outside X.
	var ratio := minf(1.0, minf((size.x - 48) / 1216.0, (size.y - 48) / 650.0))
	$Case.scale = Vector2.ONE * maxf(0.3, ratio)
	$Case.offset_left = -608.0 * ratio
	$Case.offset_right = $Case.offset_left + 1128
	$Case.offset_top = -310.0 * ratio
	$Case.offset_bottom = $Case.offset_top + 578


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh_cards()


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


func _input(event: InputEvent) -> void:
	if visible and not event.is_echo() and event.is_action_pressed("pause"):
		close_bag()
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
		_owned_cards.add_item(tr(CardDisplay.name_for(card_id)), CardDisplay.art_for(card_id))
		_owned_cards.set_item_metadata(_owned_cards.item_count - 1, card_id)
		if card_id == previously_selected:
			_owned_cards.select(_owned_cards.item_count - 1)
		if card_id == _tutorial_card_id:
			_owned_cards.select(_owned_cards.item_count - 1)
			_owned_cards.ensure_current_is_visible()

	var equipped: Array[String] = CardManager.get_equipped_cards()
	_owned_heading.text = tr("收藏  %d / %d") % [card_ids.size(), _empty_owned.size()]
	for index: int in range(_empty_owned.size()):
		_empty_owned[index].visible = index >= card_ids.size()
		_owned_hit_regions[index].mouse_filter = Control.MOUSE_FILTER_STOP if index < card_ids.size() else Control.MOUSE_FILTER_IGNORE
	var equipped_count := 0
	for index: int in range(_slot_art.size()):
		_slot_art[index].texture = CardDisplay.art_for(equipped[index])
		if equipped[index] != "NONE":
			equipped_count += 1
	_equipped_heading.text = tr("装备  %d / %d") % [equipped_count, _slot_art.size()]
	_slot_a.text = _slot_text(equipped[0], 0)
	_slot_b.text = _slot_text(equipped[1], 1)
	if card_ids.is_empty():
		_status.text = "尚未获得工作证"
	elif previously_selected.is_empty():
		_status.text = "选择一张工作证，再选择佩戴槽。"
	_equip_slot_a.disabled = _selected_card_id().is_empty()
	_equip_slot_b.disabled = _selected_card_id().is_empty()
	_apply_tutorial_highlight()
	_refresh_owned_highlights()


func set_tutorial_focus(card_id: String, slot_index: int) -> void:
	if _tutorial_card_id == card_id and _tutorial_slot_index == slot_index:
		return
	_tutorial_card_id = card_id
	_tutorial_slot_index = slot_index
	if not card_id.is_empty() and slot_index in [0,1]:
		_status.text = tr("把新工作证放入装备槽A，就能使用对应的岗位身份。") if slot_index == 0 else tr("把新工作证放入装备槽，就能使用对应的岗位身份。")
	_refresh_cards()


func _apply_tutorial_highlight() -> void:
	_equip_slot_a.modulate = Color("ffe3a1") if _tutorial_slot_index == 0 else Color.WHITE
	_equip_slot_b.modulate = Color("ffe3a1") if _tutorial_slot_index == 1 else Color.WHITE
	_equip_slot_a.tooltip_text = tr("把新工作证装备到这个槽") if _tutorial_slot_index == 0 else ""
	_equip_slot_b.tooltip_text = tr("把新工作证装备到这个槽") if _tutorial_slot_index == 1 else ""


func _on_card_selected(_index: int) -> void:
	_equip_slot_a.disabled = false
	_equip_slot_b.disabled = false
	_status.text = "选择佩戴槽后装备工作证"
	_refresh_owned_highlights()


func _on_owned_slot_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_select_owned_card(index)


func _select_owned_card(index: int) -> void:
	if index < 0 or index >= _owned_cards.item_count:
		return
	_owned_cards.select(index)
	_owned_cards.grab_focus()
	_on_card_selected(index)


func _set_hovered_owned_slot(index: int) -> void:
	_hovered_owned_index = index
	_refresh_owned_highlights()


func _refresh_owned_highlights() -> void:
	var selected := _owned_cards.get_selected_items()
	var focused_index := -1
	if _owned_cards.has_focus() and _owned_cards.item_count > 0:
		focused_index = 0 if selected.is_empty() else selected[0]
	for index in _owned_hit_regions.size():
		var region := _owned_hit_regions[index]
		var style_name := "empty_slot"
		if index < _owned_cards.item_count:
			if index == focused_index:
				style_name = "focused_slot"
			elif _owned_cards.is_selected(index):
				style_name = "selected_slot"
			elif index == _hovered_owned_index:
				style_name = "hovered_slot"
		var style := region.get_theme_stylebox(style_name)
		if region.get_theme_stylebox("panel") != style:
			region.add_theme_stylebox_override("panel", style)


func _equip_selected(slot_index: int) -> void:
	var card_id := _selected_card_id()
	if card_id.is_empty():
		_status.text = "请先选择已获得的工作证"
		return
	if slot_index < 0 or slot_index > 1:
		_status.text = "无效的佩戴槽"
		return
	if not CardManager.equip_card(card_id, slot_index):
		if CardManager.last_identity_change_block_reason == "NPC_OBSERVATION":
			_status.text = tr("有人正在看着你，不能在这里更换身份。先离开对方视线。")
		elif CardManager.last_identity_change_block_reason == "CHECKER_RESTRICTION":
			_status.text = tr("核验区内不能调整证件。先退到安全工作台，再按I换证。")
		else:
			_status.text = tr("装备失败：该工作证可能已在目标槽或请求无效")
		return
	_status.text = "已装备到槽 A" if slot_index == 0 else "已装备到槽 B"
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
		return tr("%s · 生效", "bag slot") % tr(card_name)
	return card_name
