extends Node2D
## Temporary shared test entry. D's menu and UI connect here during integration.

@onready var state_label: Label = $DeveloperOverlay/Margin/Info/State


func _ready() -> void:
	GameManager.state_changed.connect(_on_state_changed)
	CardManager.cards_changed.connect(_on_cards_changed)
	if GameManager.game_state == "MENU":
		GameManager.start_game()
	_on_state_changed(GameManager.game_state)


func _on_state_changed(new_state: String) -> void:
	state_label.text = "状态：%s  ·  当前楼层：%dF  ·  当前卡：%s" % [
		new_state, GameManager.current_floor, CardManager.active_card
	]


func _on_cards_changed() -> void:
	_on_state_changed(GameManager.game_state)
