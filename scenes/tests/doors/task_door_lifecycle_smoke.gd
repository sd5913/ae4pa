extends SceneTree
## Real task/work/door APIs without the unrelated animated main-menu fixture.
var failures: Array[String] = []
var game: Node
var cards: Node
var host: Node2D
var floor_node: Node
var scheduler: Node
var dialogue: Control

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		printerr("FAIL: ", message)

func settle() -> void:
	for i in range(5): await physics_frame
	await process_frame

func bind_floor() -> void:
	floor_node = host.get_child(0)
	floor_node.set_process(false)
	floor_node.player.set_physics_process(false)
	for door in floor_node._doors:
		door.set_physics_process(false)
	for child in floor_node.get_children():
		if child.get_script() == load("res://scenes/doors/door_scheduler.gd"):
			scheduler = child
			scheduler.set_process(false)

func travel(number: int) -> void:
	floor_node.player.position.x = floor_node.get_stair_interaction_center(number > game.current_floor)
	check(game.request_floor_travel(number), "Real stair travel to " + str(number))
	bind_floor()
	await settle()

func press_e() -> void:
	floor_node._refresh_component_eligibility()
	floor_node._needs_e_release = false
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	floor_node._unhandled_input(event)

func close_dialogue() -> void:
	for i in range(30):
		if not dialogue.visible: break
		dialogue.advance()
	floor_node.set_monster_dialogue_room("")

func run() -> void:
	game = root.get_node("GameManager")
	cards = root.get_node("CardManager")
	host = Node2D.new()
	root.add_child(host)
	game.set_floor_host(host)
	game.start_game()
	game.set_process(false)
	game.complete_manager_intro()
	bind_floor()
	await travel(2)
	dialogue = load("res://scenes/ui/monster_dialogue.gd").new()
	root.add_child(dialogue)
	game.task_completed.connect(func(task: String):
		if task in ["TASK_01_CLEAN", "TASK_02_PARCEL"]:
			floor_node.set_monster_dialogue_room("201" if task == "TASK_01_CLEAN" else "202")
		if task in ["TASK_01_CLEAN", "TASK_02_PARCEL"]:
			check(dialogue.show_dialogue("NOSE:DELIVERED" if task == "TASK_01_CLEAN" else "EYE:DELIVERED"), "Real delivery dialogue opens")
	)
	var nose: Node2D = floor_node.get_node("DoorRoot/Room201/Door")
	floor_node.player.global_position.x = nose.global_position.x - 112
	scheduler._process(0.1)
	check(nose.door_state == "WARNING", "201 first approach warns before opening")
	scheduler._process(nose.warning_time)
	nose._physics_process(0)
	check(nose.door_state == "OPEN" and game.task_status == "AVAILABLE", "201 initial encounter opens and offers")
	check(game.accept_task("TASK_01_CLEAN"), "201 actual acceptance")
	scheduler._process(0)
	check(nose.door_state == "OPEN", "Accepted201 keeps resident supervising")
	await travel(1)
	cards.collect_card("CLEANER")
	cards.equip_card("CLEANER", cards.active_slot)
	await travel(2)
	nose = floor_node.get_node("DoorRoot/Room201/Door")
	floor_node.player.global_position.x = nose.global_position.x - 112
	for i in range(10): scheduler._process(10)
	check(nose.door_state == "OPEN", "Returning keeps201 resident without replaying warning")
	check(not game.record_work_started("PARCEL_CABINET_2F"), "Unrelated work cannot start supervision")
	floor_node.player.global_position.x = 852
	await settle()
	press_e()
	check(floor_node._work.is_interacting(), "E begins actual cleaning component")
	scheduler._process(0)
	check(nose.door_state == "OPEN", "Starting real cleaning opens 201")
	floor_node._cancel_held_interaction()
	scheduler._process(100)
	check(nose.door_state == "OPEN", "Cancelled hold does not end supervision")
	await travel(1)
	await travel(2)
	nose = floor_node.get_node("DoorRoot/Room201/Door")
	scheduler._process(100)
	check(nose.door_state == "OPEN", "Supervision survives floor unload and revisit")
	floor_node.player.global_position.x = 852
	await settle()
	press_e()
	floor_node._work.advance_interaction(2)
	check(game.task_status == "READY_TO_SUBMIT", "Actual cleaning completes through authoritative work report")
	floor_node.player.global_position.x = nose.global_position.x - 110
	scheduler._process(100)
	press_e()
	check(game.get_completed_task_ids().has("TASK_01_CLEAN") and dialogue.visible, "201 delivery reaches real completion dialogue")
	scheduler._process(100)
	check(nose.door_state == "OPEN", "201 remains open throughout completion dialogue")
	close_dialogue()
	scheduler._process(0)
	check(nose.door_state == "CLOSED", "201 closes when completion dialogue ends")
	for i in range(10): scheduler._process(10)
	check(nose.door_state == "CLOSED", "Completed 201 never random-opens again")
	var eye: Node2D = floor_node.get_node("DoorRoot/Room202/Door")
	floor_node.player.global_position.x = eye.global_position.x - 110
	scheduler._process(0)
	check(eye.door_state == "WARNING", "202 first approach warns before opening")
	scheduler._process(eye.warning_time)
	eye._physics_process(0)
	floor_node._try_offer_task_02()
	check(game.accept_task("TASK_02_PARCEL"), "202 actual acceptance")
	for i in range(10): scheduler._process(10)
	check(eye.door_state == "OPEN", "202 resident supervises throughout task")
	cards.collect_card("SECURITY")
	cards.equip_card("SECURITY", cards.active_slot)
	floor_node.player.global_position.x = 990
	await settle()
	press_e()
	check(game.task_status == "READY_TO_SUBMIT", "Actual parcel cabinet reports pickup")
	scheduler._process(100)
	check(eye.door_state == "OPEN", "202 resident stays visible away from doorway")
	floor_node.player.global_position.x = eye.global_position.x - 110
	scheduler._process(0)
	check(eye.door_state == "OPEN" and nose.door_state == "CLOSED", "Return to 202 opens only that door")
	# Reproduce E on the entry frame before the scheduler gets its next tick.
	eye.set_managed_state("CLOSED")
	var other: Node2D = floor_node.get_node("DoorRoot/Room203/Door")
	scheduler.active = other
	other.set_managed_state("OPEN")
	press_e()
	scheduler._process(100)
	check(dialogue.visible and eye.door_state == "OPEN" and other.door_state == "CLOSED", "Entry-frame delivery opens202 before modal and closes previous door")
	close_dialogue()
	scheduler._process(0)
	check(eye.door_state == "CLOSED", "202 closes after dialogue")
	check(load("res://scenes/tests/core/tutorial_test_setup.gd").complete_remaining(game, cards), "Explicit203–205 prerequisite fixture before independent302 regression")
	await travel(3)
	if game.current_floor != 3:
		printerr("STATE: ", game.current_task_id, " / ", game.task_status, " / ", game.get_pending_monster_encounter())
		quit(1)
		return
	var hat: Node2D = floor_node.get_node("DoorRoot/Room302/Door")
	floor_node.player.global_position.x = hat.global_position.x + 200
	floor_node._apply_task_route()
	check(floor_node.player.global_position.x <= hat.global_position.x - 112, "302 unaccepted gate clamps an actor arriving from the right")
	floor_node._try_offer_task_03()
	scheduler._process(0)
	check(game.task_status == "AVAILABLE" and hat.door_state == "OPEN", "Mandatory 302 encounter opens before acceptance")
	check(game.accept_task("TASK_03_AUTHORIZE"), "302 actual acceptance")
	for i in range(10): scheduler._process(10)
	check(hat.door_state == "CLOSED", "302 never reopens during management task")
	cards.collect_card("MANAGER")
	cards.equip_card("MANAGER", cards.active_slot)
	floor_node.player.global_position.x = floor_node.get_node("Interactions/Register309").global_position.x
	await settle()
	press_e()
	check(game.get_completed_task_ids().has("TASK_03_AUTHORIZE"), "Actual registration completes task03")
	floor_node.player.global_position.x = hat.global_position.x
	for i in range(10): scheduler._process(10)
	check(hat.door_state == "CLOSED", "Completed302 remains closed on return")
	# Tasks04/05 are not enabled in this revision. Supply explicit future-state
	# fixtures only to verify the common scheduler policy, never claim gameplay.
	for pair in [[4, "403", "TASK_04_PATROL"], [5, "501", "TASK_05_EXIT"]]:
		game._load_floor(pair[0])
		bind_floor()
		var door: Node2D = floor_node.get_node("DoorRoot/Room" + pair[1] + "/Door")
		check(not load("res://scenes/doors/v4_door_catalog.gd").FIRST.has(pair[1]), "Later task room is not duplicate first teaching")
		game.current_task_id = pair[2]
		game.task_status = "ACTIVE"
		floor_node.player.global_position.x = door.global_position.x
		scheduler._process(100)
		check(door.door_state == "CLOSED", "Future active task room stays closed: " + pair[1])
		game.task_status = "READY_TO_SUBMIT"
		scheduler._process(0)
		check(door.door_state == "OPEN", "Future delivery opens room: " + pair[1])
		game._completed_task_ids.append(pair[2])
		game.task_status = "COMPLETED"
		for i in range(10): scheduler._process(10)
		check(door.door_state == "CLOSED", "Completed task never reopens: " + pair[1])
	dialogue.queue_free()
	host.queue_free()
	await process_frame
	game.set_floor_host(null)
	game.set_process(true)
	for failure in failures: printerr("FAIL: ", failure)
	print("TASK_DOOR_LIFECYCLE: PASS" if failures.is_empty() else "TASK_DOOR_LIFECYCLE: FAIL")
	quit(0 if failures.is_empty() else 1)
