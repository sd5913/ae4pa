extends Node2D
## Rear footprint mirrors B's real facing/range, without changing theft rules.
var staff: Node2D
func _ready() -> void:
	staff = get_parent()
	z_index = 3
func get_rear_direction() -> int: return -staff.facing_direction
func _process(_delta: float) -> void:
	var player: Node2D = staff.get("_player")
	visible = GameManager.is_world_input_allowed() and staff.is_task_eligible() and staff.is_reward_available() and is_instance_valid(player) and absf(player.global_position.x - staff.global_position.x) < 220
	queue_redraw()
func _draw() -> void:
	if not is_instance_valid(staff): return
	var width: float = maxf(0, staff.steal_radius - 12)
	var side: float = get_rear_direction()
	var center := Vector2(side * (12 + width * 0.5), 0)
	var color := Color("a4d5be") if staff.is_player_behind() else Color("efc57f")
	var rect := Rect2(center - Vector2(width*0.5, 7), Vector2(width,14))
	draw_rect(rect, Color(color,0.3))
	draw_rect(rect, color, false, 2)
	for offset in [-4,4]: draw_circle(center + Vector2(offset,0), 2, color)
	draw_line(Vector2(-side*12, -4), Vector2(-side*12,4), Color("d78372"),3)
