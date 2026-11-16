extends CanvasLayer
## A adapts D's fixed review components to current GameManager APIs.

signal menu_requested()

const OFFER_MODAL: String = "TASK_OFFER"
const FAILURE_MODAL: String = "TASK_FAILURE"

@onready var board: Control = $MissionBoard
@onready var failure: Control = $Failure
@onready var hud: Control = $HUD


func _ready() -> void:
	board.task_accepted.connect(_on_task_accepted)
	board.visibility_changed.connect(_on_offer_visibility_changed)
	failure.retry_requested.connect(_on_retry_requested)
	failure.return_to_menu_requested.connect(func() -> void: menu_requested.emit())
	GameManager.task_offered.connect(open_offer)
	GameManager.task_updated.connect(_refresh_offer)
	GameManager.game_failed.connect(_show_failure)
	GameManager.state_changed.connect(_on_state_changed)
	# D's HUD currently has two direct PanelContainer children; stack these instance
	# children without changing D's shared scene or script.
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	hud.add_child(stack)
	hud.get_node("Readout").reparent(stack)
	hud.get_node("TaskReadout").reparent(stack)
	_refresh_hud()


func _input(event: InputEvent) -> void:
	if (board.visible or failure.visible) and (event.is_action_pressed("interact") or event.is_action_pressed("switch_id")):
		get_viewport().set_input_as_handled()


func open_offer(task_id: String) -> void:
	if task_id != GameManager.current_task_id or GameManager.task_status != "AVAILABLE" or GameManager.game_state != "PLAYING" or GameManager.current_floor != 2:
		return
	failure.hide()
	GameManager.set_modal_open(FAILURE_MODAL, false)
	board.open_board()
	_refresh_offer()


func _refresh_offer() -> void:
	if not board.visible:
		return
	if GameManager.task_status != "AVAILABLE" or GameManager.game_state != "PLAYING":
		board.hide()
		return
	board.get("_retry_button").hide()
	board.get("_status").self_modulate = Color.WHITE
	var view: Dictionary = GameManager.get_task_view()
	var hint: Label = board.get("_hint")
	hint.text = "所需身份：%s · 接受后限时 %d 秒\n回 1F 取得保洁工作证，再到 2F 清理污渍，最后回 201 交付。" % [view["required_card"], int(view["time_limit"])]
	# This is the acceptance page. Travel remains the floor's real E stair action.
	for button: Button in board.get("_floor_buttons"):
		button.hide()
	_refresh_hud()


func _on_offer_visibility_changed() -> void:
	GameManager.set_modal_open(OFFER_MODAL, board.visible and GameManager.task_status == "AVAILABLE")
	_refresh_hud()


func _on_task_accepted(task_id: String) -> void:
	if task_id == GameManager.current_task_id and GameManager.task_status == "ACTIVE":
		board.hide()


func _show_failure(reason: String) -> void:
	if GameManager.game_state != "FAILED":
		return
	board.hide()
	failure.show_failure(reason)
	failure.get_node("Center/Panel/Content/Title").text = "任务超时" if reason == "TASK_TIMEOUT" else "偷窃被发现" if reason == "STAFF_CAUGHT" else "任务失败"
	failure.get_node("Center/Panel/Content/Eyebrow").text = "本次任务"
	if reason == "TASK_TIMEOUT":
		failure.get_node("%Reason").text = "任务超时，请回到接取前重新挑战。"
	var retry: Button = failure.get_node("%RetryButton")
	retry.text = "重新挑战本任务"
	retry.disabled = not GameManager.can_retry_current_task()
	retry.tooltip_text = "回到 201 接受前，撤销本任务获得的卡片与清理结果。" if not retry.disabled else "当前没有可恢复的任务检查点。"
	failure.get_node("%MenuButton").text = "返回菜单"
	GameManager.set_modal_open(FAILURE_MODAL, true)
	if not retry.disabled:
		retry.grab_focus()
	_refresh_hud()


func _on_retry_requested() -> void:
	if not failure.visible or not GameManager.can_retry_current_task():
		return
	if not GameManager.retry_current_task():
		_show_failure(GameManager.fail_reason)


func _on_state_changed(state: String) -> void:
	if state in ["RESTORING", "MENU"] or (state == "PLAYING" and GameManager.task_status == "NONE"):
		close_views()
	_refresh_hud()


func close_views() -> void:
	board.hide()
	failure.hide()
	GameManager.set_modal_open(OFFER_MODAL, false)
	GameManager.set_modal_open(FAILURE_MODAL, false)
	_refresh_hud()


func _refresh_hud() -> void:
	hud.visible = GameManager.game_state == "PLAYING" and not board.visible and not failure.visible


func _exit_tree() -> void:
	GameManager.set_modal_open(OFFER_MODAL, false)
	GameManager.set_modal_open(FAILURE_MODAL, false)
