extends SceneTree
## A's first V4 task contract, using the real autoloads.

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game: Node = root.get_node("GameManager")
	var cards: Node = root.get_node("CardManager")
	game.call("start_game")
	_expect(not game.call("offer_task", "TASK_01_CLEAN"), "201 cannot offer before manager introduction")
	game.call("complete_manager_intro")
	game.set("current_floor", 2) # Story and task fixture; floor travel has its own integration test.
	_expect(game.call("offer_task", "TASK_01_CLEAN"), "201 offers the first task")
	_expect(game.get("task_status") == "AVAILABLE", "Offer stays available without a timer")
	game.call("_process", 15.0)
	_expect(is_zero_approx(game.get("remaining_time")), "Offer does not consume time")
	_expect(not game.call("offer_task", "TASK_02_PARCEL"), "Another task cannot replace the offer")
	game.set("current_floor", 1)
	_expect(not game.call("accept_task", "TASK_01_CLEAN"), "An offer cannot be accepted after leaving its floor")
	game.set("current_floor", 2)
	_expect(game.call("accept_task", "TASK_01_CLEAN"), "First acceptance begins the task")
	_expect(not game.call("accept_task", "TASK_01_CLEAN"), "Repeated acceptance cannot restart the timer")
	_expect(not game.call("submit_task", "TASK_01_CLEAN"), "Delivery before cleaning cannot settle")
	_expect(is_equal_approx(game.get("remaining_time"), 210.0), "Task 01 receives its full time limit")
	game.call("_process", 10.0)
	_expect(is_equal_approx(game.get("remaining_time"), 200.0), "Active task time decreases")
	game.call("set_modal_open", "BAG", true)
	game.call("_process", 20.0)
	_expect(is_equal_approx(game.get("remaining_time"), 200.0), "Open bag stops the task timer")
	game.call("set_modal_open", "DIALOGUE", true)
	game.call("set_modal_open", "BAG", false)
	game.call("_process", 20.0)
	_expect(is_equal_approx(game.get("remaining_time"), 200.0), "Closing one of two modals keeps time stopped")
	game.call("set_modal_open", "DIALOGUE", false)
	_expect(not game.call("record_work_result", "STAIN_201"), "No cleaner identity cannot clean")
	_expect(cards.call("collect_card", "CLEANER"), "Real CardManager grants the cleaner card")
	_expect(not game.call("record_work_result", "PARCEL_CABINET_2F"), "Wrong target cannot advance task 01")
	_expect(game.call("record_work_result", "STAIN_201"), "Cleaner at the stain completes the work")
	_expect(not game.call("record_work_result", "STAIN_201"), "Duplicate work result is ignored")
	_expect(game.get("task_status") == "READY_TO_SUBMIT", "Cleaning still requires return to 201")
	game.call("_process", 10.0)
	_expect(is_equal_approx(game.get("remaining_time"), 190.0), "Timer continues until 201 delivery")
	_expect(game.call("submit_task", "TASK_01_CLEAN"), "201 delivery completes task 01")
	_expect(not game.call("submit_task", "TASK_01_CLEAN"), "Repeated delivery cannot settle twice")
	_expect(game.get("task_status") == "COMPLETED", "Delivery completes the task")
	var stopped: float = game.get("remaining_time")
	game.call("_process", 30.0)
	_expect(is_equal_approx(game.get("remaining_time"), stopped), "Completed task stops the timer")
	var view: Dictionary = game.call("get_task_view")
	view["status"] = "ACTIVE"
	_expect(game.get("task_status") == "COMPLETED", "Task view does not expose writable state")

	game.call("start_game")
	_expect(game.get("current_task_id") == "NONE" and game.get("task_status") == "NONE", "New game clears task 01")
	game.call("complete_manager_intro")
	game.set("current_floor", 2)
	game.call("offer_task", "TASK_01_CLEAN")
	game.call("accept_task", "TASK_01_CLEAN")
	var failure_reasons: Array[String] = []
	game.connect("task_failed", func(_task_id: String, reason: String) -> void: failure_reasons.append(reason))
	game.call("_process", 210.0)
	_expect(game.get("task_status") == "FAILED" and game.get("game_state") == "FAILED", "Zero remaining time fails once")
	_expect(not game.call("record_work_result", "STAIN_201"), "Work after timeout cannot settle")
	_expect(not game.call("submit_task", "TASK_01_CLEAN"), "Delivery after timeout cannot settle")
	game.call("_process", 1.0)
	_expect(failure_reasons == ["TASK_TIMEOUT"], "Timeout reports one task failure")

	game.call("start_game")
	game.call("complete_manager_intro")
	game.set("current_floor", 2)
	game.call("offer_task", "TASK_01_CLEAN")
	game.call("accept_task", "TASK_01_CLEAN")
	cards.call("collect_card", "CLEANER")
	game.call("record_work_result", "STAIN_201")
	game.call("_process", 210.0)
	_expect(game.get("task_status") == "FAILED", "Cleaned but undelivered task still expires")
	_expect(not game.call("submit_task", "TASK_01_CLEAN"), "Timeout beats late delivery")

	game.call("start_game")
	game.call("complete_manager_intro")
	game.set("current_floor", 2)
	game.call("offer_task", "TASK_01_CLEAN")
	game.call("accept_task", "TASK_01_CLEAN")
	cards.call("collect_card", "CLEANER")
	game.call("record_work_result", "STAIN_201")
	game.call("fail", "STAFF_CAUGHT")
	_expect(game.get("task_status") == "FAILED", "Being caught before delivery fails the active task")
	_finish()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS: task 01 offer, timer, modal pause, work, delivery, reset, and timeout.")
	quit(0 if failures.is_empty() else 1)
