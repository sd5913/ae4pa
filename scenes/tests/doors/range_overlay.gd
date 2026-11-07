extends Node2D
## Test-only display, never required by the production door scene.


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var doors: Array[Node] = get_parent().get_node("DoorSlot").get_children()
	for index: int in range(doors.size()):
		var door: Node2D = doors[index]
		var point: Vector2 = to_local(door.global_position)
		var color := Color(0.9, 0.3, 0.2, 0.25) if door.door_state == "OPEN" else Color(0.5, 0.65, 0.7, 0.15)
		draw_rect(Rect2(point + Vector2(-door.radius, 4), Vector2(door.radius * 2, 58)), color)
		if index + 1 < doors.size():
			var next: Node2D = doors[index + 1]
			var left: float = point.x + door.radius
			var right: float = to_local(next.global_position).x - next.radius
			draw_rect(Rect2(left, point.y + 4, right - left, 58), Color(0.2, 0.8, 0.5, 0.18))
