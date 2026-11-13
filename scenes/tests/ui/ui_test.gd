extends Node2D

const MissionBoardScreen = preload("res://scenes/ui/mission_board.gd")
const FailureScreen = preload("res://scenes/ui/failure.gd")

@onready var _hud: Control = $UISlot/HUD
@onready var _mission_board: MissionBoardScreen = $UISlot/MissionBoard
@onready var _failure: FailureScreen = $UISlot/Failure
@onready var _status: Label = $UISlot/Status


func _ready() -> void:
	_mission_board.task_accepted.connect(_show_status.bind("GameManager 已接受任务请求"))
	_mission_board.floor_selected.connect(_on_floor_selected)
	_failure.retry_requested.connect(_show_status.bind("收到重试请求"))
	_failure.return_to_menu_requested.connect(_show_status.bind("收到返回菜单请求"))
	GameManager.game_failed.connect(_failure.show_failure)
	$UISlot/Controls/ShowMission.pressed.connect(_mission_board.open_board)
	$UISlot/Controls/ShowWarning.pressed.connect(_show_warning_preview)
	$UISlot/Controls/ShowTaskFailure.pressed.connect(_show_task_failure_preview)
	$UISlot/Controls/ShowFailure.pressed.connect(_show_failure_preview)
	if "--ui-smoke" in OS.get_cmdline_user_args():
		GameManager.start_game()
		GameManager.complete_manager_intro()
		_run_smoke.call_deferred()


func _show_warning_preview() -> void:
	_mission_board.show_warning("普通违规提示预览")


func _show_task_failure_preview() -> void:
	_mission_board.show_task_failure("TASK_TIMEOUT")


func _show_failure_preview() -> void:
	GameManager.fail("STAFF_CAUGHT")


func _on_floor_selected(floor_number: int) -> void:
	_show_status("GameManager 已接受前往 %dF 请求" % floor_number)


func _show_status(message: String) -> void:
	_status.text = message
	_status.show()


func _run_smoke() -> void:
	var failures: Array[String] = []
	var task_view: Dictionary = GameManager.get_task_view()
	var available_floors: Array = GameManager.get_available_floors()
	_mission_board.refresh_from_game_manager()
	_check(_mission_board._task_id == str(task_view.get("task_id", "")),
		"Mission board reads the task ID from GameManager.get_task_view()", failures)
	var task_status := str(task_view.get("status", ""))
	var expected_status := "暂无任务" if task_status == "NONE" else task_status
	_check(_mission_board._status.text.begins_with(expected_status),
		"Mission board displays the status from the real task view", failures)
	for index: int in _mission_board._floor_buttons.size():
		_check(_mission_board._floor_buttons[index].disabled == not available_floors.has(index + 1),
			"Floor choices mirror GameManager.get_available_floors()", failures)

	var objective: Label = _hud.get_node("%Objective")
	var remaining: Label = _hud.get_node("%RemainingTime")
	_check(_hud.get_node("%FloorValue").text == "%dF" % GameManager.current_floor,
		"HUD reads the current floor from GameManager", failures)
	var task_name := str(task_view.get("name", ""))
	_check(objective.text.contains(task_name if not task_name.is_empty() else "当前无任务"),
		"HUD displays the task name from the live task view", failures)
	var remaining_seconds := maxi(0, ceili(float(task_view.get("remaining_time", 0.0))))
	var expected_time := "%d:%02d" % [remaining_seconds / 60, remaining_seconds % 60]
	_check(remaining.text.contains(expected_time), "HUD displays GameManager's remaining time", failures)
	_check(_hud.find_children("*", "Timer", true, false).is_empty(),
		"HUD does not create or advance a private timer", failures)

	_mission_board.open_board()
	_check(not GameManager.is_world_input_allowed(),
		"Opening the mission board registers a modal with GameManager", failures)
	var floor_requests: Array[int] = []
	_mission_board.floor_selected.connect(func(floor_number: int) -> void: floor_requests.append(floor_number))
	var next_floor := GameManager.current_floor + 1
	if available_floors.has(next_floor):
		_mission_board._select_floor(next_floor)
		_check(_mission_board.visible and floor_requests.is_empty() and GameManager.current_floor == 1,
			"A denied floor request restores the board without changing floors", failures)
		_check(not GameManager.is_world_input_allowed(),
			"A denied floor request restores modal registration", failures)
	_mission_board.hide()
	_check(GameManager.is_world_input_allowed(), "Closing the board releases its modal registration", failures)

	var accepted: Array[String] = []
	_mission_board.task_accepted.connect(func(task_id: String) -> void: accepted.append(task_id))
	_mission_board.refresh_from_game_manager()
	if str(task_view.get("status", "")) != "AVAILABLE":
		_check(_mission_board._accept_button.disabled, "Unavailable tasks cannot be accepted", failures)
		_mission_board._accept_task()
		_check(accepted.is_empty(), "Unavailable task sends no accepted signal", failures)

	_mission_board.show_warning("普通违规测试提示")
	_check(_mission_board._status.text.begins_with("普通警告 ·") and not _mission_board._retry_button.visible,
		"Ordinary warning stays separate from task failure", failures)
	_mission_board.show_task_failure("TASK_TIMEOUT")
	_check(_mission_board._status.text.begins_with("任务失败 ·") and _mission_board._retry_button.visible,
		"Task failure uses its own display", failures)
	_check(_mission_board._retry_button.disabled and not GameManager.has_method("restore_checkpoint"),
		"Retry stays disabled because main has no checkpoint restore API", failures)

	_failure.show_failure("STAFF_CAUGHT")
	_check(_failure.visible and _failure.get_node("%Reason").text == "偷窃被发现",
		"Failure page shows the real reason text", failures)
	_check(_failure.get_node("%RetryButton").disabled,
		"Failure page retry remains disabled without checkpoint restoration", failures)
	if failures.is_empty():
		print("PASS: mission board reads the live task view and floor list; guarded accept uses GameManager's real API.")
		print("PASS: HUD reads the live floor, task and remaining time without a private timer.")
		print("PASS: floor request uses GameManager, modal registration is released/restored correctly, ordinary warning and task failure remain distinct.")
		print("PASS: fatal failure text and disabled retry without a checkpoint API.")
	else:
		for failure: String in failures:
			push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)


func _check(condition: bool, description: String, failures: Array[String]) -> void:
	if condition:
		print("PASS: %s" % description)
	else:
		failures.append(description)
		push_error("FAIL: %s" % description)
