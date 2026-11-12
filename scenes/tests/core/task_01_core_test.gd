extends Node2D
## A-only F6 developer entry. C doors require the published V4 component; no fake retry.

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
	_add_label(panel, "A/D 移动 · E 员工／楼梯 · Q 切卡；代记按钮不代表正式 201 验收。", 18)
	_add_label(panel, "待接：B 快照／清理、D 正式页面；C 门需同步 PR #12。重试不可用。", 18)
	var row1 := HBoxContainer.new()
	row1.name = "Row1"
	panel.add_child(row1)
	_add_button(row1, "Intro", "代记经理对白", func() -> void: GameManager.complete_manager_intro())
	_add_button(row1, "Offer", "代发 201 介绍", func() -> void: _report(GameManager.offer_task("TASK_01_CLEAN"), "任务介绍"))
	_add_button(row1, "Accept", "开发：接受任务", func() -> void: _report(GameManager.accept_task("TASK_01_CLEAN"), "接受任务"))
	_add_button(row1, "Clean", "代记清洁结果", func() -> void: _report(GameManager.record_work_result("STAIN_201"), "清洁结果"))
	_add_button(row1, "Deliver", "代发 201 交付", func() -> void: _report(GameManager.submit_task("TASK_01_CLEAN"), "201 交付"))
	var row2 := HBoxContainer.new()
	row2.name = "Row2"
	panel.add_child(row2)
	_add_button(row2, "Pause", "开发模态开／关", _toggle_pause)
	_add_button(row2, "Timeout", "代发计时归零", func() -> void: GameManager._process(GameManager.remaining_time))
	_add_button(row2, "Caught", "代发偷窃被抓", func() -> void: GameManager.request_task_failure("STAFF_CAUGHT"))
	_add_button(row2, "Restart", "开发新局", _restart)
	var retry := _add_button(row2, "Retry", "重试：等待 B 快照", Callable())
	retry.disabled = true
	_notice = _add_label(panel, "先代记经理对白，再走到 1F 右端按 E。", 18)
	GameManager.floor_changed.connect(_on_floor_changed)
	GameManager.game_failed.connect(func(reason: String) -> void: _notice.text = "失败：%s；快照未交付，只能用开发新局。" % reason)
	GameManager.safe_return_started.connect(func(reason: String) -> void: _notice.text = "普通门警告：%s；退回来侧，不回滚任务。" % reason)
	GameManager.set_floor_host($World)
	_restart()


func _process(_delta: float) -> void:
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
