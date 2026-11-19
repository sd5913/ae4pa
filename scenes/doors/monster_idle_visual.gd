extends AnimatedSprite2D
## Shared full-cell atlas animation: no individual trimming or frame scaling.
var kind := ""
func configure(value: String, height_scale: float = 1.0) -> void:
	if kind == value:
		return
	kind = value
	var texture: Texture2D = load("res://assets/final/monster_idle/%s_idle_sheet.png" % value.to_lower())
	var frames := SpriteFrames.new()
	frames.add_animation("idle")
	frames.set_animation_speed("idle",6.0)
	for i in range(8):
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(i%4*362,i/4*543,362,543)
		frames.add_frame("idle",atlas,2.0 if i in [0,7] else 1.0)
	sprite_frames = frames
	centered = false
	var baselines := {"EYE":487.0,"NOSE":514.0,"HAT":507.0,"EAR":455.0,"CHECKER":512.0}
	offset = Vector2(-181,-baselines[value])
	scale = Vector2.ONE*height_scale
	play("idle")

func _process(_delta: float) -> void:
	speed_scale = 1.0 if GameManager.is_world_input_allowed() else 0.0
