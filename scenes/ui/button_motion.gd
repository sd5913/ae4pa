extends Node
## Visual feedback only: absolute scale targets, one tween per button.
const UI_THEME := preload("res://scenes/ui/staff_ui_theme.tres")
var _buttons: Array[Button] = []

func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)
	for button: Node in get_parent().find_children("*", "Button", true, false):
		_bind_button(button)

func _on_node_added(node: Node) -> void:
	if node is Button and get_parent().is_ancestor_of(node):
		_bind_button(node)

func _bind_button(button: Button) -> void:
	if _buttons.has(button):
		return
	_buttons.append(button)
	var binding_key := "button_motion_%d" % get_instance_id()
	if button.has_meta(binding_key): return
	button.set_meta(binding_key, true)
	button.theme = UI_THEME
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	button.clip_text = false
	button.resized.connect(func() -> void: button.pivot_offset = button.size * 0.5)
	button.pivot_offset = button.size * 0.5
	for event: StringName in [&"mouse_entered", &"mouse_exited", &"focus_entered", &"focus_exited", &"button_down", &"button_up", &"visibility_changed"]:
		button.connect(event, _refresh.bind(button))
	button.tree_exiting.connect(func() -> void: _buttons.erase(button))
	_refresh(button)

func _process(_delta: float) -> void:
	for button: Button in _buttons:
		if button.disabled and button.scale != Vector2.ONE:
			_refresh(button)

func _refresh(button: Button) -> void:
	var old_tween: Tween = button.get_meta("hover_tween") if button.has_meta("hover_tween") else null
	if old_tween != null and old_tween.is_valid():
		old_tween.kill()
	button.remove_meta("hover_tween") if button.has_meta("hover_tween") else null
	if not button.is_visible_in_tree() or button.disabled:
		button.scale = Vector2.ONE
		button.self_modulate = Color.WHITE
		return
	# Color feedback keeps geometry and hit rectangles stationary.
	button.scale = Vector2.ONE
	var target := Color(1.035, 1.025, 1.01) if button.is_hovered() else Color.WHITE
	if button.is_pressed(): target = Color(0.96, 0.95, 0.93)
	var tween := button.create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(button, "self_modulate", target, 0.12)
	button.set_meta("hover_tween", tween)
