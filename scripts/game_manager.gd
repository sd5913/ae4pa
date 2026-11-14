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

const TaskDefinitions = preload("res://scripts/task_definitions.gd")
const TASK_01_ID: String = "TASK_01_CLEAN"

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
	if _completed_task_ids.has(TASK_01_ID):
		entries[1] = {"id": "NOSE", "name": "长鼻客", "status": "KNOWN", "text": "长鼻客开门时会辨识气味。将保洁工作证切为当前身份后再经过。"}
	return {"unlocked": _manager_intro_finished, "entries": entries}


func get_task_view() -> Dictionary:
	var definition: Dictionary = get_task_definition(current_task_id)
	return {
		"task_id": current_task_id,
		"status": task_status,
		"remaining_time": remaining_time,
		"time_limit": definition.get("time_limit", 0.0),
		"name": definition.get("name", ""),
		"location": definition.get("location", ""),
		"step": "RETURN_TO_201" if task_status == "READY_TO_SUBMIT" else "CLEAN_STAIN" if task_status == "ACTIVE" else "",
		"target_id": definition.get("target_id", ""),
		"required_card": definition.get("required_card", ""),
	}


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
	if current_task_id != TASK_01_ID:
		return false
	match target_id:
		"STAFF_CLEANER_1F":
			return not CardManager.has_card("CLEANER")
		"STAIN_201":
			return not _world_flags.get("stain_201_cleaned", false)
	return false


func get_visited_floors() -> Array[int]:
	return _visited_floors.duplicate()


func get_available_floors() -> Array[int]:
	var available: Array[int] = []
	if game_state != "PLAYING":
		return available
	for floor_number: int in _visited_floors:
		if floor_number != current_floor:
			available.append(floor_number)
	var next_floor: int = current_floor + 1
	if next_floor <= 5 and _can_unlock_next_floor() and not available.has(next_floor):
		available.append(next_floor)
	available.sort()
	return available


func request_floor_travel(floor_number: int) -> bool:
	if not is_world_input_allowed() or not _has_floor_host() or not get_available_floors().has(floor_number):
		return false
	var floor_node: Node = _floor_host.get_child(0)
	var player: Node2D = floor_node.get_node_or_null("Player")
	var stair: Node2D = floor_node.get_node_or_null("Interactions/ExitPoint" if floor_number > current_floor else "Interactions/ReturnPoint")
	if player == null or stair == null or absf(player.global_position.x - stair.global_position.x) > 70.0:
		return false
	_load_floor(floor_number, floor_number < current_floor)
	return true


func _can_unlock_next_floor() -> bool:
	match current_floor:
		1:
			return _manager_intro_finished
		2:
			return _completed_task_ids.has(TASK_01_ID) and _completed_task_ids.has("TASK_02_PARCEL")
		3:
			return has_friend
		4:
			return has_friend and _completed_task_ids.has("TASK_04_PATROL")
	return false


func offer_task(task_id: String) -> bool:
	if game_state != "PLAYING" or current_floor != 2 or not _manager_intro_finished:
		return false
	if task_id != TASK_01_ID or task_status != "NONE":
		return false
	current_task_id = task_id
	task_status = "AVAILABLE"
	task_offered.emit(task_id)
	task_updated.emit()
	return true


func accept_task(task_id: String) -> bool:
	if game_state != "PLAYING" or current_floor != 2 or task_status != "AVAILABLE" or current_task_id != task_id:
		return false
	var checkpoint: Dictionary = _capture_task_checkpoint()
	if _has_floor_host() and checkpoint.is_empty():
		return false
	_task_checkpoint = checkpoint
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
	}


func can_retry_current_task() -> bool:
	return game_state == "FAILED" and task_status == "FAILED" and _has_floor_host() \
		and _task_checkpoint.get("task_id", "") == current_task_id \
		and _task_checkpoint.get("floor", 0) == 2 \
		and CardManager.validate_snapshot(_task_checkpoint.get("cards", {}))


func retry_current_task() -> bool:
	if not can_retry_current_task():
		return false
	var checkpoint: Dictionary = _task_checkpoint.duplicate(true)
	var scene: PackedScene = load("res://scenes/levels/floor_2.tscn")
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


func record_work_result(target_id: String) -> bool:
	if not is_interaction_allowed(target_id):
		return false
	if current_task_id != TASK_01_ID or target_id != "STAIN_201" or current_floor != 2:
		return false
	if CardManager.active_card != "CLEANER" or _world_flags.has("stain_201_cleaned"):
		return false
	_world_flags["stain_201_cleaned"] = true
	task_status = "READY_TO_SUBMIT"
	task_updated.emit()
	return true


func submit_task(task_id: String) -> bool:
	if not is_world_input_allowed() or task_status != "READY_TO_SUBMIT" or remaining_time <= 0.0:
		return false
	if current_task_id != TASK_01_ID or task_id != TASK_01_ID or current_floor != 2:
		return false
	if not _world_flags.get("stain_201_cleaned", false):
		return false
	task_status = "COMPLETED"
	_completed_task_ids.append(task_id)
	_world_flags["passage_201_unlocked"] = true
	notebook_changed.emit()
	task_completed.emit(task_id)
	task_updated.emit()
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
