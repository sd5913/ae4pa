@tool
extends Node2D
## One full-canvas sprite and one transform for every state of each room.

@export var room_id: String = "201":
	set(value):
		room_id = value
		if is_node_ready():
			_refresh()
@export_enum("CLOSED", "WARNING", "OPEN") var state: String = "CLOSED":
	set(value):
		if value not in ["CLOSED", "WARNING", "OPEN"]:
			return
		state = value
		if has_node("MonsterIdle"):
			$MonsterIdle.visible = value == "OPEN"
		if is_node_ready():
			_refresh()


func _ready() -> void:
	_refresh()


func set_state(value: String) -> void:
	if state != value:
		state = value
		if has_node("MonsterIdle"):
			$MonsterIdle.visible = value == "OPEN"


func _refresh() -> void:
	$Sprite2D.texture = load("res://assets/final/doors/room_%s/door_%s.png" % [room_id, state.to_lower()])


func set_monster(value: String) -> void:
	# Preserve the approved OPEN image, including door leaf, plaque and warm interior.
	# The animated guest is a separate foreground sprite, with no doorway cover.
	if not has_node("MonsterIdle"):
		var idle := preload("res://scenes/doors/monster_idle_visual.gd").new()
		idle.name = "MonsterIdle"
		idle.position.y = -65
		add_child(idle)
	$MonsterIdle.configure(value,1.35)
	$MonsterIdle.visible = state == "OPEN"
