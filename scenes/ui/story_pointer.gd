extends RefCounted
## Recognize a click on a story surface; scrolling and dragging remain GUI gestures.
const IGNORE := 0
const CONSUME := 1
const ADVANCE := 2
var _down := false
var _origin := Vector2.ZERO
var _dragged := false
var _touch_until := 0
func reset() -> void:
	_down = false
	_dragged = false
func feed(event: InputEvent, surfaces: Array[Rect2], blocked: bool = false) -> int:
	var interact := event.is_action("interact")
	if event is InputEventKey:
		# Respect the configured key even when a legacy mapping pins a keyboard device ID.
		for binding in InputMap.action_get_events("interact"):
			if binding is InputEventKey:
				var code: int = binding.physical_keycode if binding.physical_keycode != 0 else binding.keycode
				var actual: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
				interact = interact or (actual == code and event.ctrl_pressed == binding.ctrl_pressed and event.alt_pressed == binding.alt_pressed and event.shift_pressed == binding.shift_pressed and event.meta_pressed == binding.meta_pressed)
	if interact:
		return ADVANCE if event.is_pressed() and not event.is_echo() and not blocked else CONSUME
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		_touch_until = Time.get_ticks_msec() + 500
	elif event is InputEventMouse and event.device == InputEvent.DEVICE_ID_EMULATION and Time.get_ticks_msec() < _touch_until:
		return CONSUME
	if blocked:
		reset()
		return CONSUME if event is InputEventMouse or event is InputEventScreenTouch or event is InputEventScreenDrag else IGNORE
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		if _down and event.position.distance_to(_origin) > 8.0:
			_dragged = true
		return IGNORE
	if event is InputEventMouseButton and event.button_index != MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragged = true
		return IGNORE
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		var inside := false
		for rect in surfaces:
			inside = inside or rect.has_point(event.position)
		if event.pressed:
			_down = inside
			_origin = event.position
			_dragged = false
			return IGNORE if inside else CONSUME
		var advance := _down and inside and not _dragged
		reset()
		return ADVANCE if advance else IGNORE
	return IGNORE
