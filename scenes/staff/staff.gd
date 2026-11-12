extends Node2D

signal card_stolen(card_id: String)
signal steal_attempted(card_id: String, succeeded: bool)
signal task_failure_requested(reason: String, target_id: String)

@export_enum("SECURITY", "CLEANER", "MANAGER") var card_id: String = "SECURITY"
@export var target_id: String = ""
@export_enum("CARD") var reward_type: String = "CARD"
@export var requires_task_eligibility: bool = false
@export var steal_radius: float = 55.0
@export var steal_hold_time: float = 0.8
@export var turn_warning_time: float = 0.4

var _player: HotelPlayer
var _player_in_range: bool = false
var _is_stealing: bool = false
var _steal_elapsed: float = 0.0
var _task_eligible: bool = false
var facing_direction: int = 1

@onready var steal_area: Area2D = $StealArea
@onready var steal_shape: CollisionShape2D = $StealArea/CollisionShape2D
@onready var eye: Polygon2D = $Eye
@onready var turn_timer: Timer = $TurnTimer
@onready var turn_warning_timer: Timer = $TurnWarningTimer
@onready var turn_warning: Label = $TurnWarning
@onready var card_marker: Label = $CardMarker
@onready var feedback_label: Label = $FeedbackLabel
@onready var feedback_timer: Timer = $FeedbackTimer


func _ready() -> void:
	var rectangle: RectangleShape2D = steal_shape.shape.duplicate() as RectangleShape2D
	rectangle.size.x = steal_radius * 2.0
	steal_shape.shape = rectangle
	_update_facing_visual()
	turn_warning_timer.wait_time = maxf(turn_timer.wait_time - turn_warning_time, 0.01)
	turn_warning_timer.start()
	CardManager.cards_changed.connect(_update_card_marker)
	_update_card_marker()


func setup(player: HotelPlayer) -> void:
	_player = player
	_player_in_range = steal_area.get_overlapping_bodies().has(player)


func set_task_eligible(eligible: bool) -> void:
	_task_eligible = eligible
	if not is_task_eligible():
		cancel_steal()
	_update_card_marker()


func is_task_eligible() -> bool:
	return not requires_task_eligibility or _task_eligible


func try_steal() -> bool:
	return begin_steal()


func begin_steal() -> bool:
	if (
		_player == null
		or not _player_in_range
		or GameManager.game_state != "PLAYING"
	):
		steal_attempted.emit(card_id, false)
		return false
	if not is_task_eligible() or not _is_reward_available():
		steal_attempted.emit(card_id, false)
		return false
	if not is_player_behind():
		steal_attempted.emit(card_id, false)
		_request_task_failure("STAFF_CAUGHT")
		return false
	if _player.is_moving:
		steal_attempted.emit(card_id, false)
		return false
	_is_stealing = true
	_steal_elapsed = 0.0
	return true


func cancel_steal() -> void:
	if not _is_stealing:
		return
	_is_stealing = false
	_steal_elapsed = 0.0
	steal_attempted.emit(card_id, false)


func is_stealing() -> bool:
	return _is_stealing


func _complete_steal() -> bool:
	_is_stealing = false
	_steal_elapsed = 0.0
	var succeeded: bool = reward_type == "CARD" and CardManager.collect_card(card_id)
	steal_attempted.emit(card_id, succeeded)
	if succeeded:
		feedback_label.text = "GOT %s ID" % card_id
		feedback_label.visible = true
		feedback_timer.start()
		_update_card_marker()
		card_stolen.emit(card_id)
	return succeeded


func is_player_in_range() -> bool:
	return _player_in_range


func is_player_behind() -> bool:
	if _player == null:
		return false
	var player_side: float = _player.global_position.x - global_position.x
	return player_side * facing_direction < 0.0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not event.is_echo() and _player_in_range:
		begin_steal()
		get_viewport().set_input_as_handled()
	elif event.is_action_released("interact") and _is_stealing:
		cancel_steal()
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if not _is_stealing:
		return
	if GameManager.game_state != "PLAYING" or not _player_in_range or _player == null:
		cancel_steal()
		return
	if _player.is_moving:
		cancel_steal()
		return
	if not is_player_behind():
		cancel_steal()
		_request_task_failure("STAFF_CAUGHT")
		return
	_steal_elapsed += delta
	if _steal_elapsed >= steal_hold_time:
		_complete_steal()


func _on_steal_area_body_entered(body: Node2D) -> void:
	if body == _player:
		_player_in_range = true


func _on_steal_area_body_exited(body: Node2D) -> void:
	if body == _player:
		_player_in_range = false
		cancel_steal()


func _on_turn_timer_timeout() -> void:
	facing_direction *= -1
	_update_facing_visual()
	turn_warning.visible = false
	turn_warning_timer.start()
	if _is_stealing and not is_player_behind():
		cancel_steal()
		_request_task_failure("STAFF_CAUGHT")


func _update_facing_visual() -> void:
	eye.position.x = 10.0 * facing_direction


func _on_turn_warning_timer_timeout() -> void:
	turn_warning.visible = true


func _on_feedback_timer_timeout() -> void:
	feedback_label.visible = false


func _update_card_marker() -> void:
	card_marker.visible = is_task_eligible() and _is_reward_available()


func _is_reward_available() -> bool:
	return reward_type == "CARD" and not CardManager.has_card(card_id)


func _request_task_failure(reason: String) -> void:
	task_failure_requested.emit(reason, target_id)
