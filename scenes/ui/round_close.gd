extends Button
func _ready() -> void:
	text = ""
	tooltip_text = tr("关闭")
	for state in ["normal","hover","pressed","focus","disabled"]: add_theme_stylebox_override(state, StyleBoxEmpty.new())
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
func _has_point(point: Vector2) -> bool:
	return point.distance_to(size * 0.5) <= minf(size.x,size.y)*0.5
func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, 18, Color("485248") if is_hovered() else Color("27332d"))
	draw_arc(center,18,0,TAU,48,Color("d8b66d"),2,true)
	draw_line(center-Vector2(5,5),center+Vector2(5,5),Color("f2dfb7"),2,true)
	draw_line(center+Vector2(-5,5),center+Vector2(5,-5),Color("f2dfb7"),2,true)
