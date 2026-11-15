@tool
extends Node2D
## Source-space layout. Floor 2 maps it to the existing 3600px corridor.

var _doors: Dictionary = {}


func bind_door(room_id: String, door: Node2D) -> void:
	_doors[room_id] = door
	door.hide() # Hide placeholder visuals, not gameplay processing or signals.
	_sync_door(room_id, door)


func _process(_delta: float) -> void:
	for room_id: String in _doors:
		var door = _doors[room_id]
		if is_instance_valid(door):
			_sync_door(room_id, door)


func _sync_door(room_id: String, door: Node2D) -> void:
	var visual: Node = get_node_or_null("Doors/Room" + room_id)
	if visual != null:
		visual.set_state(door.door_state)
