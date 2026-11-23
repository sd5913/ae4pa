extends "res://scenes/ui/bag.gd"
## A integration: D panel + drag/click requests; CardManager owns all equipment.
var _drop_targets: Array[Panel] = []

func _ready() -> void:
	super._ready()
	_owned_cards.set_drag_forwarding(_card_drag_data, Callable(), Callable())
	for slot in range(2):
		var target := Panel.new()
		target.name = "CardDrop" + ("A" if slot == 0 else "B")
		target.mouse_filter = Control.MOUSE_FILTER_STOP
		target.position = _slot_art[slot].position - Vector2(12,8)
		target.size = Vector2(132,164)
		var style := StyleBoxFlat.new()
		style.bg_color = Color.TRANSPARENT
		style.border_color = Color("e7c885",0.0)
		style.set_border_width_all(3)
		style.set_corner_radius_all(6)
		target.add_theme_stylebox_override("panel",style)
		_slot_art[slot].get_parent().add_child(target)
		target.set_drag_forwarding(Callable(), _can_drop_card.bind(slot), _drop_card.bind(slot))
		var button: Button = _equip_slot_a if slot == 0 else _equip_slot_b
		button.set_drag_forwarding(Callable(), _can_drop_card.bind(slot), _drop_card.bind(slot))
		_drop_targets.append(target)

func _notification(what: int) -> void:
	super._notification(what)
	if what == NOTIFICATION_DRAG_BEGIN or what == NOTIFICATION_DRAG_END:
		for target in _drop_targets:
			var style: StyleBoxFlat = target.get_theme_stylebox("panel")
			style.border_color.a = 0.9 if what == NOTIFICATION_DRAG_BEGIN else 0.0

func _card_drag_data(at_position: Vector2) -> Variant:
	var index := _owned_cards.get_item_at_position(at_position, true)
	if index < 0: return null
	var id := str(_owned_cards.get_item_metadata(index))
	if not CardManager.has_card(id): return null
	_owned_cards.select(index)
	_on_card_selected(index)
	var preview := TextureRect.new()
	preview.texture = CardDisplay.art_for(id)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.size = Vector2(90,108)
	preview.modulate.a = 0.85
	_owned_cards.set_drag_preview(preview)
	return {"source": get_instance_id(), "card_id": id}

func _can_drop_card(_at_position: Vector2, data: Variant, slot: int) -> bool:
	if slot not in [0,1] or not data is Dictionary or data.get("source",0) != get_instance_id() or not CardManager.has_card(data.get("card_id","")):
		return false
	var floor_node: Node = get_tree().get_first_node_in_group("current_identity_observer")
	if floor_node != null:
		var block_reason: String = floor_node.get_identity_change_block_reason(false)
		if block_reason == "NPC_OBSERVATION":
			_status.text = tr("有人正在看着你，不能在这里更换身份。先离开对方视线。")
			return false
		if block_reason == "CHECKER_RESTRICTION":
			_status.text = tr("核验区内不能调整证件。先退到安全工作台，再按I换证。")
			return false
	return true

func _drop_card(at_position: Vector2, data: Variant, slot: int) -> void:
	if not _can_drop_card(at_position,data,slot): return
	for index in _owned_cards.item_count:
		if _owned_cards.get_item_metadata(index) == data["card_id"]:
			_owned_cards.select(index)
			_equip_selected(slot)
			return



func _refresh_cards() -> void:
	super._refresh_cards()
	var equipped := CardManager.get_equipped_cards()
	if _selected_card_id().is_empty():
		for index in _owned_cards.item_count:
			var id := str(_owned_cards.get_item_metadata(index))
			if not equipped.has(id):
				_owned_cards.select(index)
				_owned_cards.ensure_current_is_visible()
				break
	var selected := _selected_card_id()
	_equip_slot_a.disabled = selected.is_empty()
	_equip_slot_b.disabled = selected.is_empty()
	if not selected.is_empty():
		_status.text = tr("已选%s：拖到A／B槽，或点装备按钮；原证保留。") % tr(CardDisplay.name_for(selected))
	elif not CardManager.get_owned_cards().is_empty():
		_status.text = tr("收藏保留全部证件。拖到A／B槽，关闭后按Q切当前身份。")

func _on_card_selected(index: int) -> void:
	super._on_card_selected(index)
	if not _tutorial_card_id.is_empty() and _selected_card_id() == _tutorial_card_id:
		_status.text = tr("把新工作证放入装备槽A，就能使用对应的岗位身份。") if _tutorial_slot_index == 0 else tr("把工作证放入装备槽，就能使用对应的岗位身份。")
	else:
		_status.text = tr("已选%s：拖到A／B槽，或点装备按钮；原证保留。") % tr(CardDisplay.name_for(_selected_card_id()))

func _equip_selected(slot_index: int) -> void:
	var id := _selected_card_id()
	super._equip_selected(slot_index)
	if slot_index in [0,1] and not id.is_empty() and CardManager.get_equipped_cards()[slot_index] == id:
		_status.text = tr("已装备%s到槽%s；全部证件仍在收藏。关闭背包后按Q切换身份。") % [tr(CardDisplay.name_for(id)),"A" if slot_index == 0 else "B"]
