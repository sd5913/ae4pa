extends "res://scenes/ui/bag.gd"
## Keep D's live inventory feedback consistent when the first card is collected.


func _refresh_cards() -> void:
	super._refresh_cards()
	if not CardManager.get_owned_cards().is_empty() and _status.text == "尚未获得工作证":
		_status.text = "选择工作证后可以装备到两个佩戴槽。"
