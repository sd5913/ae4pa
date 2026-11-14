extends Node2D

@onready var player: HotelPlayer = $Corridor/Player
@onready var pickup: CleaningSpot = $Pickup
@onready var authorize_309: CleaningSpot = $Authorize309
@onready var authorize_exit: CleaningSpot = $AuthorizeExit
@onready var patrol: Node = $PatrolStaff
@onready var status: Label = $Status/Label
@onready var caught: Label = $Caught/Label
@onready var recovery_timer: Timer = $RecoveryTimer

var _held_work: CleaningSpot
var _last_event := "SECURITY 当前生效：靠近包裹柜按 E；Q 切 MANAGER 后测试两个登记台"
var _start_position: Vector2


func _ready() -> void:
	_start_position = player.global_position
	GameManager.start_game()
	CardManager.collect_card("SECURITY")
	CardManager.collect_card("MANAGER")
	for work: CleaningSpot in [pickup, authorize_309, authorize_exit]:
		work.setup(player)
		work.set_task_active(true)
		work.work_requested.connect(_on_work_requested.bind(work))
	patrol.setup(player)
	patrol.set_process_unhandled_input(false)
	patrol.set_task_eligible(true)
	patrol.task_item_stolen.connect(_on_task_item_stolen)
	patrol.task_failure_requested.connect(_on_patrol_failure)
	CardManager.cards_changed.connect(_refresh_status)
	_refresh_status()


func _process(delta: float) -> void:
	if is_instance_valid(_held_work):
		_held_work.advance_interaction(delta)
		if not _held_work.is_interacting():
			_held_work = null
	_refresh_status()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_R:
		_reset_test()
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not event.is_echo():
		if patrol.is_player_in_range():
			patrol.begin_steal()
			get_viewport().set_input_as_handled()
			return
		for work: CleaningSpot in [pickup, authorize_309, authorize_exit]:
			if work.is_player_in_range():
				if work.begin_interaction() and work.is_interacting():
					_held_work = work
				else:
					_last_event = "交互被拒绝：请确认当前身份、任务资格与是否已完成"
				get_viewport().set_input_as_handled()
				return
	elif event.is_action_released("interact"):
		if is_instance_valid(_held_work):
			_held_work.cancel_interaction()
			_held_work = null
		patrol.cancel_steal()


func _on_work_requested(target_id: String, work: CleaningSpot) -> void:
	_last_event = "%s 成功：work_requested(%s)；重复 E 将被拒绝" % [work.interaction_type, target_id]


func _on_task_item_stolen(item_id: String, target_id: String) -> void:
	_last_event = "文件取得：task_item_stolen(%s, %s)；未写入 CardManager" % [item_id, target_id]


func _on_patrol_failure(reason: String, target_id: String) -> void:
	if recovery_timer.time_left > 0.0:
		return
	GameManager.fail(reason)
	patrol.set_interaction_enabled(false)
	caught.text = "CAUGHT!  %s · %s" % [reason, target_id]
	caught.visible = true
	_last_event = "偷文件失败，1.2 秒后自动恢复"
	recovery_timer.start()


func _on_recovery_timer_timeout() -> void:
	GameManager.start_game()
	CardManager.collect_card("SECURITY")
	CardManager.collect_card("MANAGER")
	player.global_position = _start_position
	player.velocity = Vector2.ZERO
	patrol.cancel_steal()
	patrol.reset_caught_alert()
	patrol.set_task_eligible(true)
	patrol.set_interaction_enabled(true)
	caught.visible = false
	_last_event = "失败已恢复：可以继续测试；已成功取得的文件状态保持由测试场景当前值决定"


func _reset_test() -> void:
	GameManager.start_game()
	CardManager.collect_card("SECURITY")
	CardManager.collect_card("MANAGER")
	player.global_position = _start_position
	player.velocity = Vector2.ZERO
	for work: CleaningSpot in [pickup, authorize_309, authorize_exit]:
		work.set_completed(false)
		work.set_task_active(true)
	patrol.reset_caught_alert()
	patrol.set_reward_available(true)
	patrol.set_task_eligible(true)
	patrol.set_interaction_enabled(true)
	caught.visible = false
	_last_event = "全部测试对象已恢复"


func _refresh_status() -> void:
	status.text = "B-V4-04/05 人工体验 · A/D 移动 · E 交互/长按 · Q 切身份 · R 全部恢复\n当前身份 %s · 双槽 %s\n包裹柜 SECURITY：%s  |  309 MANAGER：%s  |  5F MANAGER：%s\n巡房文件：背后静止长按 E 0.8 秒 · 进度 %.0f%% · 可取 %s\n%s" % [
		CardManager.active_card, CardManager.get_equipped_cards(),
		"完成" if pickup.is_completed() else "可测试",
		"完成" if authorize_309.is_completed() else "可测试",
		"完成" if authorize_exit.is_completed() else "可测试",
		patrol.get_interaction_progress() * 100.0, patrol.is_reward_available(), _last_event,
	]
