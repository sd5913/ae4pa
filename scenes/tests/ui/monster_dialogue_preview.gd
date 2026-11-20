extends Control
var _screen: Control
func _ready() -> void:
	theme = preload("res://scenes/ui/staff_ui_theme.tres")
	var heading := Label.new()
	heading.text = "五怪对白独立预览 · 新二楼任务未接入时不代表玩法完成"
	heading.position = Vector2(35, 20)
	add_child(heading)
	_screen = preload("res://scenes/ui/monster_dialogue.gd").new()
	add_child(_screen)
	var choice := OptionButton.new()
	choice.position = Vector2(35, 65)
	choice.custom_minimum_size.x = 450
	add_child(choice)
	for monster: String in _screen.data():
		for phase: String in _screen.data()[monster]:
			choice.add_item(monster + ":" + phase)
	var open := Button.new()
	open.position = Vector2(510, 65)
	open.text = "预览文案（不结算）"
	add_child(open)
	open.pressed.connect(func() -> void: _screen.preview_dialogue(choice.get_item_text(choice.selected)))
