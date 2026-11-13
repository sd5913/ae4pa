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
@export var turn_interval_min: float = 0.0
@export var turn_interval_max: float = 0.0
@export var cleaner_behavior_enabled: bool = true
@export var cleaner_walk_distance: float = 36.0
@export var cleaner_walk_speed: float = 28.0

var _player: HotelPlayer
var _player_in_range: bool = false
var _is_stealing: bool = false
var _steal_elapsed: float = 0.0
var _task_eligible: bool = false
var _interaction_enabled: bool = true
var _is_alerted: bool = false
var _is_suspicious: bool = false
var _suspicion_previous_state: String = "IDLE"
var _turn_rng := RandomNumberGenerator.new()
var _cleaner_state: String = "IDLE"
var _cleaner_home_position: Vector2
var _cleaner_target_position: Vector2
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
@onready var behavior_label: Label = $BehaviorLabel
@onready var behavior_timer: Timer = $BehaviorTimer
@onready var suspicion_timer: Timer = $SuspicionTimer


func _ready() -> void:
	var rectangle: RectangleShape2D = steal_shape.shape.duplicate() as RectangleShape2D
	rectangle.size.x = steal_radius * 2.0
	steal_shape.shape = rectangle
	_update_facing_visual()
	_turn_rng.randomize()
	_schedule_next_turn()
	_cleaner_home_position = position
	if _uses_cleaner_behavior():
		_set_cleaner_state("CLEANING")
		behavior_timer.start(_turn_rng.randf_range(2.2, 3.2))
	CardManager.cards_changed.connect(_on_cards_changed)
	CardManager.identity_changed.connect(_on_identity_changed)
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


func set_interaction_enabled(enabled: bool) -> void:
	_interaction_enabled = enabled
	if not enabled:
		cancel_steal()


func is_alerted() -> bool:
	return _is_alerted


func is_suspicious() -> bool:
	return _is_suspicious


func show_caught_alert() -> void:
	_end_suspicion(false)
	_is_alerted = true
	cancel_steal()
	turn_timer.stop()
	turn_warning_timer.stop()
	behavior_timer.stop()
	if _player != null:
		facing_direction = 1 if _player.global_position.x >= global_position.x else -1
		_update_facing_visual()
	turn_warning.text = "!"
	turn_warning.add_theme_color_override("font_color", Color(1.0, 0.15, 0.12, 1.0))
	turn_warning.visible = true
	behavior_label.visible = true
	behavior_label.text = "CAUGHT"
	behavior_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.2, 1.0))


func reset_caught_alert() -> void:
	_is_alerted = false
	turn_warning.visible = false
	turn_warning.text = "!"
	turn_warning.add_theme_color_override("font_color", Color(1.0, 0.15, 0.12, 1.0))
	behavior_label.add_theme_color_override("font_color", Color(0.55, 0.9, 0.65, 1.0))
	if _uses_cleaner_behavior():
		set_cleaner_behavior_enabled(true)
	else:
		behavior_label.visible = false
		_schedule_next_turn()


func set_cleaner_behavior_enabled(enabled: bool) -> void:
	cleaner_behavior_enabled = enabled
	behavior_timer.stop()
	if enabled and card_id == "CLEANER":
		position = _cleaner_home_position
		turn_timer.stop()
		turn_warning_timer.stop()
		turn_warning.visible = false
		_set_cleaner_state("CLEANING")
		behavior_timer.start(_turn_rng.randf_range(2.2, 3.2))
		_schedule_next_turn()
	else:
		position = _cleaner_home_position
		_set_cleaner_state("IDLE")


func get_cleaner_behavior_state() -> String:
	return _cleaner_state


func try_steal() -> bool:
	return begin_steal()


func begin_steal() -> bool:
	if (
		_player == null
		or not _player_in_range
		or not _interaction_enabled
		or _is_alerted
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
	if _player.is_moving or _is_cleaner_walking():
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
		_end_suspicion(true)
		turn_warning.visible = false
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
	_update_cleaner_behavior(delta)
	if not _is_stealing:
		return
	if not _interaction_enabled or GameManager.game_state != "PLAYING" or not _player_in_range or _player == null:
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
		_consider_suspicion()


func _on_steal_area_body_exited(body: Node2D) -> void:
	if body == _player:
		_player_in_range = false
		cancel_steal()


func _on_turn_timer_timeout() -> void:
	if _is_alerted or _is_suspicious:
		return
	facing_direction *= -1
	_update_facing_visual()
	if _is_stealing and not is_player_behind():
		cancel_steal()
		_request_task_failure("STAFF_CAUGHT")
	_schedule_next_turn()


func _update_facing_visual() -> void:
	eye.position.x = 10.0 * facing_direction


func _on_turn_warning_timer_timeout() -> void:
	if _is_alerted or _is_suspicious:
		return
	turn_warning.visible = false
	eye.position.x = 4.0 * facing_direction


func _on_feedback_timer_timeout() -> void:
	feedback_label.visible = false


func _on_cards_changed() -> void:
	_update_card_marker()
	if _is_player_recognized():
		_end_suspicion(true)


func _on_identity_changed(_action: String) -> void:
	if _is_player_recognized():
		_end_suspicion(true)
	elif _player_in_range:
		_consider_suspicion()


func _update_card_marker() -> void:
	card_marker.visible = is_task_eligible() and _is_reward_available()
	if not _is_alerted:
		turn_warning.visible = false


func _is_reward_available() -> bool:
	return reward_type == "CARD" and not CardManager.has_card(card_id)


func _request_task_failure(reason: String) -> void:
	show_caught_alert()
	task_failure_requested.emit(reason, target_id)


func get_current_turn_interval() -> float:
	return turn_timer.wait_time


func get_turn_interval_range() -> Vector2:
	if turn_interval_min > 0.0 and turn_interval_max >= turn_interval_min:
		return Vector2(turn_interval_min, turn_interval_max)
	match card_id:
		"MANAGER":
			return Vector2(5.2, 6.8)
		"CLEANER":
			return Vector2(3.4, 4.8)
		_:
			return Vector2(2.2, 3.2)


func _schedule_next_turn() -> void:
	if _is_alerted or _is_suspicious:
		return
	var interval_range: Vector2 = get_turn_interval_range()
	var next_interval: float = _turn_rng.randf_range(interval_range.x, interval_range.y)
	turn_warning.visible = false
	turn_timer.start(next_interval)
	turn_warning_timer.start(maxf(next_interval - turn_warning_time, 0.01))


func _uses_cleaner_behavior() -> bool:
	return cleaner_behavior_enabled and card_id == "CLEANER"


func _is_cleaner_walking() -> bool:
	return _cleaner_state == "WALK_TO_CART" or _cleaner_state == "WALK_TO_CLEAN"


func _set_cleaner_state(next_state: String) -> void:
	_cleaner_state = next_state
	behavior_label.visible = _uses_cleaner_behavior()
	match next_state:
		"CLEANING":
			behavior_label.text = "CLEANING"
		"ORGANIZING":
			behavior_label.text = "TOOLS"
		"TURN_TO_CART", "TURN_TO_CLEAN":
			behavior_label.text = "PAUSE"
		"WALK_TO_CART", "WALK_TO_CLEAN":
			behavior_label.text = "WALKING"
		_:
			behavior_label.text = ""


func _prepare_cleaner_walk(to_cart: bool) -> void:
	cancel_steal()
	turn_timer.stop()
	turn_warning_timer.stop()
	turn_warning.visible = false
	eye.position.x = 4.0 * facing_direction
	_set_cleaner_state("TURN_TO_CART" if to_cart else "TURN_TO_CLEAN")
	behavior_timer.start(turn_warning_time)


func _start_cleaner_walk(to_cart: bool) -> void:
	turn_warning.visible = false
	facing_direction = 1 if to_cart else -1
	_update_facing_visual()
	_cleaner_target_position = _cleaner_home_position + Vector2(cleaner_walk_distance if to_cart else 0.0, 0.0)
	_set_cleaner_state("WALK_TO_CART" if to_cart else "WALK_TO_CLEAN")


func _update_cleaner_behavior(delta: float) -> void:
	if _is_alerted or _is_suspicious or not _uses_cleaner_behavior() or not _is_cleaner_walking():
		return
	position = position.move_toward(_cleaner_target_position, cleaner_walk_speed * delta)
	if not position.is_equal_approx(_cleaner_target_position):
		return
	if _cleaner_state == "WALK_TO_CART":
		_set_cleaner_state("ORGANIZING")
		behavior_timer.start(_turn_rng.randf_range(1.5, 2.4))
	else:
		_set_cleaner_state("CLEANING")
		behavior_timer.start(_turn_rng.randf_range(2.2, 3.2))
	_schedule_next_turn()


func _on_behavior_timer_timeout() -> void:
	if _is_alerted or _is_suspicious or not _uses_cleaner_behavior():
		return
	match _cleaner_state:
		"CLEANING":
			_prepare_cleaner_walk(true)
		"ORGANIZING":
			_prepare_cleaner_walk(false)
		"TURN_TO_CART":
			_start_cleaner_walk(true)
		"TURN_TO_CLEAN":
			_start_cleaner_walk(false)


func _is_player_recognized() -> bool:
	return CardManager.active_card == card_id


func _consider_suspicion() -> void:
	if (
		card_id != "CLEANER"
		or _player == null
		or not _player_in_range
		or _is_alerted
		or _is_suspicious
		or _is_player_recognized()
		or GameManager.game_state != "PLAYING"
	):
		return
	_is_suspicious = true
	_suspicion_previous_state = _cleaner_state
	turn_timer.stop()
	turn_warning_timer.stop()
	behavior_timer.stop()
	facing_direction = 1 if _player.global_position.x >= global_position.x else -1
	_update_facing_visual()
	turn_warning.text = "?"
	turn_warning.add_theme_color_override("font_color", Color(0.72, 0.82, 0.9, 0.9))
	turn_warning.visible = true
	behavior_label.visible = true
	behavior_label.text = "CURIOUS"
	behavior_label.add_theme_color_override("font_color", Color(0.72, 0.82, 0.9, 1.0))
	suspicion_timer.start()


func _end_suspicion(resume_behavior: bool) -> void:
	if not _is_suspicious:
		return
	_is_suspicious = false
	suspicion_timer.stop()
	turn_warning.visible = false
	turn_warning.text = "!"
	turn_warning.add_theme_color_override("font_color", Color(1.0, 0.15, 0.12, 1.0))
	behavior_label.add_theme_color_override("font_color", Color(0.55, 0.9, 0.65, 1.0))
	if not resume_behavior:
		return
	if _uses_cleaner_behavior():
		match _suspicion_previous_state:
			"WALK_TO_CART", "WALK_TO_CLEAN":
				_set_cleaner_state(_suspicion_previous_state)
			"ORGANIZING":
				_set_cleaner_state("ORGANIZING")
				behavior_timer.start(_turn_rng.randf_range(1.0, 1.8))
			_:
				_set_cleaner_state("CLEANING")
				behavior_timer.start(_turn_rng.randf_range(1.5, 2.4))
	_schedule_next_turn()


func _on_suspicion_timer_timeout() -> void:
	_end_suspicion(true)
