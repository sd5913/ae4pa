extends Node2D
## Presentation only: completion/reward truth stays with the B component.
var _work: Node2D
var _item: Sprite2D
var _cabinet: Sprite2D

func _ready() -> void:
	_work = get_parent()
	var target := str(_work.get("target_id"))
	match target:
		"STAIN_201":
			_hide("Stain")
			_item = _sprite("stain_201.png",Rect2(181,206,1811,383),Vector2(110,30),Vector2(0,3))
		"PARCEL_CABINET_2F":
			_hide("ItemVisual")
			_cabinet = _work.get_node_or_null("PersistentVisual")
			var ancestor: Node = _work.get_parent()
			while ancestor != null:
				var formal := ancestor.get_node_or_null("Floor2Art/InteractiveProps/PackageCabinet")
				if formal is Sprite2D:
					_cabinet = formal
					break
				ancestor = ancestor.get_parent()
		"EXIT_REGISTER_5F":
			_hide("WorkVisual")
			_item = _sprite("exit_authorization_503.png",Rect2(12,12,1563,967),Vector2(70,32),Vector2(0,-48))
		"STAFF_PATROL_4F":
			_item = _sprite("patrol_record_402.png",Rect2(60,39,1256,961),Vector2(50,37),Vector2(-30,-85))
	_sync()

func _hide(path: String) -> void:
	var node := _work.get_node_or_null(path)
	if node is CanvasItem:
		node.hide()

func _sprite(file: String,rect: Rect2,size: Vector2,at: Vector2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = load("res://assets/final/work/"+file)
	sprite.region_enabled = true
	sprite.region_rect = rect
	sprite.scale = size/rect.size
	sprite.position = at
	sprite.z_index = 1
	add_child(sprite)
	return sprite

func _process(_delta: float) -> void:
	_sync()

func _sync() -> void:
	if not is_instance_valid(_work):
		return
	var completed: bool = _work.is_completed() if _work.has_method("is_completed") else not _work.is_reward_available()
	if is_instance_valid(_item):
		_item.visible = not completed
		if _work.has_method("is_reward_available"):
			_item.position.x = -30.0*_work.facing_direction
	if is_instance_valid(_cabinet):
		_cabinet.texture = load("res://assets/final/work/parcel_cabinet_empty.png") if completed else load("res://assets/final/floor_2_layers/05_interactive/mail_package_cabinet.png")
		# Keep the shared cabinet; only its envelope-containing cubby changes.
		_hide("ItemVisual")
