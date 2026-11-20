extends Node
## One active WARNING/OPEN door per loaded floor. Timers freeze with world input.
var doors: Array[Node2D] = []
var player: HotelPlayer
var active: Node2D
var elapsed := 0.0
var cooldown := 0.0


func task_phase(door: Node2D) -> String:
	# Fixed task rooms stop participating in the random cycle after acceptance.
	if not preload("res://scenes/doors/v4_door_catalog.gd").FIRST.has(door.room_id):
		return "CYCLE"
	if GameManager.get_completed_task_ids().has(door.task_id):
		return "CLOSED"
	if GameManager.current_task_id != door.task_id or GameManager.task_status not in ["ACTIVE", "READY_TO_SUBMIT", "FAILED"]:
		return "CYCLE"
	if GameManager.task_status == "FAILED" or door.room_id == "302":
		return "CLOSED"
	if door.room_id == "201":
		return "OPEN" if GameManager.get_world_flags().get("stain_201_cleaned_started", false) or GameManager.task_status == "READY_TO_SUBMIT" else "CLOSED"
	# Parcel/patrol/exit work happens elsewhere. Open only for the return visit.
	return "OPEN" if GameManager.task_status == "READY_TO_SUBMIT" and absf(player.global_position.x - door.global_position.x) <= door.story_radius else "CLOSED"


func _activate(door: Node2D, state: String) -> void:
	if is_instance_valid(active) and active != door:
		active.set_managed_state("CLOSED")
	active = door
	active.set_managed_state(state)


func prepare_delivery(door: Node2D) -> void:
	# E can arrive before this frame's scheduler tick. Open before the completion
	# signal synchronously opens a modal and freezes the scheduler.
	if GameManager.is_world_input_allowed() and doors.has(door) and task_phase(door) == "OPEN":
		_activate(door, "OPEN")


func _process(delta: float) -> void:
	if not GameManager.is_world_input_allowed() or not is_instance_valid(player):
		return
	# A persistent work/delivery opening reserves the one-door slot. Modal freezes
	# preserve it through the real delivery dialogue, then completion closes it.
	for door in doors:
		var phase := task_phase(door)
		if phase == "CLOSED":
			door.set_managed_state("CLOSED")
			if active == door:
				active = null
		elif phase == "OPEN":
			_activate(door, "OPEN")
			return
	var pending: Dictionary = GameManager.get_pending_monster_encounter()
	if not pending.is_empty():
		for door in doors:
			if door.room_id == pending.room_id:
				if is_instance_valid(active) and active != door:
					active.set_managed_state("CLOSED")
				active = door
				active.set_managed_state("OPEN")
				return
		return # A pending encounter on another floor cannot be overwritten.
	if is_instance_valid(active):
		if pending.get("room_id", "") == active.room_id:
			active.set_managed_state("OPEN")
			return
		elapsed += delta
		if elapsed >= active.warning_time + active.open_time:
			active.set_managed_state("CLOSED")
			active = null
			cooldown = 1.5
		elif elapsed >= active.warning_time:
			active.set_managed_state("OPEN")
	# First contact takes priority even if a different door was cycling.
	var nearest: Node2D
	var distance := 210.0
	for door in doors:
		if task_phase(door) != "CYCLE":
			continue
		var d := absf(player.global_position.x-door.global_position.x)
		if not GameManager.has_met_monster(door.monster_type) and d < distance:
			distance = d
			nearest = door
	if nearest != null and (active == null or pending.is_empty()):
		if active != null and active != nearest:
			active.set_managed_state("CLOSED")
		active = nearest
		elapsed = active.warning_time
		active.set_managed_state("OPEN")
		return
	if active != null:
		return
	cooldown -= delta
	if cooldown > 0.0 or doors.is_empty():
		return
	var candidates: Array[Node2D] = []
	for door in doors:
		if task_phase(door) == "CYCLE" and absf(player.global_position.x-door.global_position.x) < 400.0:
			candidates.append(door)
	if candidates.is_empty():
		cooldown = 0.5
		return
	active = candidates.pick_random()
	elapsed = 0.0
	active.set_managed_state("WARNING")
