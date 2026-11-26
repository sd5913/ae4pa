extends Control
## Presentation only: closing a card never advances a dialogue beat or settles rescue.
signal closed
var active := false
var ready_to_continue := false
var _tween: Tween
var _heading: Label
var _location: Label
var _hint: Label
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.065, 0.065, 0.72)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.anchor_left = 0.18; box.anchor_right = 0.82
	box.anchor_top = 0.30; box.anchor_bottom = 0.73
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 22)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)
	_heading = _label(22, Color("dabb80")); box.add_child(_heading)
	var ornament := _label(22, Color("b99252")); ornament.text = "────────  ◇  ────────"; box.add_child(ornament)
	_location = _label(44, Color("f3e8cf")); box.add_child(_location)
	_hint = _label(17, Color("c7bba4")); box.add_child(_hint)
	_hint.text = "点击或按 E 继续"
	hide()
func _label(font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label
func present(heading: String, location: String) -> void:
	cancel()
	active = true
	_heading.text = heading; _location.text = location
	_hint.modulate.a = 0.0
	modulate.a = 0.0
	show()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.65)
	_tween.tween_interval(1.0)
	_tween.tween_property(_hint, "modulate:a", 1.0, 0.25)
	_tween.tween_callback(func(): ready_to_continue = true)
func dismiss() -> void:
	if not active or not ready_to_continue: return
	ready_to_continue = false
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, 0.35)
	_tween.tween_callback(func(): active = false; hide(); closed.emit())
func cancel() -> void:
	if _tween != null: _tween.kill(); _tween = null
	active = false; ready_to_continue = false
	hide()
