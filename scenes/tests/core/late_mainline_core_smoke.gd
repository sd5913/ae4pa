extends SceneTree
## Domain checks. Earlier story state is an explicit API fixture, not a full playthrough.
var failures: Array[String] = []
var game: Node
var cards: Node

func _initialize() -> void: call_deferred("_run")
func _expect(ok: bool, message: String) -> void:
	if not ok: failures.append(message)

func _run() -> void:
	game = root.get_node("GameManager")
	cards = root.get_node("CardManager")
	game.set_process(false)
	game.start_game()
	game.complete_manager_intro()
	game.current_floor = 4
	_expect(not game.can_offer_task("TASK_04_PATROL"), "403 requires rescue")
	game.get("_completed_task_ids").assign(["TASK_03_AUTHORIZE"])
	game.has_friend = true
	game.get("_world_flags")["rescue_309_completed"] = true
	_expect(game.can_offer_task("TASK_04_PATROL"), "HAS_FRIEND reads the real rescue fact")
	_expect(not game.is_interaction_allowed("STAFF_PATROL_4F"), "No patrol theft before accepting")
	_expect(game.offer_task("TASK_04_PATROL") and game.accept_task("TASK_04_PATROL"), "403 accepts with 120-second clock")
	_expect(game.remaining_time == 120, "403 limit is 120")
	_expect(game.is_interaction_allowed("STAFF_PATROL_4F"), "Patrol reward is eligible without an empty card requirement")
	_expect(not game.record_work_result("STAFF_PATROL_4F"), "Generic work callback cannot forge a stolen file")
	if game.has_method("record_task_item_result"):
		_expect(not game.record_task_item_result("EXIT_FORM", "STAFF_PATROL_4F"), "Wrong reward rejected")
		_expect(not game.record_task_item_result("PATROL_RECORD", "PATROL_CABINET_204"), "204 teaching record cannot settle403")
		_expect(game.record_task_item_result("PATROL_RECORD", "STAFF_PATROL_4F"), "Real file result becomes ready")
		_expect(not game.record_task_item_result("PATROL_RECORD", "STAFF_PATROL_4F"), "Duplicate file rejected")
		_expect(game.task_status == "READY_TO_SUBMIT" and not game.get_available_floors().has(5), "Collected without delivery never opens5F")
		_expect(game.get_task_view()["target_id"] == "ROOM_403", "Ready patrol points to403")
		game.current_floor = 3
		_expect(not game.submit_task("TASK_04_PATROL"), "Cannot deliver on another floor")
		game.current_floor = 4
		_expect(game.submit_task("TASK_04_PATROL"), "403 delivery has no required identity")
		_expect(not game.submit_task("TASK_04_PATROL") and game.get_available_floors().has(5), "Only first delivery opens5F")
		game.current_floor = 5
		_expect(game.offer_task("TASK_05_EXIT") and game.accept_task("TASK_05_EXIT"), "501 uses actual prior task and rescue prerequisite")
		cards.collect_card("CLEANER")
		cards.collect_card("MANAGER")
		cards.equip_card("CLEANER", 0)
		cards.equip_card("MANAGER", 1)
		_expect(not game.record_work_result("EXIT_REGISTER_5F"), "Standby manager cannot approve exit")
		cards.switch_active()
		_expect(game.record_work_result("EXIT_REGISTER_5F"), "Current manager approves exit")
		_expect(game.task_status == "READY_TO_SUBMIT" and game.remaining_time == 180, "Approval still needs timed delivery")
		_expect(game.get_task_view()["target_id"] == "ROOM_501", "Ready exit points to501")
		cards.switch_active()
		_expect(not game.submit_task("TASK_05_EXIT"), "501 delivery rechecks current manager")
		cards.switch_active()
		_expect(game.submit_task("TASK_05_EXIT"), "501 real delivery succeeds")
		_expect(game.get_world_flags().get("exit_form_delivered", false), "501 writes separate final flag")
	else:
		_expect(false, "Typed task file settlement exists")
	_expect(game.has_method("can_escape") and game.has_method("request_escape") and game.has_signal("game_won"), "Guarded EXIT API and one-shot signal exist")
	if game.has_method("request_escape"):
		_expect(not game.request_escape(), "No real exit/floor host cannot win")
	if failures.is_empty(): print("PASS: late_mainline_core")
	for message in failures: print("FAIL: ", message)
	quit(0 if failures.is_empty() else 1)
