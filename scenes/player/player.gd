class_name HotelPlayer
extends CharacterBody2D

@export var walk_speed: float = 160.0

var is_moving: bool = false
var facing_direction: int = 1
var _left_bound: float = 64.0
var _right_bound: float = 2736.0
var _movement_locked: bool = false

@onready var visual: Node2D = $Visual


func _physics_process(delta: float) -> void:
	var direction: float = 0.0
	if not _movement_locked and GameManager.game_state == "PLAYING":
		direction = Input.get_axis("move_left", "move_right")

	var previous_x: float = global_position.x
	global_position.x = clampf(previous_x + direction * walk_speed * delta, _left_bound, _right_bound)
	is_moving = not is_equal_approx(global_position.x, previous_x)
	if not is_zero_approx(direction):
		facing_direction = 1 if direction > 0.0 else -1
		visual.scale.x = float(facing_direction)


func set_walk_bounds(left_x: float, right_x: float) -> void:
	assert(left_x <= right_x, "Player walk bounds must be ordered left to right.")
	_left_bound = left_x
	_right_bound = right_x
	global_position.x = clampf(global_position.x, _left_bound, _right_bound)


func set_movement_locked(locked: bool) -> void:
	_movement_locked = locked
	if locked:
		is_moving = false
