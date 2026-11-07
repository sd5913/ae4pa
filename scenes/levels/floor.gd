extends Node2D
## Shared placeholder corridor. Markers are integration positions, not functional staff/doors.

@export_range(1, 5) var floor_number: int = 1
@export var corridor_width: float = 3600.0

@onready var player: HotelPlayer = $Player
@onready var exit_point: Marker2D = $Interactions/ExitPoint
@onready var exit_hint: Label = $Interactions/ExitPoint/Hint


func _ready() -> void:
	player.global_position = $SpawnPoint.global_position
	player.set_walk_bounds(64.0, corridor_width - 64.0)
	var camera: Camera2D = player.get_node("Camera2D")
	camera.limit_right = roundi(corridor_width)
	camera.reset_smoothing()
	for slot: Node2D in $StaffRoot.get_children():
		_add_caption(slot, "%s\n员工接入位" % slot.get_meta("card_id"), -165.0)
	for slot: Node2D in $DoorRoot.get_children():
		_add_caption(slot, "%s · %s\n房门接入位" % [slot.get_meta("room_number"), slot.get_meta("monster_type")], -230.0)
	if $Interactions.has_node("RescuePoint"):
		_add_caption($Interactions/RescuePoint, "309 · 救援接入位\n对白与救援尚未实现", -165.0)
	_refresh_exit_hint()
	queue_redraw()


func _process(_delta: float) -> void:
	_refresh_exit_hint()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or event.is_echo():
		return
	if GameManager.game_state != "PLAYING" or floor_number == 5:
		return
	if absf(player.global_position.x - exit_point.global_position.x) > 70.0:
		return
	get_viewport().set_input_as_handled()
	GameManager.go_to_floor(floor_number + 1)


func _refresh_exit_hint() -> void:
	if floor_number == 5:
		exit_hint.text = "EXIT · 终点接入位\n通关功能待 A-10"
	elif floor_number == 1 and not CardManager.has_all_cards():
		exit_hint.text = "上楼需要集齐三张 ID\n等待 B 的真实卡片组件"
	elif floor_number == 3 and not GameManager.has_friend:
		exit_hint.text = "先完成 309 救援才能上楼\n救援功能待 A-08"
	else:
		exit_hint.text = "靠近后按 E → %dF" % (floor_number + 1)


func _add_caption(slot: Node2D, caption: String, top: float) -> void:
	var label := Label.new()
	label.position = Vector2(-160, top)
	label.size = Vector2(320, 64)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.text = caption
	slot.add_child(label)


func _draw() -> void:
	var wall_colors: Array[Color] = [Color("33464a"), Color("2a3d4d"), Color("3c3549"), Color("30433e"), Color("493c35")]
	draw_rect(Rect2(0, 0, corridor_width, 720), Color("172226"))
	draw_rect(Rect2(0, 180, corridor_width, 380), wall_colors[floor_number - 1])
	for x: int in range(160, int(corridor_width), 160):
		draw_line(Vector2(x, 180), Vector2(x, 560), Color(1, 1, 1, 0.05))
	draw_rect(Rect2(0, 560, corridor_width, 160), Color("111b20"))
	draw_line(Vector2(0, 560), Vector2(corridor_width, 560), Color("b89862"), 3.0)
	for slot: Node2D in $DoorRoot.get_children():
		draw_rect(Rect2(slot.position + Vector2(-65, -150), Vector2(130, 150)), Color("17232b"))
		draw_rect(Rect2(slot.position + Vector2(-65, -150), Vector2(130, 150)), Color("9a927f"), false, 3.0)
	for slot: Node2D in $StaffRoot.get_children():
		draw_circle(slot.position + Vector2(0, -50), 25, Color("738784"))
	draw_rect(Rect2(exit_point.position + Vector2(-30, -110), Vector2(60, 110)), Color("507e70"))
