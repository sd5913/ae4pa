extends Node2D
## F6 art placement study using the supplied PNGs and A's real horizontal player.

const WORLD_WIDTH: float = 3600.0
const WALK_Y: float = 560.0
const ART_REGIONS: Array[Rect2i] = [
	Rect2i(0, 806, 3840, 548),
	Rect2i(0, 866, 3840, 428),
	Rect2i(0, 866, 3840, 428),
	Rect2i(0, 845, 3840, 470),
	Rect2i(0, 736, 3840, 688),
]
const ART_WALK_Y: Array[float] = [1290.0, 1260.0, 1260.0, 1280.0, 1390.0]
const FLOOR_TITLES: Array[String] = ["大堂", "客房走廊", "登记与 309", "员工楼层", "逃生楼层"]

var current_floor: int = 1
var _title: Label
var _marker_toggle: CheckButton

@onready var player: HotelPlayer = $Player
@onready var background: Sprite2D = $FloorBackground
@onready var markers: Node2D = $IntegrationMarkers


func _ready() -> void:
	GameManager.set_floor_host(null)
	GameManager.start_game()
	player.set_walk_bounds(64.0, WORLD_WIDTH - 64.0)
	player.get_node("Camera2D").limit_right = int(WORLD_WIDTH)
	# Enlarge the preview figure at the visual level, retaining the existing camera.
	for part: Node2D in player.get_node("Visual").get_children():
		part.scale = Vector2(2.4, 2.4)
	_build_controls()
	select_floor(1)


func select_floor(floor_number: int) -> void:
	if floor_number < 1 or floor_number > 5:
		return
	current_floor = floor_number
	var region: Rect2i = ART_REGIONS[floor_number - 1]
	var atlas := AtlasTexture.new()
	atlas.atlas = load("res://assets/backgrounds/floor_%d.png" % floor_number)
	atlas.region = Rect2(region)
	background.texture = atlas
	var art_scale: float = WORLD_WIDTH / float(region.size.x)
	background.scale = Vector2(art_scale, art_scale)
	background.position = Vector2(0.0, WALK_Y - (ART_WALK_Y[floor_number - 1] - region.position.y) * art_scale)
	player.global_position = Vector2(600.0, WALK_Y)
	player.get_node("Camera2D").reset_smoothing()
	_title.text = "%dF · %s · 背景接入预览" % [floor_number, FLOOR_TITLES[floor_number - 1]]
	_refresh_markers(floor_number)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.is_echo():
		return
	var floor_number: int = int(event.physical_keycode) - KEY_1 + 1
	if floor_number >= 1 and floor_number <= 5:
		select_floor(floor_number)
		get_viewport().set_input_as_handled()


func _build_controls() -> void:
	var layer := CanvasLayer.new()
	layer.name = "PreviewControls"
	layer.layer = 10
	add_child(layer)
	var panel := PanelContainer.new()
	panel.name = "Panel"
	panel.position = Vector2(16, 12)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.02, 0.04, 0.92)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	panel.add_theme_stylebox_override("panel", style)
	layer.add_child(panel)
	var column := VBoxContainer.new()
	column.name = "Content"
	panel.add_child(column)
	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 22)
	column.add_child(_title)
	var help := Label.new()
	help.text = "A / D 或方向键移动 · 1—5 换层 · 图中人物与房门为静态内容"
	column.add_child(help)
	var row := HBoxContainer.new()
	row.name = "FloorButtons"
	column.add_child(row)
	for number: int in range(1, 6):
		var button := Button.new()
		button.name = "Floor%d" % number
		button.text = "%dF" % number
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(select_floor.bind(number))
		row.add_child(button)
	_marker_toggle = CheckButton.new()
	_marker_toggle.name = "IntegrationToggle"
	_marker_toggle.text = "显示当前主线接入点"
	_marker_toggle.focus_mode = Control.FOCUS_NONE
	_marker_toggle.toggled.connect(func(enabled: bool) -> void: markers.visible = enabled)
	row.add_child(_marker_toggle)


func _refresh_markers(floor_number: int) -> void:
	for child: Node in markers.get_children():
		markers.remove_child(child)
		child.queue_free()
	var floor_scene: Node = load("res://scenes/levels/floor_%d.tscn" % floor_number).instantiate()
	for slot: Node2D in floor_scene.get_node("DoorRoot").get_children():
		_add_marker(slot.position.x, str(slot.get_meta("room_number")))
	for slot: Node2D in floor_scene.get_node("StaffRoot").get_children():
		_add_marker(slot.position.x, str(slot.get_meta("card_id")))
	if floor_scene.has_node("Interactions/Stain201Slot"):
		_add_marker(floor_scene.get_node("Interactions/Stain201Slot").position.x, "STAIN_201")
	_add_marker(floor_scene.get_node("Interactions/ExitPoint").position.x, "EXIT")
	_add_marker(floor_scene.get_node("Interactions/ReturnPoint").position.x, "STAIRS")
	floor_scene.free()


func _add_marker(world_x: float, caption: String) -> void:
	var line := Line2D.new()
	line.points = PackedVector2Array([Vector2(world_x, 290.0), Vector2(world_x, WALK_Y + 15.0)])
	line.width = 2.0
	line.default_color = Color(0.3, 0.95, 1.0, 0.8)
	markers.add_child(line)
	var label := Label.new()
	label.text = "%s · x%d" % [caption, int(world_x)]
	label.position = Vector2(world_x - 70.0, 265.0)
	label.add_theme_color_override("font_color", Color(0.6, 1.0, 1.0))
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	markers.add_child(label)
