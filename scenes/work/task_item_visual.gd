extends Node2D
## Presentation only: completion/reward truth stays with the B component.
var _work: Node2D
var _item: Sprite2D
var _cabinet: Sprite2D
var _name_label: Label
var _result_label: Label
var _result_timer: Timer

func _ready() -> void:
	_work = get_parent()
	var target := str(_work.get("target_id"))
	match target:
		"STAIN_201", "STAIN_204":
			_hide("Stain")
			_item = _sprite("stain_201.png",Rect2(181,206,1811,383),Vector2(130,34),Vector2(0,3))
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
		"ROOM_SERVICE_203", "TRANSIT_REGISTER_205", "REGISTER_309", "EXIT_REGISTER_5F":
			_hide("WorkVisual")
			if target == "EXIT_REGISTER_5F" and not _work.has_node("PersistentVisual"):
				var desk := Sprite2D.new()
				desk.name = "PersistentVisual"
				desk.texture = load("res://assets/final/floor_3_layers/03_furniture/registration_desk.png")
				desk.scale = Vector2(0.16,0.16)
				desk.position = Vector2(0,-81.36)
				_work.add_child(desk)
			# Keep the form on a clear section of the desk, away from the key rack.
			_item = _sprite("exit_authorization_503.png",Rect2(12,12,1563,967),Vector2(72,34),Vector2(-45,-68))
			_name_label = _label("ItemName", -218)
			_result_label = _label("ResultFeedback", -244)
			_result_label.modulate = Color("e6eec1")
			_result_label.hide()
			_result_timer = Timer.new()
			_result_timer.one_shot = true
			_result_timer.wait_time = 3.0
			_result_timer.timeout.connect(func() -> void: _result_label.hide())
			add_child(_result_timer)
		"STAFF_PATROL_4F":
			_item = _sprite("patrol_record_402.png",Rect2(60,39,1256,961),Vector2(50,37),Vector2(-30,-85))
	_sync()

func _label(node_name: String, top: float) -> Label:
	var label := Label.new()
	label.name = node_name
	label.position = Vector2(-170,top)
	label.size = Vector2(340,48)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",16)
	label.add_theme_color_override("font_outline_color", Color("211c17"))
	label.add_theme_constant_override("outline_size",4)
	label.z_index = 3
	add_child(label)
	return label

func show_result() -> void:
	if not is_instance_valid(_result_label): return
	_result_label.text = tr("已批准：%s") % _work.get_display_name()
	_result_label.show()
	_result_timer.start()

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
	if is_instance_valid(_name_label):
		_name_label.text = _work.get_display_name()
		var player: Node2D = _work.get("_player")
		_name_label.visible = not completed and GameManager.is_world_input_allowed() and is_instance_valid(player) and absf(player.global_position.x - _work.global_position.x) < 180
		if not completed:
			_result_label.hide()
			_result_timer.stop()
	if is_instance_valid(_item):
		_item.visible = not completed
		if _work.get("interaction_type") == "CLEAN":
			_item.modulate.a = 1.0 - 0.65 * _work.get_interaction_progress()
		if _work.has_method("is_reward_available"):
			_item.position.x = -30.0*_work.facing_direction
	if is_instance_valid(_cabinet):
		_cabinet.texture = load("res://assets/final/work/parcel_cabinet_empty.png") if completed else load("res://assets/final/floor_2_layers/05_interactive/mail_package_cabinet.png")
		# Keep the shared cabinet; only its envelope-containing cubby changes.
		_hide("ItemVisual")
