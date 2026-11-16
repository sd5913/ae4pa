extends Node2D
## A-only F6 developer entry; acceptance UI remains D's responsibility.

var _status: Label
var _notice: Label
var _paused: bool = false


func _ready() -> void:
	var overlay := CanvasLayer.new()
	overlay.name = "DeveloperOverlay"
	overlay.layer = 10
	add_child(overlay)
	var panel := VBoxContainer.new()
	panel.name = "Panel"
	panel.position = Vector2(24, 18)
	panel.size.x = 1232
	panel.add_theme_constant_override("separation", 6)
	overlay.add_child(panel)
	_add_label(panel, "CORE · 任务 01 接线测试（开发入口）", 25)
	_status = _add_label(panel, "", 18)
	_add_label(panel, "A/D 移动 · E 楼梯／身后偷卡／清理／201 交付 · Q 切卡。", 18)
	_add_label(panel, "仅介绍／接受／失败使用开发按钮；偷卡、清理、交付、重试走真实组件。D 正式页面待交付。", 18)
	var row1 := HBoxContainer.new()
	row1.name = "Row1"
	panel.add_child(row1)
	_add_button(row1, "Intro", "代记经理对白", func() -> void: GameManager.complete_manager_intro())
	_add_button(row1, "Offer", "代发 201 介绍", func() -> void: _report(GameManager.offer_task("TASK_01_CLEAN"), "任务介绍"))
	_add_button(row1, "Accept", "开发：接受任务", func() -> void: _report(GameManager.accept_task("TASK_01_CLEAN"), "接受任务"))
	var row2 := HBoxContainer.new()
	row2.name = "Row2"
	panel.add_child(row2)
	_add_button(row2, "Pause", "开发模态开／关", _toggle_pause)
	_add_button(row2, "Timeout", "代发计时归零", func() -> void: GameManager._process(GameManager.remaining_time))
	_add_button(row2, "Caught", "代发偷窃被抓", func() -> void: GameManager.request_task_failure("STAFF_CAUGHT"))
	_add_button(row2, "Restart", "开发新局", _restart)
	var retry := _add_button(row2, "Retry", "开发：检查点重试", func() -> void:
		_notice.text = "已恢复 201 接取前状态；请重新接受，才开始 210 秒计时。" if GameManager.retry_current_task() else "当前没有可恢复的失败任务。"
	)
	retry.disabled = true
	_notice = _add_label(panel, "先代记经理对白，再走到 1F 右端按 E。", 18)
	GameManager.floor_changed.connect(_on_floor_changed)
	GameManager.game_failed.connect(func(reason: String) -> void: _notice.text = "失败：%s；可点检查点重试，回 201 重新接受。" % reason)
	GameManager.state_changed.connect(func(state: String) -> void:
		if state == "RESTORING":
			_paused = false
	)
	GameManager.safe_return_started.connect(func(reason: String) -> void: _notice.text = "普通门警告：%s；退回来侧，不回滚任务。" % reason)
	GameManager.set_floor_host($World)
	_restart()


func _process(_delta: float) -> void:
	$DeveloperOverlay/Panel/Row2/Retry.disabled = not GameManager.can_retry_current_task()
	_status.text = "%dF · %s · %s / %s · %.1f 秒\n卡：%s · 当前：%s · E 目标：%s" % [GameManager.current_floor, GameManager.game_state, GameManager.current_task_id, GameManager.task_status, GameManager.remaining_time, CardManager.get_equipped_cards(), CardManager.active_card, $World.get_child(0).get_interaction_target_id()]


func _restart() -> void:
	_paused = false
	GameManager.start_game()


func _toggle_pause() -> void:
	_paused = not _paused
	GameManager.set_modal_open("CORE_PAUSE", _paused)
	_notice.text = "开发模态：%s；只验停表与世界 E 屏蔽，不代表完整世界冻结。" % ("打开" if _paused else "关闭")


func _report(accepted: bool, action: String) -> void:
	_notice.text = "%s：%s（开发调用；距离／正式页面另验）" % [action, "已接受" if accepted else "条件不足"]


func _on_floor_changed(_floor_number: int) -> void:
	$World.get_child(0).notice_requested.connect(func(message: String) -> void: _notice.text = message)


func _add_label(parent: Node, text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label


func _add_button(parent: Node, node_name: String, text: String, action: Callable) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	if action.is_valid():
		button.pressed.connect(action)
	parent.add_child(button)
	return button
