class_name HotelPlayer
extends CharacterBody2D

@export var walk_speed: float = 160.0

signal stamina_changed(value: float, exhausted: bool)
const RunState = preload("res://scenes/player/run_stamina.gd")
static var stamina := RunState.new()
static var _checkpoint_stamina: Dictionary = {}
static var _last_status := "NONE"
static var _last_state := "MENU"

var is_moving: bool = false
var facing_direction: int = 1
var _left_bound: float = 64.0
var _right_bound: float = 2736.0
var _movement_locked: bool = false

@onready var visual: Node2D = $Visual
@onready var _artwork = $Visual/Artwork


func _ready() -> void:
	_state_changed(GameManager.game_state)
	GameManager.state_changed.connect(_state_changed)
	GameManager.modal_changed.connect(_modal_changed)
	GameManager.task_updated.connect(_task_changed)

	var outfit := preload("res://scenes/player/player_identity_outfit.gd").new()
	outfit.name = "IdentityOutfit"
	_artwork.add_child(outfit)


func _physics_process(delta: float) -> void:
	var direction: float = 0.0
	if not _movement_locked and GameManager.is_world_input_allowed():
		direction = Input.get_axis("move_left", "move_right")

	if Input.is_action_pressed("interact"): stamina.running = false
	var previous_x: float = global_position.x
	global_position.x = clampf(previous_x + direction * walk_speed * (RunState.MULTIPLIER if stamina.running else 1.0) * delta, _left_bound, _right_bound)
	is_moving = not is_equal_approx(global_position.x, previous_x)
	if GameManager.is_world_input_allowed() and not _movement_locked:
		stamina.tick(delta, is_moving)
	stamina_changed.emit(stamina.value, stamina.exhausted)
	_artwork.set_walking(is_moving)
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
		stamina.running = false
		is_moving = false
		_artwork.set_walking(false)

func _input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo(): return
	var matched := event.is_action("toggle_run")
	if event is InputEventKey:
		for binding in InputMap.action_get_events("toggle_run"):
			if binding is InputEventKey and event.physical_keycode == binding.physical_keycode and (binding.location == 0 or event.location == binding.location): matched = true
	if matched and GameManager.is_world_input_allowed() and not _movement_locked and not Input.is_action_pressed("interact"):
		stamina.toggle()
		get_viewport().set_input_as_handled()

func _modal_changed() -> void:
	if not GameManager.is_world_input_allowed(): stamina.running = false

func _state_changed(state: String) -> void:
	stamina.running = false
	if state == "LOADING" and _last_state in ["MENU","WON"]:
		stamina.restore({})
		_checkpoint_stamina.clear()
		_last_status = "NONE"
	if state == "RESTORING" and not _checkpoint_stamina.is_empty(): stamina.restore(_checkpoint_stamina)
	_last_state = state

func _task_changed() -> void:
	var status: String = GameManager.get_task_view().status
	if status == "ACTIVE" and _last_status == "AVAILABLE": _checkpoint_stamina = stamina.capture()
	_last_status = status

func capture_stamina_state() -> Dictionary:
	return stamina.capture()

func restore_stamina_state(data: Dictionary) -> void:
	stamina.restore(data)
	stamina_changed.emit(stamina.value,stamina.exhausted)
