extends SceneTree
## Notebook facts come from the same manager/settlement state as checkpoints.

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game: Node = root.get_node("GameManager")
	var cards: Node = root.get_node("CardManager")
	if not game.has_method("get_notebook_view"):
		printerr("FAIL: GameManager must own the progressive notebook view")
		quit(1)
		return
	game.call("start_game")
	var view: Dictionary = game.call("get_notebook_view")
	_expect(not view["unlocked"], "Notebook has no story clues before manager talk")
	_expect(_statuses(view) == ["UNKNOWN", "UNKNOWN", "UNKNOWN", "UNKNOWN", "UNKNOWN"], "New game has five unknown entries")
	view["entries"][0]["text"] = "Injected knowledge"
	_expect(game.call("get_notebook_view")["entries"][0]["text"] != "Injected knowledge", "Nested notebook reads cannot change the game's facts")
	game.call("complete_manager_intro")
	view = game.call("get_notebook_view")
	_expect(view["unlocked"] and _statuses(view) == ["HINT", "HINT", "UNKNOWN", "UNKNOWN", "UNKNOWN"], "Manager unlocks exactly the two vague source clues")
	var manager_notes: Dictionary = view.duplicate(true)
	game.set("current_floor", 2)
	game.call("offer_task", "TASK_01_CLEAN")
	game.call("accept_task", "TASK_01_CLEAN")
	cards.call("collect_card", "CLEANER")
	game.call("record_work_result", "STAIN_201")
	_expect(game.call("get_notebook_view") == manager_notes, "Getting a card and cleaning without delivery do not reveal the nose rule")
	game.call("_process", 209.999)
	_expect(game.call("submit_task", "TASK_01_CLEAN"), "Positive remaining time permits immediate effective delivery")
	game.call("_process", 1.0)
	_expect(game.get("task_status") == "COMPLETED", "A later timeout update cannot reverse effective delivery")
	view = game.call("get_notebook_view")
	_expect(_statuses(view) == ["HINT", "KNOWN", "UNKNOWN", "UNKNOWN", "UNKNOWN"], "Only 201 delivery reveals the nose rule")
	_expect("保洁" in view["entries"][1]["text"], "Known nose note explains the actually earned identity rule")
	game.call("start_game")
	game.call("complete_manager_intro")
	game.set("current_floor", 2)
	game.call("offer_task", "TASK_01_CLEAN")
	game.call("accept_task", "TASK_01_CLEAN")
	cards.call("collect_card", "CLEANER")
	game.call("record_work_result", "STAIN_201")
	game.call("_process", 210.0)
	_expect(not game.call("submit_task", "TASK_01_CLEAN"), "Delivery arriving after zero is rejected")
	_expect(game.call("get_notebook_view") == manager_notes, "Timeout without delivery never reveals a rule")
	game.call("start_game")
	_expect(not game.call("get_notebook_view")["unlocked"] and _statuses(game.call("get_notebook_view")) == ["UNKNOWN", "UNKNOWN", "UNKNOWN", "UNKNOWN", "UNKNOWN"], "New game clears notebook knowledge with story/task facts")
	for message: String in failures:
		printerr("FAIL: ", message)
	if failures.is_empty():
		print("PASS: progressive notebook, protected reads, delivery/timeout ordering and new-game reset.")
	quit(0 if failures.is_empty() else 1)


func _statuses(view: Dictionary) -> Array:
	var result: Array = []
	for entry: Dictionary in view["entries"]:
		result.append(entry["status"])
	return result


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
