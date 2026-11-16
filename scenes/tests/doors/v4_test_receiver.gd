extends Node2D
## TEST DOUBLE ONLY. Not A's GameManager/task/checkpoint/safe-return implementation.

var events: Array[Dictionary] = []
var task_state: String = "NONE"
var permission_open: bool = false
var auto_return: bool = true
var recovering: bool = false
var _return_frame: int = -1

@onready var player: HotelPlayer = $Corridor/Player
@onready var story: Node2D = $Door201
@onready var normal: Node2D = $NormalDoor


func _ready() -> void:
	process_physics_priority = 2
	$Corridor/DoorRoot.hide()
	story.setup(player)
	normal.setup(player)
	story.story_intercept_requested.connect(_on_story)
	story.story_progress_requested.connect(_on_progress)
	story.task_submit_requested.connect(_on_submit)
	normal.rule_violated.connect(_on_violation)
	story.set_story_state(task_state)


func _on_story(id: String, room: String) -> void:
	events.append({"event": "story", "task": id, "room": room})
	set_test_state("AVAILABLE")


func _on_progress(id: String) -> void:
	events.append({"event": "progress", "task": id})


func _on_submit(id: String) -> void:
	events.append({"event": "submit", "task": id})
	if task_state == "READY_TO_SUBMIT":
		set_test_state("COMPLETED")


func set_test_state(state: String) -> void:
	task_state = state
	permission_open = state == "COMPLETED"
	story.set_story_state(state)


func _on_violation(reason: String, side: int) -> void:
	events.append({"event": "violation", "room": normal.room_id, "reason": reason, "side": side})
	if auto_return:
		execute_test_return(side)


func safe_point_valid(point: Vector2, side: int) -> bool:
	if side not in [-1, 1] or (point.x - normal.global_position.x) * side <= normal.radius:
		return false
	# A must also validate its real topology, interactions, colliders and spawn bounds.
	for door: Node2D in [normal, $NeighborDoor]:
		if absf(point.x - door.global_position.x) <= door.radius:
			return false
	if absf(point.x - story.global_position.x) <= story.story_radius:
		return false
	if point.x >= $Barrier.position.x - 20.0 or point.x < 64.0:
		return false # Same connected region before the locked barrier.
	return true


func execute_test_return(side: int) -> bool:
	if recovering or _return_frame == Engine.get_physics_frames():
		return false
	var point: Vector2 = $SafeLeft.global_position if side == -1 else $SafeRight.global_position
	if not safe_point_valid(point, side):
		return false
	_return_frame = Engine.get_physics_frames()
	recovering = true
	player.set_movement_locked(true)
	player.global_position = point # TEST RECEIVER moves; monster_door never does.
	var finished: bool = normal.finish_safe_return()
	player.set_movement_locked(false)
	recovering = false
	return finished


func _physics_process(_delta: float) -> void:
	# TEST DOUBLE for A's independent downstream permit, never tied to door phase.
	if not permission_open and player.global_position.x > $Barrier.position.x - 20.0:
		player.global_position.x = $Barrier.position.x - 20.0


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_T and task_state == "AVAILABLE":
		set_test_state("ACTIVE")
	elif event.keycode == KEY_Y and task_state == "ACTIVE":
		set_test_state("READY_TO_SUBMIT")
	elif event.is_action_pressed("interact"):
		story.request_interaction() # Only this TEST router receives E.
	elif event.keycode == KEY_1:
		CardManager.collect_card("SECURITY")
		CardManager.equip_card("SECURITY", CardManager.active_slot)
	elif event.keycode == KEY_R:
		GameManager.start_game()
		player.global_position = Vector2(192, 560)
		set_test_state("NONE")
		story.reset_cycle()
		normal.reset_cycle()
		normal.finish_safe_return()
		events.clear()


func _process(_delta: float) -> void:
	$TestLabel/Status.text = "TEST任务=%s | 后段许可=%s | 最新事件=%s" % [task_state, permission_open, str(events.back()) if not events.is_empty() else "无"]
