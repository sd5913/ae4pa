extends Node
## A owns the session state. Floor loading and story flow are added at integration.

signal state_changed(new_state: String)
signal game_failed(reason: String)

var game_state: String = "MENU"
var current_floor: int = 1
var has_friend: bool = false
var fail_reason: String = ""


func start_game() -> void:
	CardManager.reset_for_new_game()
	current_floor = 1
	has_friend = false
	fail_reason = ""
	_set_state("PLAYING")


func fail(reason: String) -> void:
	if game_state != "PLAYING":
		return
	fail_reason = reason
	_set_state("FAILED")
	game_failed.emit(reason)


func _set_state(next_state: String) -> void:
	if game_state == next_state:
		return
	game_state = next_state
	state_changed.emit(game_state)
