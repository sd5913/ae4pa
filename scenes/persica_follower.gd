extends Node2D
## Visual companion only; no collisions, task rewards or independent rescue state.
var player: Node2D
var _flip_h := false
var _art := preload("res://scenes/ui/character_world_art_v2.gd").new()
var _phase := 0.0
var _walking := false
func _ready() -> void:
	_art.setup("terese")
	queue_redraw()
	var label := Label.new()
	label.text = "Terese"
	label.position = Vector2(-60, -210)
	label.size.x = 120
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	GameManager.safe_return_started.connect(snap_to_player.unbind(1))
func setup(target: Node2D) -> void:
	player = target
	snap_to_player()
func snap_to_player() -> void:
	if not is_instance_valid(player): return
	global_position = player.global_position + Vector2(-72, 0)
func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or not GameManager.is_world_input_allowed():
		_walking = false
		queue_redraw()
		return
	var previous_x := global_position.x
	var dx := player.global_position.x - global_position.x
	if absf(dx) > 72:
		global_position.x = move_toward(global_position.x, player.global_position.x - signf(dx)*72, 180*delta)
		_flip_h = dx < 0
	global_position.y = player.global_position.y
	var distance := absf(global_position.x - previous_x)
	_walking = distance > 0.001
	_phase += distance / 96.0
	queue_redraw()

func _draw() -> void:
	if not is_node_ready(): return
	var pose := _art.pose(_walking, _phase, 180.0)
	if _flip_h:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(-1, 1))
	draw_texture_rect_region(pose.texture, pose.destination, pose.source)
	draw_set_transform(Vector2.ZERO)
