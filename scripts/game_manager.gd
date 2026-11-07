extends Node
## A owns session state and optional floor loading; standalone component tests need no host.

signal state_changed(new_state: String)
signal game_failed(reason: String)
signal floor_changed(floor_number: int)

var game_state: String = "MENU"
var current_floor: int = 1
var has_friend: bool = false
var fail_reason: String = ""
var _floor_host: Node2D
var _preview_enabled: bool = false


func set_floor_host(host: Node2D, enable_preview: bool = false) -> void:
	_floor_host = host
	_preview_enabled = enable_preview and OS.has_feature("editor")


func start_game() -> void:
	CardManager.reset_for_new_game()
	current_floor = 1
	has_friend = false
	fail_reason = ""
	if _has_floor_host():
		_load_floor(1)
	else:
		_set_state("PLAYING")


func go_to_floor(floor_number: int) -> void:
	if game_state != "PLAYING" or not _has_floor_host():
		return
	if floor_number != current_floor + 1 or floor_number > 5:
		return
	if current_floor == 1 and not CardManager.has_all_cards():
		return
	if current_floor == 3 and not has_friend:
		return
	_load_floor(floor_number)


func preview_floor(floor_number: int) -> void:
	# Development-only navigation: never grants cards or changes rescue progress.
	if not _preview_enabled or game_state != "PLAYING" or not _has_floor_host():
		return
	if floor_number < 1 or floor_number > 5 or floor_number == current_floor:
		return
	_load_floor(floor_number)


func _has_floor_host() -> bool:
	return is_instance_valid(_floor_host) and _floor_host.is_inside_tree()


func _load_floor(floor_number: int) -> void:
	var scene: PackedScene = load("res://scenes/levels/floor_%d.tscn" % floor_number)
	if scene == null:
		return
	var floor_node: Node = scene.instantiate()
	_set_state("LOADING")
	for previous: Node in _floor_host.get_children():
		_floor_host.remove_child(previous)
		previous.queue_free()
	current_floor = floor_number
	_floor_host.add_child(floor_node)
	_set_state("PLAYING")
	floor_changed.emit(current_floor)


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
