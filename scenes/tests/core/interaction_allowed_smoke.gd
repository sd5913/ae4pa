extends SceneTree
## A's task eligibility contract; B still owns range, facing, hold and rewards.

var failures: Array[String] = []
var game: Node
var cards: Node


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	game = root.get_node("GameManager")
	cards = root.get_node("CardManager")
	if not game.has_method("is_interaction_allowed"):
		_expect(false, "GameManager must provide the real task eligibility query")
		_finish()
		return

	game.call("start_game")
	_expect_task_01_blocked("Before any task")
	game.call("complete_manager_intro")
	game.set("current_floor", 2) # Task fixture; actual travel is covered by floor_return_smoke.
	_expect(game.call("offer_task", "TASK_01_CLEAN"), "201 offers task 01")
	_expect_task_01_blocked("Viewing the offer without accepting")
	_expect(game.call("accept_task", "TASK_01_CLEAN"), "Accepting starts task 01")
	_expect(_allowed("STAFF_CLEANER_1F"), "Accepted task allows the cleaner reward")
	_expect(_allowed("STAIN_201"), "Stain is a task target; B separately checks current identity")
	for target_id: String in ["", "UNKNOWN", "staff_cleaner_1f", "STAFF_SECURITY_1F", "STAFF_SECURITY_2F", "STAFF_MANAGER_1F", "STAFF_PATROL_4F", "PARCEL_CABINET_2F", "REGISTER_309", "EXIT_REGISTER_5F"]:
		_expect(not _allowed(target_id), "Unknown or unimplemented target is denied: " + target_id)

	game.set("current_floor", 1)
	_expect(_allowed("STAFF_CLEANER_1F"), "Task eligibility survives return to 1F")
	var time_before: float = game.get("remaining_time")
	var task_before: Dictionary = game.call("get_task_view")
	for _attempt: int in range(3):
		_allowed("STAFF_CLEANER_1F")
		_allowed("STAIN_201")
	_expect(cards.call("get_owned_cards").is_empty(), "Eligibility never grants a card")
	_expect(game.call("get_task_view") == task_before, "Queries do not advance or modify the task")
	_expect(game.call("get_world_flags").is_empty(), "Queries do not complete work")
	_expect(is_equal_approx(game.get("remaining_time"), time_before), "Queries do not consume or reset time")
	for modal_id: String in ["DIALOGUE", "HELP", "BAG", "PAUSE"]:
		game.call("set_modal_open", modal_id, true)
		_expect_task_01_blocked("Open modal " + modal_id)
		game.call("set_modal_open", modal_id, false)
		_expect(_allowed("STAFF_CLEANER_1F"), "Closing the last modal restores eligibility")
	game.call("set_modal_open", "BAG", true)
	game.call("set_modal_open", "DIALOGUE", true)
	game.call("set_modal_open", "BAG", false)
	_expect_task_01_blocked("Another modal remains open")
	game.call("set_modal_open", "DIALOGUE", false)

	for state: String in ["MENU", "LOADING", "INTRO", "RESCUE_DIALOGUE", "FAILED", "WON"]:
		game.set("game_state", state) # Non-playing fixture, with task otherwise still ACTIVE.
		_expect_task_01_blocked("Game state " + state)
	game.set("game_state", "PLAYING")
	_expect(_allowed("STAFF_CLEANER_1F"), "Returning to PLAYING restores valid eligibility")
	game.set("remaining_time", 0.0) # Zero-time boundary before the timeout transition.
	_expect_task_01_blocked("No remaining time")
	_expect(game.get("task_status") == "ACTIVE", "Query is read-only even at the timeout boundary")
	game.set("remaining_time", time_before)

	_expect(cards.call("collect_card", "CLEANER"), "Real CardManager grants the fixture card")
	_expect(not _allowed("STAFF_CLEANER_1F"), "Owned cleaner card cannot be stolen again")
	_expect(_allowed("STAIN_201"), "Acquiring cleaner does not consume the cleaning step")
	game.set("current_floor", 2)
	_expect(game.call("record_work_result", "STAIN_201"), "Real work result advances to delivery")
	_expect_task_01_blocked("Ready to submit")
	_expect(game.call("submit_task", "TASK_01_CLEAN"), "Real delivery completes task 01")
	_expect_task_01_blocked("Completed task")

	_start_task()
	game.call("request_task_failure", "STAFF_CAUGHT")
	_expect_task_01_blocked("Caught during an accepted task")
	_start_task()
	game.call("_process", 210.0)
	_expect_task_01_blocked("Timed out task")
	game.call("start_game")
	_expect_task_01_blocked("New game clears eligibility")
	_start_task()
	_expect(_allowed("STAFF_CLEANER_1F"), "Fresh acceptance allows cleaner again")
	_finish()


func _start_task() -> void:
	game.call("start_game")
	game.call("complete_manager_intro")
	game.set("current_floor", 2)
	_expect(game.call("offer_task", "TASK_01_CLEAN"), "Fresh task offer succeeds")
	_expect(game.call("accept_task", "TASK_01_CLEAN"), "Fresh task acceptance succeeds")


func _allowed(target_id: String) -> bool:
	return game.call("is_interaction_allowed", target_id)


func _expect_task_01_blocked(context: String) -> void:
	_expect(not _allowed("STAFF_CLEANER_1F"), context + " denies cleaner theft")
	_expect(not _allowed("STAIN_201"), context + " denies cleaning")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS: task eligibility, reward ownership, modal locks, lifecycle, and read-only queries.")
	quit(0 if failures.is_empty() else 1)
