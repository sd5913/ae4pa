extends Node
## One active WARNING/OPEN door per loaded floor. Timers freeze with world input.
var doors: Array[Node2D] = []
var player: HotelPlayer
var active: Node2D
var elapsed := 0.0
var cooldown := 0.0
## A opts the five2F teaching doors into a persistent encounter lifecycle.
var tutorial_mode := false
var story_dialogue_room := ""

func set_story_dialogue_room(room_id: String) -> void:
	story_dialogue_room = room_id
	if tutorial_mode: sync_tutorial_visuals()

func sync_tutorial_visuals() -> void:
	for door: Node2D in doors:
		if not story_dialogue_room.is_empty():
			door.set_managed_state("OPEN" if story_dialogue_room == door.room_id else "CLOSED")
		elif GameManager.get_completed_task_ids().has(door.task_id):
			door.set_managed_state("CLOSED")
		elif GameManager.is_tutorial_room_revealed(door.room_id):
			door.set_managed_state("OPEN")
		elif door == active:
			door.set_managed_state("WARNING")
		else:
			door.set_managed_state("CLOSED")

func _process_tutorial(delta: float) -> void:
	sync_tutorial_visuals() # Dialogue can freeze input, never its visible resident.
	if not GameManager.is_world_input_allowed() or not is_instance_valid(player): return
	if is_instance_valid(active):
		if GameManager.is_tutorial_room_revealed(active.room_id) or not GameManager.can_offer_task(active.task_id):
			active = null
		else:
			elapsed += delta
			if elapsed >= active.warning_time:
				if GameManager.reveal_tutorial_room(active.room_id): active.set_managed_state("OPEN")
			return
	for door: Node2D in doors:
		if GameManager.can_offer_task(door.task_id) and absf(player.global_position.x-door.global_position.x) < 210.0:
			if GameManager.is_tutorial_room_revealed(door.room_id): return
			active = door
			elapsed = 0.0
			door.set_managed_state("WARNING")
			return



func task_phase(door: Node2D) -> String:
	# 2F owns its first-meeting lifecycle. Later fixed tasks are independent of
	# the random monster assignment and must not become duplicate tutorials.
	var task_id: String = {"302":"TASK_03_AUTHORIZE", "403":"TASK_04_PATROL", "501":"TASK_05_EXIT"}.get(door.room_id, "")
	if task_id.is_empty():
		return "CYCLE"
	if GameManager.get_completed_task_ids().has(task_id):
		return "CLOSED"
	if GameManager.current_task_id != task_id or GameManager.task_status not in ["ACTIVE", "READY_TO_SUBMIT", "FAILED"]:
		return "CYCLE"
	if GameManager.task_status == "FAILED" or door.room_id == "302":
		return "CLOSED"
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
	if tutorial_mode:
		_process_tutorial(delta)
		return
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
