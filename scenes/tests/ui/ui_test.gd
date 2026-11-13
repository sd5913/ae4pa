extends Node2D
## F6 opens the manual test. Pass -- --ui-smoke to check the same scene headlessly.

const MainMenuScreen = preload("res://scenes/ui/main_menu.gd")
const HelpScreen = preload("res://scenes/ui/help.gd")
const FailureScreen = preload("res://scenes/ui/failure.gd")
const BagScreen = preload("res://scenes/ui/bag.gd")
const DialogueScreen = preload("res://scenes/ui/dialogue.gd")
const WinScreen = preload("res://scenes/ui/win.gd")
const MissionBoardScreen = preload("res://scenes/ui/mission_board.gd")

const EXPECTED_REASONS := {
	"STAFF_CAUGHT": "偷窃被发现",
	"WRONG_CARD": "当前工作证不符合要求",
	"MOVED_NEAR_EAR": "大耳客开门时仍在移动",
	"SWITCHED_NEAR_CHECKER": "核验客面前更换了工作证",
}

@onready var _menu: MainMenuScreen = $UISlot/MainMenu
@onready var _help: HelpScreen = $UISlot/Help
@onready var _bag: BagScreen = $UISlot/Bag
@onready var _dialogue: DialogueScreen = $UISlot/Dialogue
@onready var _win: WinScreen = $UISlot/Win
@onready var _failure: FailureScreen = $UISlot/Failure
@onready var _hud: Control = $UISlot/HUD
@onready var _status: Label = $UISlot/Status
@onready var _failure_controls: HBoxContainer = $UISlot/FailureControls
@onready var _reason_choice: OptionButton = $UISlot/FailureControls/ReasonChoice
@onready var _mission_board: MissionBoardScreen = $UISlot/MissionBoard


func _ready() -> void:
	_menu.start_requested.connect(_on_start_requested)
	_menu.help_requested.connect(_help.open_help)
	_failure.retry_requested.connect(_show_status.bind("收到重试本层请求 · 待 A 接入"))
	_failure.return_to_menu_requested.connect(_show_status.bind("收到返回菜单请求 · 待 A 接入"))
	_dialogue.dialogue_finished.connect(_on_dialogue_finished)
	GameManager.game_failed.connect(_on_game_failed)
	GameManager.game_failed.connect(_failure.show_failure)
	GameManager.state_changed.connect(_update_overlay_shortcuts.unbind(1))
	_help.visibility_changed.connect(_update_overlay_shortcuts)
	_bag.visibility_changed.connect(_update_overlay_shortcuts)
	_mission_board.task_accepted.connect(_show_status.bind("GameManager 已接受任务"))
	_mission_board.floor_selected.connect(_on_floor_travel_accepted)
	_mission_board.retry_requested.connect(_show_status.bind("收到重新挑战本任务请求 · 待 A 接入"))
	_update_overlay_shortcuts()

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
	_hud.show()
	_failure_controls.show()
	_show_status("收到开始请求 · 选择一种失败原因并模拟")


func _on_simulate_failure_pressed() -> void:
	GameManager.fail(_reason_choice.get_selected_metadata())


func _on_show_intro_pressed() -> void:
	_dialogue.show_dialogue("INTRO")


func _on_show_rescue_pressed() -> void:
	_dialogue.show_dialogue("RESCUE_309")


func _on_show_mission_pressed() -> void:
	_mission_board.open_board()


func _on_floor_travel_accepted(floor_number: int) -> void:
	_show_status("GameManager 已接受前往 %dF" % floor_number)


func _on_dialogue_finished(dialogue_id: String) -> void:
	_show_status("对白 %s 已完成 · 测试入口" % dialogue_id)


func _on_game_failed(_reason: String) -> void:
	_help.close_help()
	_bag.close_bag()
	_hud.hide()
	_failure_controls.hide()
	_show_status("收到 GameManager.game_failed · 可测试两个请求按钮")


func _update_overlay_shortcuts() -> void:
	var state: String = GameManager.game_state
	_bag.set_process_unhandled_input(state == "PLAYING" and not _help.visible)
	_help.set_process_unhandled_input(state != "FAILED" and not _bag.visible)


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
	var page_next: Button = _help.get_node("%NextButton")
	var page_previous: Button = _help.get_node("%PreviousButton")
	_check(not _help.visible and not _failure.visible, "Overlays start hidden", failures)
	help_button.grab_focus()
	help_button.pressed.emit()
	_check(_help.visible and close_button.has_focus(), "Help opens and takes focus", failures)
	_check(_help.get_node("%PageIndicator").text == "1 / 2", "Menu opens the work-card page", failures)
	_check_help_content(failures)
	page_next.pressed.emit()
	_check(_help.get_node("%PageIndicator").text == "2 / 2" and _help.get_node("%MonsterPage").visible,
		"Next page opens the monster encyclopedia", failures)
	page_previous.pressed.emit()
	_check(_help.get_node("%PageIndicator").text == "1 / 2" and _help.get_node("%WorkCardPage").visible,
		"Previous page returns to work cards", failures)
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
	page_next.pressed.emit()
	get_viewport().push_input(help_key)
	_check(not _help.visible, "Mapped H key closes help from the monster page", failures)
	_check_dialogue(failures)
	_check_mission_board(failures)
	_check_win(failures)

	var floor_value: Label = _hud.get_node("%FloorValue")
	var active_card_value: Label = _hud.get_node("%ActiveCardValue")
	var slot_a_value: Label = _hud.get_node("%SlotAValue")
	var slot_b_value: Label = _hud.get_node("%SlotBValue")
	var card_values: Array[Label] = [active_card_value, slot_a_value, slot_b_value]
	_check(not _hud.visible and floor_value.text == "%dF" % GameManager.current_floor,
		"HUD reads the current floor on initialization", failures)
	for label: Label in card_values:
		_check(label.text == "未装备", "HUD reads the initial empty card state", failures)
		# Clear rendered text so an unchanged value cannot mask a missing refresh.
		label.text = ""
	CardManager.reset_for_new_game()
	for label: Label in card_values:
		_check(label.text == "未装备", "cards_changed restores the empty card display", failures)

	floor_value.text = ""
	_hud.show()
	_check(floor_value.text == "%dF" % GameManager.current_floor,
		"Showing the HUD rereads the current floor", failures)
	_hud.hide()

	var start_button: Button = _menu.get_node("%StartButton")
	start_button.pressed.emit()
	_check(GameManager.game_state == "PLAYING", "Start request starts the test game", failures)
	_check(_hud.visible and floor_value.text == "1F", "New game displays the HUD on 1F", failures)
	_check_bag(failures)

	var reason_label: Label = _failure.get_node("%Reason")
	for reason: String in EXPECTED_REASONS:
		_failure.hide()
		GameManager.start_game()
		_help.open_help()
		floor_value.text = ""
		GameManager.fail(reason)
		_check(GameManager.game_state == "FAILED", "GameManager accepted " + reason, failures)
		_check(_failure.visible and reason_label.text == EXPECTED_REASONS[reason],
			"Failure message for " + reason, failures)
		_check(not _help.visible and _failure.get_node("%MenuButton").has_focus(),
			"Failure takes focus from help and keeps menu reachable for " + reason, failures)
		_check(_failure.get_node("%RetryButton").disabled and _failure.get_node("%RetryButton").text.contains("待 A 接入"),
			"Fatal failure cannot retry before a checkpoint restore API exists", failures)
		_check(not _hud.visible and floor_value.text == "1F",
			"GameManager state_changed refreshes the floor and failure hides the HUD", failures)

	_failure.show_failure("STAFF_CAUGHT")
	_check(_failure.get_node("%RetryButton").disabled,
		"Caught employee failure keeps retry unavailable until A supplies checkpoint restore", failures)

	_failure.show_failure("UNKNOWN_REASON")
	_check(reason_label.text == "未能通过检查", "Unknown reason has a Chinese fallback", failures)
	var retry_button: Button = _failure.get_node("%RetryButton")
	var menu_button: Button = _failure.get_node("%MenuButton")
	retry_button.pressed.emit()
	menu_button.pressed.emit()
	get_viewport().push_input(help_key)
	_check(not _help.visible, "Help shortcut stays disabled over failure", failures)
	_check(requests == ["help", "start", "menu"], "Disabled retry emits no request; menu request remains available", failures)
	_check(GameManager.game_state == "FAILED", "Retry/menu only emit requests in this test", failures)

	if failures.is_empty():
		print("PASS: menu and H open/close help, both encyclopedia pages, all three card IDs, five monster rules and confirmed failure IDs.")
		print("PASS: fatal failure display, fallback, disabled retry and menu request.")
		print("PASS: INTRO and RESCUE_309 dialogue text, progression, skip, interact key and completion signals.")
		print("PASS: win screen display and restart/menu request signals without changing game state.")
		print("PASS: HUD initial floor and empty cards, first show, new game, cards_changed and state_changed.")
		print("PASS: mission board reads live task/floor data when available, distinguishes warning/task failure, and keeps retry disabled pending checkpoint API.")
		print("PASS: bag open/close, three owned cards, equip and replace both slots, active identity and HUD refresh, invalid requests and pause state.")
	else:
		for failure: String in failures:
			push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)


func _check_mission_board(failures: Array[String]) -> void:
	var board := preload("res://scenes/ui/mission_board.tscn").instantiate() as MissionBoardScreen
	add_child(board)
	var retried := [false]
	board.retry_requested.connect(func() -> void: retried[0] = true)
	board.refresh_from_game_manager()
	if GameManager.has_method("get_task_view") and GameManager.has_method("get_available_floors"):
		var task_view: Dictionary = GameManager.call("get_task_view")
		var available_floors: Array = GameManager.call("get_available_floors")
		_check(board._task_id == str(task_view.get("task_id", "")), "Board reads the task ID from GameManager", failures)
		for index in board._floor_buttons.size():
			_check(board._floor_buttons[index].disabled == not available_floors.has(index + 1),
				"Floor choices mirror GameManager availability", failures)
	else:
		_check(board._status.text.contains("接口待 A 同步") and board._accept_button.disabled,
			"Board stays unavailable without task and floor APIs", failures)
	board.show_warning("普通违规：请退回等待")
	_check(board._status.text.begins_with("普通警告 ·") and not board._retry_button.visible,
		"Ordinary violation is an inline warning without task-failure controls", failures)
	board.show_task_failure("TASK_TIMEOUT")
	_check(board._status.text.begins_with("任务失败 ·") and board._retry_button.visible and board._retry_button.disabled,
		"Task failure is distinct and retry stays disabled without checkpoint restore", failures)
	board._retry_button.pressed.emit()
	_check(not retried[0], "Disabled retry button sends no request", failures)
	board.queue_free()


func _check_help_content(failures: Array[String]) -> void:
	var work_page: Control = _help.get_node("%WorkCardPage")
	var monster_page: Control = _help.get_node("%MonsterPage")
	for node_name: String in ["SecurityId", "CleanerId", "ManagerId"]:
		_check(not str(work_page.get_node(node_name).text).is_empty(), "Work-card page includes " + node_name, failures)
	for node_name: String in ["SECURITY", "CLEANER", "MANAGER"]:
		var all_text := ""
		for child: Node in work_page.get_children():
			if child is Label:
				all_text += child.text + " "
		_check(all_text.contains(node_name), "Work-card page uses public ID " + node_name, failures)
	_check(work_page.get_node("SecurityRule").text.contains("EYE") and work_page.get_node("SecurityRule").text.contains("独眼客"),
		"SECURITY rule matches EYE", failures)
	_check(work_page.get_node("CleanerRule").text.contains("NOSE") and work_page.get_node("CleanerRule").text.contains("长鼻客"),
		"CLEANER rule matches NOSE", failures)
	_check(work_page.get_node("ManagerRule").text.contains("HAT") and work_page.get_node("ManagerRule").text.contains("礼帽客"),
		"MANAGER rule matches HAT", failures)

	var expected_monsters := {
		"EyeId": "EYE", "NoseId": "NOSE", "HatId": "HAT", "EarId": "EAR", "CheckerId": "CHECKER",
	}
	for node_name: String in expected_monsters:
		_check(monster_page.get_node(node_name).text.contains(expected_monsters[node_name]),
			"Monster page includes public ID " + expected_monsters[node_name], failures)
	_check(monster_page.get_node("EyeRule").text.contains("SECURITY") and monster_page.get_node("EyeRule").text.contains("WRONG_CARD"),
		"EYE rule documents required card and failure ID", failures)
	_check(monster_page.get_node("NoseRule").text.contains("CLEANER") and monster_page.get_node("NoseRule").text.contains("WRONG_CARD"),
		"NOSE rule documents required card and failure ID", failures)
	_check(monster_page.get_node("HatRule").text.contains("MANAGER") and monster_page.get_node("HatRule").text.contains("WRONG_CARD"),
		"HAT rule documents required card and failure ID", failures)
	_check(monster_page.get_node("EarRule").text.contains("MOVED_NEAR_EAR"), "EAR rule documents confirmed failure ID", failures)
	_check(monster_page.get_node("CheckerRule").text.contains("SWITCHED_NEAR_CHECKER"),
		"CHECKER rule documents confirmed failure ID", failures)
	_check(monster_page.get_node("Unconfirmed").text.contains("待确认"), "Unconfirmed edge rules are labeled", failures)


func _check_dialogue(failures: Array[String]) -> void:
	var completed: Array[String] = []
	_dialogue.dialogue_finished.connect(func(dialogue_id: String) -> void: completed.append(dialogue_id))
	var line: Label = _dialogue.get_node("%Line")
	var continue_button: Button = _dialogue.get_node("%ContinueButton")
	var skip_button: Button = _dialogue.get_node("%SkipButton")

	_check(not _dialogue.visible, "Dialogue starts hidden", failures)
	_dialogue.show_dialogue("INTRO")
	_check(_dialogue.visible and line.text == "他们不让我离开……我在309号房。",
		"INTRO starts with the confirmed phone message", failures)
	_check(continue_button.text == "继续" and skip_button.text == "跳过", "Dialogue offers continue and skip", failures)
	continue_button.pressed.emit()
	_check(line.text == "前往 309 房间，营救被困的同伴。", "Continue advances to the confirmed rescue goal", failures)
	continue_button.pressed.emit()
	_check(not _dialogue.visible and completed == ["INTRO"], "Finishing the last line emits INTRO once", failures)

	completed.clear()
	_dialogue.show_dialogue("INTRO")
	skip_button.pressed.emit()
	_check(not _dialogue.visible and completed == ["INTRO"], "Skip ends INTRO and emits completion", failures)

	completed.clear()
	_dialogue.show_dialogue("INTRO")
	var interact_key := InputEventKey.new()
	interact_key.physical_keycode = KEY_E
	interact_key.pressed = true
	get_viewport().push_input(interact_key)
	_check(line.text == "前往 309 房间，营救被困的同伴。", "Mapped E confirms and advances dialogue", failures)
	get_viewport().push_input(interact_key)
	_check(not _dialogue.visible and completed == ["INTRO"], "Mapped E completes INTRO", failures)

	completed.clear()
	_dialogue.show_dialogue("RESCUE_309")
	_check(_dialogue.visible and line.text == "你终于来了！" and _dialogue.get_node("%Speaker").text == "闺蜜",
		"RESCUE_309 shows the confirmed first rescue line", failures)
	continue_button.pressed.emit()
	_check(line.text == "下面的路被封了，五楼有紧急出口！",
		"RESCUE_309 continues to the confirmed route information", failures)
	continue_button.pressed.emit()
	_check(not _dialogue.visible and completed == ["RESCUE_309"],
		"Finishing rescue dialogue emits RESCUE_309 once", failures)

	completed.clear()
	_dialogue.show_dialogue("RESCUE_309")
	skip_button.pressed.emit()
	_check(not _dialogue.visible and completed == ["RESCUE_309"],
		"Skipping rescue dialogue emits RESCUE_309", failures)


func _check_win(failures: Array[String]) -> void:
	var requests: Array[String] = []
	_win.restart_requested.connect(func() -> void: requests.append("restart"))
	_win.return_to_menu_requested.connect(func() -> void: requests.append("menu"))
	var game_state_before: String = GameManager.game_state
	_check(not _win.visible, "Win screen starts hidden", failures)
	_win.show_win()
	_check(_win.visible and _win.get_node("%Title").text == "ESCAPED", "show_win displays the ending", failures)
	_check(_win.get_node("%Ending").text.contains("同伴"), "Win screen confirms both escaped", failures)
	_check(_win.get_node("%StatisticsNote").text.contains("待 A 接入"), "Unavailable statistics are not fabricated", failures)
	var restart_button: Button = _win.get_node("%RestartButton")
	var return_button: Button = _win.get_node("%ReturnButton")
	restart_button.pressed.emit()
	_check(requests == ["restart"], "Restart button emits its request", failures)
	_check(GameManager.game_state == game_state_before, "Restart request does not change game state", failures)
	return_button.pressed.emit()
	_check(requests == ["restart", "menu"], "Return button emits its request", failures)
	_check(GameManager.game_state == game_state_before, "Return request does not change game state", failures)


func _check_bag(failures: Array[String]) -> void:
	var bag_key := InputEventKey.new()
	bag_key.physical_keycode = KEY_I
	bag_key.pressed = true
	var was_paused := get_tree().paused
	var open_button: Button = $UISlot/FailureControls/OpenBag
	var close_button: Button = _bag.get_node("%CloseButton")

	CardManager.reset_for_new_game()
	for card_id: String in ["SECURITY", "CLEANER", "MANAGER"]:
		_check(CardManager.collect_card(card_id), "Test setup collects " + card_id + " through CardManager", failures)
	_check(not _bag.visible, "Bag starts closed", failures)
	open_button.grab_focus()
	get_viewport().push_input(bag_key)
	_check(_bag.visible and close_button.has_focus(), "Mapped I opens bag and transfers focus", failures)
	_check(get_tree().paused == was_paused, "Opening the bag preserves the pause state", failures)

	var owned_cards: ItemList = _bag.get_node("%OwnedCards")
	var slot_a: Label = _bag.get_node("%SlotAValue")
	var slot_b: Label = _bag.get_node("%SlotBValue")
	var equip_a: Button = _bag.get_node("%EquipSlotA")
	var equip_b: Button = _bag.get_node("%EquipSlotB")
	_check(owned_cards.item_count == 3, "Bag displays all three owned cards", failures)
	_check(owned_cards.get_item_metadata(0) == "SECURITY" and owned_cards.get_item_metadata(1) == "CLEANER" and owned_cards.get_item_metadata(2) == "MANAGER",
		"Owned card choices keep their real CardManager IDs", failures)
	_check(equip_a.disabled and equip_b.disabled, "Equipment actions wait for a card selection", failures)
	_check(slot_a.text.contains("保安工作证") and slot_b.text.contains("保洁工作证"), "Bag reads the initially equipped slots", failures)

	# Select the third card and replace slot A, then replace slot B.
	owned_cards.select(2)
	owned_cards.item_selected.emit(2)
	_check(not equip_a.disabled and not equip_b.disabled, "Selecting an owned card enables equipment actions", failures)
	equip_a.pressed.emit()
	_check(CardManager.get_equipped_cards() == ["MANAGER", "CLEANER"], "Equipping MANAGER replaces slot A from the real API", failures)
	_check(slot_a.text.contains("经理工作证") and slot_a.text.contains("生效"), "Bag marks the active equipped card", failures)
	_check(_hud.get_node("%ActiveCardValue").text == "经理工作证", "Successful equip refreshes the HUD active card", failures)
	owned_cards.select(0)
	owned_cards.item_selected.emit(0)
	equip_b.pressed.emit()
	_check(CardManager.get_equipped_cards() == ["MANAGER", "SECURITY"], "Equipping SECURITY replaces slot B", failures)
	_check(slot_b.text.contains("保安工作证"), "Bag refreshes the replaced slot", failures)
	var duplicate_equip_state: Array[String] = CardManager.get_equipped_cards()
	equip_b.pressed.emit()
	_check(_bag.get_node("%Status").text.begins_with("装备失败"), "Bag explains a rejected duplicate equip", failures)
	_check(CardManager.get_equipped_cards() == duplicate_equip_state, "Rejected duplicate equip leaves data unchanged", failures)

	# Switching through CardManager emits cards_changed and refreshes the HUD.
	_check(CardManager.switch_active(), "CardManager accepts active slot switch", failures)
	_check(CardManager.active_slot == 1 and CardManager.active_card == "SECURITY", "Active card follows the real active slot", failures)
	_check(_hud.get_node("%ActiveCardValue").text == "保安工作证", "HUD refreshes after active card switch", failures)
	_check(slot_b.text.contains("生效") and not slot_a.text.contains("生效"), "Bag updates the active slot marker", failures)

	var equipped_before_invalid: Array[String] = CardManager.get_equipped_cards()
	var owned_before_invalid: Array[String] = CardManager.get_owned_cards()
	_check(not CardManager.equip_card("INVALID_CARD", 0), "CardManager rejects an unknown card", failures)
	_check(not CardManager.equip_card("CLEANER", 2), "CardManager rejects an invalid slot", failures)
	_check(CardManager.get_equipped_cards() == equipped_before_invalid and CardManager.get_owned_cards() == owned_before_invalid,
		"Invalid equip requests do not change card data", failures)
	_bag.call("_equip_selected", -1)
	_check(_bag.get_node("%Status").text == "无效的佩戴槽", "Bag explains an invalid slot request", failures)
	_check(CardManager.get_equipped_cards() == equipped_before_invalid, "Bag invalid slot request leaves data unchanged", failures)

	# Clearing rendered values proves CardManager's notification refreshes both views.
	var hud_slot_a: Label = _hud.get_node("%SlotAValue")
	slot_a.text = ""
	hud_slot_a.text = ""
	CardManager.switch_active()
	_check(slot_a.text.contains("生效") and hud_slot_a.text.contains("生效"),
		"cards_changed refreshes both bag and HUD from CardManager", failures)

	close_button.pressed.emit()
	_check(not _bag.visible and open_button.has_focus(), "Close button restores focus", failures)
	open_button.pressed.emit()
	_check(_bag.visible, "Test button reopens the bag", failures)
	get_viewport().push_input(bag_key)
	_check(not _bag.visible, "Mapped I closes the bag", failures)
	_check(get_tree().paused == was_paused, "Closing the bag preserves the pause state", failures)


func _check(condition: bool, description: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(description)
