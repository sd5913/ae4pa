extends SceneTree

const DEFAULT_SAVE_ROOT := "user://memory_cross_process_smoke_20261124"
var _main: Node
var _game: Node
var _cards: Node
var _service: Node
var _passed := true
var _history: Script
var _ui: Node
var _save_root := OS.get_environment("AE4PA_MEMORY_SAVE_ROOT")
var _evidence := OS.get_environment("AE4PA_MEMORY_EVIDENCE")

func _initialize() -> void:
	run.call_deferred()

func _check(condition: bool, label: String) -> void:
	if not condition:
		_passed = false
		push_error("MEMORY_CROSS_PROCESS: " + label)

func _settle() -> void:
	for _i in range(3): await process_frame

func _ready_for_capture() -> void:
	_main.get_node("TaskLayer/MonsterDialogue").cancel_dialogue()
	_main.dialogue.cancel_presentation()
	_game.set_modal_open("STORY_DIALOGUE", false)
	_game.set_modal_open("LATE_TASK_STORY", false)
	await _settle()

func _save_slot(slot_id: int, label: String) -> void:
	await _ready_for_capture()
	var result: Dictionary = _service.save_memory(slot_id)
	_check(result.get("ok", false), "%s saved: %s" % [label, str(result)])

func _load_slot(slot_id: int, label: String) -> void:
	var result: Dictionary = _service.load_memory(slot_id)
	_check(result.get("ok", false), "%s loaded: %s" % [label, str(result)])

func _slot_zero_files() -> Dictionary:
	var snapshot := {}
	var directory := DirAccess.open(_save_root)
	if directory == null:
		return snapshot
	for filename: String in directory.get_files():
		if filename == "manual_0.json" or filename.begins_with("manual_0.json.gen_") and filename.ends_with(".json"):
			snapshot[filename] = FileAccess.get_file_as_string(_save_root.path_join(filename))
	return snapshot

func _shot(name: String) -> void:
	if _evidence.is_empty() or DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	var language := "en960" if OS.get_cmdline_user_args().has("--english") else "zh1280"
	_check(root.get_texture().get_image().save_png(_evidence.path_join(language + "_" + name + ".png")) == OK, "screenshot " + name)

func _hold_evidence() -> void:
	if not _evidence.is_empty(): await create_timer(1.25).timeout

func _move_floor(floor_number: int) -> void:
	_game.call("_load_floor", floor_number, false, true)
	await _settle()
	await _ready_for_capture()

func _offer_and_accept(task_id: String) -> void:
	_check(_game.offer_task(task_id), "%s offered" % task_id)
	_check(_game.accept_task(task_id), "%s checkpoint accepted" % task_id)

func run() -> void:
	_game = root.get_node("GameManager")
	_cards = root.get_node("CardManager")
	_history = load("res://scenes/ui/memory_history.gd")
	var english := OS.get_cmdline_user_args().has("--english")
	TranslationServer.set_locale("en" if english else "zh_CN")
	root.size = Vector2i(960, 540) if english else Vector2i(1280, 720)
	_main = load("res://scenes/main.tscn").instantiate()
	root.add_child(_main)
	await _settle()
	_game.set_process(false)
	_ui = _main.get_node("MenuLayer/MainMenu/MemoryUI")
	_service = _main.get_node("MemoryService")
	if _save_root.is_empty():
		_save_root = DEFAULT_SAVE_ROOT
	_service.storage_root = _save_root
	var load_mode := OS.get_cmdline_user_args().has("--load")
	if load_mode:
		await _run_load_phase()
	else:
		_main._start_session()
		await _ready_for_capture()
		await _run_save_phase()
	print("MEMORY_CROSS_PROCESS_%s: %s" % ["LOAD" if load_mode else "SAVE", "PASS" if _passed else "FAIL"])
	quit(0 if _passed else 1)

func _run_save_phase() -> void:
	_game.call("_load_floor", 2, false, true)
	await _ready_for_capture()
	_game.set("_manager_intro_finished", true)
	var flow: Node = _main.get_node("MenuLayer/Bag/CarolUIFlow")
	flow.set("_tutorial_seen", true)
	_check(_cards.collect_card("SECURITY"), "security credential collected")
	_check(_cards.collect_card("CLEANER"), "cleaner credential collected")
	_check(_cards.equip_card("SECURITY", 0), "security manually equipped")
	_check(_cards.equip_card("CLEANER", 1), "cleaner manually equipped")
	_check(_cards.switch_active(), "current identity switched to cleaner")
	_floor().get_node("Player").restore_stamina_state({"value": 62.0, "rest": 0.25, "exhausted": false})
	await _offer_and_accept(_game.TASK_01_ID)
	await _ready_for_capture()
	_game.remaining_time = 123.25
	_game.play_time_seconds = 42.5
	_main.get_node("TaskLayer").play_overlay.toggle_pause()
	_ui.open("save")
	_floor().get_node("Player").restore_stamina_state({"value": 18.0, "rest": 0.7, "exhausted": true})
	await _shot("save")
	await _hold_evidence()
	_ui._request_action()
	if _ui._confirm.visible: _ui._confirm.confirmed.emit(); _ui._confirm.hide()
	_check(_ui._status.text == _ui.tr("记忆已保存"), "real pause UI saved slot 0")
	await _shot("saved")
	await _hold_evidence()
	var original := _slot_zero_files()
	_ui._request_action()
	_check(_ui._confirm.visible, "overwrite prompts for confirmation")
	_ui._confirm.canceled.emit()
	_ui._confirm.hide()
	_check(_slot_zero_files() == original, "cancel preserves previous save")
	_ui.close_page()
	_main.get_node("TaskLayer").play_overlay.close_page()
	_check(_cards.get_equipped_cards() == ["SECURITY", "CLEANER"] and _cards.active_card == "CLEANER", "two-slot combination is captured")
	_check(_game.record_work_result("STAIN_201"), "201 work is completed without hand-in")
	await _save_slot(1, "201 work completed but not delivered")

	await _move_floor(3)
	_game.get("_completed_task_ids").assign([_game.TASK_01_ID, _game.TASK_02_ID, _game.TUTORIAL_03_ID, _game.TUTORIAL_04_ID, _game.TUTORIAL_05_ID])
	_game.current_task_id = _game.TUTORIAL_05_ID
	_game.task_status = "COMPLETED"
	_game.remaining_time = 0.0
	_game.get("_world_flags")["passage_201_unlocked"] = true
	_game.get("_world_flags")["parcel_delivered"] = true
	_game.get("_world_flags")["room_service_203_approved"] = true
	_game.get("_world_flags")["tutorial_patrol_collected"] = true
	_game.get("_world_flags")["transit_205_approved"] = true
	_check(_cards.collect_card("MANAGER"), "manager credential collected")
	_check(_cards.equip_card("MANAGER", 0), "manager replaces first-slot credential")
	if _cards.active_card != "MANAGER": _cards.switch_active()
	await _offer_and_accept(_game.TASK_03_ID)
	_check(_game.record_work_result("REGISTER_309"), "309 registration is approved through A task API")
	await _save_slot(2, "309 rescue before settlement")
	_check(not _game.has_friend and not _floor().has_node("Persica"), "pre-rescue save has no follower")
	_cards.switch_active()
	var reunion := _main.get_node("Room309Reunion")
	reunion.open_reunion()
	await create_timer(1.0).timeout
	_check(is_instance_valid(reunion.cg) and not _game.has_friend, "actual 309 CG opens without settling rescue")
	_check(not _service.can_save_memory().allowed, "309 CG blocks saves")
	await _shot("309")
	for index in range(36):
		if not is_instance_valid(reunion.cg): break
		while reunion.cg.get("_transitioning") or reunion.cg.get("_displayed_index") != reunion.cg.get("_index"):
			await process_frame
		_check(_history.entries.filter(func(entry): return entry.chapter == "309_REUNION").size() == index + 1, "exactly one historical record per displayed beat")
		_check(not _game.has_friend, "recording does not settle rescue")
		reunion.cg.advance()
	_check(_game.has_friend, "actual 309 CG completion settles rescue")
	_cards.switch_active()
	await _ready_for_capture()
	await _save_slot(3, "309 rescue after settlement")
	_check(_game.has_friend and _floor().has_node("Persica"), "post-rescue world has its follower")

	await _move_floor(4)
	await _offer_and_accept(_game.TASK_04_ID)
	_game.remaining_time = 91.5
	_check(_game.record_task_item_result("PATROL_RECORD", "STAFF_PATROL_4F"), "403 record is acquired but not delivered")
	await _save_slot(4, "403 progress before delivery")

	_check(_game.submit_task(_game.TASK_04_ID), "403 record delivered")
	await _move_floor(5)
	await _offer_and_accept(_game.TASK_05_ID)
	if _cards.active_card != "MANAGER": _cards.switch_active()
	_check(_game.record_work_result("EXIT_REGISTER_5F"), "501 exit form approved")
	_check(_game.submit_task(_game.TASK_05_ID), "501 exit form delivered")
	await _ready_for_capture()
	_floor().get_node("Player").global_position = _floor().get_node("Interactions/ExitPoint").global_position
	_check(_game.can_escape(), "real EXIT requirements pass after delivery")
	await _save_slot(5, "501 delivered at real EXIT")
	_check(_service.list_memory_slots().any(func(slot): return slot.slot_id == -1 and slot.status == "VALID"), "stable progression writes the automatic slot")

func _run_load_phase() -> void:
	var before := _slot_zero_files()
	_main._start_session()
	await _ready_for_capture()
	_check(not before.is_empty() and _slot_zero_files() == before, "new game preserves existing slots")
	_main._show_menu()
	_ui.open("load")
	await _shot("load")
	await _hold_evidence()
	_ui._request_action()
	_check(_ui._confirm.visible, "load prompts for confirmation")
	_ui._confirm.confirmed.emit()
	_ui._confirm.hide()
	_check(not _ui.is_open() and not _main.menu.visible, "load confirmation returns to the world")
	var checkpoint: Dictionary = _main.capture_memory_document_state()
	var bad_completed := checkpoint.duplicate(true)
	bad_completed.game.retry_checkpoint.completed = [123]
	_check(not _main.validate_memory_document_state(bad_completed), "invalid completed task in nested checkpoint is rejected")
	var bad_visits := checkpoint.duplicate(true)
	bad_visits.game.retry_checkpoint.visited = ["2"]
	_check(not _main.validate_memory_document_state(bad_visits), "invalid floor in nested checkpoint is rejected")
	var wrong_marker := checkpoint.duplicate(true)
	wrong_marker.game.retry_checkpoint.position[0] += 1.0
	_check(not _main.validate_memory_document_state(wrong_marker), "in-corridor but incorrect checkpoint marker is rejected")
	var flow: Node = _main.get_node("MenuLayer/Bag/CarolUIFlow")
	_check(flow.restore_memory_ui_state({"version": 1, "tutorial_seen": false}) and flow.get("_pending_equipment"), "two equipped cards queue unseen tutorial after restore")
	flow.restore_memory_ui_state({"version": 1, "tutorial_seen": true})
	var malformed: Dictionary = _main.capture_memory_document_state()
	malformed.game.floor.doors[0].room_id = "999"
	var floor_before := _floor()
	_check(not _main.restore_memory_document({"state": malformed}), "invalid door schema is rejected before restore")
	_check(_floor() == floor_before and _game.task_status == "ACTIVE", "invalid payload leaves live world intact")
	await _shot("loaded")
	await _hold_evidence()
	_check(_game.current_floor == 2 and _game.current_task_id == _game.TASK_01_ID and _game.task_status == "ACTIVE", "active task restores")
	_check(is_equal_approx(_game.remaining_time, 123.25) and is_equal_approx(_game.play_time_seconds, 42.5), "timer and effective playtime restore without offline deduction")
	_check(_cards.get_equipped_cards() == ["SECURITY", "CLEANER"] and _cards.active_card == "CLEANER", "both equipment slots and effective identity restore")
	var player: Node = _floor().get_node("Player")
	var stamina: Dictionary = player.capture_stamina_state()
	_check(is_equal_approx(stamina.value, 18.0) and stamina.exhausted and stamina.rest >= 0.7, "current stamina and exhaustion restore across process")
	_game.request_task_failure("WRONG_CARD")
	_check(_game.game_state == "FAILED", "loaded task can fail normally")
	_check(_game.retry_current_task(), "loaded task retries from its own checkpoint")
	var retry_stamina: Dictionary = _floor().get_node("Player").capture_stamina_state()
	_check(is_equal_approx(retry_stamina.value, 62.0) and not retry_stamina.exhausted, "retry restores saved acceptance stamina separately")
	await _load_slot(1, "201 work completed but not delivered")
	_check(_game.task_status == "READY_TO_SUBMIT" and _game.get_world_flags().get("stain_201_cleaned", false), "completed work remains undelivered")
	_check(not _game.get_completed_task_ids().has(_game.TASK_01_ID), "loading does not settle a task")
	await _load_slot(2, "309 rescue before settlement")
	_check(not _game.has_friend and not _floor().has_node("Persica"), "pre-rescue load creates no follower")
	await _load_slot(3, "309 rescue after settlement")
	_check(_game.has_friend and _floor().get_children().filter(func(node): return node.name == "Persica").size() == 1, "post-rescue load creates exactly one follower")
	_check(_history.entries.filter(func(entry): return entry.chapter == "309_REUNION").size() == 36, "actual CG history restored from disk")
	_ui.open("history")
	await _shot("history")
	_ui.close_page()
	_check(_game.has_friend and _game.current_floor == 3, "reviewing history leaves the world unchanged")
	await _load_slot(4, "403 progress before delivery")
	_check(_game.current_floor == 4 and _game.current_task_id == _game.TASK_04_ID and _game.task_status == "READY_TO_SUBMIT", "403 progress restores before hand-in")
	_check(_game.get_world_flags().get("patrol_collected", false) and not _game.get_world_flags().get("patrol_delivered", false), "403 pickup and delivery remain distinct")
	await _load_slot(5, "501 delivered at real EXIT")
	_check(_game.current_floor == 5 and _game.current_task_id == _game.TASK_05_ID and _game.task_status == "COMPLETED", "501 completion restores")
	_check(_game.can_escape(), "EXIT remains gated by full rescued/delivered state")
	_game.get("_world_flags")["exit_form_delivered"] = false
	_check(not _game.request_escape(), "EXIT refuses a missing delivery flag")
	_game.get("_world_flags")["exit_form_delivered"] = true
	_check(_game.request_escape() and _game.game_state == "WON", "real EXIT request wins only after restored conditions")

func _floor() -> Node:
	return _main.get_node("World").get_child(0)
