extends Button
## Fixed-height edge drawer: hover/focus reveals text; activation still uses pressed.
var caption := ""
var expanded := false
var _motion: Tween

func configure(value: String) -> void:
	caption = value
	custom_minimum_size = Vector2(52, 48)
	size_flags_horizontal = Control.SIZE_SHRINK_END
	icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	expand_icon = true
	clip_text = true
	add_theme_constant_override("icon_max_width", 30)
	add_theme_constant_override("h_separation", 12)
	add_theme_font_size_override("font_size", 18)
	for state in ["normal", "hover", "pressed", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("293d37") if state in ["hover", "focus"] else Color("162522")
		style.border_color = Color("e4bc70")
		style.set_border_width_all(2)
		style.set_corner_radius_all(5)
		style.content_margin_left = 16
		style.content_margin_right = 10
		add_theme_stylebox_override(state, style)
	mouse_entered.connect(set_expanded.bind(true))
	mouse_exited.connect(set_expanded.bind(false))
	focus_entered.connect(set_expanded.bind(true))
	focus_exited.connect(set_expanded.bind(false))
	text = ""
	tooltip_text = tr(caption)
	set_expanded(false, true)

func set_expanded(value: bool, instant: bool = false) -> void:
	expanded = value
	if is_instance_valid(_motion): _motion.kill()
	text = tr(caption) if value else ""
	var width := 184.0 if value else 52.0
	if instant:
		offset_left = -width - 8
	else:
		_motion = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		_motion.tween_property(self, "offset_left", -width - 8, 0.14)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and not caption.is_empty():
		text = tr(caption) if expanded else ""
		tooltip_text = tr(caption)
