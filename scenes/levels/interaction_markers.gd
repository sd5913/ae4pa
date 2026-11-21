extends Node2D
## Floor-only presentation; the actual stair permission remains in GameManager.
var floor_node: Node2D
func _ready() -> void:
	floor_node = get_parent()
	z_index = 2
func is_in_stair_range(stair: Node2D) -> bool:
	return absf(floor_node.player.global_position.x - stair.global_position.x) <= GameManager.STAIR_INTERACTION_RADIUS
func _process(_delta: float) -> void:
	visible = GameManager.is_world_input_allowed()
	queue_redraw()
func _draw() -> void:
	if not is_instance_valid(floor_node): return
	for stair: Node2D in [floor_node.return_point, floor_node.exit_point]:
		if stair == floor_node.return_point and floor_node.floor_number == 1: continue
		var inside := is_in_stair_range(stair)
		var color := Color("f1d69b") if inside else Color("b4a88c")
		var rect := Rect2(stair.position + Vector2(-GameManager.STAIR_INTERACTION_RADIUS, -10), Vector2(GameManager.STAIR_INTERACTION_RADIUS * 2, 20))
		draw_rect(rect, Color(color, 0.22 if inside else 0.08))
		draw_rect(rect, Color(color, 0.9 if inside else 0.45), false, 2)
		var center := stair.position
		var direction := -1.0 if stair == floor_node.exit_point else 1.0
		if floor_node.floor_number == 5 and stair == floor_node.exit_point: direction = 0
		if direction != 0:
			draw_polyline(PackedVector2Array([center + Vector2(-9, -direction*4), center + Vector2(0,direction*4), center + Vector2(9,-direction*4)]), color, 2, true)
