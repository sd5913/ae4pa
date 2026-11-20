extends SceneTree
## UI-only state fixtures; mounts the actual F5 override, not merely D's base HUD.
var failures: Array[String] = []
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var g: Node = root.get_node("GameManager")
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main); await process_frame
	g.set_process(false)
	for id: String in ["TASK_T03_ROOM_SERVICE", "TASK_T04_DUAL_WORK", "TASK_T05_TRANSIT"]:
		for status: String in ["AVAILABLE", "ACTIVE", "READY_TO_SUBMIT", "COMPLETED", "FAILED"]:
			# D HUD reads both status and authoritative completion prerequisites.
			var completed: Array[String] = ["TASK_01_CLEAN", "TASK_02_PARCEL"]
			for previous: String in ["TASK_T03_ROOM_SERVICE", "TASK_T04_DUAL_WORK", "TASK_T05_TRANSIT"]:
				if previous == id:
					if status == "COMPLETED": completed.append(previous)
					break
				completed.append(previous)
			g.set("_completed_task_ids", completed)
			g.current_task_id = id; g.task_status = status; g.current_floor = 2
			g.task_updated.emit(); await process_frame
			if status == "AVAILABLE":
				main._on_task_offered(id)
				if g.get_task_definition(id)["room_id"] not in main.notice_label.text: failures.append(id + " intro notice still describes previous task")
			var text: String = main.get_node("TaskLayer/HUD/%Objective").text
			if "201" in text: failures.append(id + " " + status + " leaked201 objective")
			if status == "COMPLETED" and id == "TASK_T05_TRANSIT" and "3F" not in text: failures.append("205 completion needs real upstairs objective")
	main.queue_free(); await process_frame
	for text in failures: printerr("FAIL: " + text)
	if failures.is_empty(): print("PASS: actual main HUD reads all tutorial phases without201 fallback")
	quit(0 if failures.is_empty() else 1)
