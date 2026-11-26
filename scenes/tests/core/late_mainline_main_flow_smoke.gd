extends SceneTree
## Formal main scene/B components/E/UI. Earlier tutorial/309 facts, positions,
## staff facing, ordinary door phases and task clock are explicit fixtures.
var failures: Array[String] = []
var game: Node
var cards: Node
var main: Node
var won_count := 0
var prior_cards: Dictionary

func _initialize() -> void:
	create_timer(90).timeout.connect(func() -> void: print("FAIL: late main flow exceeded90 seconds"); quit(1))
	call_deferred("_run")
func _expect(ok: bool, message: String) -> void:
	if not ok: failures.append(message)
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
func _quiet_doors() -> void:
	_floor().get("_door_scheduler").set_process(false)
	for door: Node in _floor().get("_doors"): door.set_managed_state("CLOSED")
func _read_story() -> void:
	for i in range(40):
		if not main.dialogue.visible: return
		await _tap()
	_expect(false, "Story closes with actual input")
func _accept() -> void:
	var board: Control = main.get_node("TaskLayer/MissionBoard")
	_expect(board.visible, "Real task board opens")
	board.get("_accept_button").pressed.emit()
	await _settle()
	_expect(game.get("_open_modals").is_empty(), "Accepting does not auto-open a second reminder dialogue")
func _retry() -> void:
	# Timeout dialogue deliberately precedes the original retry menu.
	var presentation: Node = main.get_node("MenuLayer/Bag/CarolUIFlow")
	for i in range(40):
		if presentation.get("_mode") == "": break
		await _tap()
	_expect(presentation.get("_mode") == "" and main.get_node("TaskLayer/Failure").visible, "Failure dialogue finishes before clicking the visible retry menu")
	main.get_node("TaskLayer/Failure/%RetryButton").pressed.emit()
	await _settle()
	_quiet_doors()
func _patrol() -> Node:
	var staff: Node = _floor().get_node("StaffRoot/PatrolSlot/Staff")
	staff.set_cleaner_behavior_enabled(false) # Freeze the patrol before positioning the theft fixture.
	staff.facing_direction = 1
	for name in ["TurnTimer", "TurnWarningTimer", "BehaviorTimer", "SuspicionTimer"]: staff.get_node(name).stop()
	return staff
func _travel(destination: int) -> void:
	_player().position.x = _floor().get_stair_interaction_center(destination > game.current_floor)
	await _settle()
	_expect(game.request_floor_travel(destination), "Legal stair travel to %dF" % destination)
	await _settle()
	_quiet_doors()
func _capture(name: String) -> void:
	if "--capture" not in OS.get_cmdline_user_args(): return
	await process_frame
	await RenderingServer.frame_post_draw
	var path := OS.get_environment("AE4PA_DELIVERY_EVIDENCE")
	if path.is_empty(): path = "res://docs/qa_evidence/a_late_mainline_20261121/screenshots"
	DirAccess.make_dir_recursive_absolute(path)
	root.get_texture().get_image().save_png(path + "/" + name + ".png")

func _run() -> void:
	var english := "--english" in OS.get_cmdline_user_args()
	if english:
		root.size = Vector2i(960, 540)
	root.get_node("Localization").set_language("en" if english else "zh_CN")
	game = root.get_node("GameManager")
	cards = root.get_node("CardManager")
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await _settle()
	var menu: Control = main.get_node("MenuLayer/MainMenu")
	menu.call("_finish_opening") # This flow smoke starts at gameplay; cover motion has a separate test.
	menu.get_node("%StartButton").pressed.emit()
	main.dialogue._finish()
	game.complete_manager_intro()
	game.set_process(false)
	# Earlier six completions are a disclosed fixture; regression suites cover them.
	game.get("_completed_task_ids").assign(game.TUTORIAL_TASKS + [game.TASK_03_ID])
	game.get("_world_flags").merge({"registration_309_approved": true, "passage_201_unlocked": true, "passage_202_unlocked": true, "passage_203_unlocked": true, "passage_204_unlocked": true, "passage_205_unlocked": true})
	game.current_task_id = game.TASK_03_ID
	game.task_status = "COMPLETED"
	for kind in ["NOSE", "EYE", "HAT", "EAR", "CHECKER"]: game.get("_seen_monsters")[kind] = true
	for card in ["CLEANER", "SECURITY", "MANAGER"]: cards.collect_card(card)
	game._load_floor(3)
	await _settle()
	# Acquisition is collection-only; equip the fixture explicitly at the arrival point.
	_expect(cards.equip_card("CLEANER", 0) and cards.equip_card("SECURITY", 1), "Fixture manually equips the two tutorial slots")
	await _settle()
	# Read it through the normal input path before attempting stair travel.
	var equipment_dialogue: Node = main.get_node("MenuLayer/Bag/CarolUIFlow")
	for i in range(40):
		if equipment_dialogue.get("_mode") != "equipment": break
		await _tap()
	_expect(equipment_dialogue.get("_mode") == "" and equipment_dialogue.get("_tutorial_seen"), "Fixture reads the real two-slot tutorial before stair travel")
	_quiet_doors()
	_expect(not game.get_available_floors().has(4), "Registration alone cannot reach4F")
	_expect(game.rescue_friend(), "Explicit completed-rescue callback fixture")
	_expect("403" in main._task_03_objective(), "Rescue objective points to403 before EXIT")
	prior_cards = cards.export_snapshot()
	await _travel(4)
	await _settle()
	var route_objective: String = main.get_node("TaskLayer/HUD").get_node("%Objective").text
	_expect(("Room 403" in route_objective and "patrol log" in route_objective.to_lower()) if english else ("4F403" in route_objective and "巡房记录" in route_objective), "After the309 rescue, the live story objective points to403")
	var staff: Node = _floor().get_node_or_null("StaffRoot/PatrolSlot/Staff")
	_expect(staff != null, "4F contains actual B patrol component")
	_expect(_floor().get_node("StaffRoot").z_index > _floor().get_node("Floor4Art").z_index, "Patrol staff and its prompts render above opaque floor art")
	_expect(_floor().get_node_or_null("Interactions/Task403AcceptSafe") != null, "403 has a real safe checkpoint")
	if staff == null:
		await _finish()
		return
	staff = _patrol()
	_expect(not staff.is_task_eligible(), "Patrol file cannot be stolen before accepting403")
	var room: Node2D = _floor().get_node("DoorRoot/Room403")
	_player().position.x = room.position.x - 116
	await _settle()
	_expect(main.dialogue.visible and "403" in main.dialogue.get("_dialogue_id"), "403 formal intercept opens actual dialogue")
	await _read_story()
	_expect(game.task_status == "AVAILABLE" and game.remaining_time == 0, "Intro and closing do not start task clock")
	await _accept()
	_expect(game.task_status == "ACTIVE" and game.remaining_time == 120 and game.get("_task_checkpoint").get("floor") == 4, "403 accepts with real checkpoint")
	await _settle()
	var hud_objective: Label = main.get_node("TaskLayer/HUD").get_node("%Objective")
	_expect(hud_objective.text == ("Stand behind the patrol staff member and hold E to take the patrol log." if english else "在巡房员工身后站定，长按E偷取巡房记录。"), "403 HUD shows the live patrol objective in the selected language")
	staff = _patrol()
	var forged: Node = load("res://scenes/staff/patrol_staff_4f.tscn").instantiate()
	_floor()._on_task_item_stolen("PATROL_RECORD", "STAFF_PATROL_4F", forged)
	_floor()._on_task_item_stolen("PATROL_RECORD", "STAFF_PATROL_4F", staff)
	_expect(game.task_status == "ACTIVE" and not game.get_world_flags().get("patrol_collected", false), "External source and unperformed real-source callback cannot forge a file")
	forged.free()
	_player().global_position.x = staff.global_position.x + 40
	await _settle()
	await _tap()
	_expect(game.game_state == "FAILED", "Real front theft fails403")
	await _retry()
	_expect(game.current_floor == 4 and game.task_status == "AVAILABLE" and game.remaining_time == 0, "403 retry returns to untimed offer")
	_expect(game.has_friend and _floor().has_node("Persica") and cards.export_snapshot() == prior_cards, "403 retry retains rescue/follower/cards")
	await _accept()
	staff = _patrol()
	_player().global_position.x = staff.global_position.x - 40
	await _settle()
	await _key("interact", true)
	await create_timer(0.9).timeout
	await _key("interact", false)
	_expect(game.task_status == "READY_TO_SUBMIT" and game.get_world_flags().get("patrol_collected", false), "Real rear hold steals task file")
	await _settle()
	hud_objective = main.get_node("TaskLayer/HUD").get_node("%Objective")
	_expect("403" in hud_objective.text and ("deliver" in hud_objective.text.to_lower() if english else "交付" in hud_objective.text), "403 HUD directs Carol back to Room 403 for delivery")
	_expect(cards.export_snapshot() == prior_cards and not game.get_available_floors().has(5), "File is not a card and no5F before delivery")
	await _capture("patrol_ready")
	game._process(120)
	await _settle()
	await _retry()
	_expect(not game.get_world_flags().get("patrol_collected", false) and _patrol().is_reward_available(), "403 timeout restores stolen file")
	_expect(_player().position == _floor().get_node("Interactions/Task403AcceptSafe").position, "403 retry lands at safe marker")
	await _accept()
	staff = _patrol()
	_player().global_position.x = staff.global_position.x - 40
	await _settle()
	await _key("interact", true)
	await create_timer(0.9).timeout
	await _key("interact", false)
	# Cross-floor revisit retains the file, but failure restores the accepting floor.
	await _travel(3)
	await _travel(4)
	_expect(not _patrol().is_reward_available(), "Collected patrol remains unavailable after revisit")
	var external: Node = load("res://scenes/staff/patrol_staff_4f.tscn").instantiate()
	if _floor().has_method("_on_task_item_stolen"):
		_floor()._on_task_item_stolen("PATROL_RECORD", "STAFF_PATROL_4F", external)
	external.free()
	_player().position.x = _floor().get_node("DoorRoot/Room403").position.x - 50
	await _settle()
	await _tap()
	_expect(game.get_completed_task_ids().has(game.TASK_04_ID) and game.get_available_floors().has(5), "Actual403 E delivery unlocks5F")
	await _settle()
	route_objective = main.get_node("TaskLayer/HUD").get_node("%Objective").text
	_expect(("Room 501" in route_objective and "exit form" in route_objective.to_lower()) if english else ("5F501" in route_objective and "离店单" in route_objective), "After403 delivery, the live story objective points to501")
	await _read_story()
	await _travel(5)
	var register: Node = _floor().get_node_or_null("Interactions/ExitRegister5F")
	_expect(register != null, "5F contains actual B exit register")
	_expect(register != null and register.z_index > _floor().get_node("Floor5Art").z_index, "Exit workstation and hint render above floor art")
	if register == null:
		await _finish()
		return
	_player().position.x = _floor().get_node("DoorRoot/Room501").position.x - 116
	await _settle()
	await _read_story()
	await _accept()
	_expect(game.current_task_id == game.TASK_05_ID and game.remaining_time == 180, "Actual501 offer starts180 seconds")
	await _settle()
	hud_objective = main.get_node("TaskLayer/HUD").get_node("%Objective")
	_expect("Manager" in hud_objective.text if english else "经理" in hud_objective.text, "501 HUD presents the live manager authorization step")
	if english:
		var locked_hint: Label = _floor().exit_hint
		var hint_text := locked_hint.atr(locked_hint.text)
		_expect("501" in hint_text and "deliver" in hint_text.to_lower(), "English EXIT sign explains the outstanding Room 501 delivery")
	_player().global_position = register.global_position
	await _settle()
	await _tap()
	_expect(not register.is_completed() and game.task_status == "ACTIVE", "Wrong current identity refuses exit approval")
	# Real bag replacement and Q prepare current manager in safe work area.
	await _tap("open_bag")
	var bag: Control = main.get_node("MenuLayer/Bag")
	var items: ItemList = bag.get_node("%OwnedCards")
	for i in items.item_count:
		if items.get_item_metadata(i) == "MANAGER":
			items.select(i)
			items.item_selected.emit(i)
	bag.get_node("%EquipSlotB").pressed.emit()
	await _tap("open_bag")
	await _tap()
	_expect(game.task_status == "ACTIVE", "Manager in standby cannot approve")
	await _tap("switch_id")
	await _tap()
	_expect(game.task_status == "READY_TO_SUBMIT" and register.is_completed(), "Actual manager approval needs return501")
	var hud_notice: Label = main.get_node("TaskLayer/HUD").get_node("%Notice")
	var approved_notice := tr("%s已批准。请返回任务房间按E交付。") % tr("501离店授权单")
	_expect(hud_notice.text == approved_notice and hud_notice.tooltip_text == approved_notice, "Successful approval replaces stale wrong-identity feedback with the exact accepted approval/delivery result")
	_expect(register.get_node("TaskItemVisual/ResultFeedback").visible, "Accepted approval also exposes the component result feedback")
	await _settle()
	hud_objective = main.get_node("TaskLayer/HUD").get_node("%Objective")
	_expect("501" in hud_objective.text and ("deliver" in hud_objective.text.to_lower() if english else "交付" in hud_objective.text), "501 HUD directs Carol back to Room 501 before the exit")
	_expect(not game.request_escape(), "Approval alone cannot escape")
	await _capture("exit_approved")
	game._process(180)
	await _settle()
	await _retry()
	_expect(game.has_friend and _floor().has_node("Persica") and game.get_completed_task_ids().has(game.TASK_04_ID), "501 timeout keeps rescue and403 completion")
	_expect(not game.get_world_flags().get("exit_form_approved", false) and not _floor().get_node("Interactions/ExitRegister5F").is_completed() and cards.export_snapshot() == prior_cards, "501 timeout restores register/cards before acceptance")
	_expect(not game.get_available_floors().has(1) and not game.get_available_floors().has(2), "Retry keeps rescued lower floors sealed")
	await _accept()
	register = _floor().get_node("Interactions/ExitRegister5F")
	_player().global_position = register.global_position
	await _settle()
	cards.equip_card("MANAGER", 0) # UI path above covered; this isolates remaining EXIT guards.
	await _tap()
	_player().position.x = _floor().get_node("DoorRoot/Room501").position.x - 50
	await _settle()
	await _tap()
	await _read_story()
	_expect(game.get_world_flags().get("exit_form_delivered", false), "Actual501 E delivers final form")
	await _settle()
	route_objective = main.get_node("TaskLayer/HUD").get_node("%Objective").text
	_expect(("fire exit" in route_objective.to_lower()) if english else ("消防出口" in route_objective), "After501 delivery, the live story objective points to the fire exit")
	_expect(not game.request_escape(), "Far from EXIT cannot win")
	_player().global_position = _floor().exit_point.global_position
	await _settle()
	if english:
		var ready_hint: Label = _floor().exit_hint
		_expect(ready_hint.is_visible_in_tree() and "press e" in ready_hint.atr(ready_hint.text).to_lower() and "Terese" in ready_hint.atr(ready_hint.text), "English EXIT sign explains the escape input after delivery")
	game.set_modal_open("TEST_MODAL", true)
	_expect(not game.request_escape(), "Open modal cannot escape")
	game.set_modal_open("TEST_MODAL", false)
	for flag: String in ["rescue_309_completed", "patrol_delivered", "exit_form_approved", "exit_form_delivered"]:
		game.get("_world_flags")[flag] = false
		_expect(not game.request_escape(), "EXIT rechecks " + flag)
		game.get("_world_flags")[flag] = true
	game.game_won.connect(func() -> void: won_count += 1)
	await _tap()
	_expect(game.game_state == "WON" and won_count == 1, "Real EXIT E wins exactly once")
	_expect(not game.request_escape(), "Repeated escape rejected")
	_expect(main.dialogue.get("_dialogue_id") == "LATE_ENDING", "EXIT opens revised ending dialogue")
	_expect(main.dialogue.get_node("%Background").visible and main.dialogue.get_node("%Background").texture == main.dialogue.BACKGROUNDS.exterior, "rain ending uses the existing exterior background")
	await _read_story()
	var win: Control = main.get_node_or_null("MenuLayer/Win")
	_expect(win != null and win.visible, "Existing D success panel is actually shown")
	await _capture("escaped")
	if win != null:
		var finished_tasks: Array = game.get_completed_task_ids()
		var finished_flags: Dictionary = game.get_world_flags()
		var guide: Node = main.get_node("TaskLayer/TaskMonsterDialogue")
		# Simulate the real full-run playback cache, absent from earlier API fixtures.
		guide.set("_intro_shown", true)
		guide.get("_new_intros")[game.TUTORIAL_03_ID] = true
		win.get_node("%RestartButton").pressed.emit()
		await _settle()
		_expect(game.current_floor == 1 and not game.has_friend and game.get_completed_task_ids().is_empty() and cards.get_owned_cards().is_empty() and not win.visible and not _floor().has_node("Persica"), "Restart clears completed session/follower and starts actual opening")
		_expect(not guide.get("_intro_shown") and guide.get("_new_intros").is_empty(), "Restart clears all previous-session monster dialogue cache")
		main.dialogue._finish()
		game.complete_manager_intro()
		await _travel(2)
		var first: Node = _floor().get_node("DoorRoot/Room201/Door")
		first.set_managed_state("OPEN")
		_player().position.x = first.global_position.x - 116
		await _settle()
		_expect(main.get_node("TaskLayer/MonsterDialogue").visible, "Restart really replays201 introduction")
		# Explicit finished-session fixture isolates the second success-page menu branch.
		main._show_menu()
		main._start_session()
		main.dialogue._finish()
		game.get("_completed_task_ids").assign(finished_tasks)
		game.set("_world_flags", finished_flags)
		game.current_task_id = game.TASK_05_ID
		game.task_status = "COMPLETED"
		game.has_friend = true
		game._load_floor(5)
		await _settle()
		_quiet_doors()
		_player().global_position = _floor().exit_point.global_position
		await _tap()
		await _read_story()
		_expect(win.visible, "Second actual EXIT opens success screen for menu branch")
		win.get_node("%ReturnButton").pressed.emit()
		await _settle()
		_expect(game.game_state == "MENU" and main.menu.visible and not win.visible and not _floor().has_node("Persica") and game.get("_open_modals").is_empty(), "Success return-to-menu clears follower/modal and shows real menu")
	await _finish()

func _finish() -> void:
	if failures.is_empty(): print("PASS: late_mainline_main_flow")
	for message in failures: print("FAIL: ", message)
	main.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
