extends Node2D

@export var corridor_width: float = 2800.0

@onready var player: HotelPlayer = $Player


func _ready() -> void:
	player.global_position = $SpawnPoint.global_position
	player.set_walk_bounds(64.0, corridor_width - 64.0)
	var camera: Camera2D = player.get_node("Camera2D")
	camera.limit_right = roundi(corridor_width)
	if GameManager.game_state == "MENU":
		GameManager.start_game()
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0, 0, corridor_width, 720), Color("19282d"))
	draw_rect(Rect2(0, 180, corridor_width, 380), Color("22383d"))
	for index: int in range(1, ceili(corridor_width / 160.0)):
		var x: float = index * 160.0
		draw_line(Vector2(x, 180), Vector2(x, 560), Color("2b454a"), 1.0)
	draw_rect(Rect2(0, 560, corridor_width, 160), Color("101c21"))
	draw_line(Vector2(0, 560), Vector2(corridor_width, 560), Color("b89862"), 3.0)
	for index: int in range(1, ceili(corridor_width / 160.0)):
		var x: float = index * 160.0
		draw_line(Vector2(x, 560), Vector2(x, 720), Color("1d3037"), 1.0)
