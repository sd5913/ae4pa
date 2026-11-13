extends Node2D

@onready var player: HotelPlayer = $Corridor/Player
@onready var cleaner: Node = $Cleaner
@onready var cleaning_spot: CleaningSpot = $CleaningSpot
@onready var status: Label = $Status/Label
@onready var failure_recovery_timer: Timer = $FailureRecoveryTimer
@onready var failure_label: Label = $FailureFeedback/Label

var _player_start_position: Vector2
var _failure_recovery_pending: bool = false


func _ready() -> void:
	_player_start_position = player.global_position
	GameManager.start_game()
	cleaner.setup(player)
	cleaner.task_failure_requested.connect(_on_task_failure_requested)
	cleaner.set_task_eligible(true)
	cleaning_spot.setup(player)
	cleaning_spot.set_task_active(true)
	cleaning_spot.cleaning_completed.connect(_on_cleaning_completed)
	CardManager.cards_changed.connect(_update_status)
	_update_status()


func _process(delta: float) -> void:
	cleaning_spot.advance_interaction(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not event.is_echo():
		if cleaning_spot.begin_interaction():
			get_viewport().set_input_as_handled()
	elif event.is_action_released("interact") and cleaning_spot.is_interacting():
		cleaning_spot.cancel_interaction()
		get_viewport().set_input_as_handled()


func _on_cleaning_completed(target_id: String) -> void:
	status.text = "B SIGNAL: cleaning_completed(%s) · waiting for A task delivery" % target_id


func _on_task_failure_requested(reason: String, _target_id: String) -> void:
	# F6 compatibility adapter only; formal V4 wiring belongs to A's request_task_failure.
	if _failure_recovery_pending:
		return
	cleaner.show_caught_alert()
	GameManager.fail(reason)
	cleaner.set_interaction_enabled(false)
	_failure_recovery_pending = true
	failure_label.text = "CAUGHT!"
	failure_label.visible = true
	status.text = "FAILED: %s · Cleaner is alert · retry in %.1fs..." % [reason, failure_recovery_timer.wait_time]
	failure_recovery_timer.start()


func _on_failure_recovery_timer_timeout() -> void:
	GameManager.start_game()
	player.global_position = _player_start_position
	player.velocity = Vector2.ZERO
	player.set_movement_locked(false)
	cleaner.cancel_steal()
	cleaner.reset_caught_alert()
	cleaner.set_task_eligible(true)
	cleaner.set_interaction_enabled(true)
	failure_label.visible = false
	_failure_recovery_pending = false
	_update_status()


func is_failure_recovery_pending() -> bool:
	return _failure_recovery_pending


func _update_status() -> void:
	status.text = "Observe Cleaner: CLEANING ↔ TOOLS · ? means curious · red ! means CAUGHT\nA/D move · steal from behind while stopped · Q until CLEANER active · hold E 1.5s at stain\nOwned %s | Slots %s | Active %s" % [CardManager.get_owned_cards(), CardManager.get_equipped_cards(), CardManager.active_card]
