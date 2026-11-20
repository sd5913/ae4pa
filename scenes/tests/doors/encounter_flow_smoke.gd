extends SceneTree
var failures: Array[String] = []
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
func run() -> void:
	var gm = root.get_node("GameManager")
	var cards = root.get_node("CardManager")
	gm.start_game()
	gm.complete_manager_intro()
	gm.current_floor = 2
	var catalog = load("res://scenes/doors/v4_door_catalog.gd")
	for row in catalog.get_rows():
		var selected: String = gm.get_room_monster(row.room)
		check(row.pool.has(selected),"Allowed pool " + row.room)
		check(gm.get_room_monster(row.room) == selected,"Stable assignment " + row.room)
	check(gm.get_room_monster("203") == "HAT" and gm.get_room_monster("204") == "EAR" and gm.get_room_monster("205") == "CHECKER","All first introductions on2F")
	var floor_node = load("res://scenes/levels/floor_2.tscn").instantiate()
	root.add_child(floor_node)
	await process_frame
	floor_node.set_process(false)
	var player = floor_node.player
	player.set_physics_process(false)
	var scheduler
	for child in floor_node.get_children():
		if child.get_script() == load("res://scenes/doors/door_scheduler.gd"):
			scheduler = child
	check(scheduler != null and scheduler.doors.size()==5,"Five real managed doors")
	scheduler.set_process(false)
	for door in scheduler.doors:
		door.set_physics_process(false)
	var nose = floor_node.get_node("DoorRoot/Room201/Door")
	player.global_position.x = nose.global_position.x - 112
	scheduler._process(0.1)
	check(nose.door_state == "WARNING","First introduction starts with warning")
	scheduler._process(nose.warning_time)
	check(nose.door_state == "OPEN","First opening follows complete warning")
	nose._physics_process(0.0)
	check(gm.task_status == "AVAILABLE" and gm.get_pending_monster_encounter().room_id == "201","Existing 201 offer bridge")
	check(gm.accept_task("TASK_01_CLEAN"),"Accept existing 201 task")
	check(gm.get_pending_monster_encounter().is_empty(),"201 accept resolves forced encounter")
	var eye = floor_node.get_node("DoorRoot/Room202/Door")
	cards.collect_card("SECURITY")
	cards.equip_card("SECURITY",cards.active_slot)
	player.global_position.x = eye.global_position.x - 110
	scheduler._process(0.1)
	check(eye.door_state == "CLOSED" and nose.door_state == "OPEN","Unfinished201 stays present and202 cannot preempt it")
	cards.collect_card("CLEANER")
	cards.equip_card("CLEANER",cards.active_slot)
	gm.record_work_result("STAIN_201");gm.submit_task("TASK_01_CLEAN")
	cards.equip_card("SECURITY",cards.active_slot)
	scheduler._process(0.0)
	check(eye.door_state == "WARNING" and nose.door_state == "CLOSED","Delivered201 retires and202 warns")
	scheduler._process(eye.warning_time)
	eye._physics_process(0.0)
	check(gm.get_pending_monster_encounter().get("first_encounter",false),"First encounter compulsory even with right card")
	scheduler._process(100)
	check(eye.door_state == "OPEN","Pending dialogue does not time out")
	gm.resolve_monster_encounter("202") # Explicit future D/A acknowledgement fixture.
	eye._physics_process(0.0)
	check(gm.get_pending_monster_encounter().is_empty(),"Known monster with right card passes")
	cards.reset_for_new_game()
	eye.set_managed_state("CLOSED")
	player.global_position.x = eye.global_position.x + 20
	eye._physics_process(0.0)
	check(gm.get_pending_monster_encounter().is_empty(),"Closed door passes without card")
	check(not eye.get_node("MonsterIdle").visible,"Closed door has no monster")
	var violations: Array[String] = []
	eye.rule_violated.connect(func(reason: String, _side: int): violations.append(reason))
	eye.set_managed_state("OPEN")
	eye._physics_process(0.0)
	check(violations == ["WRONG_CARD"] and gm.get_pending_monster_encounter().is_empty(),"Known wrong card requests safe return rather than centre wall")
	player.global_position.x = eye.global_position.x - 200
	eye.finish_safe_return()
	player.global_position.x = eye.global_position.x + 20
	gm.resolve_monster_encounter("202")
	eye.door_mode = "NORMAL" # Explicit ordinary-rule fixture after the formal202 checks.
	gm._seen_monsters["EAR"] = true
	eye.monster_type = "EAR"
	player.is_moving = false
	eye._physics_process(0.0)
	check(gm.get_pending_monster_encounter().is_empty(),"Ear stopped safe")
	player.is_moving = true
	eye._physics_process(0.0)
	check(violations.back() == "MOVED_NEAR_EAR","Ear movement requests safe return")
	player.global_position.x = eye.global_position.x - 200
	eye.finish_safe_return()
	player.global_position.x = eye.global_position.x + 20
	gm.resolve_monster_encounter("202")
	eye.monster_type = "CHECKER"
	eye._on_identity_changed("SWITCH_ACTIVE")
	check(violations.back() == "SWITCHED_NEAR_CHECKER","Checker retains no-change rule")
	gm.resolve_monster_encounter("202")
	eye.monster_type = "EYE"
	for i in range(400):
		for door in scheduler.doors:
			gm._seen_monsters[door.monster_type] = true
		player.global_position.x = scheduler.doors[i%5].global_position.x - 200
		scheduler._process(0.13)
		var count := 0
		for door in scheduler.doors:
			if door.door_state != "CLOSED":
				count += 1
		check(count <= 1,"Mutual exclusion tick " + str(i))
	var elapsed: float = scheduler.elapsed
	gm.set_modal_open("TEST",true)
	scheduler._process(5)
	check(scheduler.elapsed == elapsed,"Modal freezes scheduler")
	gm.set_modal_open("TEST",false)
	floor_node.queue_free()
	await process_frame
	for number in [3,4,5]:
		gm.current_floor = number
		var upper = load("res://scenes/levels/floor_%d.tscn" % number).instantiate()
		root.add_child(upper)
		await process_frame
		check(upper._doors.size() == (4 if number == 3 else 3 if number == 5 else 5),"Expected assembled doors on floor " + str(number))
		for door in upper._doors:
			check(catalog.pool(door.room_id).has(door.monster_type),"Runtime upper-floor assignment")
			check(door.has_node("MonsterIdle"),"Upper-floor animated stand-in")
		upper.queue_free()
		await process_frame
	gm.start_game()
	check(gm._room_monsters.is_empty(),"New game clears random assignments")
	check(not gm.has_met_monster("NOSE") and gm.get_pending_monster_encounter().is_empty(),"New game resets encounter history")
	for f in failures:
		printerr("FAIL: ",f)
	print("ENCOUNTER_FLOW: PASS" if failures.is_empty() else "ENCOUNTER_FLOW: FAIL")
	quit(0 if failures.is_empty() else 1)
