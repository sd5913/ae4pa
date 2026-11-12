extends Node2D

@onready var player: HotelPlayer = $Corridor/Player
@onready var cleaner: Node = $Cleaner
@onready var cleaning_spot: CleaningSpot = $CleaningSpot
@onready var status: Label = $Status/Label


func _ready() -> void:
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
	GameManager.fail(reason)


func _update_status() -> void:
	status.text = "A/D move · steal CLEANER behind staff · Q until CLEANER active · hold E 1.5s at stain\nOwned %s | Slots %s | Active %s" % [CardManager.get_owned_cards(), CardManager.get_equipped_cards(), CardManager.active_card]
