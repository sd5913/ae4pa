extends SceneTree
## Real floor/doors; deterministic scheduler deltas, actual task facts.
var failures: Array[String] = []
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok: failures.append(message)
func run() -> void:
	var g: Node = root.get_node("GameManager");var c: Node = root.get_node("CardManager")
	g.start_game();g.complete_manager_intro();g.current_floor=2;g.set_process(false)
	var f: Node = load("res://scenes/levels/floor_2.tscn").instantiate();root.add_child(f)
	await process_frame
	f.set_process(false);f.player.set_physics_process(false)
	var sched: Node
	for child in f.get_children():
		if child.get_script()==load("res://scenes/doors/door_scheduler.gd"):sched=child
	sched.set_process(false)
	for d in f.get("_doors"):d.set_physics_process(false)
	var nose: Node=f.get_node("DoorRoot/Room201/Door");var eye: Node=f.get_node("DoorRoot/Room202/Door")
	f.player.position.x=nose.global_position.x-112
	sched._process(0.0)
	check(nose.door_state=="WARNING" and g.task_status=="NONE","201 first contact warns before opening/offer")
	sched._process(0.75)
	check(nose.door_state=="WARNING","201 keeps full warning duration")
	sched._process(0.8);nose._physics_process(0.0)
	check(nose.door_state=="OPEN" and g.task_status=="AVAILABLE","201 opens then offers")
	check(g.accept_task("TASK_01_CLEAN"),"201 accepted")
	sched._process(30)
	check(nose.door_state=="OPEN" and nose.get_node("MonsterIdle").visible,"201 monster remains throughout active task")
	g.set_modal_open("OTHER",true);sched._process(30)
	check(nose.door_state=="OPEN","modal never hides active task monster")
	g.set_modal_open("OTHER",false)
	f.player.position.x=eye.global_position.x-112;sched._process(1)
	check(eye.door_state=="CLOSED","202 waits for201 delivery")
	c.collect_card("CLEANER");g.record_work_result("STAIN_201");g.submit_task("TASK_01_CLEAN")
	# A marker describes a real visible monster conversation; no quest mutation.
	if sched.has_method("set_story_dialogue_room"):
		sched.set_story_dialogue_room("201")
		check(nose.door_state=="OPEN","201 remains visible in delivery conversation")
		sched.set_story_dialogue_room("")
	else:check(false,"scheduler exposes dialogue visibility adapter")
	f.player.position.x=nose.global_position.x-60
	sched._process(30)
	check(nose.door_state=="CLOSED","completed201 closes and never cycles")
	f.player.position.x=eye.global_position.x-112;sched._process(0)
	check(eye.door_state=="WARNING","202 also warns before first opening")
	sched._process(0.75);check(eye.door_state=="WARNING","202 warning cannot skip to open")
	if sched.has_method("set_story_dialogue_room"):
		var warning_elapsed: float=sched.elapsed
		sched.set_story_dialogue_room("201");g.set_modal_open("OTHER_DIALOGUE",true)
		sched._process(5)
		check(sched.elapsed==warning_elapsed,"another conversation freezes the unfinished warning timer")
		sched.set_story_dialogue_room("")
		check(eye.door_state=="WARNING","202 resumes remaining warning after another conversation")
		g.set_modal_open("OTHER_DIALOGUE",false)
	sched._process(0.8)
	check(eye.door_state=="OPEN","202 opens after warning")
	if sched.has_method("set_story_dialogue_room"):
		sched.set_story_dialogue_room("201")
		check(nose.door_state=="OPEN" and eye.door_state=="CLOSED","revisiting201 temporarily shows only the speaking resident")
		sched.set_story_dialogue_room("")
		check(nose.door_state=="CLOSED" and eye.door_state=="OPEN","unfinished202 returns immediately without another alarm")
	f.queue_free();await process_frame
	for message in failures:printerr("FAIL: "+message)
	if failures.is_empty():print("PASS: tutorial warn/open/observe/deliver/retire lifecycle")
	quit(0 if failures.is_empty() else 1)
