extends Node
## A owns session state and optional floor loading; standalone component tests need no host.

signal state_changed(new_state: String)
signal game_failed(reason: String)
signal floor_changed(floor_number: int)
signal task_offered(task_id: String)
signal task_updated()
signal task_completed(task_id: String)
signal task_failed(task_id: String, reason: String)
signal modal_changed()
signal safe_return_started(reason: String)
signal notebook_changed()
signal friend_rescued()
signal game_won()
## D/A consume this request; the pending encounter is not a completed task.
signal monster_encounter_requested(context: Dictionary)
var _room_monsters: Dictionary = {}
var _seen_monsters: Dictionary = {}
var _pending_monster_encounter: Dictionary = {}

func get_room_monster(room: String) -> String:
	if not _room_monsters.has(room):
		var fixed := {"302": "HAT", "403": "EAR", "501": "CHECKER"}
		var choices: Array = [fixed[room]] if fixed.has(room) else preload("res://scenes/doors/v4_door_catalog.gd").pool(room)
		if choices.is_empty():
			return ""
		_room_monsters[room] = choices.pick_random()
	return _room_monsters[room]

func has_met_monster(kind: String) -> bool:
	return _seen_monsters.has(kind)

func get_pending_monster_encounter() -> Dictionary:
	return _pending_monster_encounter.duplicate(true)

func request_monster_encounter(room: String, kind: String, reason: String) -> bool:
	if not is_world_input_allowed() or not _pending_monster_encounter.is_empty():
		return false
	var first := not has_met_monster(kind)
	var fixed_tasks := {"302": TASK_03_ID, "403": TASK_04_ID, "501": TASK_05_ID}
	_pending_monster_encounter = {"room_id":room,"monster_type":kind,"first_encounter":first,"reason":reason,"task_id":fixed_tasks.get(room, preload("res://scenes/doors/v4_door_catalog.gd").TASKS[kind])}
	_seen_monsters[kind] = true
	monster_encounter_requested.emit(get_pending_monster_encounter())
	return true

## Called by the task/chat adapter only after the forced encounter is handled.
func resolve_monster_encounter(room: String) -> bool:
	if _pending_monster_encounter.get("room_id", "") != room:
		return false
	_pending_monster_encounter.clear()
	return true


const STAIR_INTERACTION_RADIUS := 70.0

const TaskDefinitions = preload("res://scripts/task_definitions.gd")
const TASK_01_ID: String = "TASK_01_CLEAN"
const TASK_02_ID: String = "TASK_02_PARCEL"
const TASK_03_ID: String = "TASK_03_AUTHORIZE"
const TASK_04_ID: String = "TASK_04_PATROL"
const TASK_05_ID: String = "TASK_05_EXIT"
const LATE_TASKS: Array[String] = [TASK_04_ID, TASK_05_ID]
const TUTORIAL_03_ID := "TASK_T03_ROOM_SERVICE"
const TUTORIAL_04_ID := "TASK_T04_DUAL_WORK"
const TUTORIAL_05_ID := "TASK_T05_TRANSIT"
const TUTORIAL_TASKS: Array[String] = [TASK_01_ID, TASK_02_ID, TUTORIAL_03_ID, TUTORIAL_04_ID, TUTORIAL_05_ID]
const ENABLED_TASKS: Array[String] = [TASK_01_ID, TASK_02_ID, TUTORIAL_03_ID, TUTORIAL_04_ID, TUTORIAL_05_ID, TASK_03_ID, TASK_04_ID, TASK_05_ID]

var game_state: String = "MENU"
var current_floor: int = 1
var has_friend: bool = false
var fail_reason: String = ""
var current_task_id: String = "NONE"
var task_status: String = "NONE"
var remaining_time: float = 0.0
var _floor_host: Node2D
var _preview_enabled: bool = false
var _manager_intro_finished: bool = false
var _completed_task_ids: Array[String] = []
var _world_flags: Dictionary = {}
var _open_modals: Dictionary = {}
var _visited_floors: Array[int] = []
var _safe_return_in_progress: bool = false
var _last_safe_return_frame: int = -1
var _task_checkpoint: Dictionary = {}


func _process(delta: float) -> void:
	if game_state != "PLAYING" or task_status not in ["ACTIVE", "READY_TO_SUBMIT"] or not _open_modals.is_empty():
		return
	remaining_time = maxf(0.0, remaining_time - delta)
	if is_zero_approx(remaining_time):
		request_task_failure("TASK_TIMEOUT")


func set_floor_host(host: Node2D, enable_preview: bool = false) -> void:
	_floor_host = host
	_preview_enabled = enable_preview and OS.has_feature("editor")


func start_game() -> void:
	_safe_return_in_progress = false
	_last_safe_return_frame = -1
	_task_checkpoint.clear()
	_room_monsters.clear()
	_seen_monsters.clear()
	_pending_monster_encounter.clear()
	CardManager.reset_for_new_game()
	current_floor = 1
	has_friend = false
	fail_reason = ""
	current_task_id = "NONE"
	task_status = "NONE"
	remaining_time = 0.0
	_manager_intro_finished = false
	_completed_task_ids.clear()
	_world_flags.clear()
	_open_modals.clear()
	_visited_floors.clear()
	if _has_floor_host():
		_load_floor(1)
	else:
		_set_state("PLAYING")
	task_updated.emit()
	notebook_changed.emit()


func return_to_menu() -> void:
	_safe_return_in_progress = false
	_open_modals.clear()
	_set_state("MENU")
	modal_changed.emit()


func complete_manager_intro() -> bool:
	if game_state != "PLAYING" or _manager_intro_finished:
		return false
	_manager_intro_finished = true
	notebook_changed.emit()
	return true


func has_completed_manager_intro() -> bool:
	return _manager_intro_finished


func get_notebook_view() -> Dictionary:
	var entries: Array[Dictionary] = []
	for monster_id: String in ["EYE", "NOSE", "HAT", "EAR", "CHECKER"]:
		entries.append({"id": monster_id, "name": "未知住客", "status": "UNKNOWN", "text": "尚未取得线索。"})
	if _manager_intro_finished:
		entries[0]["status"] = "HINT"
		entries[0]["text"] = "有些住客不喜欢陌生人。"
		entries[1]["status"] = "HINT"
		entries[1]["text"] = "有些住客对气味敏感。"
	var learned := {"NOSE": TASK_01_ID, "EYE": TASK_02_ID, "HAT": TUTORIAL_03_ID, "EAR": TUTORIAL_04_ID, "CHECKER": TUTORIAL_05_ID}
	for entry: Dictionary in entries:
		if _completed_task_ids.has(learned[entry["id"]]):
			entry.merge(get_monster_guide(entry["id"]), true)
			entry["status"] = "KNOWN"
	return {"unlocked": _manager_intro_finished, "entries": entries}


func get_monster_guide(kind: String) -> Dictionary:
	var guides := {
		"NOSE": {"name": "长鼻客", "text": "长鼻客开门时会辨识气味。将保洁工作证切为当前身份后再经过。"},
		"EYE": {"name": "独眼客", "text": "独眼客只认可保安身份。将保安工作证切为当前身份后再经过。"},
		"HAT": {"name": "礼帽客", "text": "礼帽客只认可经理身份。先在安全处切为当前经理，再经过。"},
		"EAR": {"name": "大耳客", "text": "大耳客开门时请停下不动，等门关闭再走。换证不能代替静止。"},
		"CHECKER": {"name": "核验客", "text": "核验客开门时不要在门前换证。先在安全处准备，保持身份经过。"},
	}
	return guides.get(kind, {}).duplicate()


func get_task_view() -> Dictionary:
	var definition: Dictionary = get_task_definition(current_task_id)
	return {
		"task_id": current_task_id,
		"status": task_status,
		"remaining_time": remaining_time,
		"time_limit": definition.get("time_limit", 0.0),
		"name": definition.get("name", ""),
		"location": definition.get("location", ""),
		"step": _get_task_step(definition),
		"target_id": _get_task_target(definition),
		"target_label": _get_task_target_label(definition),
		"required_card": definition.get("required_card", ""),
		"required_cards": definition.get("required_cards", [definition.get("required_card", "")]),
	}


func _get_task_step(definition: Dictionary) -> String:
	if definition.is_empty(): return ""
	if LATE_TASKS.has(current_task_id):
		match task_status:
			"AVAILABLE": return "在%s接受任务，接受后限时180秒。" % definition["room_id"]
			"FAILED": return "重新挑战后回%s接受，救援和前序成果保留。" % definition["room_id"]
			"COMPLETED": return "403已交付；从右端楼梯上5F，在501接离店任务。" if current_task_id == TASK_04_ID else "离店单已交付；前往五楼消防出口按E逃离。"
			"READY_TO_SUBMIT": return "返回%s按E交付" % definition["room_id"]
			"ACTIVE": return "在巡房员工身后站定，长按E偷取巡房记录。" if current_task_id == TASK_04_ID else "切为当前经理身份，在五楼离店登记台按E批准。"
	if task_status == "COMPLETED" and definition.has("work_steps"):
		return "二楼五项任务已交付，前往3F继续309登记。" if current_task_id == TUTORIAL_05_ID else "前往%s继续下一项任务。" % ("204" if current_task_id == TUTORIAL_03_ID else "205")
	if task_status not in ["ACTIVE", "READY_TO_SUBMIT"]: return ""
	var steps: Array = definition["steps"]
	if task_status == "READY_TO_SUBMIT":
		return "返回%s按E交付" % definition["room_id"] if definition.has("work_steps") else steps.back()
	if definition.has("work_steps"):
		if not CardManager.has_card(definition["required_card"]): return "回1F经理身后长按E取得工作证。"
		if not has_required_equipment(current_task_id): return "打开I，装备本任务指定工作证，再Q切当前工作身份。"
		for work: Dictionary in definition["work_steps"]:
			if not _world_flags.get(work["flag"], false):
				return work["label"]
	if current_task_id == TASK_03_ID and CardManager.active_card == "MANAGER":
		return steps[2]
	return steps[0] if not CardManager.has_card(definition["required_card"]) else steps[1]


func _get_task_target(definition: Dictionary) -> String:
	if LATE_TASKS.has(current_task_id):
		if task_status in ["AVAILABLE", "FAILED", "READY_TO_SUBMIT"]: return "ROOM_" + definition["room_id"]
		if task_status == "COMPLETED": return "STAIRS_UP_4F" if current_task_id == TASK_04_ID else "EXIT_5F"
		return definition["target_id"]
	if definition.has("work_steps"):
		if task_status == "COMPLETED": return "STAIRS_UP_2F" if current_task_id == TUTORIAL_05_ID else "ROOM_" + ("204" if current_task_id == TUTORIAL_03_ID else "205")
		if not CardManager.has_card(definition["required_card"]): return definition["staff_target_id"]
		if not has_required_equipment(current_task_id): return "CARD_BAG"
		if task_status == "READY_TO_SUBMIT": return "ROOM_" + definition["room_id"]
		for work: Dictionary in definition["work_steps"]:
			if not _world_flags.get(work["flag"], false): return work["target_id"]
	return definition.get("target_id", "")


func _get_task_target_label(definition: Dictionary) -> String:
	var target := _get_task_target(definition)
	if LATE_TASKS.has(current_task_id):
		return {"ROOM_403": "返回403", "ROOM_501": "返回501", "STAFF_PATROL_4F": "4F巡房员工", "EXIT_REGISTER_5F": "五楼离店登记台", "STAIRS_UP_4F": "4F右梯 → 5F", "EXIT_5F": "五楼消防出口"}.get(target, target)
	var labels := {"STAFF_MANAGER_1F": "一楼经理", "CARD_BAG": "I证件管理", "STAIRS_UP_2F": "二楼右梯 → 3F", "ROOM_204": "前往204", "ROOM_205": "前往205", "ROOM_SERVICE_203": "二楼房务登记台", "STAIN_204": "204独立污渍", "PATROL_CABINET_204": "二楼巡房资料柜", "TRANSIT_PICKUP_205": "二楼通行单领取点", "TRANSIT_REGISTER_205": "二楼通行登记台"}
	if definition.has("work_steps") and task_status == "READY_TO_SUBMIT": return "返回" + definition["room_id"]
	return labels.get(target, target)


func get_task_definition(task_id: String) -> Dictionary:
	return TaskDefinitions.get_definition(task_id)


func get_completed_task_ids() -> Array[String]:
	return _completed_task_ids.duplicate()


func get_world_flags() -> Dictionary:
	return _world_flags.duplicate(true)


func is_world_input_allowed() -> bool:
	return game_state == "PLAYING" and _open_modals.is_empty() and not _safe_return_in_progress


func is_interaction_allowed(target_id: String) -> bool:
	# Task eligibility only; B separately checks position, facing, hold and identity.
	if game_state != "PLAYING" or task_status != "ACTIVE" or remaining_time <= 0.0 or not _open_modals.is_empty():
		return false
	if not ENABLED_TASKS.has(current_task_id):
		return false
	var definition: Dictionary = get_task_definition(current_task_id)
	if definition.get("work_type", "") == "STEAL_FILE":
		return current_floor == definition["work_floor"] and target_id == definition["target_id"] and not _world_flags.get(definition["work_flag"], false)
	if not target_id.is_empty() and target_id == definition["staff_target_id"]:
		return not CardManager.has_card(definition["required_card"])
	if definition.has("work_steps"):
		for work: Dictionary in definition["work_steps"]:
			if not _world_flags.get(work["flag"], false):
				return target_id == work["target_id"] and has_required_equipment(current_task_id)
		return false
	if target_id == definition["target_id"]:
		return not _world_flags.get(definition["work_flag"], false)
	return false


func get_visited_floors() -> Array[int]:
	return _visited_floors.duplicate()


func get_available_floors() -> Array[int]:
	var available: Array[int] = []
	if game_state != "PLAYING":
		return available
	for floor_number: int in _visited_floors:
		if has_friend and floor_number < 3:
			continue
		if floor_number != current_floor:
			available.append(floor_number)
	var next_floor: int = current_floor + 1
	if next_floor <= 5 and _can_unlock_next_floor() and not available.has(next_floor):
		available.append(next_floor)
	available.sort()
	return available


func request_floor_travel(floor_number: int) -> bool:
	# A checker violation must be retried outside its range; do not carry it across floors.
	if _pending_monster_encounter.get("reason", "") == "SWITCHED_NEAR_CHECKER": return false
	if not is_world_input_allowed() or not _has_floor_host() or not get_available_floors().has(floor_number):
		return false
	var floor_node: Node = _floor_host.get_child(0)
	var player: Node2D = floor_node.get_node_or_null("Player")
	var stair: Node2D = floor_node.get_node_or_null("Interactions/ExitPoint" if floor_number > current_floor else "Interactions/ReturnPoint")
	if player == null or stair == null or absf(player.global_position.x - stair.global_position.x) > STAIR_INTERACTION_RADIUS:
		return false
	_load_floor(floor_number, floor_number < current_floor)
	return true


func get_stair_destinations() -> Array[int]:
	var destinations: Array[int] = []
	if not _has_floor_host() or _floor_host.get_child_count() != 1: return destinations
	var floor_node: Node = _floor_host.get_child(0)
	var player: Node2D = floor_node.get_node_or_null("Player")
	if player == null: return destinations
	for destination: int in get_available_floors():
		var stair: Node2D = floor_node.get_node_or_null("Interactions/ExitPoint" if destination > current_floor else "Interactions/ReturnPoint")
		if stair != null and absf(player.global_position.x - stair.global_position.x) <= STAIR_INTERACTION_RADIUS:
			destinations.append(destination)
	return destinations


func get_identity_restriction_room() -> String:
	if not _has_floor_host() or _floor_host.get_child_count() != 1: return ""
	var floor_node: Node = _floor_host.get_child(0)
	return floor_node.get_identity_restriction_room() if floor_node.has_method("get_identity_restriction_room") else ""


func _can_unlock_next_floor() -> bool:
	match current_floor:
		1:
			return _manager_intro_finished
		2:
			return TUTORIAL_TASKS.all(func(id: String): return _completed_task_ids.has(id))
		3:
			return has_friend
		4:
			return has_friend and _completed_task_ids.has("TASK_04_PATROL")
	return false


func is_tutorial_room_revealed(room_id: String) -> bool:
	return _world_flags.get("tutorial_room_%s_revealed" % room_id, false)


func reveal_tutorial_room(room_id: String) -> bool:
	if current_floor != 2: return false
	for task_id: String in TUTORIAL_TASKS:
		if get_task_definition(task_id)["room_id"] == room_id and can_offer_task(task_id):
			_world_flags["tutorial_room_%s_revealed" % room_id] = true
			return true
	return false


func can_offer_task(task_id: String) -> bool:
	if game_state != "PLAYING" or not _manager_intro_finished or not ENABLED_TASKS.has(task_id):
		return false
	var definition: Dictionary = get_task_definition(task_id)
	if current_floor != definition["offer_floor"] or task_status not in ["NONE", "COMPLETED"] or _completed_task_ids.has(task_id):
		return false
	return _task_prerequisites_met(definition)


func _task_prerequisites_met(definition: Dictionary) -> bool:
	for prerequisite: String in definition.get("prerequisites", []):
		if prerequisite == "HAS_FRIEND":
			if not has_friend: return false
		elif prerequisite == "MANAGER_INTRO":
			if not _manager_intro_finished: return false
		elif not _completed_task_ids.has(prerequisite):
			return false
	return true


func offer_task(task_id: String) -> bool:
	if not can_offer_task(task_id):
		return false
	current_task_id = task_id
	task_status = "AVAILABLE"
	remaining_time = 0.0
	fail_reason = ""
	_task_checkpoint.clear()
	if TUTORIAL_TASKS.has(task_id):
		_world_flags["tutorial_room_%s_revealed" % get_task_definition(task_id)["room_id"]] = true
	if task_id == TASK_02_ID:
		_world_flags["task_02_intro_completed"] = true
	task_offered.emit(task_id)
	task_updated.emit()
	return true


func accept_task(task_id: String) -> bool:
	if game_state != "PLAYING" or not ENABLED_TASKS.has(task_id) or current_floor != get_task_definition(task_id)["offer_floor"] or task_status != "AVAILABLE" or current_task_id != task_id:
		return false
	if not _task_prerequisites_met(get_task_definition(task_id)): return false
	var checkpoint: Dictionary = _capture_task_checkpoint()
	if _has_floor_host() and checkpoint.is_empty():
		return false
	_task_checkpoint = checkpoint
	resolve_monster_encounter(get_task_definition(task_id)["room_id"])
	task_status = "ACTIVE"
	remaining_time = get_task_definition(task_id)["time_limit"]
	task_updated.emit()
	return true


func _capture_task_checkpoint() -> Dictionary:
	# Manager-only component tests have no physical world to restore.
	if not _has_floor_host() or _floor_host.get_child_count() != 1:
		return {}
	var floor_node: Node = _floor_host.get_child(0)
	var safe: Dictionary = floor_node.get_task_checkpoint_position(current_task_id)
	if safe.is_empty():
		return {}
	return {
		"task_id": current_task_id, "floor": current_floor, "position": safe["position"],
		"cards": CardManager.export_snapshot(), "world_flags": _world_flags.duplicate(true),
		"completed": _completed_task_ids.duplicate(), "visited": _visited_floors.duplicate(),
		"manager_intro": _manager_intro_finished, "has_friend": has_friend,
		"room_monsters": _room_monsters.duplicate(true), "seen_monsters": _seen_monsters.duplicate(true), "pending_encounter": _pending_monster_encounter.duplicate(true),
	}


func can_retry_current_task() -> bool:
	return game_state == "FAILED" and task_status == "FAILED" and _has_floor_host() \
		and _task_checkpoint.get("task_id", "") == current_task_id \
		and ENABLED_TASKS.has(current_task_id) \
		and _task_checkpoint.get("floor", 0) == get_task_definition(current_task_id)["offer_floor"] \
		and CardManager.validate_snapshot(_task_checkpoint.get("cards", {}))


func retry_current_task() -> bool:
	if not can_retry_current_task():
		return false
	var checkpoint: Dictionary = _task_checkpoint.duplicate(true)
	_room_monsters = checkpoint.get("room_monsters", {}).duplicate(true)
	_seen_monsters = checkpoint.get("seen_monsters", {}).duplicate(true)
	_pending_monster_encounter = checkpoint.get("pending_encounter", {}).duplicate(true)
	var scene: PackedScene = load("res://scenes/levels/floor_%d.tscn" % checkpoint["floor"])
	var floor_node: Node2D = scene.instantiate()
	_set_state("RESTORING") # Cancel old holds before restoring cards or world facts.
	_floor_host.add_child(floor_node)
	var safe: Dictionary = floor_node.get_task_checkpoint_position(current_task_id)
	if safe.is_empty() or safe["position"] != checkpoint["position"]:
		_floor_host.remove_child(floor_node)
		floor_node.queue_free()
		_set_state("FAILED")
		return false
	if not CardManager.restore_snapshot(checkpoint["cards"]):
		_floor_host.remove_child(floor_node)
		floor_node.queue_free()
		_set_state("FAILED")
		return false
	for previous: Node in _floor_host.get_children():
		if previous != floor_node:
			_floor_host.remove_child(previous)
			previous.queue_free()
	current_floor = checkpoint["floor"]
	_world_flags = checkpoint["world_flags"].duplicate(true)
	_completed_task_ids.assign(checkpoint["completed"])
	_visited_floors.assign(checkpoint["visited"])
	_manager_intro_finished = checkpoint["manager_intro"]
	has_friend = checkpoint["has_friend"]
	task_status = "AVAILABLE"
	remaining_time = 0.0
	fail_reason = ""
	_safe_return_in_progress = false
	_open_modals.clear()
	modal_changed.emit()
	task_updated.emit() # Rebuild work, route and C's mirror from restored A truth.
	notebook_changed.emit()
	var player: HotelPlayer = floor_node.get_node("Player")
	player.set_movement_locked(true)
	player.global_position = safe["position"]
	player.get_node("Camera2D").reset_smoothing()
	player.set_movement_locked(false)
	_set_state("PLAYING")
	floor_changed.emit(current_floor)
	task_offered.emit(current_task_id)
	return true


func record_work_started(target_id: String) -> bool:
	# Persist supervision across floor travel, but only after real eligible work starts.
	if not is_interaction_allowed(target_id):
		return false
	var definition: Dictionary = get_task_definition(current_task_id)
	if current_floor != definition["work_floor"]:
		return false
	if definition.get("work_type", "") != "CLEAN" or target_id != definition.get("target_id", "") or CardManager.active_card != definition.get("required_card", ""):
		return false
	var flag: String = definition["work_flag"] + "_started"
	if not _world_flags.get(flag, false):
		_world_flags[flag] = true
		task_updated.emit()
	return true


func record_work_result(target_id: String) -> bool:
	if not is_interaction_allowed(target_id):
		return false
	var definition: Dictionary = get_task_definition(current_task_id)
	if definition.get("work_type", "") == "STEAL_FILE": return false
	if definition.has("work_steps"):
		if current_floor != definition["work_floor"] or not has_required_equipment(current_task_id):
			return false
		for work: Dictionary in definition["work_steps"]:
			if work["target_id"] != target_id:
				continue
			if CardManager.active_card != work["required_card"] or _world_flags.get(work["flag"], false):
				return false
			_world_flags[work["flag"]] = true
			if definition["work_steps"].all(func(step: Dictionary): return _world_flags.get(step["flag"], false)):
				task_status = "READY_TO_SUBMIT"
			task_updated.emit()
			return true
		return false
	if not ENABLED_TASKS.has(current_task_id) or target_id != definition["target_id"] or current_floor != definition["work_floor"]:
		return false
	if CardManager.active_card != definition["required_card"] or _world_flags.get(definition["work_flag"], false):
		return false
	_world_flags[definition["work_flag"]] = true
	if definition["settlement"] == "AUTHORIZE":
		remaining_time = 0.0
		_complete_task(definition)
		return true
	task_status = "READY_TO_SUBMIT"
	task_updated.emit()
	return true


func record_task_item_result(item_id: String, target_id: String) -> bool:
	if not is_interaction_allowed(target_id): return false
	var definition := get_task_definition(current_task_id)
	if definition.get("work_type", "") != "STEAL_FILE" or item_id != definition.get("reward_id", "") or target_id != definition["target_id"] or current_floor != definition["work_floor"]:
		return false
	_world_flags[definition["work_flag"]] = true
	task_status = "READY_TO_SUBMIT"
	task_updated.emit()
	return true


func submit_task(task_id: String) -> bool:
	if _pending_monster_encounter.get("reason", "") == "SWITCHED_NEAR_CHECKER": return false
	if not is_world_input_allowed() or task_status != "READY_TO_SUBMIT" or remaining_time <= 0.0:
		return false
	if not ENABLED_TASKS.has(current_task_id) or task_id != current_task_id:
		return false
	var definition: Dictionary = get_task_definition(task_id)
	if current_floor != definition["offer_floor"] or not _world_flags.get(definition["work_flag"], false):
		return false
	if definition.has("work_steps") and not definition["work_steps"].all(func(work: Dictionary): return _world_flags.get(work["flag"], false)):
		return false
	var submission_card := get_submission_card(task_id)
	if (not submission_card.is_empty() and CardManager.active_card != submission_card) or (definition.has("work_steps") and not has_required_equipment(task_id)):
		return false
	_complete_task(definition)
	return true


func get_submission_card(task_id: String) -> String:
	var definition := get_task_definition(task_id)
	var work_steps: Array = definition.get("work_steps", [])
	return work_steps.back()["required_card"] if not work_steps.is_empty() else definition.get("required_card", "")


func has_required_equipment(task_id: String) -> bool:
	var required: Array = get_task_definition(task_id).get("required_cards", [])
	return required.all(func(card: String): return CardManager.get_equipped_cards().has(card))


func get_work_flag(target_id: String) -> String:
	for task_id: String in ENABLED_TASKS:
		var definition := get_task_definition(task_id)
		for work: Dictionary in definition.get("work_steps", []):
			if work["target_id"] == target_id: return work["flag"]
		if definition["target_id"] == target_id: return definition["work_flag"]
	return ""


func _complete_task(definition: Dictionary) -> void:
	remaining_time = 0.0
	resolve_monster_encounter(definition["room_id"])
	task_status = "COMPLETED"
	_completed_task_ids.append(current_task_id)
	for flag: String in definition["completion_flags"]:
		_world_flags[flag] = true
	notebook_changed.emit()
	task_completed.emit(current_task_id)
	task_updated.emit()


## Only the completed real309 CG callback settles rescue in the main scene.
func rescue_friend() -> bool:
	if not is_world_input_allowed() or current_floor != 3 or has_friend or not _completed_task_ids.has(TASK_03_ID) or not _world_flags.get("registration_309_approved", false):
		return false
	has_friend = true
	_world_flags["rescue_309_completed"] = true
	friend_rescued.emit()
	notebook_changed.emit()
	task_updated.emit()
	return true


func can_escape() -> bool:
	if not is_world_input_allowed() or current_floor != 5 or not has_friend or task_status != "COMPLETED" or current_task_id != TASK_05_ID or not _pending_monster_encounter.is_empty(): return false
	if not [TASK_03_ID, TASK_04_ID, TASK_05_ID].all(func(id: String): return _completed_task_ids.has(id)): return false
	for flag: String in ["registration_309_approved", "rescue_309_completed", "patrol_delivered", "exit_form_approved", "exit_form_delivered"]:
		if not _world_flags.get(flag, false): return false
	if not _has_floor_host() or _floor_host.get_child_count() != 1: return false
	var floor_node: Node = _floor_host.get_child(0)
	if floor_node.get("floor_number") != 5: return false
	var player: Node2D = floor_node.get_node_or_null("Player")
	var exit_point: Node2D = floor_node.get_node_or_null("Interactions/ExitPoint")
	return player != null and exit_point != null and player.global_position.distance_to(exit_point.global_position) <= 70.0


func get_story_objective() -> String:
	if not has_friend: return "309登记已批准；切为保洁身份进入309。"
	if not _completed_task_ids.has(TASK_04_ID): return "Terese已同行；前往4F403取得并交付巡房记录。"
	if not _completed_task_ids.has(TASK_05_ID): return "403已交付；前往5F501办理并交付离店单。"
	return "离店单已交付；前往五楼消防出口按E逃离。"


func get_escape_block_message() -> String:
	if not _completed_task_ids.has(TASK_03_ID) or not _world_flags.get("registration_309_approved", false):
		return "Terese还在309：先到302接受登记任务，再用当前经理身份批准309。"
	if not has_friend or not _world_flags.get("rescue_309_completed", false):
		return "309登记已批准；按I装备保洁证、按Q切为当前保洁身份，再进入309救出Terese。"
	if not _completed_task_ids.has(TASK_04_ID) or not _world_flags.get("patrol_delivered", false):
		return "带Terese前往4F403取得巡房记录并返回交付，之后才能上5F。"
	if not _world_flags.get("exit_form_approved", false):
		return "前往5F501，用当前经理身份批准离店单。"
	if not _world_flags.get("exit_form_delivered", false):
		return "离店单已批准；返回501按E交付登记，再前往消防出口。"
	return "出口尚未开放；确认五楼消防出口附近没有其他模态界面。"


func request_escape() -> bool:
	if not can_escape(): return false
	remaining_time = 0.0
	_set_state("WON")
	game_won.emit()
	return true


func set_modal_open(modal_id: String, is_open: bool) -> void:
	if modal_id.is_empty() or _open_modals.has(modal_id) == is_open:
		return
	if is_open:
		_open_modals[modal_id] = true
	else:
		_open_modals.erase(modal_id)
	modal_changed.emit()


func request_task_failure(reason: String) -> void:
	if game_state != "PLAYING" or task_status not in ["ACTIVE", "READY_TO_SUBMIT"]:
		return
	if reason.is_empty():
		return
	task_status = "FAILED"
	fail_reason = reason
	_set_state("FAILED")
	task_failed.emit(current_task_id, reason)
	game_failed.emit(reason)
	task_updated.emit()


func go_to_floor(floor_number: int) -> void:
	request_floor_travel(floor_number)


func request_safe_return(door: Node2D, reason: String, approach_side: int) -> void:
	if not is_world_input_allowed() or not _has_floor_host() or reason.is_empty():
		return
	if approach_side not in [-1, 1] or not is_instance_valid(door):
		return
	if _last_safe_return_frame == Engine.get_physics_frames():
		return
	var floor_node: Node = _floor_host.get_child(0)
	if not floor_node.has_method("get_safe_return_position"):
		return
	var destination: Dictionary = floor_node.get_safe_return_position(door, approach_side)
	if destination.is_empty():
		return
	var player: HotelPlayer = floor_node.get_node("Player")
	_safe_return_in_progress = true
	_last_safe_return_frame = Engine.get_physics_frames()
	_set_state("SAFE_RETURN") # Cancels held interactions and suppresses C's detection.
	player.set_movement_locked(true)
	player.global_position = destination["position"]
	player.get_node("Camera2D").reset_smoothing()
	# C alone owns its pending flag; all points were checked before this move.
	if not door.finish_safe_return():
		push_error("Safe return could not be acknowledged by room %s" % door.room_id)
		return # Keep the world locked rather than claim success at an unsafe location.
	call_deferred("_finish_safe_return", floor_node, player)
	safe_return_started.emit(reason)


func _finish_safe_return(floor_node: Node, player: HotelPlayer) -> void:
	if not _safe_return_in_progress or not _has_floor_host() or not is_instance_valid(floor_node):
		return
	if floor_node.get_parent() != _floor_host or not is_instance_valid(player):
		return
	_safe_return_in_progress = false
	player.set_movement_locked(false)
	if game_state == "SAFE_RETURN":
		_set_state("PLAYING")


func preview_floor(floor_number: int) -> void:
	# Development-only navigation: never grants cards or changes rescue progress.
	if not _preview_enabled or game_state != "PLAYING" or not _has_floor_host():
		return
	if floor_number < 1 or floor_number > 5 or floor_number == current_floor:
		return
	_load_floor(floor_number, false, false)


func _has_floor_host() -> bool:
	return is_instance_valid(_floor_host) and _floor_host.is_inside_tree()


func _load_floor(floor_number: int, arrive_from_above: bool = false, record_visit: bool = true) -> void:
	var scene: PackedScene = load("res://scenes/levels/floor_%d.tscn" % floor_number)
	if scene == null:
		return
	var floor_node: Node = scene.instantiate()
	_set_state("LOADING")
	for previous: Node in _floor_host.get_children():
		_floor_host.remove_child(previous)
		previous.queue_free()
	current_floor = floor_number
	_floor_host.add_child(floor_node)
	if arrive_from_above:
		var player: Node2D = floor_node.get_node("Player")
		var stair: Node2D = floor_node.get_node("Interactions/ExitPoint")
		player.global_position = stair.global_position + Vector2(-60.0, 0.0)
		player.get_node("Camera2D").reset_smoothing()
	if record_visit and not _visited_floors.has(floor_number):
		_visited_floors.append(floor_number)
	_set_state("PLAYING")
	floor_changed.emit(current_floor)


func fail(reason: String) -> void:
	if game_state != "PLAYING":
		return
	if reason == "STAFF_CAUGHT" and task_status in ["ACTIVE", "READY_TO_SUBMIT"]:
		request_task_failure(reason)
		return
	fail_reason = reason
	_set_state("FAILED")
	game_failed.emit(reason)


func _set_state(next_state: String) -> void:
	if game_state == next_state:
		return
	game_state = next_state
	state_changed.emit(game_state)
