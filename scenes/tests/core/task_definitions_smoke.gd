extends SceneTree
## Future task definitions do not enable future gameplay.

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game: Node = root.get_node("GameManager")
	if not game.has_method("get_task_definition"):
		printerr("FAIL: A must provide the shared task definition query")
		quit(1)
		return
	var ids: Array[String] = ["TASK_01_CLEAN", "TASK_02_PARCEL", "TASK_03_AUTHORIZE", "TASK_04_PATROL", "TASK_05_EXIT"]
	var limits: Array[float] = [210.0, 180.0, 240.0, 180.0, 180.0]
	var targets: Array[String] = ["STAIN_201", "PARCEL_CABINET_2F", "REGISTER_309", "STAFF_PATROL_4F", "EXIT_REGISTER_5F"]
	for i: int in range(ids.size()):
		var definition: Dictionary = game.call("get_task_definition", ids[i])
		_expect(definition.get("time_limit") == limits[i], "%s has its V4 trial limit" % ids[i])
		_expect(definition.get("target_id") == targets[i], "%s has a distinct work source" % ids[i])
		_expect(not definition.get("name", "").is_empty() and not definition.get("location", "").is_empty(), "Task panels have a name and location")
		definition["steps"].clear()
		_expect(not game.call("get_task_definition", ids[i])["steps"].is_empty(), "Definition query protects nested state")
	_expect(game.call("get_task_definition", "UNKNOWN").is_empty(), "Unknown tasks do not fall back to task 01")
	game.call("start_game")
	game.call("complete_manager_intro")
	game.set("current_floor", 2)
	_expect(not game.call("offer_task", "TASK_02_PARCEL"), "Metadata does not enable M2 before M1")
	game.call("offer_task", "TASK_01_CLEAN")
	var view: Dictionary = game.call("get_task_view")
	_expect(view.get("name") == "打扫走廊" and view.get("location") == "2F · 201", "D receives useful task panel metadata")
	game.call("accept_task", "TASK_01_CLEAN")
	game.call("_process", 10.0)
	_expect(game.get("remaining_time") == 200.0, "Task 01 continues to use the shared trial limit")
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS: five task definitions, protected metadata and task 01 consumer.")
	quit(0 if failures.is_empty() else 1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
