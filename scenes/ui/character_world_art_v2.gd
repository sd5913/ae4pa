extends RefCounted
## Visual atlas adapter only. No movement, suspicion, reward or timer rules.
const Art = preload("res://scenes/ui/character_art_v2.gd")
const ROOT := Art.ROOT + "source/"
const FILES := {
	"an": ["carol_chibi_front_side_aligned_v1.png", "carol_walk_right_8frames_v1.png"],
	"manager": ["manager_chibi_front_side_aligned_v1.png", "manager_walk_right_8frames_v1.png"],
	"terese": ["terese_chibi_side_right_v1.png", "terese_walk_right_8frames_v1.png"],
}
static var _cache: Dictionary = {}
var character_id := ""
var _data: Dictionary

func setup(id: String) -> void:
	character_id = id
	if not _cache.has(id):
		var master: Texture2D = load(ROOT + FILES[id][0])
		var idle_region := Rect2i(Vector2i.ZERO, master.get_size())
		if id != "terese":
			idle_region.position.x = master.get_width() / 2
			idle_region.size.x = master.get_width() / 2
		var idle_image := master.get_image().get_region(idle_region)
		var idle := ImageTexture.create_from_image(idle_image)
		var idle_bounds := Art.solid_bounds(idle_image)
		var walk: Texture2D = load(ROOT + FILES[id][1])
		var image := walk.get_image()
		var cell := Vector2i(image.get_width() / 4, image.get_height() / 2)
		var bounds: Array[Rect2i] = []
		var max_height := 0
		for i in range(8):
			var rect := Art.solid_bounds(image.get_region(Rect2i(Vector2i(i % 4, i / 4) * cell, cell)))
			bounds.append(rect)
			max_height = maxi(max_height, rect.size.y)
		var data := {"idle":idle, "idle_bounds":idle_bounds, "walk":walk, "cell":cell, "bounds":bounds, "max_height":max_height}
		if id == "an":
			data["cleaning"] = load(Art.ROOT + "actions/carol_cleaning.png") as Texture2D
			data["cleaning_bounds"] = Art.solid_bounds(data.cleaning.get_image())
		_cache[id] = data
	_data = _cache[id]

func pose(walking: bool, phase: float, height: float, cleaning: bool = false) -> Dictionary:
	var frame := int(phase * 8.0) % 8 if walking else -1
	var texture: Texture2D = _data.walk if walking else _data.idle
	var source := Rect2(Vector2.ZERO, texture.get_size())
	var bounds: Rect2 = _data.bounds[frame] if walking else _data.idle_bounds
	var scale_height: float = _data.max_height if walking else bounds.size.y
	if walking:
		source = Rect2(Vector2(frame % 4, frame / 4) * Vector2(_data.cell), Vector2(_data.cell))
	if cleaning and character_id == "an":
		texture = _data.cleaning
		source = Rect2(Vector2.ZERO, texture.get_size())
		bounds = _data.cleaning_bounds
		scale_height = bounds.size.y
		frame = 8
	var ratio := height / scale_height
	var destination := Rect2(-Vector2(bounds.get_center().x, bounds.end.y) * ratio, source.size * ratio)
	# The head/coat landmarks are source-relative, replacing old 362px-only masks.
	var head := Rect2(bounds.position, Vector2(bounds.size.x, bounds.size.y * 0.44))
	if cleaning:
		head.size.x *= 0.64
	var coat := Rect2(bounds.position + Vector2(bounds.size.x * 0.10, bounds.size.y * 0.44), Vector2(bounds.size.x * 0.76, bounds.size.y * 0.40))
	return {"frame":frame, "texture":texture, "source":source, "destination":destination, "new_art":true, "head_source":head, "coat_source":coat}
