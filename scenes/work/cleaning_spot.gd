class_name CleaningSpot
extends Node2D

signal cleaning_completed(target_id: String)
signal interaction_cancelled(target_id: String)

@export var target_id: String = "STAIN_201"
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
	_is_interacting = false
	_elapsed = 0.0
	_completion_reported = true
	cleaning_completed.emit(target_id)


func can_interact() -> bool:
	return _task_active and _player_in_range and CardManager.active_card == required_card


func is_interacting() -> bool:
	return _is_interacting


func reset_completion_report() -> void:
	_completion_reported = false


func _on_work_area_body_entered(body: Node2D) -> void:
	if body == _player:
		_player_in_range = true


func _on_work_area_body_exited(body: Node2D) -> void:
	if body == _player:
		_player_in_range = false
		cancel_interaction()
