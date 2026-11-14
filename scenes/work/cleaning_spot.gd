class_name CleaningSpot
extends Node2D

signal cleaning_completed(target_id: String)
signal work_requested(target_id: String)
signal interaction_cancelled(target_id: String)

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


func setup(player: HotelPlayer) -> void:
	_player = player
	_player_in_range = $WorkArea.get_overlapping_bodies().has(player)


func set_task_active(active: bool) -> void:
	_task_active = active
	if not active:
		cancel_interaction()


func is_task_active() -> bool:
	return _task_active


func begin_interaction() -> bool:
	if not can_interact() or _completion_reported:
		return false
	_is_interacting = true
	_elapsed = 0.0
	if interaction_type in ["PICKUP", "AUTHORIZE"]:
		_complete_interaction()
	return true


func cancel_interaction() -> void:
	if not _is_interacting:
		return
	_is_interacting = false
	_elapsed = 0.0
	interaction_cancelled.emit(target_id)


func advance_interaction(delta: float) -> void:
	if not _is_interacting:
		return
	if not can_interact():
		cancel_interaction()
		return
	_elapsed += delta
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


func set_completed(completed: bool) -> void:
	cancel_interaction()
	_completion_reported = completed
	_set_completed_visual(completed)


func reset_completion_report() -> void:
	set_completed(false)


func is_completed() -> bool:
	return _completion_reported


func _set_completed_visual(completed: bool) -> void:
	var visual: CanvasItem = get_node_or_null("WorkVisual")
	if visual == null:
		visual = get_node_or_null("Stain")
	if visual != null:
		visual.visible = not completed
	$Hint.visible = not completed
	$WorkArea.set_deferred("monitoring", not completed)


func _on_work_area_body_entered(body: Node2D) -> void:
	if body == _player:
		_player_in_range = true


func _on_work_area_body_exited(body: Node2D) -> void:
	if body == _player:
		_player_in_range = false
		cancel_interaction()
