extends SceneTree
## Explicit TEST adapter for the proposed pre-bag context; no production UI wiring.
var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: Node = load("res://scenes/tests/doors/v4_doors_test.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var game: Node = root.get_node("GameManager")
	var cards: Node = root.get_node("CardManager")
	var door: Node = scene.normal
	var player: Node2D = scene.player
	scene.auto_return = false
	scene.set_physics_process(false)
	player.set_physics_process(false)
	for item: Node in [scene.story, door, scene.get_node("NeighborDoor")]:
		item.set_process(false)
		item.set_physics_process(false)
	game.start_game()
	game.set_process(false)
	cards.collect_card("SECURITY")
	cards.collect_card("CLEANER")
	cards.collect_card("MANAGER")
	door.monster_type = "CHECKER"
	for side: int in [-1, 1]:
		for action: String in ["Q", "ACTIVE_SLOT", "SPARE_SLOT", "RESTORE", "INVALID"]:
			door.end_identity_inspection(false)
			player.position.x = door.position.x + side * 200.0
			door.finish_safe_return()
			door.offset = 7.0
			door.reset_cycle()
			door._physics_process(0.0)
			player.position.x = door.position.x + side * 20.0
			door._physics_process(0.0)
			scene.events.clear()
			cards.restore_snapshot({"owned_cards": ["SECURITY", "CLEANER", "MANAGER"],
				"equipped_cards": ["SECURITY", "CLEANER"], "active_slot": 0})
			_expect(door.begin_identity_inspection(), "Capture OPEN entry before modal")
			_expect(not door.begin_identity_inspection(), "Duplicate capture cannot replace evidence")
			game.set_modal_open("C_TEST_BAG", true)
			game.set_modal_open("C_TEST_HELP", true)
			var cycle_before: float = door._cycle_time
			door._process(2.0)
			_expect(door._cycle_time == cycle_before, "Door cycle freezes with world modal")
			match action:
				"Q":
					var event := InputEventAction.new()
					event.action = "switch_id"
					event.pressed = true
					cards._unhandled_input(event) # Real B Q handler; no substitute card model.
				"ACTIVE_SLOT": cards.equip_card("MANAGER", 0)
				"SPARE_SLOT": cards.equip_card("MANAGER", 1)
				"RESTORE": cards.restore_snapshot(cards.export_snapshot())
				"INVALID":
					cards.equip_card("NOT_A_CARD", 1)
					cards.equip_card("SECURITY", 0)
					cards.cards_changed.emit()
			_expect(scene.events.is_empty(), "Frozen modal never emits a premature return")
			game.set_modal_open("C_TEST_BAG", false)
			_expect(not door.end_identity_inspection(), "Other modal keeps snapshot pending")
			game.set_modal_open("C_TEST_HELP", false)
			door.offset = 0.0 # Captured phase wins; live cycle cannot erase earlier evidence.
			door.reset_cycle()
			_expect(door.end_identity_inspection(), "Resolve once after last modal")
			var changed: bool = action in ["Q", "ACTIVE_SLOT", "SPARE_SLOT"]
			_expect(scene.events.size() == int(changed), "Real changes only: " + action)
			if changed:
				_expect(scene.events[0].side == side, "Captured approach side survives modal")
				cards.switch_active()
				_expect(scene.events.size() == 1, "Pending return prevents duplicates")
			_expect(not door.end_identity_inspection(), "No second resolution")
	# Snapshot is unavailable outside, CLOSED, WARNING, STORY, unknown entry.
	player.position.x = door.position.x - 200.0
	door.finish_safe_return()
	_expect(not door.begin_identity_inspection(), "Outside cannot capture")
	player.position.x = door.position.x - 20.0
	for phase: float in [0.0, 5.6]:
		door.offset = phase
		door.reset_cycle()
		_expect(not door.begin_identity_inspection(), "Safe phases cannot capture")
	door.offset = 7.0
	door.reset_cycle()
	door.door_mode = "STORY"
	_expect(not door.begin_identity_inspection(), "Story checker never runs ordinary inspection")
	door.door_mode = "NORMAL"
	door._physics_process(0.0)
	scene.events.clear()
	_expect(door.begin_identity_inspection(), "Capture for cancellation")
	cards.switch_active()
	_expect(door.end_identity_inspection(false) and scene.events.is_empty(), "Failure/travel cancellation drops evidence")
	_expect(door.begin_identity_inspection(), "Capture for stale position")
	cards.switch_active()
	player.position.x -= 1.0
	_expect(not door.end_identity_inspection() and scene.events.is_empty(), "Moved actor invalidates frozen context")
	door.setup(null)
	door.setup(player)
	_expect(not door.begin_identity_inspection(), "Rebinding inside cannot invent direction")
	# In ordinary modal mode (no capture), all five live rules must stay silent.
	game.set_modal_open("C_TEST_BAG", true)
	for monster: String in ["EYE", "NOSE", "HAT", "EAR", "CHECKER"]:
		door.monster_type = monster
		player.is_moving = true
		door._physics_process(0.0)
		cards.switch_active()
	_expect(scene.events.is_empty(), "No ordinary reports during modal without explicit capture")
	game.set_modal_open("C_TEST_BAG", false)
	var listener_count: int = cards.identity_changed.get_connections().size()
	door.setup(player)
	door.setup(player)
	_expect(cards.identity_changed.get_connections().size() == listener_count, "Repeated setup does not duplicate listeners")
	scene.queue_free()
	await process_frame
	_expect(cards.identity_changed.get_connections().size() < listener_count, "Unloaded doors disconnect listeners")
	game.set_process(true)
	for failure: String in failures:
		printerr("FAIL: ", failure)
	if failures.is_empty():
		print("PASS C-V4-04: real Q/equipment, spare slot, snapshot restore, nested modals, phase snapshot, lifecycle and event-only guards. TEST adapter; production bag wiring pending.")
	quit(0 if failures.is_empty() else 1)


func _expect(value: bool, message: String) -> void:
	if not value:
		failures.append(message)
