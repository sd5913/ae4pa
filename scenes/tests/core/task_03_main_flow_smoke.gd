extends SceneTree
## Explicit01/02 completion, staff-facing and door-phase fixtures; real03 UI/B work.
var failures: Array[String] = []
var game: Node
var cards: Node
var main: Node
func _initialize() -> void: call_deferred("_run")
func _expect(ok: bool, message: String) -> void:
	if not ok: failures.append(message)
func _english(text: String, message: String) -> void:
	_expect(not text.is_empty(), message + " is present")
	for i in text.length():
		if text.unicode_at(i) >= 0x4e00 and text.unicode_at(i) <= 0x9fff:
			_expect(false, message + " still contains Chinese")
			return
func _floor() -> Node: return main.get_node("World").get_child(0)
func _player() -> Node2D: return _floor().get_node("Player")
func _settle() -> void:
	for i in range(5): await physics_frame
	await process_frame
func _key(action: String, pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = pressed
	Input.parse_input_event(event)
	await _settle()
func _tap(action: String = "interact") -> void:
	await _key(action, true)
	await _key(action, false)
func _freeze_doors() -> void:
	for child in _floor().get_children():
		if child.get_script() == load("res://scenes/doors/door_scheduler.gd"): child.set_process(false)
	for door in _floor().get("_doors"): door.set_managed_state("CLOSED")
func _travel(floor_number: int) -> void:
	_player().position.x = 3400 if floor_number > game.current_floor else 192
	await _settle()
	_expect(game.request_floor_travel(floor_number), "Validated stair travel to%dF" % floor_number)
	await _settle()
	_freeze_doors()
func _manager() -> Node:
	var staff: Node = _floor().get_node("StaffRoot/ManagerSlot/Staff")
	staff.facing_direction = 1
	staff.patrol_enabled = false
	for name in ["TurnTimer", "TurnWarningTimer", "BehaviorTimer"]: staff.get_node(name).stop()
	return staff
func _capture(name: String) -> void:
	if "--capture" not in OS.get_cmdline_user_args(): return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("/private/tmp/ae4pa-task03-native")
	root.get_texture().get_image().save_png("/private/tmp/ae4pa-task03-native/" + name + ".png")
func _run() -> void:
	game = root.get_node("GameManager")
	cards = root.get_node("CardManager")
	root.get_node("Localization").set_language("zh_CN")
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main.get_node("MenuLayer/MainMenu/%StartButton").pressed.emit()
	main.dialogue._finish()
	game.complete_manager_intro()
	game.set_process(false)
	await _travel(2)
	var board: Control = main.get_node("TaskLayer/MissionBoard")
	game.offer_task("TASK_01_CLEAN")
	board.get("_accept_button").pressed.emit()
	cards.collect_card("CLEANER")
	game.record_work_result("STAIN_201")
	game.submit_task("TASK_01_CLEAN")
	game.offer_task("TASK_02_PARCEL")
	board.get("_accept_button").pressed.emit()
	cards.collect_card("SECURITY")
	cards.switch_active()
	game.record_work_result("PARCEL_CABINET_2F")
	game.submit_task("TASK_02_PARCEL")
	await _travel(3)
	# Explicit prior01/02 encounter history; the setup above completed them via APIs.
	game.get("_seen_monsters")["NOSE"] = true
	game.get("_seen_monsters")["EYE"] = true
	var first_door: Node = _floor().get_node("DoorRoot/Room301/Door")
	first_door.monster_type = "NOSE"
	first_door.set_managed_state("OPEN")
	_player().position.x = first_door.global_position.x - 70
	await _settle()
	_expect(game.get_pending_monster_encounter().get("room_id", "") == "301", "Known3F wrong identity creates a real contact")
	await _tap("switch_id")
	_expect(game.get_pending_monster_encounter().is_empty(), "Correct Q clears known3F contact without restarting201")
	first_door.set_managed_state("CLOSED")
	await _tap("switch_id")
	_player().position.x = 1420
	await _settle()
	_expect(main.get("_active_dialogue_id") == "TASK_03_INTRO" and main.dialogue.visible, "302 opens real03 dialogue before acceptance")
	if main.get("_active_dialogue_id") != "TASK_03_INTRO":
		await _finish()
		return
	root.get_node("Localization").set_language("en")
	await _settle()
	var story_line: Label = main.dialogue.get_node("%Line")
	_english(story_line.atr(story_line.text), "03 English dialogue")
	await _capture("dialogue03")
	for i in range(8):
		if not main.dialogue.visible: break
		await _tap()
	_expect(board.visible and "302" in board.get("_title").text and "240" in board.get("_hint").text and game.remaining_time == 0, "03 panel names302 and240 before clock starts")
	_english(board.get("_hint").text, "03 English task details")
	await _capture("offer03")
	_expect(game.remaining_time == 0, "Language switch does not start03 clock")
	root.get_node("Localization").set_language("zh_CN")
	await _settle()
	board.get("_accept_button").pressed.emit()
	await _settle()
	_expect(game.remaining_time == 240 and game.get("_task_checkpoint").get("floor") == 3, "03 accepts with a real3F checkpoint")
	await _travel(1)
	var manager := _manager()
	_player().global_position.x = manager.global_position.x + 50
	await _settle()
	_expect(_floor().get_interaction_target_id() == "STAFF_MANAGER_1F", "Accepted03 routes E to manager theft rather than conversation")
	await _tap()
	_expect(game.game_state == "FAILED", "Real manager front theft fails03")
	main.get_node("TaskLayer/Failure/%RetryButton").pressed.emit()
	await _settle()
	_freeze_doors()
	_expect(game.current_floor == 3 and absf(_player().position.x - 1320) < 0.1 and game.task_status == "AVAILABLE" and game.remaining_time == 0, "Failure on1F restores3F safe offer without countdown")
	_expect(cards.has_card("CLEANER") and cards.has_card("SECURITY") and not cards.has_card("MANAGER") and game.get_completed_task_ids().has("TASK_02_PARCEL"), "Retry retains01/02 and removes new manager")
	board.get("_accept_button").pressed.emit()
	await _settle()
	await _travel(1)
	manager = _manager()
	_player().global_position.x = manager.global_position.x - 50
	await _settle()
	await _key("interact", true)
	await create_timer(0.9).timeout
	await _key("interact", false)
	_expect(cards.has_card("MANAGER") and cards.get_owned_cards().size() == 3 and "MANAGER" not in cards.get_equipped_cards(), "Real rear theft gives third collected card without replacing slots")
	await _tap("open_bag")
	var bag: Control = main.get_node("MenuLayer/Bag")
	var items: ItemList = bag.get_node("%OwnedCards")
	for i in items.item_count:
		if items.get_item_metadata(i) == "MANAGER":
			items.select(i)
			items.item_selected.emit(i)
	bag.get_node("%EquipSlotA").pressed.emit()
	await _tap("open_bag")
	_expect(cards.active_card == "SECURITY" and cards.get_equipped_cards().has("MANAGER"), "Actual bag equips manager into standby slot")
	await _travel(3)
	var register: Node = _floor().get_node("Interactions/Register309")
	_player().global_position.x = register.global_position.x
	await _settle()
	await _tap()
	_expect(game.task_status == "ACTIVE" and not register.is_completed(), "Standby manager is refused by real register")
	game._process(240)
	await _settle()
	main.get_node("TaskLayer/Failure/%RetryButton").pressed.emit()
	await _settle()
	_freeze_doors()
	_expect(game.current_floor == 3 and not cards.has_card("MANAGER") and not game.get_world_flags().get("registration_309_approved",false), "03 timeout restores safe3F and revokes new card/approval")
	board.get("_accept_button").pressed.emit()
	await _settle()
	# Explicit card fixture after real theft/bag above, to isolate work settlement.
	cards.collect_card("MANAGER")
	cards.equip_card("MANAGER",0)
	cards.switch_active()
	register = _floor().get_node("Interactions/Register309")
	_player().position.x = register.position.x
	await _settle()
	_floor().call("_on_work_requested", "STAIN_201", register)
	var external: Node = load("res://scenes/work/register_309.tscn").instantiate()
	_floor().call("_on_work_requested", "REGISTER_309", external)
	external.free()
	_expect(game.task_status == "ACTIVE", "Wrong target and external work sources cannot settle03")
	await _tap()
	_expect(register.is_completed() and game.task_status == "COMPLETED" and game.remaining_time == 0 and game.get_world_flags().get("registration_309_approved",false), "Real E at current-manager register immediately completes03 with stopped clock")
	_expect(not register.get_node("PersistentVisual").visible and _floor().get_node("Floor3Art/Furniture/registration_desk_10").visible, "Only the formal desk is visible")
	_expect(_floor().get_node("Floor3Art/Doors/Room309").get("state") == "OPEN", "Approval opens the actual309 visual before rescue")
	_player().position.x = 3023.4375
	await _settle()
	await _tap()
	_expect(not game.has_friend and not game.get_available_floors().has(4) and main.get("_active_dialogue_id").is_empty(), "E at309 does not present placeholder story or fake rescue/4F")
	root.get_node("Localization").set_language("en")
	await _settle()
	_english(main.get_node("TaskLayer/HUD/%Objective").text, "03 English completion HUD")
	await _capture("approved309")
	root.get_node("Localization").set_language("zh_CN")
	await _settle()
	await _travel(1)
	await _travel(3)
	_expect(_floor().get_node("Interactions/Register309").is_completed() and cards.has_card("MANAGER"), "03 approval persists across real revisits")
	# Explicit domain callback fixture only: no incomplete D story is presented as final.
	_player().position.x = 3023.4375
	_expect(game.rescue_friend(), "Guarded rescue-finished fixture settles after03")
	_player().position.x = 192
	_expect(not game.get_available_floors().has(1) and not game.get_available_floors().has(2) and not game.request_floor_travel(1) and not game.request_floor_travel(2), "Rescue blocks stale lower-floor requests as well as choices")
	_expect(game.get_available_floors().has(4), "Legitimate rescue fact opens normal4F access")
	await _finish()
func _finish() -> void:
	main.queue_free()
	await process_frame
	game.set_process(true)
	for message in failures: printerr("FAIL: ", message)
	print("TASK_03_MAIN_FLOW: PASS" if failures.is_empty() else "TASK_03_MAIN_FLOW: FAIL")
	quit(0 if failures.is_empty() else 1)
