extends Node2D
## Explicit F6-only development entry; F5 and member component scenes stay unchanged.

@onready var status: Label = $DeveloperOverlay/Margin/Info/Status
@onready var next_button: Button = $DeveloperOverlay/Margin/Info/Buttons/NextFloor


func _ready() -> void:
	GameManager.set_floor_host($World, true)
	GameManager.floor_changed.connect(_on_floor_changed)
	$DeveloperOverlay/Margin/Info/Buttons/Restart.pressed.connect(GameManager.start_game)
	next_button.pressed.connect(_preview_next_floor)
	GameManager.start_game()


func _preview_next_floor() -> void:
	GameManager.preview_floor(GameManager.current_floor + 1)


func _on_floor_changed(number: int) -> void:
	status.text = "当前 %dF · 卡片：%s · 309 已救援：%s" % [number, CardManager.active_card, "是" if GameManager.has_friend else "否"]
	next_button.disabled = number == 5 or not OS.has_feature("editor")
