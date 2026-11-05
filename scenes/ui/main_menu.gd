extends Control

signal start_requested()
signal help_requested()


func _ready() -> void:
	%StartButton.grab_focus()


func _on_start_pressed() -> void:
	start_requested.emit()


func _on_help_pressed() -> void:
	help_requested.emit()
