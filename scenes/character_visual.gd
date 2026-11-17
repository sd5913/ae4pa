extends Node2D

const CELL_SIZE := 512
const WALK_FPS := 9.0
const ART := {
	"an": {
		"stand": preload("res://assets/final/player/q_front/an_q_front.png"),
		"walk": preload("res://assets/final/player/q_walk/an_walk.png"),
		## Visible bounds measured within the standing image, then each of the six cells.
		"bounds": [Rect2(129, 151, 488, 809),
			Rect2(138, 18, 282, 467), Rect2(114, 19, 279, 468), Rect2(82, 18, 274, 466),
			Rect2(140, 23, 287, 465), Rect2(112, 23, 281, 466), Rect2(81, 22, 275, 464)],
	},
	"cleaner": {
		"stand": preload("res://assets/final/staff/q_front/cleaner_q_front.png"),
		"walk": preload("res://assets/final/staff/q_walk/cleaner_walk.png"),
		## Visible bounds measured within the standing image, then each of the six cells.
		"bounds": [Rect2(168, 90, 420, 918),
			Rect2(151, 35, 266, 455), Rect2(122, 44, 263, 444), Rect2(97, 37, 261, 453),
			Rect2(152, 36, 270, 453), Rect2(124, 42, 262, 446), Rect2(96, 39, 262, 449)],
	},
	"manager": {
		"stand": preload("res://assets/final/staff/q_front/manager_q_front.png"),
		"walk": preload("res://assets/final/staff/q_walk/manager_walk.png"),
		## Visible bounds measured within the standing image, then each of the six cells.
		"bounds": [Rect2(160, 140, 476, 830),
			Rect2(164, 21, 301, 460), Rect2(98, 22, 299, 458), Rect2(61, 20, 297, 460),
			Rect2(162, 19, 303, 465), Rect2(97, 19, 304, 460), Rect2(61, 18, 300, 461)],
	},
	"security": {
		"stand": preload("res://assets/final/staff/q_front/security_q_front.png"),
		"walk": preload("res://assets/final/staff/q_walk/security_walk.png"),
		## Visible bounds measured within the standing image, then each of the six cells.
		"bounds": [Rect2(185, 116, 377, 875),
			Rect2(138, 23, 278, 458), Rect2(124, 24, 272, 457), Rect2(107, 23, 272, 458),
			Rect2(138, 26, 278, 455), Rect2(121, 27, 276, 454), Rect2(106, 26, 275, 455)],
	},
}

@export var character_id := "an"
@export var visible_height := 66.0

var _art: Dictionary
var _walking := false
var _elapsed := 0.0
var _frame := 0


func _ready() -> void:
	set_character(character_id)
	set_process(false)


func set_character(id: String) -> void:
	_art = ART[id]
	queue_redraw()


func set_walking(walking: bool) -> void:
	if _walking == walking:
		return
	_walking = walking
	_elapsed = 0.0
	_frame = 0
	set_process(walking)
	queue_redraw()


func _process(delta: float) -> void:
	_elapsed = fmod(_elapsed + delta, 6.0 / WALK_FPS)
	var frame_index := int(_elapsed * WALK_FPS)
	if _frame != frame_index:
		_frame = frame_index
		queue_redraw()


func _draw() -> void:
	if _art.is_empty():
		return
	var texture: Texture2D = _art["walk"] if _walking else _art["stand"]
	var bounds: Rect2 = _art["bounds"][_frame + 1 if _walking else 0]
	var source := Rect2(Vector2.ZERO, texture.get_size())
	if _walking:
		source = Rect2(Vector2(_frame % 3, 0 if _frame < 3 else 1) * CELL_SIZE, Vector2.ONE * CELL_SIZE)

	# Keep the visible foot and head at the same height for every pose.
	var ratio := visible_height / bounds.size.y
	var origin := Vector2(bounds.get_center().x, bounds.end.y)
	draw_texture_rect_region(texture, Rect2(-origin * ratio, source.size * ratio), source)
