extends Control

signal restart_requested()
signal return_to_menu_requested()


func show_win() -> void:
	show()
	%RestartButton.grab_focus()


func _on_restart_pressed() -> void:
	restart_requested.emit()


func _on_return_to_menu_pressed() -> void:
	return_to_menu_requested.emit()
