extends Node2D
## Presentation only. Original player geometry and CardManager remain authoritative.
const HEADWEAR := {"CLEANER":preload("res://assets/final/player/identity_outfits/cleaner_headscarf.png"),"SECURITY":preload("res://assets/final/player/identity_outfits/security_cap.png")}
const JACKET := preload("res://scenes/player/manager_jacket.gdshader")
# Original source-pixel mustard bounds. Frame8 is capped above the broom/legs.
const COATS: Array[Rect2] = [Rect2(137,152,99,122),Rect2(140,152,78,121),Rect2(152,152,69,116),Rect2(138,152,93,122),Rect2(141,152,81,121),Rect2(145,152,76,114),Rect2(117,162,134,106),Rect2(137,141,113,127),Rect2(105,140,134,122),Rect2(138,152,87,116),Rect2(135,156,94,113),Rect2(111,153,107,117)]
static var _heads: Dictionary = {}
static var _accessory_bounds: Dictionary = {}
var card_id := "NONE"
var _artwork: Node2D
var _jacket := ShaderMaterial.new()
var _head_rect := Rect2()
var _angle := 0.0
var _pose: Dictionary = {}

func _ready() -> void:
	_artwork=get_parent()
	_jacket.shader=JACKET
	_artwork.material=_jacket
	if _artwork.get("_refreshed") == null: _build_geometry()
	CardManager.cards_changed.connect(_sync)
	_sync()

func _solid_bounds(image: Image, max_y: int) -> Rect2:
	var lo:=image.get_size()
	var hi:=Vector2i.ZERO
	for y in mini(max_y,image.get_height()):
		for x in image.get_width():
			if image.get_pixel(x,y).a>=0.5:
				lo=lo.min(Vector2i(x,y));hi=hi.max(Vector2i(x,y))
	return Rect2(lo,hi-lo+Vector2i.ONE)

func _build_geometry() -> void:
	if not _heads.is_empty(): return
	var master: Image=_artwork.get("_master").get_image()
	_heads[-1]=_solid_bounds(master,438)
	var atlas: Image=_artwork.get("_atlas").get_image()
	for frame in range(12):
		var image:=atlas.get_region(Rect2i(frame%3*362,frame/3*362,362,362))
		_heads[frame]=_solid_bounds(image,int(COATS[frame].position.y)-2)
	for id: String in HEADWEAR:
		var image: Image=HEADWEAR[id].get_image()
		_accessory_bounds[id]=_solid_bounds(image,image.get_height())

func get_outfit_view() -> Dictionary:
	return {"card_id":card_id,"headwear":{"CLEANER":"headscarf","SECURITY":"cap"}.get(card_id,"NONE"),"jacket":card_id=="MANAGER","frame":_pose.get("frame",-1),"headwear_rect":_head_rect}

func _process(_delta: float) -> void: _sync()

func _sync() -> void:
	card_id=CardManager.active_card
	_pose=_artwork.get_render_pose()
	if _pose.is_empty(): return
	var frame: int=_pose["frame"]
	var destination: Rect2=_pose["destination"]
	var source: Rect2=_pose["source"]
	var ratio: float=destination.size.x/source.size.x
	var refreshed: bool = _pose.get("new_art", false)
	var head: Rect2 = _pose["head_source"] if refreshed else _heads[frame]
	head=Rect2(destination.position+head.position*ratio,head.size*ratio)
	var coat_source: Rect2 = _pose["coat_source"] if refreshed else (Rect2(202,440,189,307) if frame<0 else COATS[frame])
	var coat:=Rect2(destination.position+coat_source.position*ratio,coat_source.size*ratio)
	_jacket.set_shader_parameter("manager_active",card_id=="MANAGER")
	_jacket.set_shader_parameter("refresh_palette",refreshed)
	_jacket.set_shader_parameter("coat_rect",Vector4(coat.position.x-1,coat.position.y-2,coat.size.x+2,coat.size.y+2))
	# The bent cleaning pose has a short hem below the main coat; keep the broom untouched.
	var hem:=Rect2(destination.position+Vector2(141,262)*ratio,Vector2(14,4)*ratio) if frame==8 and not refreshed else Rect2()
	_jacket.set_shader_parameter("hem_rect",Vector4(hem.position.x,hem.position.y,hem.size.x,hem.size.y))
	# The original right-facing V-neck sits toward the leading edge of the shoulder.
	var neck_x: float=head.end.x-head.size.x*0.36 if frame<6 else coat.position.x+coat.size.x*0.60
	_jacket.set_shader_parameter("collar_top",Vector2(neck_x,coat.position.y+2))
	_jacket.set_shader_parameter("collar_bottom",Vector2(neck_x-1,coat.position.y+13))
	_head_rect=Rect2()
	_angle=0.12 if frame==8 else 0.0
	if HEADWEAR.has(card_id):
		if _accessory_bounds.is_empty():
			for id: String in HEADWEAR:
				var accessory_image: Image = HEADWEAR[id].get_image()
				_accessory_bounds[id] = _solid_bounds(accessory_image, accessory_image.get_height())
		var bounds: Rect2=_accessory_bounds[card_id]
		var width: float=head.size.x*(0.96 if card_id=="CLEANER" else 0.94)
		var height: float=width*bounds.size.y/bounds.size.x
		var top_offset := -0.40
		if card_id == "CLEANER":
			top_offset = 0.12 if refreshed else -0.10
		var top := head.position.y + height * top_offset
		_head_rect=Rect2(head.position.x+head.size.x*0.02,top,width,height)
	queue_redraw()

func _draw() -> void:
	if not HEADWEAR.has(card_id) or _head_rect.size==Vector2.ZERO: return
	var pivot:=_head_rect.get_center()
	draw_set_transform(pivot,_angle)
	draw_texture_rect_region(HEADWEAR[card_id],Rect2(-_head_rect.size*0.5,_head_rect.size),_accessory_bounds[card_id])
	draw_set_transform(Vector2.ZERO)
