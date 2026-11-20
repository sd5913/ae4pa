extends SceneTree
var failures:Array[String]=[]
func _initialize()->void:call_deferred("run")
func run()->void:
	var g:Node=root.get_node("GameManager");var c:Node=root.get_node("CardManager")
	g.start_game();g.complete_manager_intro();g.current_floor=2;g.set_process(false)
	g.offer_task("TASK_01_CLEAN");g.accept_task("TASK_01_CLEAN");c.collect_card("CLEANER");c.collect_card("SECURITY");g.record_work_result("STAIN_201")
	c.switch_active()
	if g.submit_task("TASK_01_CLEAN"):failures.append("201 rejects delivery with wrong current ID even after work")
	if not g.get_completed_task_ids().is_empty():failures.append("wrong ID cannot retire monster or unlock passage")
	c.switch_active()
	if not g.submit_task("TASK_01_CLEAN"):failures.append("201 accepts real result and correct ID")
	for message in failures:printerr("FAIL: "+message)
	if failures.is_empty():print("PASS: delivery checks current work identity")
	quit(0 if failures.is_empty() else 1)
