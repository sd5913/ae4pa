extends CanvasLayer
var box := HBoxContainer.new()
var label := Label.new()
var bar := ProgressBar.new()
var player: Node
func _ready() -> void:
 layer = 8
 var anchor := MarginContainer.new()
 add_child(anchor)
 anchor.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
 anchor.offset_left = 24
 anchor.offset_top = -44
 anchor.offset_bottom = -24
 anchor.add_child(box)
 box.add_theme_constant_override("separation",8)
 box.add_child(label)
 bar.custom_minimum_size = Vector2(160,10)
 bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
 bar.show_percentage = false
 var frame := StyleBoxFlat.new()
 frame.bg_color = Color("172624")
 frame.set_border_width_all(1)
 frame.border_color = Color("bd9457")
 bar.add_theme_stylebox_override("background",frame)
 box.add_child(bar)
func _process(_delta: float) -> void:
 var main := get_tree().current_scene
 if main == null or not main.has_node("World"): box.hide(); return
 var world := main.get_node("World")
 var next: Node = world.get_child(0).get_node_or_null("Player") if world.get_child_count()>0 else null
 if next != player:
  if is_instance_valid(player) and player.stamina_changed.is_connected(_changed): player.stamina_changed.disconnect(_changed)
  player = next
  if is_instance_valid(player): player.stamina_changed.connect(_changed)
 box.visible = get_parent().is_visible_in_tree() and is_instance_valid(player) and GameManager.is_world_input_allowed()
func _changed(value: float, exhausted: bool) -> void:
 bar.value = value
 var fill := StyleBoxFlat.new()
 fill.bg_color = Color("d4a35f") if value<30 else Color("9cb89a")
 bar.add_theme_stylebox_override("fill",fill)
 var keys := InputMap.action_get_events("toggle_run")
 var key := OS.get_keycode_string(keys[0].physical_keycode) if not keys.is_empty() else ""
 label.text = tr("体力不足") if exhausted else tr("体力")+" · "+key
