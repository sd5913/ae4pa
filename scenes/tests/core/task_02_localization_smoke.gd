extends SceneTree
## Explicit 201 completion and direct 202 dialogue fixtures; no human acceptance claim.
var failures: Array[String] = []
var game: Node
var cards: Node
var main: Node
var localization: Node

func _initialize() -> void:
	call_deferred("_run")

func _expect(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)

func _english(text: String, message: String) -> void:
	_expect(not text.is_empty(), message + " is not empty")
	for i in text.length():
		if text.unicode_at(i) >= 0x4e00 and text.unicode_at(i) <= 0x9fff:
			_expect(false, message + " contains untranslated Chinese: " + text)
			return

func _switch(locale: String) -> void:
	var task: Dictionary = game.get_task_view().duplicate(true)
	var flags: Dictionary = game.get_world_flags().duplicate(true)
	var checkpoint: Dictionary = game.get("_task_checkpoint").duplicate(true)
	var card_state: Dictionary = cards.export_snapshot()
	var line_index: int = main.dialogue.get("_line_index")
	localization.set_language(locale)
	await process_frame
	await process_frame
	_expect(game.get_task_view() == task and game.get_world_flags() == flags and game.get("_task_checkpoint") == checkpoint and cards.export_snapshot() == card_state and main.dialogue.get("_line_index") == line_index,
		"Language switch preserves task, time, world, checkpoint, cards and dialogue position")

func _run() -> void:
	game = root.get_node("GameManager")
	cards = root.get_node("CardManager")
	localization = root.get_node("Localization")
	localization.set_language("zh_CN")
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	main.dialogue._finish() # Explicit intro fixture.
	game.complete_manager_intro()
	game.set_process(false)
	var floor_node: Node = main.get_node("World").get_child(0)
	floor_node.player.global_position = floor_node.exit_point.global_position
	_expect(game.request_floor_travel(2), "Fixture reaches real2F")
	await process_frame
	var board: Control = main.get_node("TaskLayer/MissionBoard")
	_expect(game.offer_task(game.TASK_01_ID), "Fixture offers201")
	_drain_monster()
	board.get("_accept_button").pressed.emit()
	cards.collect_card("CLEANER")
	_expect(game.record_work_result("STAIN_201") and game.submit_task(game.TASK_01_ID), "Explicit201 completion fixture")
	_drain_monster()
	main.call("_show_story_dialogue", "TASK_02_INTRO")
	var monster: Control = main.get_node("TaskLayer/MonsterDialogue")
	_expect(monster.visible and monster.get("_id") == "EYE:INTRO", "202 uses D actual on-site panel")
	var cjk_font: Font = load("res://assets/final/fonts/hotel_staff_cjk.otf")
	for row: Array in monster.get("_lines"):
		for i in row[1].length():
			var code: int = row[1].unicode_at(i)
			if code >= 0x4e00 and code <= 0x9fff: _expect(cjk_font.has_char(code), "Bundled font covers D202 dialogue")
	monster.advance()
	var line_index: int = monster.get("_index")
	var text: String = monster.get("_body").text
	await _switch("en")
	_expect(monster.get("_index") == line_index and monster.get("_body").text == text, "Locale switching preserves D Chinese narrative (English narrative not delivered)")
	_drain_monster()
	await process_frame
	_expect(board.visible and game.current_task_id == game.TASK_02_ID and game.remaining_time == 0, "Translated dialogue still opens202 offer without time")
	_english(board.get("_hint").text, "202 offer details")
	_expect("180" in board.get("_hint").text and "202" in board.get("_title").text, "202 offer preserves actual limit and room")
	_english(board.get("_title").text, "202 offer title")
	await _switch("zh_CN")
	_expect("保安" in board.get("_hint").text, "Open offer returns to Chinese")
	await _switch("en")
	_english(board.get("_hint").text, "Open offer refreshes in English")
	board.get("_accept_button").pressed.emit()
	await process_frame
	var hud: Control = main.get_node("TaskLayer/HUD")
	_english(hud.get_node("%Objective").text, "202 active objective")
	_english(hud.get_node("%RemainingTime").text, "202 timer and status")
	_expect("3:00" in hud.get_node("%RemainingTime").text, "202 timer uses the shared minute format")
	_english(main.objective_label.text, "202 developer objective")
	cards.collect_card("SECURITY")
	await _switch("zh_CN")
	_expect("Q" in hud.get_node("%Objective").text, "Standby security still needs switching")
	cards.switch_active()
	await _switch("en")
	_english(hud.get_node("%Objective").text, "202 active-security objective")
	_expect("Q" not in hud.get_node("%Objective").text, "Active security is not told to switch again")
	_expect(game.record_work_result("PARCEL_CABINET_2F"), "Real task API records parcel")
	await process_frame
	_english(hud.get_node("%Objective").text, "202 parcel return objective")
	game._process(180)
	await process_frame
	var failure: Control = main.get_node("TaskLayer/Failure")
	_expect(failure.visible, "202 timeout shows actual failure UI")
	_english(failure.get_node("%RetryButton").atr(failure.get_node("%RetryButton").tooltip_text), "202 retry explanation")
	_expect("201" in failure.get_node("%RetryButton").tooltip_text and "202" in failure.get_node("%RetryButton").tooltip_text, "Retry explanation preserves both task references")
	await _switch("zh_CN")
	failure.get_node("%RetryButton").pressed.emit()
	await _switch("en")
	_expect(game.task_status == "AVAILABLE" and cards.has_card("CLEANER") and not cards.has_card("SECURITY"), "Translated retry retains201 and rolls back202")
	_english(board.get("_hint").text, "202 retry offer")
	board.get("_accept_button").pressed.emit()
	cards.collect_card("SECURITY")
	cards.switch_active()
	_expect(game.record_work_result("PARCEL_CABINET_2F") and game.submit_task(game.TASK_02_ID), "Retried202 can still deliver")
	await _switch("zh_CN")
	_expect("203" in main.objective_label.text and "203" in hud.get_node("%Objective").text, "Completion announces next2F tutorial in real HUD")
	await _switch("en")
	_english(hud.get_node("%Objective").text, "202 completed objective")
	_english(main.objective_label.text, "202 completed developer objective")
	_expect(not game.get_available_floors().has(3) and game.can_offer_task("TASK_T03_ROOM_SERVICE"), "Translated completion advances to203 before3F")
	localization.set_language("zh_CN")
	main.queue_free()
	await process_frame
	for message in failures:
		printerr("FAIL: ", message)
	print("TASK_02_LOCALIZATION: PASS" if failures.is_empty() else "TASK_02_LOCALIZATION: FAIL")
	quit(0 if failures.is_empty() else 1)

func _drain_monster() -> void:
	var monster: Control = main.get_node("TaskLayer/MonsterDialogue")
	for i in range(80):
		if not monster.visible: return
		monster.advance()
