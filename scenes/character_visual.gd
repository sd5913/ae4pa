extends Node2D

@export var character_id := "an"
@export var visible_height := 190.0
const DISPLAY_HEIGHTS := {"an":190.0,"manager":190.0,"security":200.0,"cleaner":190.0}
var _master: Texture2D
var _atlas: Texture2D
var _master_rect: Rect2
var _cell: Vector2
var _cycle_ratio := 1.0
var _origins: Array[Vector2] = []
var _phase := 0.0
var _walking := false
var cleaning_active := false
var _owner_node: Node2D
var _previous_x := 0.0

# AN: 160px/s / 96px per cycle * 6 frames = 10fps (previously 16fps).
const AN_WALK_CYCLE_DISTANCE := 96.0
const STAFF_WALK_CYCLE_DISTANCE := 60.0

func _ready() -> void:
	set_character(character_id)

func set_cleaning_visual(active: bool) -> void:
	cleaning_active = active
	queue_redraw()

func set_character(id: String) -> void:
	character_id = id
	visible_height = DISPLAY_HEIGHTS[id]
	var master := (load("res://assets/final/characters/approved_static/%s.png" % id) as Texture2D).get_image()
	var side := master.get_region(Rect2i(master.get_width()/2,0,master.get_width()/2,master.get_height()))
	_master = ImageTexture.create_from_image(side)
	_master_rect = _solid_bounds(side)
	var image := (load("res://assets/final/characters/approved_actions/%s.png" % id) as Texture2D).get_image()
	_atlas = ImageTexture.create_from_image(image)
	_cell = Vector2(image.get_width()/3.0,image.get_height()/4.0)
	_origins.clear()
	var cycle_height := 0.0
	for i in 12:
		var frame := image.get_region(Rect2i(Vector2i(i%3,i/3)*Vector2i(_cell),Vector2i(_cell)))
		var bounds := _solid_bounds(frame)
		_origins.append(Vector2(bounds.get_center().x,bounds.end.y))
		if i < 6:
			cycle_height = maxf(cycle_height,bounds.size.y)
	_cycle_ratio = (200.0 if id == "security" else 190.0) / cycle_height
	_owner_node = get_parent().get_parent() if get_parent().name == "Visual" else get_parent()
	_previous_x = _owner_node.global_position.x
	queue_redraw()

func _solid_bounds(image: Image) -> Rect2:
	var lo := image.get_size()
	var hi := Vector2i.ZERO
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x,y).a >= 0.5:
				lo = Vector2i(mini(x,lo.x),mini(y,lo.y))
				hi = Vector2i(maxi(x,hi.x),maxi(y,hi.y))
	return Rect2(lo,hi-lo+Vector2i.ONE)

func set_walking(value: bool) -> void:
	_walking = value

func _process(delta: float) -> void:
	if not is_instance_valid(_owner_node):
		return
	var distance := absf(_owner_node.global_position.x-_previous_x)
	_previous_x = _owner_node.global_position.x
	if GameManager.game_state == "PLAYING":
		var cycle_distance := AN_WALK_CYCLE_DISTANCE if character_id == "an" else STAFF_WALK_CYCLE_DISTANCE
		_phase += distance/cycle_distance if _walking else delta*0.6
	queue_redraw()

func get_render_pose() -> Dictionary:
	if _atlas == null:
		return {}
	var frame := -1
	if character_id == "an" and cleaning_active:
		frame = 8
	elif _walking:
		frame = int(_phase*6.0)%6
	elif is_instance_valid(_owner_node) and _owner_node.has_method("is_alerted"):
		if _owner_node.is_alerted():
			frame = 11
		elif _owner_node.is_suspicious():
			frame = 10
		else:
			var state: String = _owner_node.get_cleaner_behavior_state()
			if state.begins_with("TURN"):
				frame = 9
			elif character_id == "cleaner" and state == "CLEANING":
				frame = 6+int(_phase*2.0)%2
			elif character_id == "cleaner" and state == "ORGANIZING":
				frame = 8
			elif character_id in ["manager","security"] and state in ["CLEANING","ORGANIZING"]:
				frame = 6 # Neutral standing pose; frames 7/8 are expressions, not an idle loop.
	if frame < 0:
		var ratio := (200.0 if character_id == "security" else 190.0)/_master_rect.size.y
		return {"frame":frame,"texture":_master,"source":Rect2(Vector2.ZERO,_master.get_size()),"destination":Rect2(-Vector2(_master_rect.get_center().x,_master_rect.end.y)*ratio,_master.get_size()*ratio)}
	var source := Rect2(Vector2(frame%3,frame/3)*_cell,_cell)
	return {"frame":frame,"texture":_atlas,"source":source,"destination":Rect2(-_origins[frame]*_cycle_ratio,_cell*_cycle_ratio)}


func _draw() -> void:
	var pose := get_render_pose()
	if pose.is_empty(): return
	draw_texture_rect_region(pose["texture"],pose["destination"],pose["source"])
