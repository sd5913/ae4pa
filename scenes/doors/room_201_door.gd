@tool
extends "res://scenes/doors/monster_door.gd"
## Optional 201 skin: inherits existing gameplay without changing other doors.


func _refresh_visuals() -> void:
	super._refresh_visuals()
	for path: String in ["Frame", "DoorPanel", "Handle", "MonsterPlaceholder", "RoomNumber"]:
		get_node(path).hide()
	$Art.set_state(door_state)
