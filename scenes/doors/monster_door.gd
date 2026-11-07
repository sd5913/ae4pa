@tool
extends Node2D
## Reusable door visuals and CLOSED -> WARNING -> OPEN cycle.

@export var room_id: String = "201":
	set(value):
		room_id = value
		if is_node_ready():
			$RoomNumber.text = room_id

@export_range(0.01, 60.0, 0.01) var closed_time: float = 5.5
@export_range(0.01, 60.0, 0.01) var warning_time: float = 1.4
@export_range(0.01, 60.0, 0.01) var open_time: float = 2.8

var door_state: String = "CLOSED"
var _cycle_time: float = 0.0


func _ready() -> void:
	$RoomNumber.text = room_id
	reset_cycle()


func _process(delta: float) -> void:
	if Engine.is_editor_hint() or GameManager.game_state != "PLAYING":
		return
	# Retain overflow instead of discarding the last frame at each transition.
	var closed: float = maxf(closed_time, 0.01)
	var warning: float = maxf(warning_time, 0.01)
	var opened: float = maxf(open_time, 0.01)
	_cycle_time = fposmod(_cycle_time + delta, closed + warning + opened)
	var next_state: String = "CLOSED"
	if _cycle_time >= closed + warning:
		next_state = "OPEN"
	elif _cycle_time >= closed:
		next_state = "WARNING"
	if next_state != door_state:
		door_state = next_state
		_refresh_visuals()


func reset_cycle() -> void:
	_cycle_time = 0.0
	door_state = "CLOSED"
	if is_node_ready():
		_refresh_visuals()


func _refresh_visuals() -> void:
	$MonsterPlaceholder.visible = door_state == "OPEN"
	$DoorPanel.visible = door_state != "OPEN"
	$Handle.visible = door_state != "OPEN"
	$StateLabel.text = door_state
