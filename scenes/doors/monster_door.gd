@tool
extends Node2D
## C-01: reusable visual shell. Timing and danger checks start at C-02.

@export var room_id: String = "201":
	set(value):
		room_id = value
		if is_node_ready():
			$RoomNumber.text = room_id


func _ready() -> void:
	$RoomNumber.text = room_id
