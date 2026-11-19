extends CanvasLayer
## A adapts D's fixed review components to current GameManager APIs.

signal menu_requested()

const PlayOverlay = preload("res://scenes/ui/play_overlay.gd")
const InteractionProgress = preload("res://scenes/ui/interaction_progress.gd")
var play_overlay: Control
var interaction_progress: Control

const OFFER_MODAL: String = "TASK_OFFER"
const FAILURE_MODAL: String = "TASK_FAILURE"

@onready var board: Control = $MissionBoard
@onready var failure: Control = $Failure
@onready var hud: Control = $HUD


func _ready() -> void:
	play_overlay = PlayOverlay.new()
	play_overlay.name = "PlayOverlay"
	add_child(play_overlay)
	play_overlay.return_to_menu_requested.connect(func() -> void: menu_requested.emit())
	board.task_accepted.connect(_on_task_accepted)
	board.visibility_changed.connect(_on_offer_visibility_changed)
	failure.retry_requested.connect(_on_retry_requested)
	failure.return_to_menu_requested.connect(func() -> void: menu_requested.emit())
	GameManager.task_offered.connect(open_offer)
	GameManager.task_updated.connect(_refresh_offer)
	GameManager.game_failed.connect(_show_failure)
	GameManager.state_changed.connect(_on_state_changed)
	interaction_progress = InteractionProgress.new()
	interaction_progress.name = "InteractionProgress"
	hud.get_node("%ProgressHost").add_child(interaction_progress)
	_refresh_hud()


func bind_interaction_floor(floor_node: Node) -> void:
	interaction_progress.bind_floor(floor_node)


func open_floor_selection() -> void:
	play_overlay.open_floor_selection()


func _input(event: InputEvent) -> void:
	if not event.is_echo() and event.is_action_pressed("pause") and GameManager.is_world_input_allowed():
		play_overlay.toggle_pause()
		get_viewport().set_input_as_handled()
		return
	if (board.visible or failure.visible) and (event.is_action_pressed("interact") or event.is_action_pressed("switch_id")):
		get_viewport().set_input_as_handled()


func open_offer(task_id: String) -> void:
	if task_id != GameManager.current_task_id or GameManager.task_status != "AVAILABLE" or GameManager.game_state != "PLAYING" or GameManager.current_floor != 2:
		return
	failure.hide()
	GameManager.set_modal_open(FAILURE_MODAL, false)
	board.open_task_details()
	_refresh_offer()


func _refresh_offer() -> void:
	if not board.visible:
		return
	if GameManager.task_status != "AVAILABLE" or GameManager.game_state != "PLAYING":
		board.hide()
		return
	var view: Dictionary = GameManager.get_task_view()
	board.configure_task_details("所需身份：%s · 接受后限时 %d 秒\n回 1F 取得保洁工作证，再到 2F 清理污渍，最后回 201 交付。" % [view["required_card"], int(view["time_limit"])])
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
	var can_retry := GameManager.can_retry_current_task()
	failure.configure_retry(can_retry,
		"回到 201 接受前，撤销本任务获得的卡片与清理结果。" if can_retry else "当前没有可恢复的任务检查点。")
	GameManager.set_modal_open(FAILURE_MODAL, true)
	_refresh_hud()


func _on_retry_requested() -> void:
	if not failure.visible or not GameManager.can_retry_current_task():
		return
	if not GameManager.retry_current_task():
		_show_failure(GameManager.fail_reason)


func _on_state_changed(state: String) -> void:
	if state != "PLAYING":
		play_overlay.close_page()
	if state in ["RESTORING", "MENU"] or (state == "PLAYING" and GameManager.task_status == "NONE"):
		close_views()
	_refresh_hud()


func close_views() -> void:
	play_overlay.close_page()
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
