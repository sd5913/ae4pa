extends Node2D
## Explicit F6-only development entry; F5 and member component scenes stay unchanged.

@onready var status: Label = $DeveloperOverlay/Margin/Info/Status
@onready var next_button: Button = $DeveloperOverlay/Margin/Info/Buttons/NextFloor
@onready var notice: Label = $DeveloperOverlay/Margin/Info/Notice


func _ready() -> void:
	GameManager.set_floor_host($World, true)
	GameManager.floor_changed.connect(_on_floor_changed)
	GameManager.game_failed.connect(_on_game_failed)
	CardManager.cards_changed.connect(_refresh_status)
	$DeveloperOverlay/Margin/Info/Buttons/Restart.pressed.connect(GameManager.start_game)
	next_button.pressed.connect(_preview_next_floor)
	GameManager.start_game()


func _preview_next_floor() -> void:
	GameManager.preview_floor(GameManager.current_floor + 1)


func _on_floor_changed(number: int) -> void:
	$World.get_child(0).notice_requested.connect(_show_notice)
	notice.text = "临时开发提示 · 正面偷卡待 B 迭代；开发跳层不计入正式通行验收"
	_refresh_status()
	next_button.disabled = number == 5 or not OS.has_feature("editor")


func _refresh_status() -> void:
	status.text = "%dF · 状态：%s · 已获：%d/3 · 双槽：%s · 当前：%s" % [
		GameManager.current_floor, GameManager.game_state, CardManager.get_owned_cards().size(),
		CardManager.get_equipped_cards(), CardManager.active_card
	]


func _show_notice(message: String) -> void:
	notice.text = message


func _on_game_failed(reason: String) -> void:
	_refresh_status()
	_show_notice("偷窃被发现 · 可点开发新局重新测试" if reason == "STAFF_CAUGHT" else "失败：" + reason)
