extends Node2D
## F6 visual-only fixture: leaves the production floor's task/gate rules untouched.
var floor_node: Node2D
func _ready() -> void:
	GameManager.start_game()
	GameManager.current_floor = 3
	floor_node = preload("res://scenes/levels/floor_3.tscn").instantiate()
	add_child(floor_node)
	# This isolated art fixture permits viewing the full corridor, never F5.
	floor_node.player.set_walk_bounds(64, floor_node.corridor_width - 64)
	for door in floor_node._doors:
		door.set_physics_process(false)
	for child in floor_node.get_children():
		if child.get_script() == preload("res://scenes/doors/door_scheduler.gd"):
			child.set_process(false)
