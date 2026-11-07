extends Node2D


func _ready() -> void:
	# Start beside the doors so F6 immediately shows both reusable instances.
	$Corridor/Player.global_position = Vector2(1280, 560)
	$Corridor/DoorRoot.hide()
	for door: Node in $DoorSlot.get_children():
		door.setup($Corridor/Player)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	# Test-only preparation through B's real public methods.
	if event.keycode == KEY_1:
		CardManager.collect_card("SECURITY")
		CardManager.equip_card("SECURITY", CardManager.active_slot)
	elif event.keycode == KEY_2:
		CardManager.collect_card("CLEANER")
		CardManager.equip_card("CLEANER", CardManager.active_slot)
	elif event.keycode == KEY_R:
		GameManager.start_game()
		$Corridor/Player.global_position = Vector2(1280, 560)
		for door: Node in $DoorSlot.get_children():
			door.reset_cycle()


func _process(_delta: float) -> void:
	$TestLabel/Status.text = "当前卡：%s | 状态：%s | %s" % [
		CardManager.active_card, GameManager.game_state,
		GameManager.fail_reason + " · 按 R 重开" if GameManager.game_state == "FAILED" else "仅开门且范围内检查",
	]
