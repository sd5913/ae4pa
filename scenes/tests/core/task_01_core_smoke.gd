extends SceneTree
## Checks the explicit developer entry; these buttons do not replace B/C/D acceptance.

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not ResourceLoader.exists("res://scenes/tests/core/task_01_core_test.tscn"):
		_expect(false, "Task 01 must have an explicit core test scene")
		_finish()
		return
	var core: Node = load("res://scenes/tests/core/task_01_core_test.tscn").instantiate()
	root.add_child(core)
	await process_frame
	var game: Node = root.get_node("GameManager")
	var cards: Node = root.get_node("CardManager")
	var panel: Node = core.get_node("DeveloperOverlay/Panel")
	_expect(game.get("current_floor") == 1 and cards.call("get_owned_cards").is_empty(), "Core starts the shared 1F without cards")
	_expect(panel.get_node("Row2/Retry").disabled, "A fresh session has no failed checkpoint to retry")
	_expect(not panel.has_node("Row1/Clean") and not panel.has_node("Row1/Deliver"), "Developer entry uses actual B work and C delivery rather than fake completion controls")
	panel.get_node("Row1/Intro").emit_signal("pressed")
	core.get_node("World").get_child(0).get_node("Player").global_position.x = 3400.0
	_expect(game.call("request_floor_travel", 2), "Core reuses real manager-gated floor loading")
	panel.get_node("Row1/Offer").emit_signal("pressed")
	_expect(game.get("task_status") == "AVAILABLE" and is_zero_approx(game.get("remaining_time")), "Developer offer does not begin time")
	panel.get_node("Row1/Accept").emit_signal("pressed")
	_expect(game.get("task_status") == "ACTIVE" and is_equal_approx(game.get("remaining_time"), 210.0), "Developer acceptance uses the real task limit")
	panel.get_node("Row2/Pause").emit_signal("pressed")
	var stopped: float = game.get("remaining_time")
	game.call("_process", 20.0)
	_expect(is_equal_approx(game.get("remaining_time"), stopped), "Core modal pauses the manager's timer")
	panel.get_node("Row2/Pause").emit_signal("pressed")
	panel.get_node("Row2/Timeout").emit_signal("pressed")
	await process_frame
	await process_frame
	_expect(game.get("task_status") == "FAILED" and not panel.get_node("Row2/Retry").disabled, "A real failed checkpoint enables the developer retry control")
	panel.get_node("Row2/Pause").emit_signal("pressed")
	panel.get_node("Row2/Retry").emit_signal("pressed")
	_expect(game.get("task_status") == "AVAILABLE" and game.get("remaining_time") == 0.0, "Retry returns to acceptance rather than restarting time")
	_expect(not core.get("_paused") and game.call("is_world_input_allowed"), "Retry clears developer modal state as well as manager locks")
	panel.get_node("Row2/Restart").emit_signal("pressed")
	_expect(game.get("task_status") == "NONE" and cards.call("get_owned_cards").is_empty(), "Core new game clears task and cards")
	core.queue_free()
	await process_frame
	_finish()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS: task 01 developer entry, real acceptance, pause, timeout and checkpoint retry.")
	quit(0 if failures.is_empty() else 1)
