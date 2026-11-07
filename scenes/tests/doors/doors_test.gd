extends Node2D


func _ready() -> void:
	# Start beside the doors so F6 immediately shows both reusable instances.
	$Corridor/Player.global_position = Vector2(1280, 560)
	$Corridor/DoorRoot.hide()
