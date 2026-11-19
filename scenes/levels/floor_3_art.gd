@tool
extends "res://scenes/levels/floor_2_art.gd"
## Layered art only. Rescue state is read from A's existing session truth.
func _process(delta: float) -> void:
	super._process(delta)
	if not Engine.is_editor_hint():
		$Doors/Room309.set_state("OPEN" if GameManager.has_friend else "CLOSED")
