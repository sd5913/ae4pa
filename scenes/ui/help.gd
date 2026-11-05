extends Control

var _previous_focus: Control


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("open_help"):
		return
	if visible:
		close_help()
	else:
		open_help()
	get_viewport().set_input_as_handled()


func open_help() -> void:
	if visible:
		return
	_previous_focus = get_viewport().gui_get_focus_owner()
	show()
	%CloseButton.grab_focus()


func close_help() -> void:
	hide()
	if is_instance_valid(_previous_focus) and _previous_focus.is_visible_in_tree():
		_previous_focus.grab_focus()
	_previous_focus = null
