extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _expect(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)

func _run() -> void:
	var game = root.get_node("GameManager")
	var cards = root.get_node("CardManager")
	game.start_game()
	game.set_process(false)
	game.complete_manager_intro()
	game.current_floor = 2
	_expect(not game.offer_task("TASK_02_PARCEL"), "202 requires delivered201")
	game.offer_task("TASK_01_CLEAN")
	game.accept_task("TASK_01_CLEAN")
	_expect(not game.offer_task("TASK_02_PARCEL"), "202 cannot replace active201")
	cards.collect_card("CLEANER")
	game.record_work_result("STAIN_201")
	game.submit_task("TASK_01_CLEAN")
	_expect(game.offer_task("TASK_02_PARCEL"), "Delivered201 permits real task02")
	if game.current_task_id != "TASK_02_PARCEL":
		_finish()
		return
	_expect(game.remaining_time == 0.0 and game.task_status == "AVAILABLE", "Reading202 does not start clock")
	_expect(not game.is_interaction_allowed("STAFF_SECURITY_1F"), "No theft before acceptance")
	_expect(game.accept_task("TASK_02_PARCEL"), "Task02 accepts")
	_expect(game.remaining_time == 180.0, "Task02 gets its own180 second limit")
	_expect(game.is_interaction_allowed("STAFF_SECURITY_1F") and not game.is_interaction_allowed("STAFF_SECURITY_2F"), "Only fixed1F security source is eligible")
	_expect(not game.record_work_result("STAIN_201"), "Old work cannot advance new task")
	_expect(not game.submit_task("TASK_02_PARCEL"), "Cannot deliver without parcel")
	cards.collect_card("SECURITY")
	_expect(cards.active_card == "CLEANER" and not game.record_work_result("PARCEL_CABINET_2F"), "Standby security is not pickup permission")
	cards.switch_active()
	_expect(game.record_work_result("PARCEL_CABINET_2F"), "Current security permits real parcel source")
	_expect(game.task_status == "READY_TO_SUBMIT" and not game.get_world_flags().get("parcel_delivered",false), "Pickup still requires202 delivery")
	game._process(5.0)
	_expect(game.remaining_time == 175.0, "Pickup does not stop countdown")
	game.set_modal_open("TEST",true)
	game._process(10.0)
	_expect(game.remaining_time == 175.0 and not game.submit_task("TASK_02_PARCEL"), "Modal freezes clock and delivery")
	game.set_modal_open("TEST",false)
	_expect(not game.record_work_result("PARCEL_CABINET_2F"), "Repeated pickup cannot settle twice")
	_expect(not game.get_available_floors().has(3), "Pickup alone does not open3F")
	_expect(not game.submit_task("TASK_01_CLEAN") and game.submit_task("TASK_02_PARCEL"), "Only actual current task delivers")
	_expect(game.get_completed_task_ids() == ["TASK_01_CLEAN","TASK_02_PARCEL"], "Both achievements remain")
	_expect(game.get_world_flags().get("stain_201_cleaned",false) and game.get_world_flags().get("parcel_delivered",false) and not game.get_available_floors().has(3), "Delivery retains201; remaining2F tutorials still gate3F")
	_expect(not game.submit_task("TASK_02_PARCEL"), "Delivery is once only")
	game.current_floor = 3
	_expect(not game.offer_task("TASK_03_AUTHORIZE") and game.get_completed_task_ids().has("TASK_02_PARCEL"), "Delivered02 does not skip203–205 to reach309 task")
	_expect(not game.offer_task("TASK_04_PATROL") and game.get_completed_task_ids().has("TASK_02_PARCEL"), "04 remains gated and02 remains completed")
	_finish()

func _finish() -> void:
	for message in failures:
		printerr("FAIL: ",message)
	print("TASK_02_CORE: ","PASS" if failures.is_empty() else "FAIL")
	quit(0 if failures.is_empty() else 1)
