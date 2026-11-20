extends SceneTree
var failures: Array[String] = []
func _initialize() -> void:
	call_deferred("_run")
func _expect(ok: bool, message: String) -> void:
	if not ok: failures.append(message)
func _run() -> void:
	var game := root.get_node("GameManager")
	var cards := root.get_node("CardManager")
	game.start_game()
	game.set_process(false)
	game.complete_manager_intro()
	game.current_floor = 3
	_expect(not game.offer_task("TASK_03_AUTHORIZE"), "03 requires delivered02")
	game.current_floor = 2
	game.offer_task("TASK_01_CLEAN")
	game.accept_task("TASK_01_CLEAN")
	cards.collect_card("CLEANER")
	game.record_work_result("STAIN_201")
	game.submit_task("TASK_01_CLEAN")
	game.offer_task("TASK_02_PARCEL")
	game.accept_task("TASK_02_PARCEL")
	cards.collect_card("SECURITY")
	cards.switch_active()
	game.record_work_result("PARCEL_CABINET_2F")
	game.submit_task("TASK_02_PARCEL")
	_expect(not game.offer_task("TASK_03_AUTHORIZE"), "03 cannot be offered on2F")
	game.current_floor = 3
	_expect(game.offer_task("TASK_03_AUTHORIZE"), "Delivered02 permits03 on3F")
	if game.current_task_id != "TASK_03_AUTHORIZE":
		_finish()
		return
	_expect(game.remaining_time == 0 and not game.is_interaction_allowed("STAFF_MANAGER_1F"), "03 offer grants no theft or countdown")
	game.current_floor = 1
	_expect(not game.accept_task("TASK_03_AUTHORIZE"), "Acceptance requires its3F offer location")
	game.current_floor = 3
	_expect(game.accept_task("TASK_03_AUTHORIZE") and game.remaining_time == 240, "03 accepts with240 seconds")
	_expect(game.is_interaction_allowed("STAFF_MANAGER_1F"), "Only accepted03 enables manager source")
	_expect(not game.record_work_result("REGISTER_309"), "Security cannot approve309")
	cards.collect_card("MANAGER")
	_expect(cards.get_owned_cards().size() == 3 and "MANAGER" not in cards.get_equipped_cards(), "Third card is collected without replacing an equipped card")
	_expect(not game.record_work_result("REGISTER_309"), "Collected-only manager is not authority")
	cards.equip_card("MANAGER", 0)
	_expect(cards.active_card == "SECURITY" and not game.record_work_result("REGISTER_309"), "Standby manager cannot authorize")
	cards.switch_active()
	_expect(game.get_task_view()["step"] == "AUTHORIZE_309", "Active manager advances to actual authorization step")
	game.current_floor = 1
	_expect(not game.record_work_result("REGISTER_309"), "Register report on the wrong floor is rejected")
	game.current_floor = 3
	game.set_modal_open("TEST", true)
	game._process(20)
	_expect(game.remaining_time == 240 and not game.record_work_result("REGISTER_309"), "Modal stops clock and approval")
	game.set_modal_open("TEST", false)
	_expect(game.has_method("rescue_friend") and not game.call("rescue_friend"), "Cannot rescue before approval")
	_expect(game.record_work_result("REGISTER_309"), "Current manager authorizes on3F")
	_expect(game.task_status == "COMPLETED" and game.remaining_time == 0 and game.get_completed_task_ids().has("TASK_03_AUTHORIZE"), "Approval immediately completes03 and stops time")
	_expect(game.get_world_flags().get("registration_309_approved", false) and not game.has_friend and not game.get_available_floors().has(4), "Approval unlocks309 but is not rescue or4F")
	_expect(not game.submit_task("TASK_03_AUTHORIZE") and not game.record_work_result("REGISTER_309"), "No extra delivery or duplicate settlement")
	game._process(500)
	_expect(game.game_state == "PLAYING" and game.remaining_time == 0, "Completed03 cannot time out")
	# Explicit core fixture for the future real D dialogue-finished callback.
	var visits: Array[int] = [1,2,3,4,5]
	game.set("_visited_floors", visits)
	_expect(game.call("rescue_friend"), "Approved3F rescue callback can settle once")
	_expect(game.has_friend and game.get_available_floors() == [4,5], "Rescue filters lower floors and keeps visited upper floors")
	_expect(not game.call("rescue_friend"), "Repeated dialogue completion cannot duplicate rescue")
	_expect(not game.offer_task("TASK_04_PATROL"), "04 remains outside current implementation")
	_finish()
func _finish() -> void:
	for message in failures: printerr("FAIL: ", message)
	print("TASK_03_CORE: PASS" if failures.is_empty() else "TASK_03_CORE: FAIL")
	quit(0 if failures.is_empty() else 1)
