extends SceneTree
## Production ordinary doors3–5F plus an explicit2F ordinary-component compatibility fixture.
var failures: Array[String] = []
var game: Node
var cards: Node
var host: Node2D

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		printerr("FAIL: ", message)

func settle() -> void:
	for i in range(5): await physics_frame
	await process_frame

func run() -> void:
	game = root.get_node("GameManager")
	cards = root.get_node("CardManager")
	host = Node2D.new()
	root.add_child(host)
	game.set_floor_host(host)
	game.start_game()
	game.set_process(false)
	# Explicit unlocked-floor fixtures exercise the real production detectors;
	# this does not claim completed task04/05 gameplay.
	for number in [2, 3, 4, 5]:
		game.current_task_id = "TASK_03_AUTHORIZE"
		game.task_status = "ACTIVE"
		game._completed_task_ids.assign(["TASK_01_CLEAN", "TASK_02_PARCEL"])
		# Unlocked later-floor fixture: test ordinary returns beyond the new story gates.
		if number >= 4: game._completed_task_ids.append("TASK_04_PATROL")
		if number == 5: game._completed_task_ids.append("TASK_05_EXIT")
		game._world_flags = {"passage_201_unlocked": true, "passage_202_unlocked": true}
		game._pending_monster_encounter.clear()
		game._seen_monsters = {"NOSE": true, "EYE": true, "HAT": true, "EAR": true, "CHECKER": true}
		game._load_floor(number)
		var floor_node: Node = host.get_child(0)
		floor_node.set_process(false)
		floor_node.player.set_physics_process(false)
		for child in floor_node.get_children():
			if child.get_script() == load("res://scenes/doors/door_scheduler.gd"):
				child.set_process(false)
		for item in floor_node._doors:
			item.set_physics_process(false)
		var room: String = {2: "203", 3: "301", 4: "401", 5: "502"}[number]
		var door: Node2D = floor_node.get_node("DoorRoot/Room" + room + "/Door")
		# All2F doors are now compulsory tutorials. Only this isolated detector fixture
		# converts203 to NORMAL to retain2F landing/inspection API coverage.
		if number == 2: door.door_mode = "NORMAL"
		var player = floor_node.player
		var memory: Vector2 = floor_node.return_point.global_position
		door.monster_type = "NOSE"
		game.remaining_time = 37.5
		cards.reset_for_new_game()
		var truth: Dictionary = game.get_world_flags()
		for side in [-1, 1]:
			await settle()
			player.global_position.x = door.global_position.x + side * 60
			door._last_managed_x = door.global_position.x + side * 180
			door.set_managed_state("OPEN")
			door._physics_process(0)
			check(player.global_position == memory, "Wrong ID from either side returns to left stairs: " + room + "/" + str(side))
			check(game.game_state == "SAFE_RETURN" and not player.is_moving, "Return locks input and clears movement")
			game._process(5)
			check(game.remaining_time == 37.5 and game.task_status == "ACTIVE", "Return preserves active task and timer")
			check(game.get_pending_monster_encounter().is_empty(), "Wrong ID does not leave a centre-wall encounter")
			await settle()
			check(game.game_state == "PLAYING" and not door._violation_pending, "Return resumes and acknowledges real detector")
			check(game.get_world_flags() == truth and cards.get_owned_cards().is_empty(), "Return preserves inventory and world progress")
		# Correct card passes even from the right; closed doors need no card.
		cards.collect_card("CLEANER")
		for side in [-1, 1]:
			player.global_position.x = door.global_position.x + side * 60
			door._last_managed_x = door.global_position.x + side * 180
			door._physics_process(0)
			check(is_equal_approx(player.global_position.x, door.global_position.x + side * 60), "Correct ID passes from either side: " + room)
		door.set_managed_state("CLOSED")
		cards.equip_card("NONE", cards.active_slot)
		door._physics_process(0)
		check(game.game_state == "PLAYING" and player.global_position != memory, "Closed door passes without ID")
		# Existing EAR and CHECKER rules use the same safe landing.
		door.monster_type = "EAR"
		door.set_managed_state("OPEN")
		player.is_moving = false
		door._physics_process(0)
		check(game.game_state == "PLAYING", "EAR still permits stopping")
		player.is_moving = true
		door._physics_process(0)
		check(player.global_position == memory, "EAR moving returns to left stairs")
		await settle()
		door.monster_type = "CHECKER"
		player.global_position.x = door.global_position.x + 60
		door._last_managed_x = door.global_position.x + 180
		cards.switch_active()
		check(player.global_position == memory, "CHECKER nearby switch returns to left stairs")
		await settle()
		player.global_position.x = door.global_position.x - 60
		door._last_managed_x = door.global_position.x - 180
		door._sample_entry()
		# Explicit inspection protocol retains evidence while a modal is open.
		door._entry_side = -1
		check(door.begin_identity_inspection(), "Begin checker inspection")
		game.set_modal_open("RETURN_TEST", true)
		cards.switch_active()
		game.set_modal_open("RETURN_TEST", false)
		check(door.end_identity_inspection() and player.global_position == memory, "Deferred checker inspection also returns to stairs")
		await settle()
		var foreign := Node2D.new()
		root.add_child(foreign)
		player.global_position.x = door.global_position.x + 60
		var before: Vector2 = player.global_position
		game.request_safe_return(foreign, "WRONG_CARD", -1)
		game.request_safe_return(door, "WRONG_CARD", 0)
		check(player.global_position == before, "Foreign source and unknown side cannot teleport")
		foreign.queue_free()
		var radius_before: float = door.radius
		door.radius = absf(door.global_position.x - memory.x) + 1
		check(floor_node.get_safe_return_position(door, -1).is_empty(), "Reject memory point inside a changed danger radius")
		door.radius = radius_before
		game._process(1)
		check(game.remaining_time == 36.5, "The same countdown resumes after return")
	game.set_floor_host(null)
	host.queue_free()
	await process_frame
	game.set_process(true)
	print("SAFE_RETURN: PASS" if failures.is_empty() else "SAFE_RETURN: FAIL")
	quit(0 if failures.is_empty() else 1)
