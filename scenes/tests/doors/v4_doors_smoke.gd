extends SceneTree

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: Node = load("res://scenes/tests/doors/v4_doors_test.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var story = scene.story
	var door = scene.normal
	var player = scene.player
	var manager = root.get_node("GameManager")
	var cards = root.get_node("CardManager")
	scene.auto_return = false
	scene.set_physics_process(false)
	player.set_physics_process(false)
	for item: Node in [story, door, scene.get_node("NeighborDoor")]:
		item.set_process(false)
		item.set_physics_process(false)
	manager.start_game()
	for phase: float in [0.0, 5.6, 7.0]:
		scene.events.clear()
		scene.set_test_state("NONE")
		story.offset = phase
		story.reset_cycle()
		player.global_position.x = 500.0
		story._physics_process(0.0)
		player.global_position.x = 700.0
		story._physics_process(0.0)
		_expect(_count(scene, "story") == 1, "Story intercept at phase " + str(phase))
		for repeat: int in range(10):
			story._physics_process(0.0)
		story.reset_cycle()
		player.global_position.x = 500.0
		story._physics_process(0.0)
		player.global_position.x = 700.0
		story._physics_process(0.0)
		_expect(_count(scene, "story") == 1 and _count(scene, "violation") == 0, "No dialogue replay or normal outcome")
		scene.set_test_state("ACTIVE")
		player.global_position.x = 500.0
		story._physics_process(0.0)
		player.global_position.x = 700.0
		story._physics_process(0.0)
		story._physics_process(0.0)
		_expect(_count(scene, "progress") == 1, "Active reapproach gives one progress hint")
		_expect(not story.request_interaction(), "Active cannot submit")
		# Working and stair routes remain reachable; only a separate downstream lock.
		for x: float in [900.0, 192.0]:
			player.global_position.x = x
			scene._physics_process(0.0)
			_expect(player.global_position.x == x, "Accepted task leaves work/stair route open")
		story.offset = 0.0
		story.reset_cycle()
		player.global_position.x = 1500.0
		scene._physics_process(0.0)
		_expect(player.global_position.x == 1430.0 and not scene.permission_open, "Closed door cannot bypass downstream task lock")
		scene.set_test_state("READY_TO_SUBMIT")
		_expect(not story.request_interaction(), "Out of range E rejected")
		player.global_position.x = 700.0
		story._physics_process(0.0)
		_expect(_count(scene, "submit") == 0 and not scene.permission_open, "Ready alone does not submit or unlock")
		_expect(story.request_interaction(), "E requests submission")
		_expect(not story.request_interaction() and _count(scene, "submit") == 1, "Submission is not repeated")
		_expect(scene.permission_open, "Only test receiver completion opens permission")
	# Keep the full original five-monster conditions; migrate outcome to event only.
	var required: Dictionary = {"EYE": "SECURITY", "NOSE": "CLEANER", "HAT": "MANAGER"}
	var cases: int = 0
	for kind: String in ["EYE", "NOSE", "HAT", "EAR", "CHECKER"]:
		for phase: float in [0.0, 5.6, 7.0]:
			for distance: float in [-90.1, -90.0, 0.0, 90.0, 90.1]:
				for card: String in ["NONE", "SECURITY", "CLEANER", "MANAGER"]:
					for moving: bool in [false, true]:
						manager.start_game()
						scene.events.clear()
						door.monster_type = kind
						door.offset = phase
						door.reset_cycle()
						var side: int = -1 if distance <= 0.0 else 1
						player.global_position.x = door.global_position.x + side * 200.0
						door.finish_safe_return()
						door._physics_process(0.0)
						if card != "NONE":
							cards.collect_card(card)
						player.global_position.x = door.global_position.x + distance
						player.is_moving = moving
						var before: Vector2 = player.global_position
						door._physics_process(0.0)
						var danger: bool = phase == 7.0 and absf(distance) <= 90.0 and ((required.has(kind) and card != required[kind]) or (kind == "EAR" and moving))
						_expect(_count(scene, "violation") == int(danger), "V4 rule matrix %s %s %s %s %s" % [kind, phase, distance, card, moving])
						_expect(manager.game_state == "PLAYING" and player.global_position == before, "Door never fails game or teleports")
						if danger:
							var event: Dictionary = scene.events.back()
							_expect(event.side == side and event.room == "TEST_NORMAL", "Report contains source room and pre-entry side")
							_expect(event.reason == ("MOVED_NEAR_EAR" if kind == "EAR" else "WRONG_CARD"), "Reason preserved")
							door._physics_process(0.0)
							_expect(_count(scene, "violation") == 1, "One report while recovery pending")
						cases += 1
	# Actual CardManager events remain the sole CHECKER trigger.
	door.monster_type = "CHECKER"
	for phase: float in [0.0, 5.6, 7.0]:
		for distance: float in [-90.1, -90.0, 0.0, 90.0, 90.1]:
			for action: String in ["SWITCH_ACTIVE", "EQUIP_CARD"]:
				manager.start_game()
				scene.events.clear()
				door.offset = phase
				door.reset_cycle()
				player.global_position.x = 900.0
				door.finish_safe_return()
				door._physics_process(0.0)
				cards.collect_card("SECURITY")
				cards.collect_card("CLEANER")
				cards.collect_card("MANAGER")
				player.global_position.x = door.global_position.x + distance
				cards.cards_changed.emit()
				_expect(_count(scene, "violation") == 0, "Refresh/collection are safe")
				if action == "SWITCH_ACTIVE":
					cards.switch_active()
				else:
					cards.equip_card("MANAGER", 1 - cards.active_slot)
				var danger: bool = phase == 7.0 and absf(distance) <= 90.0
				_expect(_count(scene, "violation") == int(danger), "Real checker event conditions")
				if danger:
					_expect(scene.events.back().reason == "SWITCHED_NEAR_CHECKER", "Checker reason")
	# Side is entry history, even if facing flips after entry. A test receiver returns.
	door.monster_type = "EYE"
	door.offset = 7.0
	door.reset_cycle()
	for side: int in [-1, 1]:
		await physics_frame
		manager.start_game()
		scene.events.clear()
		player.global_position.x = door.global_position.x + side * 200.0
		door.finish_safe_return()
		door._physics_process(0.0)
		player.global_position.x = door.global_position.x + side * 20.0
		player.facing_direction = side # Facing now points back toward entry.
		door._physics_process(0.0)
		_expect(scene.events.back().side == side, "Facing does not choose return side")
		_expect(not door.finish_safe_return(), "Cannot acknowledge inside danger zone")
		_expect(scene.execute_test_return(side), "Test receiver safely completes return")
		_expect(player.global_position.x == (950.0 if side == -1 else 1250.0), "Correct left/right safe point")
		var safe_position: Vector2 = player.global_position
		_expect(not scene.execute_test_return(-side) and player.global_position == safe_position, "Test coordinator rejects second same-frame return")
		for repeat: int in range(5):
			door._physics_process(0.0)
		_expect(_count(scene, "violation") == 1, "Return does not chain report")
	for point: Vector2 in [Vector2(1100, 560), Vector2(2000, 560), Vector2(700, 560), Vector2(1450, 560), Vector2(1600, 560)]:
		_expect(not scene.safe_point_valid(point, 1), "Reject unsafe point " + str(point))
	# Unknown spawn inside must not guess a direction from facing.
	door.setup(null)
	door.setup(player)
	player.global_position.x = 1100.0
	scene.events.clear()
	door._physics_process(0.0)
	_expect(_count(scene, "violation") == 0, "Unknown inside spawn awaits outside sample")
	# Pausing must not consume a live checker event in this M1 context.
	# Full pre-bag context handling is deliberately deferred to M2.
	player.global_position.x = 900.0
	door.finish_safe_return()
	door._physics_process(0.0)
	door.monster_type = "CHECKER"
	player.global_position.x = 1100.0
	scene.events.clear()
	paused = true
	cards.switch_active()
	_expect(_count(scene, "violation") == 0, "M1 paused world produces no ordinary report")
	paused = false
	cards.switch_active()
	_expect(_count(scene, "violation") == 1, "Real checker event remains covered after resume")
	scene.queue_free()
	await process_frame
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS C-V4-01~03: phase-independent 201, progress/submit/permit separation, 600 event-only rules, 30 real identity events, bidirectional entry history, safe return validation.")
	quit(0 if failures.is_empty() else 1)


func _count(scene: Node, kind: String) -> int:
	var count: int = 0
	for event: Dictionary in scene.events:
		if event.event == kind:
			count += 1
	return count


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
