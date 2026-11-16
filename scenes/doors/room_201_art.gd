@tool
extends Node2D
## Full-canvas textures share one Sprite2D, transform and bottom-center anchor.

const TEXTURES = {
	"CLOSED": preload("res://assets/final/doors/room_201/door_closed.png"),
	"WARNING": preload("res://assets/final/doors/room_201/door_warning.png"),
	"OPEN": preload("res://assets/final/doors/room_201/door_open.png"),
}

@export_enum("CLOSED", "WARNING", "OPEN") var state: String = "CLOSED":
	set(value):
		if not TEXTURES.has(value):
			return
		state = value
		if is_node_ready():
			$Sprite2D.texture = TEXTURES[state]


func _ready() -> void:
	$Sprite2D.texture = TEXTURES[state]


func set_state(value: String) -> void:
	state = value
