@tool
extends Node2D
## Reusable door visuals and CLOSED -> WARNING -> OPEN cycle.

# V4 events wired by A; optional identity inspection still needs modal integration.
signal rule_violated(reason: String, approach_side: int)
signal story_intercept_requested(task_id: String, room_id: String)
signal task_submit_requested(task_id: String)
signal story_progress_requested(task_id: String)

@export_enum("NORMAL", "STORY") var door_mode: String = "NORMAL"
@export var task_id: String = ""
@export_range(1.0, 500.0, 1.0) var story_radius: float = 120.0

var _story_status: String = "NONE" # A-supplied presentation mirror, not task truth.
var _story_requested: bool = false
var _story_inside: bool = false
var _submit_pending: bool = false
var _violation_pending: bool = false
var _outside_side: int = 0
var _entry_side: int = 0
var _inside: bool = false
var _identity_inspection: Dictionary = {}

@export var room_id: String = "201":
	set(value):
		room_id = value
		if is_node_ready():
			$RoomNumber.text = room_id

@export_range(0.01, 60.0, 0.01) var closed_time: float = 5.5
@export_range(0.01, 60.0, 0.01) var warning_time: float = 1.4
@export_range(0.01, 60.0, 0.01) var open_time: float = 2.8
@export_range(0.0, 500.0, 1.0) var radius: float = 90.0
## Seconds already elapsed in the cycle. Reset reproduces this configured phase.
@export_range(-600.0, 600.0, 0.1) var offset: float = 0.0
@export_enum("EYE", "NOSE", "HAT", "EAR", "CHECKER") var monster_type: String = "EYE"

var door_state: String = "CLOSED"
var _cycle_time: float = 0.0
var _player: HotelPlayer


func setup(player: HotelPlayer) -> void:
	if player != _player:
		_identity_inspection.clear()
		_outside_side = 0
		_entry_side = 0
		_inside = false
		_violation_pending = false
		_story_inside = false
	_player = player
	if is_inside_tree() and not Engine.is_editor_hint():
		_connect_identity_signal()


func _connect_identity_signal() -> void:
	if not CardManager.identity_changed.is_connected(_on_identity_changed):
		CardManager.identity_changed.connect(_on_identity_changed)


func _exit_tree() -> void:
	_identity_inspection.clear()
	if not Engine.is_editor_hint() and CardManager.identity_changed.is_connected(_on_identity_changed):
		CardManager.identity_changed.disconnect(_on_identity_changed)


func _can_check() -> bool:
	return (door_mode == "NORMAL" and not _violation_pending
		and not Engine.is_editor_hint() and can_process()
		and GameManager.is_world_input_allowed() and door_state == "OPEN"
		and is_instance_valid(_player)
		and absf(_player.global_position.x - global_position.x) <= maxf(radius, 0.0))


func _on_identity_changed(action: String) -> void:
	if not _identity_inspection.is_empty():
		if action in ["SWITCH_ACTIVE", "EQUIP_CARD"]:
			_identity_inspection.changed = true
		return
	_sample_entry()
	if monster_type == "CHECKER" and action in ["SWITCH_ACTIVE", "EQUIP_CARD"] and _can_check():
		_report_violation("SWITCHED_NEAR_CHECKER")


## Opt-in M2 adapter. A captures BEFORE freezing/opening the bag; never automatic.
func begin_identity_inspection() -> bool:
	if not _identity_inspection.is_empty() or monster_type != "CHECKER":
		return false
	_sample_entry()
	if not _can_check() or _entry_side == 0:
		return false
	_identity_inspection = {"player": _player, "position": _player.global_position,
		"door_position": global_position, "side": _entry_side, "changed": false}
	return true


## Resolve after the LAST modal closes, before movement resumes. False cancels on
## failure/travel/retry; restore_snapshot emits no identity_changed, hence no report.
func end_identity_inspection(resolve: bool = true) -> bool:
	if _identity_inspection.is_empty():
		return false
	if resolve and not GameManager.is_world_input_allowed():
		return false # Nested modal: keep evidence until A resolves or cancels it.
	var context: Dictionary = _identity_inspection
	_identity_inspection = {}
	if not resolve:
		return true
	if not is_instance_valid(_player) or context.player != _player:
		return false
	if _player.global_position != context.position or global_position != context.door_position:
		return false # A must freeze positions; stale evidence cannot move a new actor.
	if door_mode != "NORMAL" or monster_type != "CHECKER":
		return false
	if context.changed:
		_entry_side = context.side
		_report_violation("SWITCHED_NEAR_CHECKER")
	return true


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint() or not can_process() or not is_instance_valid(_player):
		return
	_sample_entry()
	if not GameManager.is_world_input_allowed():
		return
	if door_mode == "STORY":
		_check_story()
		return
	if not _can_check():
		return
	var required_cards: Dictionary = {"EYE": "SECURITY", "NOSE": "CLEANER", "HAT": "MANAGER"}
	if required_cards.has(monster_type) and CardManager.active_card != required_cards[monster_type]:
		_report_violation("WRONG_CARD")
	elif monster_type == "EAR" and _player.is_moving:
		_report_violation("MOVED_NEAR_EAR")


func _sample_entry() -> void:
	if Engine.is_editor_hint() or not is_instance_valid(_player):
		return
	var distance: float = _player.global_position.x - global_position.x
	if absf(distance) > maxf(radius, 0.0):
		_outside_side = -1 if distance < 0.0 else 1
		_inside = false
	elif not _inside:
		_entry_side = _outside_side
		_inside = true


func _report_violation(reason: String) -> void:
	# Unknown spawn/teleport inside is not evidence of a safe approach direction.
	if _violation_pending or _entry_side == 0:
		return
	_violation_pending = true # Set before a synchronous receiver can react.
	rule_violated.emit(reason, _entry_side)


func finish_safe_return() -> bool:
	if not is_instance_valid(_player):
		return false
	if absf(_player.global_position.x - global_position.x) <= maxf(radius, 0.0):
		return false
	_sample_entry()
	_violation_pending = false
	return true


func set_story_state(status: String) -> void:
	if status not in ["NONE", "AVAILABLE", "ACTIVE", "READY_TO_SUBMIT", "COMPLETED", "FAILED"]:
		return
	var previous: String = _story_status
	_story_status = status
	_submit_pending = false # A acknowledges acceptance/rejection by resynchronizing.
	if status == "NONE" and previous != "NONE":
		_story_requested = false # Explicit A retry/restore; cycle reset never reoffers.


func _check_story() -> void:
	var inside: bool = absf(_player.global_position.x - global_position.x) <= story_radius
	var entered: bool = inside and not _story_inside
	_story_inside = inside
	if not inside or task_id.is_empty():
		return
	if _story_status == "NONE" and not _story_requested:
		_story_requested = true
		story_intercept_requested.emit(task_id, room_id)
	elif entered and _story_status in ["ACTIVE", "READY_TO_SUBMIT"]:
		story_progress_requested.emit(task_id)


func request_interaction() -> bool:
	# A's unique E router calls this; the component does not listen to E itself.
	if door_mode != "STORY" or _story_status != "READY_TO_SUBMIT" or _submit_pending:
		return false
	if not can_process() or not GameManager.is_world_input_allowed() or not is_instance_valid(_player):
		return false
	if absf(_player.global_position.x - global_position.x) > story_radius:
		return false
	_submit_pending = true
	task_submit_requested.emit(task_id)
	return true


func _ready() -> void:
	$RoomNumber.text = room_id
	# Player computes this frame's actual displacement before EAR reads it.
	process_physics_priority = 1
	if not Engine.is_editor_hint():
		_connect_identity_signal()
	reset_cycle()


func _process(delta: float) -> void:
	if Engine.is_editor_hint() or not GameManager.is_world_input_allowed():
		return
	# Retain overflow instead of discarding the last frame at each transition.
	var closed: float = maxf(closed_time, 0.01)
	var warning: float = maxf(warning_time, 0.01)
	var opened: float = maxf(open_time, 0.01)
	_cycle_time = fposmod(_cycle_time + delta, closed + warning + opened)
	_update_phase()


func _update_phase() -> void:
	var closed: float = maxf(closed_time, 0.01)
	var warning: float = maxf(warning_time, 0.01)
	var next_state: String = "CLOSED"
	if _cycle_time >= closed + warning:
		next_state = "OPEN"
	elif _cycle_time >= closed:
		next_state = "WARNING"
	if next_state != door_state:
		door_state = next_state
		_refresh_visuals()
	if door_state == "WARNING":
		# Alternating border plus words: visible with sound muted or without color.
		$Frame.modulate = Color(1.0, 0.65, 0.2) if int(_cycle_time * 6.0) % 2 == 0 else Color.WHITE


func reset_cycle() -> void:
	var total: float = maxf(closed_time, 0.01) + maxf(warning_time, 0.01) + maxf(open_time, 0.01)
	_cycle_time = fposmod(offset, total)
	if is_node_ready():
		_refresh_visuals()
		_update_phase()


func _refresh_visuals() -> void:
	$MonsterPlaceholder.visible = door_state == "OPEN"
	$DoorPanel.visible = door_state != "OPEN"
	$Handle.visible = door_state != "OPEN"
	$StateLabel.text = monster_type + " · " + door_state
	$Frame.modulate = Color.WHITE
	$WarningLabel.visible = door_state == "WARNING"
