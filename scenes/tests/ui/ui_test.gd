extends Node2D
## F6 opens the manual test. Pass -- --ui-smoke to check the same scene headlessly.

const MainMenuScreen = preload("res://scenes/ui/main_menu.gd")
const HelpScreen = preload("res://scenes/ui/help.gd")
const FailureScreen = preload("res://scenes/ui/failure.gd")
const BagScreen = preload("res://scenes/ui/bag.gd")

const EXPECTED_REASONS := {
	"STAFF_CAUGHT": "偷窃被发现",
	"WRONG_CARD": "当前工作证不符合要求",
	"MOVED_NEAR_EAR": "大耳客开门时仍在移动",
	"SWITCHED_NEAR_CHECKER": "核验客面前更换了工作证",
}

@onready var _menu: MainMenuScreen = $UISlot/MainMenu
@onready var _help: HelpScreen = $UISlot/Help
@onready var _bag: BagScreen = $UISlot/Bag
@onready var _failure: FailureScreen = $UISlot/Failure
@onready var _hud: Control = $UISlot/HUD
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
	GameManager.state_changed.connect(_update_overlay_shortcuts.unbind(1))
	_help.visibility_changed.connect(_update_overlay_shortcuts)
	_bag.visibility_changed.connect(_update_overlay_shortcuts)
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
		_check(not _help.visible and _failure.get_node("%RetryButton").has_focus(),
			"Failure takes focus from help for " + reason, failures)
		_check(not _hud.visible and floor_value.text == "1F",
			"GameManager state_changed refreshes the floor and failure hides the HUD", failures)

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
		print("PASS: HUD initial floor and empty cards, first show, new game, cards_changed and state_changed.")
		print("PASS: bag open/close, three owned cards, equip and replace both slots, active identity and HUD refresh, invalid requests and pause state.")
	else:
		for failure: String in failures:
			push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)


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
