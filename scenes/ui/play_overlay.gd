extends Control

signal return_to_menu_requested()

const FLOOR_MODAL := "FLOOR_SELECT"
const PAUSE_MODAL := "PAUSE"

var _modal_id := ""
var _title: Label
var _message: Label
var _choices: VBoxContainer
var _close: Button
var _menu: Button




func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = preload("res://scenes/ui/staff_ui_theme.tres")
	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.035, 0.055, 0.84)
	add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = 420
	center.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	panel.add_child(content)
	content.add_theme_constant_override("separation", 16)
	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_title)
	_message = Label.new()
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_message)
	_choices = VBoxContainer.new()
	content.add_child(_choices)
	_menu = Button.new()
	_menu.text = "返回菜单"
	_menu.hide()
	content.add_child(_menu)
	_menu.pressed.connect(func() -> void:
		close_page()
		return_to_menu_requested.emit()
	)

	_close = Button.new()
	_close.theme_type_variation = &"PrimaryButton"
	content.add_child(_close)
	_close.pressed.connect(close_page)
	hide()


func open_floor_selection() -> void:
	if not GameManager.is_world_input_allowed():
		return
	_show_floors("")


func _show_floors(message: String) -> void:
	_open_page(FLOOR_MODAL, "楼层选择", "关闭")
	for child in _choices.get_children():
		_choices.remove_child(child)
		child.queue_free()
	for floor_number: int in GameManager.get_stair_destinations():
		var button := Button.new()
		button.text = "%dF" % floor_number
		button.pressed.connect(_request_floor.bind(floor_number))
		_choices.add_child(button)
	_choices.show()
	_menu.hide()
	if message.is_empty():
		message = "请选择楼层。" if _choices.get_child_count() else "目前没有可前往的楼层。"
	_message.text = message
	if _choices.get_child_count():
		_choices.get_child(0).grab_focus()


func _request_floor(floor_number: int) -> void:
	if _modal_id != FLOOR_MODAL:
		return
	close_page()
	if not GameManager.request_floor_travel(floor_number) and GameManager.is_world_input_allowed():
		_show_floors("无法前往该楼层，请使用对应方向的楼梯。")


func toggle_pause() -> void:
	if _modal_id == PAUSE_MODAL:
		close_page()
	elif GameManager.is_world_input_allowed():
		_open_page(PAUSE_MODAL, "游戏暂停", "继续游戏")
		_choices.hide()
		_menu.show()
		_message.text = "倒计时已暂停。"


func _open_page(modal_id: String, title: String, close_text: String) -> void:
	_modal_id = modal_id
	_title.text = title
	_close.text = close_text
	GameManager.set_modal_open(modal_id, true)
	show()
	_close.grab_focus()


func close_page() -> void:
	if _modal_id.is_empty():
		return
	var closing_id := _modal_id
	_modal_id = ""
	hide()
	GameManager.set_modal_open(closing_id, false)


func _input(event: InputEvent) -> void:
	if not visible or event.is_echo():
		return
	if event.is_action_pressed("pause"):
		close_page()
	elif not (event.is_action_pressed("interact") or event.is_action_pressed("switch_id")):
		return
	get_viewport().set_input_as_handled()


func _exit_tree() -> void:
	close_page()
