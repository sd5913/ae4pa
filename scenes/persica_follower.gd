extends Node2D
## Visual companion only; no collisions, task rewards or independent rescue state.
var player: Node2D
var sprite := Sprite2D.new()
func _ready() -> void:
	var sheet: Texture2D = preload("res://assets/final/characters/persica/q_views.png")
	var image := sheet.get_image().get_region(Rect2i(0, 0, sheet.get_width()/3, sheet.get_height()))
	var bounds := image.get_used_rect()
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	atlas.region = Rect2(bounds)
	sprite.texture = atlas
	sprite.scale = Vector2.ONE * 180.0 / bounds.size.y
	sprite.position.y = -90
	add_child(sprite)
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
	if not is_instance_valid(player) or not GameManager.is_world_input_allowed(): return
	var dx := player.global_position.x - global_position.x
	if absf(dx) > 72:
		global_position.x = move_toward(global_position.x, player.global_position.x - signf(dx)*72, 180*delta)
		sprite.flip_h = dx < 0
	global_position.y = player.global_position.y
