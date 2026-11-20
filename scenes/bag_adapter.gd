extends "res://scenes/ui/bag.gd"
## Keep D's live inventory feedback consistent when the first card is collected.


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
		_status.text = "已选%s：点右侧槽A/B替换；原证保留，关闭后Q切身份。" % tr(CardDisplay.name_for(selected))
	elif not CardManager.get_owned_cards().is_empty():
		_status.text = "收藏显示全部已获得证件；选择证件，再点击装备到槽A或B。Q仅切换两个装备槽。"

func _on_card_selected(index: int) -> void:
	super._on_card_selected(index)
	_status.text = "已选%s：点击装备到槽A或B；替换不会丢失原证件。" % tr(CardDisplay.name_for(_selected_card_id()))

func _equip_selected(slot_index: int) -> void:
	var id := _selected_card_id()
	super._equip_selected(slot_index)
	if slot_index in [0,1] and not id.is_empty() and CardManager.get_equipped_cards()[slot_index] == id:
		_status.text = "已装备%s到槽%s；全部证件仍在收藏。关闭背包后按Q切换身份。" % [tr(CardDisplay.name_for(id)),"A" if slot_index == 0 else "B"]
