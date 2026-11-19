class_name CleaningSpot
extends Node2D

signal cleaning_completed(target_id: String)
signal work_requested(target_id: String)
signal interaction_cancelled(target_id: String)
signal interaction_state_changed(target_id: String, state: Dictionary)

@export var target_id: String = "STAIN_201"
@export_enum("CLEAN", "PICKUP", "AUTHORIZE") var interaction_type: String = "CLEAN"
@export var required_card: String = "CLEANER"
@export var hold_duration: float = 1.5

var _task_active: bool = false
var _player_in_range: bool = false
var _is_interacting: bool = false
var _elapsed: float = 0.0
var _completion_reported: bool = false
var _player: HotelPlayer

func _ready() -> void:
	if target_id in ["STAIN_201","PARCEL_CABINET_2F","EXIT_REGISTER_5F"]:
		add_child(preload("res://scenes/work/task_item_visual.gd").new())

func _exit_tree() -> void:
	_set_player_cleaning_visual(false)

func _set_player_cleaning_visual(active: bool) -> void:
	if interaction_type != "CLEAN" or not is_instance_valid(_player):
		return
	var visual := _player.get_node_or_null("Visual/Artwork")
	if visual != null and visual.has_method("set_cleaning_visual"):
		visual.set_cleaning_visual(active)


func setup(player: HotelPlayer) -> void:
	_player = player
	_player_in_range = $WorkArea.get_overlapping_bodies().has(player)
	if not CardManager.identity_changed.is_connected(_on_identity_changed):
		CardManager.identity_changed.connect(_on_identity_changed)
	_emit_interaction_state()


func set_task_active(active: bool) -> void:
	_task_active = active
	if not active:
		cancel_interaction()
	_emit_interaction_state()


func is_task_active() -> bool:
	return _task_active


func begin_interaction() -> bool:
	if not can_interact() or _completion_reported:
		return false
	_is_interacting = true
	_elapsed = 0.0
	_emit_interaction_state("ACTIVE")
	if interaction_type in ["PICKUP", "AUTHORIZE"]:
		_complete_interaction()
	return true


func cancel_interaction() -> void:
	if not _is_interacting:
		return
	_is_interacting = false
	_elapsed = 0.0
	interaction_cancelled.emit(target_id)
	_emit_interaction_state("CANCELLED")


func advance_interaction(delta: float) -> void:
	if not _is_interacting:
		return
	if not can_interact():
		cancel_interaction()
		return
	_elapsed += delta
	_emit_interaction_state("ACTIVE")
	if _elapsed < hold_duration:
		return
	_complete_interaction()


func _complete_interaction() -> void:
	_is_interacting = false
	_elapsed = 0.0
	_completion_reported = true
	_set_completed_visual(true)
	work_requested.emit(target_id)
	if interaction_type == "CLEAN":
		cleaning_completed.emit(target_id)
	_emit_interaction_state("COMPLETED", 1.0, get_required_interaction_time())


func can_interact() -> bool:
	return (
		_task_active
		and _player_in_range
		and _player != null
		and not _player.is_moving
		and GameManager.is_world_input_allowed()
		and CardManager.active_card == required_card
	)


func is_interacting() -> bool:
	return _is_interacting


func is_player_in_range() -> bool:
	return _player_in_range


func get_interaction_progress() -> float:
	if not _is_interacting:
		return 0.0
	if interaction_type in ["PICKUP", "AUTHORIZE"] or hold_duration <= 0.0:
		return 1.0
	return clampf(_elapsed / hold_duration, 0.0, 1.0)


func get_interaction_elapsed() -> float:
	return _elapsed if _is_interacting else 0.0


func get_required_interaction_time() -> float:
	return hold_duration if interaction_type == "CLEAN" else 0.0


func get_interaction_block_reason() -> String:
	if _completion_reported:
		return "COMPLETED"
	if not _task_active:
		return "TASK_INACTIVE"
	if not _player_in_range:
		return "OUT_OF_RANGE"
	if _player == null:
		return "NO_PLAYER"
	if _player.is_moving:
		return "PLAYER_MOVING"
	if not GameManager.is_world_input_allowed():
		return "WORLD_LOCKED"
	if CardManager.active_card != required_card:
		return "WRONG_IDENTITY"
	return "READY"


func get_interaction_state() -> Dictionary:
	return _make_interaction_state()


func set_completed(completed: bool) -> void:
	cancel_interaction()
	_completion_reported = completed
	_set_completed_visual(completed)
	_emit_interaction_state("COMPLETED" if completed else "RESET", 1.0 if completed else 0.0, get_required_interaction_time() if completed else 0.0)


func reset_completion_report() -> void:
	set_completed(false)


func is_completed() -> bool:
	return _completion_reported


func _set_completed_visual(completed: bool) -> void:
	# Only the reward/interaction item disappears. Environment furniture such as
	# the parcel cabinet or 309 desk remains visible after completion.
	for node_name: String in ["WorkVisual", "ItemVisual", "Stain"]:
		var visual: CanvasItem = get_node_or_null(node_name)
		if visual != null:
			visual.visible = not completed
	$Hint.visible = not completed
	$WorkArea.set_deferred("monitoring", not completed)


func _on_work_area_body_entered(body: Node2D) -> void:
	if body == _player:
		_player_in_range = true
		_emit_interaction_state()


func _on_work_area_body_exited(body: Node2D) -> void:
	if body == _player:
		_player_in_range = false
		cancel_interaction()
		_emit_interaction_state()


func _on_identity_changed(_action: String) -> void:
	if _is_interacting and CardManager.active_card != required_card:
		cancel_interaction()
	_emit_interaction_state()


func _make_interaction_state(status_override: String = "", progress_override: float = -1.0, elapsed_override: float = -1.0) -> Dictionary:
	var block_reason: String = get_interaction_block_reason()
	var status: String = status_override
	if status.is_empty():
		if _completion_reported:
			status = "COMPLETED"
		elif _is_interacting:
			status = "ACTIVE"
		elif block_reason == "READY":
			status = "READY"
		else:
			status = "BLOCKED"
	return {
		"target_id": target_id,
		"interaction_type": interaction_type,
		"status": status,
		"progress": get_interaction_progress() if progress_override < 0.0 else progress_override,
		"elapsed": get_interaction_elapsed() if elapsed_override < 0.0 else elapsed_override,
		"required_time": get_required_interaction_time(),
		"block_reason": block_reason,
	}


func _emit_interaction_state(status_override: String = "", progress_override: float = -1.0, elapsed_override: float = -1.0) -> void:
	_set_player_cleaning_visual(_is_interacting)
	interaction_state_changed.emit(target_id, _make_interaction_state(status_override, progress_override, elapsed_override))
