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
@export_range(0.0, 500.0, 1.0) var radius: float = 90.0
## Seconds already elapsed in the cycle. Reset reproduces this configured phase.
@export_range(-600.0, 600.0, 0.1) var offset: float = 0.0
@export_enum("EYE", "NOSE", "HAT", "EAR", "CHECKER") var monster_type: String = "EYE"

var door_state: String = "CLOSED"
var _cycle_time: float = 0.0
var _player: HotelPlayer


func setup(player: HotelPlayer) -> void:
	_player = player
	if is_inside_tree() and not Engine.is_editor_hint():
		_connect_identity_signal()


func _connect_identity_signal() -> void:
	if not CardManager.identity_changed.is_connected(_on_identity_changed):
		CardManager.identity_changed.connect(_on_identity_changed)


func _exit_tree() -> void:
	if not Engine.is_editor_hint() and CardManager.identity_changed.is_connected(_on_identity_changed):
		CardManager.identity_changed.disconnect(_on_identity_changed)


func _can_check() -> bool:
	return (not Engine.is_editor_hint() and can_process()
		and GameManager.game_state == "PLAYING" and door_state == "OPEN"
		and is_instance_valid(_player)
		and absf(_player.global_position.x - global_position.x) <= maxf(radius, 0.0))


func _on_identity_changed(action: String) -> void:
	if monster_type == "CHECKER" and action in ["SWITCH_ACTIVE", "EQUIP_CARD"] and _can_check():
		GameManager.fail("SWITCHED_NEAR_CHECKER")


func _physics_process(_delta: float) -> void:
	if not _can_check():
		return
	var required_cards: Dictionary = {"EYE": "SECURITY", "NOSE": "CLEANER", "HAT": "MANAGER"}
	if required_cards.has(monster_type) and CardManager.active_card != required_cards[monster_type]:
		GameManager.fail("WRONG_CARD")
	elif monster_type == "EAR" and _player.is_moving:
		GameManager.fail("MOVED_NEAR_EAR")


func _ready() -> void:
	$RoomNumber.text = room_id
	# Player computes this frame's actual displacement before EAR reads it.
	process_physics_priority = 1
	if not Engine.is_editor_hint():
		_connect_identity_signal()
	reset_cycle()


func _process(delta: float) -> void:
	if Engine.is_editor_hint() or GameManager.game_state != "PLAYING":
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
