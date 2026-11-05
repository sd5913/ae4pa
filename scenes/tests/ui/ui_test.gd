extends Node2D
## F6 opens the manual test. Pass -- --ui-smoke to check the same scene headlessly.

const MainMenuScreen = preload("res://scenes/ui/main_menu.gd")
const HelpScreen = preload("res://scenes/ui/help.gd")
const FailureScreen = preload("res://scenes/ui/failure.gd")

const EXPECTED_REASONS := {
	"STAFF_CAUGHT": "偷窃被发现",
	"WRONG_CARD": "当前工作证不符合要求",
	"MOVED_NEAR_EAR": "大耳客开门时仍在移动",
	"SWITCHED_NEAR_CHECKER": "核验客面前更换了工作证",
}

@onready var _menu: MainMenuScreen = $UISlot/MainMenu
@onready var _help: HelpScreen = $UISlot/Help
@onready var _failure: FailureScreen = $UISlot/Failure
@onready var _status: Label = $UISlot/Status
@onready var _failure_controls: HBoxContainer = $UISlot/FailureControls
@onready var _reason_choice: OptionButton = $UISlot/FailureControls/ReasonChoice


func _ready() -> void:
	_menu.start_requested.connect(_on_start_requested)
	_menu.help_requested.connect(_help.open_help)
	_failure.retry_requested.connect(_show_status.bind("收到重试本层请求 · 待 A 接入"))
	_failure.return_to_menu_requested.connect(_show_status.bind("收到返回菜单请求 · 待 A 接入"))
	GameManager.game_failed.connect(_on_game_failed)
	GameManager.game_failed.connect(_failure.show_failure)

	for reason: String in EXPECTED_REASONS:
		_reason_choice.add_item(EXPECTED_REASONS[reason])
		_reason_choice.set_item_metadata(_reason_choice.item_count - 1, reason)
	_reason_choice.select(0)
	_show_status("点击开始或操作说明，也可按 H 查看说明")

	if "--ui-smoke" in OS.get_cmdline_user_args():
		_run_smoke.call_deferred()


func _on_start_requested() -> void:
	GameManager.start_game()
	_menu.hide()
	_failure_controls.show()
	_show_status("收到开始请求 · 选择一种失败原因并模拟")


func _on_simulate_failure_pressed() -> void:
	GameManager.fail(_reason_choice.get_selected_metadata())


func _on_game_failed(_reason: String) -> void:
	_help.close_help()
	_help.set_process_unhandled_input(false)
	_failure_controls.hide()
	_show_status("收到 GameManager.game_failed · 可测试两个请求按钮")


func _show_status(message: String) -> void:
	_status.text = "D · 独立 UI 测试  /  " + message


func _run_smoke() -> void:
	var failures: Array[String] = []
	var requests: Array[String] = []
	_menu.start_requested.connect(func() -> void: requests.append("start"))
	_menu.help_requested.connect(func() -> void: requests.append("help"))
	_failure.retry_requested.connect(func() -> void: requests.append("retry"))
	_failure.return_to_menu_requested.connect(func() -> void: requests.append("menu"))

	var help_button: Button = _menu.get_node("%HelpButton")
	var close_button: Button = _help.get_node("%CloseButton")
	_check(not _help.visible and not _failure.visible, "Overlays start hidden", failures)
	help_button.grab_focus()
	help_button.pressed.emit()
	_check(_help.visible and close_button.has_focus(), "Help opens and takes focus", failures)
	close_button.pressed.emit()
	_check(not _help.visible and help_button.has_focus(), "Help closes and restores focus", failures)
	_help.open_help()
	_check(_help.visible, "Public open_help() shows help", failures)
	_help.close_help()
	_check(not _help.visible, "Public close_help() hides help", failures)

	var help_key := InputEventKey.new()
	help_key.physical_keycode = KEY_H
	help_key.pressed = true
	get_viewport().push_input(help_key)
	_check(_help.visible, "Mapped H key opens help", failures)
	get_viewport().push_input(help_key)
	_check(not _help.visible, "Mapped H key closes help", failures)

	var start_button: Button = _menu.get_node("%StartButton")
	start_button.pressed.emit()
	_check(GameManager.game_state == "PLAYING", "Start request starts the test game", failures)

	var reason_label: Label = _failure.get_node("%Reason")
	for reason: String in EXPECTED_REASONS:
		_failure.hide()
		GameManager.start_game()
		_help.open_help()
		GameManager.fail(reason)
		_check(GameManager.game_state == "FAILED", "GameManager accepted " + reason, failures)
		_check(_failure.visible and reason_label.text == EXPECTED_REASONS[reason],
			"Failure message for " + reason, failures)
		_check(not _help.visible and _failure.get_node("%RetryButton").has_focus(),
			"Failure takes focus from help for " + reason, failures)

	_failure.show_failure("UNKNOWN_REASON")
	_check(reason_label.text == "未能通过检查", "Unknown reason has a Chinese fallback", failures)
	var retry_button: Button = _failure.get_node("%RetryButton")
	var menu_button: Button = _failure.get_node("%MenuButton")
	retry_button.pressed.emit()
	menu_button.pressed.emit()
	get_viewport().push_input(help_key)
	_check(not _help.visible, "Help shortcut stays disabled over failure", failures)
	_check(requests == ["help", "start", "retry", "menu"], "Each button emitted its request once", failures)
	_check(GameManager.game_state == "FAILED", "Retry/menu only emit requests in this test", failures)

	if failures.is_empty():
		print("PASS: menu requests, help visibility and focus, four GameManager failure messages, fallback, retry/menu requests.")
	else:
		for failure: String in failures:
			push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)


func _check(condition: bool, description: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(description)
