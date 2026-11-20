extends SceneTree
## 201 setup/travel/clock/staff facing are explicit fixtures; 202 uses real UI/B/C events.
var failures: Array[String] = []
var main: Node
var game: Node
var cards: Node

func _initialize() -> void:
	call_deferred("_run")

func _expect(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)

func _settle() -> void:
	for i in range(5):
		await physics_frame
	await process_frame

func _key(action: String, pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = pressed
	Input.parse_input_event(event)
	await _settle()

func _tap(action: String = "interact") -> void:
	await _key(action,true)
	await _key(action,false)

func _floor() -> Node:
	return main.get_node("World").get_child(0)

func _player() -> Node2D:
	return _floor().get_node("Player")

func _run() -> void:
	game = root.get_node("GameManager")
	cards = root.get_node("CardManager")
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	main.dialogue._finish() # Explicit prologue fixture still uses D's real finish event.
	game.complete_manager_intro()
	game.set_process(false)
	_player().position.x = 3400
	_expect(game.request_floor_travel(2), "Fixture reaches2F through validated stair")
	_expect(_floor().get_node("StaffRoot").get_child_count() == 0, "No card staff on2F")
	_player().position.x = 580
	await _settle()
	await _read_monster_dialogue()
	var board = main.get_node("TaskLayer/MissionBoard")
	board._accept_button.pressed.emit()
	await _settle()
	_player().global_position.x = _floor().get_node("DoorRoot/Room202").global_position.x - 110
	await _settle()
	_expect(game.current_task_id == "TASK_01_CLEAN" and game.task_status == "ACTIVE" and main.get("_active_dialogue_id").is_empty(), "Early202 contact cannot overwrite active201 or start dialogue")
	cards.collect_card("CLEANER")
	game.record_work_result("STAIN_201")
	_player().global_position.x = _floor().get_node("DoorRoot/Room201").global_position.x
	await _settle()
	await _tap()
	_expect(game.task_status == "COMPLETED", "Real201 delivery precedes202")
	await _read_monster_dialogue()
	_player().global_position.x = _floor().get_node("DoorRoot/Room202").global_position.x - 110
	await _settle()
	_expect(main.get("_active_dialogue_id") == "TASK_02_INTRO" and main.get_node("TaskLayer/MonsterDialogue").visible, "202 opens real monster dialogue before accepting")
	if main.get("_active_dialogue_id") != "TASK_02_INTRO":
		await _finish()
		return
	var before: float = game.remaining_time
	game._process(10)
	_expect(game.remaining_time == before and not game.is_world_input_allowed(), "202 dialogue freezes world and task clock")
	for i in range(8):
		if main.get("_active_dialogue_id").is_empty():
			break
		await _tap()
	_expect(board.visible and game.current_task_id == "TASK_02_PARCEL" and game.task_status == "AVAILABLE" and game.remaining_time == 0, "Dialogue finish opens actual202 offer without starting time")
	_expect("202" in board.get("_title").text and "180" in board.get("_hint").text, "202 title and real limit replace stale201 details")
	board.hide()
	await _tap()
	_expect(board.visible and main.get("_active_dialogue_id").is_empty(), "E reopens202 offer without replaying intro")
	board._accept_button.pressed.emit()
	await _settle()
	_expect(game.task_status == "ACTIVE" and game.remaining_time == 180 and game.get_pending_monster_encounter().is_empty(), "Real acceptance starts202 and resolves its own contact")
	await _tap("pause")
	game._process(10)
	_expect(game.remaining_time == 180 and not game.is_world_input_allowed(), "Real202 pause freezes its clock")
	main.get_node("TaskLayer/PlayOverlay").get("_close").pressed.emit()
	await _settle()
	Input.action_press("move_right")
	await create_timer(2.6).timeout
	Input.action_release("move_right")
	await _settle()
	_expect(_player().position.x <= 1476.1, "Undelivered202 blocks the rear corridor while leaving guard/cabinet reachable")
	var parcel = _floor().get_node("Interactions/ParcelCabinet2F")
	_player().global_position.x = parcel.global_position.x
	await _settle()
	await _tap()
	_expect(not parcel.is_completed() and not game.get_world_flags().get("parcel_collected",false), "Current cleaner cannot pick parcel")
	await _steal_security()
	_expect(cards.has_card("SECURITY") and cards.active_card == "CLEANER", "Real1F rear theft gives standby security without switching identity")
	parcel = _floor().get_node("Interactions/ParcelCabinet2F")
	await _tap("switch_id")
	_expect("Q" not in main.objective_label.text and "Q" not in main.get_node("TaskLayer/HUD/%Objective").text, "An already active security card is not told to switch back")
	_player().global_position.x = parcel.global_position.x
	await _settle()
	await _tap()
	_expect(game.task_status == "READY_TO_SUBMIT" and parcel.is_completed(), "Real security E pickup reaches ready-to-deliver")
	_expect(not parcel.get_node("ItemVisual").visible and _floor().get_node("Floor2Art/InteractiveProps/PackageCabinet").visible, "Reward disappears while formal cabinet remains")
	await _travel(1)
	await _travel(2)
	_expect(_floor().get_node("Interactions/ParcelCabinet2F").is_completed() and game.task_status == "READY_TO_SUBMIT" and cards.has_card("SECURITY"), "Real stair revisit retains parcel and card without reoffering")
	# Actual front theft failure is covered after restoring an acceptance checkpoint.
	game._process(180)
	await _settle()
	var failure = main.get_node("TaskLayer/Failure")
	_expect(failure.visible and game.task_status == "FAILED", "Parcel-not-delivered timeout opens real failure UI")
	_expect("202" in failure.get_node("%RetryButton").tooltip_text, "Retry feedback names202")
	failure.get_node("%RetryButton").pressed.emit()
	await _settle()
	_expect(board.visible and game.task_status == "AVAILABLE" and game.remaining_time == 0, "202 retry returns to offer without auto-countdown")
	_expect(game.current_floor == 2 and absf(_player().global_position.x - 1070.0) < 0.1, "Retry uses202's safe acceptance point, not201's")
	_expect(cards.has_card("CLEANER") and not cards.has_card("SECURITY") and game.get_world_flags().get("stain_201_cleaned",false) and game.get_world_flags().get("passage_201_unlocked",false), "202 rollback retains201 but removes new security")
	_expect(not game.get_world_flags().get("parcel_collected",false) and not _floor().get_node("Interactions/ParcelCabinet2F").is_completed(), "Retry restores parcel")
	board._accept_button.pressed.emit()
	await _settle()
	await _travel(1)
	var guard = _floor().get_node("StaffRoot/SecuritySlot/Staff")
	_freeze_guard(guard)
	_player().global_position.x = guard.global_position.x + 50
	await _settle()
	await _tap()
	_expect(game.task_status == "FAILED" and game.fail_reason == "STAFF_CAUGHT", "Real front security E fails task02")
	failure.get_node("%RetryButton").pressed.emit()
	await _settle()
	_expect(game.get_completed_task_ids() == ["TASK_01_CLEAN"] and cards.has_card("CLEANER"), "Caught retry also retains01")
	board._accept_button.pressed.emit()
	await _settle()
	await _steal_security()
	await _tap("switch_id")
	parcel = _floor().get_node("Interactions/ParcelCabinet2F")
	_player().global_position.x = parcel.global_position.x
	await _settle()
	await _tap()
	for child in _floor().get_children():
		if child.get_script() == load("res://scenes/doors/door_scheduler.gd"):
			child.set_process(false)
	_floor().get_node("DoorRoot/Room202/Door").set_managed_state("OPEN")
	_player().global_position.x = _floor().get_node("DoorRoot/Room202").global_position.x
	await _settle()
	_expect("202" in main.notice_label.text and "201" not in main.notice_label.text, "Returning with parcel gives202 delivery feedback, not stale201 cleaning text")
	await _tap()
	_expect(game.task_status == "COMPLETED" and game.get_world_flags().get("parcel_delivered",false) and game.get_available_floors().has(3), "Real202 E delivery unlocks3F")
	await _read_monster_dialogue()
	# Exercise actual blocking and Q recovery at each remaining normal door.
	for room in ["203","204","205"]:
		for door in _floor().get("_doors"):
			door.set_managed_state("CLOSED")
		var kind: String = "EYE" if room == "204" else "NOSE"
		var wrong_card: String = "CLEANER" if kind == "EYE" else "SECURITY"
		if cards.active_card != wrong_card:
			await _tap("switch_id")
		var door = _floor().get_node("DoorRoot/Room"+room+"/Door")
		door.monster_type = kind # Both existing2F kinds, already taught by201/202.
		door.set_managed_state("OPEN")
		_player().global_position.x = door.global_position.x - 70
		await _settle()
		_expect(game.get_pending_monster_encounter().get("room_id","") == room, "Wrong current identity retains normal contact at"+room)
		_expect("等待聊天" not in main.notice_label.text and ("保安" in main.notice_label.text if kind == "EYE" else "保洁" in main.notice_label.text), "Known contact explains the actual identity instead of waiting for unimplemented dialogue")
		await _tap("switch_id")
		_expect(game.get_pending_monster_encounter().is_empty() and main.get("_active_dialogue_id").is_empty(), "Correct Q identity resolves known contact without repeating introduction")
		Input.action_press("move_right")
		await create_timer(0.9).timeout
		Input.action_release("move_right")
		await _settle()
		_expect(_player().global_position.x > door.global_position.x + 24, "Player physically passes known normal door"+room)
	Input.action_press("move_right")
	for i in range(300):
		await physics_frame
		if _player().position.x >= 3370:
			break
	Input.action_release("move_right")
	await _settle()
	await _travel(3,false)
	await _settle()
	_expect(game.current_floor == 3 and game.current_task_id == "TASK_02_PARCEL" and game.can_offer_task("TASK_03_AUTHORIZE") and not game.offer_task("TASK_04_PATROL"), "3F arrival preserves02, makes authorized03 available at its own trigger, and still rejects04")
	_player().position.x = 192
	_expect(game.request_floor_travel(2), "3F can revisit2F")
	await _settle()
	_expect(_floor().get_node("Interactions/ParcelCabinet2F").is_completed() and cards.has_card("SECURITY"), "Revisit does not respawn reward or lose identity")
	await _finish()

func _travel(destination: int, position_fixture: bool = true) -> void:
	if position_fixture:
		_player().position.x = 3400 if destination > game.current_floor else 192
		await _settle()
	await _tap()
	var overlay = main.get_node("TaskLayer/PlayOverlay")
	_expect(overlay.visible, "Real stair E opens destination selection")
	for button in overlay.get("_choices").get_children():
		if button.text == "%dF" % destination:
			button.pressed.emit()
			break
	await _settle()
	_expect(game.current_floor == destination and not overlay.visible, "Real destination button travels to%dF" % destination)

func _freeze_guard(guard: Node) -> void:
	guard.facing_direction = 1
	guard.patrol_enabled = false
	for name in ["TurnTimer","TurnWarningTimer","BehaviorTimer"]:
		guard.get_node(name).stop()

func _steal_security() -> void:
	await _travel(1)
	var guard = _floor().get_node("StaffRoot/SecuritySlot/Staff")
	if guard.is_suspicious():
		await guard.get_node("SuspicionTimer").timeout
	_freeze_guard(guard)
	_player().global_position.x = guard.global_position.x - 50
	await _settle()
	await _key("interact",true)
	await create_timer(0.9).timeout
	await _key("interact",false)
	await _travel(2)

func _read_monster_dialogue() -> void:
	var screen: Control = main.get_node("TaskLayer/MonsterDialogue")
	for i in range(80):
		if not screen.visible: return
		await _tap()
	_expect(false, "Monster dialogue closes after real E input")

func _finish() -> void:
	main.queue_free()
	await process_frame
	game.set_process(true)
	for message in failures:
		printerr("FAIL: ",message)
	print("TASK_02_MAIN_FLOW: ","PASS" if failures.is_empty() else "FAIL")
	quit(0 if failures.is_empty() else 1)
