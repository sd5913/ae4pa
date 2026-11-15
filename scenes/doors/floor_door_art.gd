@tool
extends Node2D
## One full-canvas sprite and one transform for every state of each room.

@export_enum("201", "202", "203", "204", "205") var room_id: String = "201":
	set(value):
		room_id = value
		if is_node_ready():
			_refresh()
@export_enum("CLOSED", "WARNING", "OPEN") var state: String = "CLOSED":
	set(value):
		if value not in ["CLOSED", "WARNING", "OPEN"]:
			return
		state = value
		if is_node_ready():
			_refresh()


func _ready() -> void:
	_refresh()


func set_state(value: String) -> void:
	if state != value:
		state = value


func _refresh() -> void:
	$Sprite2D.texture = load("res://assets/final/doors/room_%s/door_%s.png" % [room_id, state.to_lower()])
