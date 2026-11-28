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
signal memory_stable_point(reason: String)
## D/A consume this request; the pending encounter is not a completed task.
signal monster_encounter_requested(context: Dictionary)
var _room_monsters: Dictionary = {}
var _seen_monsters: Dictionary = {}
var _pending_monster_encounter: Dictionary = {}

func _room_monster_pool(room: String) -> Array:
	var fixed := {"302": "HAT", "403": "EAR", "501": "CHECKER"}
	return [fixed[room]] if fixed.has(room) else preload("res://scenes/doors/v4_door_catalog.gd").pool(room)

func get_room_monster(room: String) -> String:
	if not _room_monsters.has(room):
		var choices := _room_monster_pool(room)
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


# Saves made before the 120-second playtest adjustment keep the recorded clock.
const LEGACY_THEFT_TASK_SAVE_LIMITS := {
	"TASK_01_CLEAN": 210.0,
	"TASK_02_PARCEL": 180.0,
	"TASK_T03_ROOM_SERVICE": 240.0,
	"TASK_03_AUTHORIZE": 240.0,
	"TASK_04_PATROL": 180.0,
}

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
var play_time_seconds: float = 0.0
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
	if game_state == "PLAYING" and _open_modals.is_empty():
		play_time_seconds += delta
	if game_state != "PLAYING" or task_status not in ["ACTIVE", "READY_TO_SUBMIT"] or not _open_modals.is_empty():
		return
	remaining_time = maxf(0.0, remaining_time - delta)
	if is_zero_approx(remaining_time):
		request_task_failure("TASK_TIMEOUT")


func set_floor_host(host: Node2D, enable_preview: bool = false) -> void:
	_floor_host = host
	_preview_enabled = enable_preview and OS.has_feature("editor")


func start_game() -> void:
	HotelPlayer.reset_stamina()
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
	play_time_seconds = 0.0
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
		"CHECKER": {"name": "门缝客", "text": "门缝客开门时不要在门前换证。先在安全处准备，保持身份经过。"},
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

func get_open_modals() -> Array[String]:
	var ids: Array[String] = []
	for modal_id: String in _open_modals.keys(): ids.append(modal_id)
	ids.sort()
	return ids

func capture_memory_state() -> Dictionary:
	if not _has_floor_host() or _floor_host.get_child_count() != 1:
		return {}
	var floor_node: Node = _floor_host.get_child(0)
	var player: Node2D = floor_node.get_node_or_null("Player")
	if player == null or not floor_node.has_method("capture_memory_state"):
		return {}
	var checkpoint := _encode_task_checkpoint(_task_checkpoint)
	return {
		"version": 1,
		"game_state": game_state,
		"current_floor": current_floor,
		"has_friend": has_friend,
		"fail_reason": fail_reason,
		"current_task_id": current_task_id,
		"task_status": task_status,
		"remaining_time": remaining_time,
		"play_time_seconds": play_time_seconds,
		"manager_intro_finished": _manager_intro_finished,
		"completed_task_ids": _completed_task_ids.duplicate(),
		"world_flags": _world_flags.duplicate(true),
		"visited_floors": _visited_floors.duplicate(),
		"room_monsters": _room_monsters.duplicate(true),
		"seen_monsters": _seen_monsters.duplicate(true),
		"pending_encounter": _pending_monster_encounter.duplicate(true),
		"retry_checkpoint": checkpoint,
		"player": {
			"position": [player.global_position.x, player.global_position.y],
			"facing_direction": player.facing_direction,
			"stamina": player.capture_stamina_state(),
		},
		"floor": floor_node.capture_memory_state(),
	}

func validate_memory_state(value: Dictionary) -> bool:
	if value.get("version") != 1 or value.get("game_state") != "PLAYING": return false
	if not (value.get("current_floor") is int or value.get("current_floor") is float) or not is_finite(float(value.current_floor)) or float(value.current_floor) != floorf(float(value.current_floor)) or value.current_floor < 1 or value.current_floor > 5: return false
	if not value.get("has_friend") is bool or not value.get("manager_intro_finished") is bool: return false
	if not value.get("current_task_id") is String or not value.get("task_status") is String: return false
	var task_id: String = value.current_task_id
	var status: String = value.task_status
	if task_id != "NONE" and not ENABLED_TASKS.has(task_id): return false
	if status not in ["NONE", "AVAILABLE", "ACTIVE", "READY_TO_SUBMIT", "COMPLETED"]: return false
	if (task_id == "NONE") != (status == "NONE"): return false
	if not value.get("fail_reason") is String: return false
	if not value.get("remaining_time") is float or not is_finite(value.remaining_time) or value.remaining_time < 0.0: return false
	if not value.get("play_time_seconds") is float or not is_finite(value.play_time_seconds) or value.play_time_seconds < 0.0: return false
	if status in ["ACTIVE", "READY_TO_SUBMIT"] and value.remaining_time <= 0.0: return false
	if status in ["NONE", "AVAILABLE", "COMPLETED"] and not is_zero_approx(value.remaining_time): return false
	if not _validate_memory_tasks(value.get("completed_task_ids"), value.get("world_flags")): return false
	if (status == "COMPLETED") != value.completed_task_ids.has(task_id): return false
	if not _validate_memory_companion(value.has_friend, int(value.current_floor), value.completed_task_ids, value.world_flags): return false
	if status in ["ACTIVE", "READY_TO_SUBMIT"] and value.remaining_time > float(LEGACY_THEFT_TASK_SAVE_LIMITS.get(task_id, get_task_definition(task_id).time_limit)): return false
	if not _validate_memory_visits(value.get("visited_floors"), int(value.current_floor)): return false
	if not _validate_memory_encounters(value.get("room_monsters"), value.get("seen_monsters"), value.get("pending_encounter")): return false
	if not value.get("player") is Dictionary or not value.player.get("position") is Array or value.player.position.size() != 2: return false
	if not (value.player.position[0] is float or value.player.position[0] is int) or not (value.player.position[1] is float or value.player.position[1] is int): return false
	if not (value.player.get("facing_direction") is int or value.player.get("facing_direction") is float) or absf(float(value.player.facing_direction)) != 1.0: return false
	if value.player.has("stamina") and not _is_valid_saved_stamina(value.player.stamina): return false
	for coordinate: Variant in value.player.position:
		if not is_finite(float(coordinate)): return false
	if not preload("res://scenes/levels/floor.gd").is_memory_position_on_corridor(value.player.position): return false
	if not value.get("floor") is Dictionary or value.floor.get("floor_number") != value.current_floor or not preload("res://scenes/levels/floor.gd").validate_memory_state(value.floor): return false
	if not value.get("retry_checkpoint") is Dictionary or not _validate_encoded_task_checkpoint(value.retry_checkpoint): return false
	if status in ["ACTIVE", "READY_TO_SUBMIT"] and value.retry_checkpoint.get("task_id") != task_id: return false
	return true

func restore_memory_state(value: Dictionary) -> bool:
	if not validate_memory_state(value) or not _has_floor_host(): return false
	var scene: PackedScene = load("res://scenes/levels/floor_%d.tscn" % value.current_floor)
	if scene == null: return false
	var floor_node: Node = scene.instantiate()
	if floor_node == null: return false
	var previous_state := game_state
	_set_state("RESTORING")
	_open_modals.clear()
	modal_changed.emit()
	var old_room_monsters := _room_monsters
	_room_monsters = value.room_monsters.duplicate(true)
	_floor_host.add_child(floor_node)
	var player: HotelPlayer = floor_node.get_node("Player")
	player.global_position = Vector2(float(value.player.position[0]), float(value.player.position[1]))
	if not floor_node.restore_memory_state(value.floor):
		_room_monsters = old_room_monsters
		_floor_host.remove_child(floor_node)
		floor_node.queue_free()
		_set_state(previous_state)
		return false
	player.facing_direction = int(value.player.facing_direction)
	player.visual.scale.x = float(player.facing_direction)
	# Older saves predate running. Start them at full stamina, in walk mode.
	player.restore_stamina_state(value.player.get("stamina", {}))
	player.get_node("Camera2D").reset_smoothing()
	# All fallible payload/floor validation has completed. Commit the A-owned facts now.
	current_floor = int(value.current_floor)
	has_friend = value.has_friend
	fail_reason = str(value.get("fail_reason", ""))
	current_task_id = value.current_task_id
	task_status = value.task_status
	remaining_time = value.remaining_time
	play_time_seconds = value.play_time_seconds
	_manager_intro_finished = value.manager_intro_finished
	_completed_task_ids.assign(value.completed_task_ids)
	_world_flags = value.world_flags.duplicate(true)
	_visited_floors.assign(value.visited_floors.map(func(item: Variant): return int(item)))
	_seen_monsters = value.seen_monsters.duplicate(true)
	_pending_monster_encounter = value.pending_encounter.duplicate(true)
	_task_checkpoint = _decode_task_checkpoint(value.retry_checkpoint)
	for previous: Node in _floor_host.get_children():
		if previous != floor_node:
			_floor_host.remove_child(previous)
			previous.queue_free()
	_safe_return_in_progress = false
	_last_safe_return_frame = -1
	_open_modals.clear()
	modal_changed.emit()
	task_updated.emit()
	notebook_changed.emit()
	_set_state("PLAYING")
	player.set_movement_locked(false)
	floor_changed.emit(current_floor)
	return true

func _validate_memory_tasks(completed: Variant, flags: Variant) -> bool:
	if not completed is Array or not flags is Dictionary: return false
	var seen := {}
	for id: Variant in completed:
		if not id is String or not ENABLED_TASKS.has(id) or seen.has(id): return false
		seen[id] = true
	for flag: Variant in flags:
		if not flag is String or not flags[flag] is bool: return false
	return true

func _validate_memory_companion(companion: bool, floor_number: int, completed: Array, flags: Dictionary) -> bool:
	if companion != flags.get("rescue_309_completed", false): return false
	return not companion or (floor_number >= 3 and completed.has(TASK_03_ID) and flags.get("registration_309_approved", false))

func _validate_memory_visits(visited: Variant, floor_number: int) -> bool:
	if not visited is Array: return false
	var seen := {}
	for item: Variant in visited:
		if not (item is int or item is float) or not is_finite(float(item)) or float(item) != floorf(float(item)) or item < 1 or item > 5:
			return false
		var visited_floor := int(item)
		if seen.has(visited_floor): return false
		seen[visited_floor] = true
	return seen.has(floor_number)

func _validate_memory_encounters(rooms: Variant, seen: Variant, pending: Variant) -> bool:
	if not rooms is Dictionary or not seen is Dictionary or not pending is Dictionary: return false
	for room: Variant in rooms:
		if not room is String or not _room_monster_pool(room).has(rooms[room]): return false
	for kind: Variant in seen:
		if kind not in ["NOSE", "EYE", "HAT", "EAR", "CHECKER"] or seen[kind] != true: return false
	if pending.is_empty():
		return true
	if not pending.get("room_id") is String or not pending.get("monster_type") is String \
		or not pending.get("first_encounter") is bool or not pending.get("reason") is String:
		return false
	if not _room_monster_pool(pending.room_id).has(pending.monster_type) or not seen.has(pending.monster_type):
		return false
	var fixed_tasks := {"302": TASK_03_ID, "403": TASK_04_ID, "501": TASK_05_ID}
	var task_by_kind: Dictionary = preload("res://scenes/doors/v4_door_catalog.gd").TASKS
	return pending.get("task_id") == fixed_tasks.get(pending.room_id, task_by_kind.get(pending.monster_type))

func _is_valid_saved_stamina(value: Variant) -> bool:
	return value is Dictionary and HotelPlayer.validate_stamina_state(value)

func _validate_encoded_task_checkpoint(value: Dictionary) -> bool:
	if value.is_empty(): return true
	if value.has("stamina") and not _is_valid_saved_stamina(value.stamina): return false
	if not value.get("task_id") is String or not ENABLED_TASKS.has(value.task_id): return false
	var floor_number: int = get_task_definition(value.task_id)["offer_floor"]
	if value.get("floor") != floor_number: return false
	if not value.get("cards") is Dictionary or not CardManager.validate_snapshot(value.cards): return false
	if not _validate_memory_tasks(value.get("completed"), value.get("world_flags")) or value.completed.has(value.task_id): return false
	if not value.get("manager_intro") is bool or not value.get("has_friend") is bool: return false
	if not _validate_memory_companion(value.has_friend, floor_number, value.completed, value.world_flags): return false
	if not _validate_memory_visits(value.get("visited"), floor_number): return false
	if not _validate_memory_encounters(value.get("room_monsters"), value.get("seen_monsters"), value.get("pending_encounter")): return false
	if not value.get("position") is Array or value.position.size() != 2: return false
	for coordinate: Variant in value.position:
		if not (coordinate is float or coordinate is int) or not is_finite(float(coordinate)): return false
	var position := Vector2(float(value.position[0]), float(value.position[1]))
	if not preload("res://scenes/levels/floor.gd").is_memory_position_on_corridor(value.position): return false
	return _matches_checkpoint_marker(value.task_id, floor_number, position)

func get_task_checkpoint_marker_path(task_id: String) -> String:
	var definition := get_task_definition(task_id)
	if definition.has("checkpoint_marker"):
		return "Interactions/" + str(definition["checkpoint_marker"])
	if task_id in [TUTORIAL_03_ID, TUTORIAL_04_ID, TUTORIAL_05_ID]:
		return "Interactions/Task%sAcceptSafe" % definition["room_id"]
	return "Interactions/Task03AcceptSafe" if task_id == TASK_03_ID else "Interactions/Task01AcceptSafe" if task_id == TASK_01_ID else "Interactions/Task02AcceptSafe"

func _matches_checkpoint_marker(task_id: String, floor_number: int, position: Vector2) -> bool:
	var scene := load("res://scenes/levels/floor_%d.tscn" % floor_number) as PackedScene
	if scene == null: return false
	# Authored checkpoint markers use corridor coordinates. Read their scenes without running _ready().
	var state := scene.get_state()
	var marker_path := get_task_checkpoint_marker_path(task_id)
	for node_index in state.get_node_count():
		if str(state.get_node_path(node_index)).trim_prefix("./") != marker_path:
			continue
		for property_index in state.get_node_property_count(node_index):
			if state.get_node_property_name(node_index, property_index) == &"position":
				return state.get_node_property_value(node_index, property_index) == position
	return false

func _encode_task_checkpoint(checkpoint: Dictionary) -> Dictionary:
	if checkpoint.is_empty(): return {}
	var result := checkpoint.duplicate(true)
	var position: Vector2 = checkpoint.get("position", Vector2.ZERO)
	result["position"] = [position.x, position.y]
	return result

func _decode_task_checkpoint(checkpoint: Dictionary) -> Dictionary:
	if checkpoint.is_empty(): return {}
	var result := checkpoint.duplicate(true)
	var position: Variant = checkpoint.get("position")
	if not position is Array or position.size() != 2: return {}
	result["position"] = Vector2(float(position[0]), float(position[1]))
	result["floor"] = int(result.floor)
	result["visited"] = result.visited.map(func(item: Variant): return int(item))
	return result


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
	if not is_world_input_allowed() or not _has_floor_host() or _floor_host.get_child_count() != 1 or not get_available_floors().has(floor_number):
		return false
	var floor_node: Node2D = _floor_host.get_child(0)
	if not floor_node.is_player_at_stair(floor_number > current_floor):
		return false
	_load_floor(floor_number, floor_number < current_floor, true, true)
	return true


func get_stair_destinations() -> Array[int]:
	var destinations: Array[int] = []
	if not _has_floor_host() or _floor_host.get_child_count() != 1: return destinations
	var floor_node: Node2D = _floor_host.get_child(0)
	for destination: int in get_available_floors():
		if floor_node.is_player_at_stair(destination > current_floor):
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
	memory_stable_point.emit("TASK_ACCEPTED")
	return true


func _capture_task_checkpoint() -> Dictionary:
	# Manager-only component tests have no physical world to restore.
	if not _has_floor_host() or _floor_host.get_child_count() != 1:
		return {}
	var floor_node: Node = _floor_host.get_child(0)
	var safe: Dictionary = floor_node.get_task_checkpoint_position(current_task_id)
	if safe.is_empty():
		return {}
	var player: HotelPlayer = floor_node.get_node("Player")
	return {
		"stamina": player.capture_stamina_state(),
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
	player.restore_stamina_state(checkpoint.get("stamina", {}))
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
			memory_stable_point.emit("WORK_STEP_COMPLETED")
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
	memory_stable_point.emit("WORK_COMPLETED")
	return true


func record_task_item_result(item_id: String, target_id: String) -> bool:
	if not is_interaction_allowed(target_id): return false
	var definition := get_task_definition(current_task_id)
	if definition.get("work_type", "") != "STEAL_FILE" or item_id != definition.get("reward_id", "") or target_id != definition["target_id"] or current_floor != definition["work_floor"]:
		return false
	_world_flags[definition["work_flag"]] = true
	task_status = "READY_TO_SUBMIT"
	task_updated.emit()
	memory_stable_point.emit("WORK_COMPLETED")
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
	memory_stable_point.emit("TASK_HANDED_IN")


## Only the completed real309 CG callback settles rescue in the main scene.
func rescue_friend() -> bool:
	if not is_world_input_allowed() or current_floor != 3 or has_friend or not _completed_task_ids.has(TASK_03_ID) or not _world_flags.get("registration_309_approved", false):
		return false
	has_friend = true
	_world_flags["rescue_309_completed"] = true
	friend_rescued.emit()
	notebook_changed.emit()
	task_updated.emit()
	memory_stable_point.emit("RESCUE_SETTLED")
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


func _load_floor(floor_number: int, arrive_from_above: bool = false, record_visit: bool = true, autosave_after_load: bool = false) -> void:
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
	if autosave_after_load: memory_stable_point.emit("FLOOR_LOADED")


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
