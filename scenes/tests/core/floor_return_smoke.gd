extends SceneTree
## A-V4-03: real 1F/2F travel must preserve an accepted task.

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game: Node = root.get_node("GameManager")
	var cards: Node = root.get_node("CardManager")
	var host := Node2D.new()
	root.add_child(host)
	game.call("set_floor_host", host)
	game.call("start_game")
	await process_frame
	_expect(game.call("get_available_floors").is_empty(), "1F stair is locked before manager dialogue")
	_expect(not game.call("request_floor_travel", 2), "No dialogue blocks 2F even at the stair")
	game.call("complete_manager_intro")
	_expect(game.call("get_available_floors") == [2], "Manager dialogue opens 2F without cards")
	_expect(not game.call("request_floor_travel", 2), "Remote request cannot activate distant stairs")
	host.get_child(0).get_node("Player").global_position.x = 3400.0
	_expect(game.call("request_floor_travel", 2), "1F right stair reaches 2F")
	await process_frame
	_expect(game.get("current_floor") == 2 and cards.call("get_owned_cards").is_empty(), "Travel does not require or invent cards")
	_expect(game.call("get_available_floors") == [1], "2F can return to visited 1F")
	_expect(not game.call("request_floor_travel", 3), "Unfinished tasks block 3F")
	_expect(game.call("offer_task", "TASK_01_CLEAN"), "201 can offer task on arrival")
	_expect(game.call("accept_task", "TASK_01_CLEAN"), "201 task begins")
	game.call("_process", 10.0)
	var time_before_return: float = game.get("remaining_time")
	_expect(game.call("request_floor_travel", 1), "2F left stair returns to 1F")
	await process_frame
	_expect(game.get("current_floor") == 1, "Return loads 1F")
	_expect(host.get_child(0).get_node("Player").global_position.x > 3200.0, "Return appears near the right stair")
	_expect(game.get("current_task_id") == "TASK_01_CLEAN" and game.get("task_status") == "ACTIVE", "Task survives return")
	_expect(game.get("remaining_time") <= time_before_return and game.get("remaining_time") > 190.0, "Return preserves remaining time")
	_expect(game.call("get_available_floors") == [2], "Visited 2F remains reachable")
	_expect(not game.call("request_floor_travel", 3), "A number cannot skip 2F")
	host.queue_free()
	await process_frame
	_finish()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS: manager gate, real stairs, 1F/2F return, and task persistence.")
	quit(0 if failures.is_empty() else 1)
