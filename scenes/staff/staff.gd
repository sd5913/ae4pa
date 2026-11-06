extends Node2D

signal card_stolen(card_id: String)
signal steal_attempted(card_id: String, succeeded: bool)

@export_enum("SECURITY", "CLEANER", "MANAGER") var card_id: String = "SECURITY"
@export var steal_radius: float = 55.0

var _player: HotelPlayer
var _player_in_range: bool = false

@onready var steal_area: Area2D = $StealArea
@onready var steal_shape: CollisionShape2D = $StealArea/CollisionShape2D


func _ready() -> void:
	var rectangle: RectangleShape2D = steal_shape.shape.duplicate() as RectangleShape2D
	rectangle.size.x = steal_radius * 2.0
	steal_shape.shape = rectangle


func setup(player: HotelPlayer) -> void:
	_player = player
	_player_in_range = steal_area.get_overlapping_bodies().has(player)


func try_steal() -> bool:
	if _player == null or not _player_in_range or GameManager.game_state != "PLAYING":
		steal_attempted.emit(card_id, false)
		return false
	var succeeded: bool = CardManager.collect_card(card_id)
	steal_attempted.emit(card_id, succeeded)
	if succeeded:
		card_stolen.emit(card_id)
	return succeeded


func is_player_in_range() -> bool:
	return _player_in_range


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not event.is_echo() and _player_in_range:
		try_steal()
		get_viewport().set_input_as_handled()


func _on_steal_area_body_entered(body: Node2D) -> void:
	if body == _player:
		_player_in_range = true


func _on_steal_area_body_exited(body: Node2D) -> void:
	if body == _player:
		_player_in_range = false
