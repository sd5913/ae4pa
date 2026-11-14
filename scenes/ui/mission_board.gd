extends Control

signal task_accepted(task_id: String)
signal floor_selected(floor_number: int)
signal retry_requested()

var _task_id := ""
var _accept_button: Button
var _retry_button: Button
var _floor_buttons: Array[Button] = []
var _status: Label
var _hint: Label


func _ready() -> void:
	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.035, 0.055, 0.84)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(760, 0)
	panel.theme = load("res://scenes/ui/staff_ui_theme.tres")
	center.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)
	var title := Label.new()
	title.text = "201  /  本次任务"
	title.add_theme_font_size_override("font_size", 30)
	content.add_child(title)
	_status = Label.new()
	_status.text = ""
	content.add_child(_status)
	_hint = Label.new()
	_hint.text = "任务状态与可选楼层由 GameManager 提供。"
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_hint)
	var floors := HBoxContainer.new()
	floors.add_theme_constant_override("separation", 8)
	content.add_child(floors)
	for floor_number in range(1, 6):
		var button := Button.new()
		button.text = "%dF" % floor_number
		button.disabled = true
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_select_floor.bind(floor_number))
		floors.add_child(button)
		_floor_buttons.append(button)
	_accept_button = Button.new()
	_accept_button.text = "接受任务"
	_accept_button.disabled = true
	content.add_child(_accept_button)
	_accept_button.pressed.connect(_accept_task)
	_retry_button = Button.new()
	_retry_button.text = "重新挑战本任务"
	_retry_button.visible = false
	_retry_button.disabled = true
	_retry_button.tooltip_text = "检查点恢复接口尚未提供"
	content.add_child(_retry_button)
	_retry_button.pressed.connect(_on_retry_pressed)
	var close_button := Button.new()
	close_button.text = "关闭"
	content.add_child(close_button)
	close_button.pressed.connect(hide)
	if GameManager.has_signal("task_updated"):
		GameManager.connect("task_updated", refresh_from_game_manager)
	if GameManager.has_signal("task_offered"):
		GameManager.connect("task_offered", refresh_from_game_manager.unbind(1))
	if GameManager.has_signal("task_completed"):
		GameManager.connect("task_completed", refresh_from_game_manager.unbind(1))
	if GameManager.has_signal("task_failed"):
		GameManager.connect("task_failed", _on_task_failed)
	refresh_from_game_manager()


func open_board() -> void:
	refresh_from_game_manager()
	show()
	_accept_button.grab_focus()


func refresh_from_game_manager(_unused: Variant = null) -> void:
	if not GameManager.has_method("get_task_view") or not GameManager.has_method("get_available_floors"):
		_task_id = ""
		_status.text = "任务／楼层接口待 A 同步"
		_accept_button.disabled = true
		for button: Button in _floor_buttons:
			button.disabled = true
			button.text = button.text.left(2)
		return
	var task_view: Dictionary = GameManager.call("get_task_view")
	var available_floors: Array = GameManager.call("get_available_floors")
	_task_id = str(task_view.get("task_id", ""))
	var task_status: String = str(task_view.get("status", ""))
	var task_name: String = str(task_view.get("name", ""))
	var location: String = str(task_view.get("location", ""))
	_status.text = _format_task_view(task_status, task_name, location)
	_accept_button.disabled = task_status != "AVAILABLE" or _task_id.is_empty()
	for index in _floor_buttons.size():
		var floor_number := index + 1
		var button := _floor_buttons[index]
		button.disabled = not available_floors.has(floor_number)
		button.text = "%dF%s" % [floor_number, " · 可前往" if not button.disabled else ""]
	var remaining: float = float(task_view.get("remaining_time", 0.0))
	var target_id: String = str(task_view.get("target_id", ""))
	var step: String = str(task_view.get("step", ""))
	_hint.text = "目标：%s · 步骤：%s · 剩余：%s" % [target_id, step, _format_time(remaining)] if not target_id.is_empty() else "任务目标与剩余时间由 GameManager 提供。"


func show_warning(message: String) -> void:
	_retry_button.visible = false
	_retry_button.disabled = true
	_status.text = "普通警告 · " + message
	_status.self_modulate = Color("f0c86e")
	show()


func show_task_failure(reason: String) -> void:
	_status.text = "任务失败 · " + reason
	_status.self_modulate = Color("f08a72")
	_retry_button.visible = true
	_retry_button.disabled = true
	_retry_button.text = "重试功能待 A 接入"
	_retry_button.tooltip_text = "GameManager 尚未提供检查点恢复接口"
	show()


func _accept_task() -> void:
	if _task_id.is_empty() or not GameManager.has_method("accept_task"):
		return
	if bool(GameManager.call("accept_task", _task_id)):
		task_accepted.emit(_task_id)
		refresh_from_game_manager()
	else:
		_status.text = "GameManager 未接受此任务"


func _select_floor(floor_number: int) -> void:
	if not GameManager.has_method("request_floor_travel"):
		return
	if bool(GameManager.call("request_floor_travel", floor_number)):
		floor_selected.emit(floor_number)
		hide()
	else:
		_status.text = "无法前往该楼层，请到对应楼梯旁操作"


func _on_task_failed(task_id: String, reason: String) -> void:
	refresh_from_game_manager()
	show_task_failure("%s：%s" % [task_id, reason])


func _on_retry_pressed() -> void:
	if _retry_button.disabled:
		return
	retry_requested.emit()


func _format_task_view(task_status: String, task_name: String, location: String) -> String:
	var status_names := {
		"NONE": "暂无任务",
		"AVAILABLE": "可接受",
		"ACTIVE": "进行中",
		"READY_TO_SUBMIT": "待交付",
		"COMPLETED": "已完成",
		"FAILED": "失败",
	}
	var status_text: String = str(status_names.get(task_status, task_status))
	if task_name.is_empty():
		return status_text
	return "%s · %s · %s" % [status_text, task_name, location]


func _format_time(seconds: float) -> String:
	var total_seconds := maxi(0, ceili(seconds))
	return "%d:%02d" % [total_seconds / 60, total_seconds % 60]
