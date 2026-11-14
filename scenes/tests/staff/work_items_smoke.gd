extends Node

var _failed := false
var _patrol_events: Array[Array] = []


func _ready() -> void:
	var test: Node = load("res://scenes/tests/staff/work_items_test.tscn").instantiate()
	add_child(test)
	await get_tree().process_frame
	await get_tree().physics_frame
	var player: HotelPlayer = test.get_node("Corridor/Player")
	var pickup: CleaningSpot = test.get_node("Pickup")
	var register_309: CleaningSpot = test.get_node("Authorize309")
	var exit_register: CleaningSpot = test.get_node("AuthorizeExit")
	var patrol: Node = test.get_node("PatrolStaff")

	_expect(CardManager.active_card == "SECURITY", "SECURITY test fixture should start active")
	player.global_position = pickup.global_position
	player.velocity = Vector2.ZERO
	player.is_moving = false
	pickup._on_work_area_body_entered(player)
	await get_tree().physics_frame
	_expect(pickup.begin_interaction(), "SECURITY could not PICKUP PARCEL_CABINET_2F")
	_expect(pickup.is_completed(), "PICKUP should complete on one E press")
	_expect(not pickup.begin_interaction(), "completed PICKUP repeated")

	player.global_position = register_309.global_position
	player.velocity = Vector2.ZERO
	player.is_moving = false
	register_309._on_work_area_body_entered(player)
	await get_tree().physics_frame
	_expect(not register_309.begin_interaction(), "SECURITY incorrectly satisfied MANAGER authorization")
	CardManager.switch_active()
	_expect(CardManager.active_card == "MANAGER", "MANAGER slot did not become active")
	_expect(register_309.begin_interaction(), "MANAGER could not AUTHORIZE REGISTER_309")
	player.global_position = exit_register.global_position
	player.velocity = Vector2.ZERO
	player.is_moving = false
	exit_register._on_work_area_body_entered(player)
	await get_tree().physics_frame
	_expect(exit_register.begin_interaction(), "MANAGER could not AUTHORIZE EXIT_REGISTER_5F")
	exit_register.set_completed(false)
	_expect(exit_register.begin_interaction(), "restored AUTHORIZE point did not become available")

	var progress_point: CleaningSpot = load("res://scenes/work/work_point.tscn").instantiate()
	test.add_child(progress_point)
	progress_point.position = Vector2(760, 560)
	progress_point.interaction_type = "CLEAN"
	progress_point.required_card = "MANAGER"
	progress_point.hold_duration = 1.5
	progress_point.setup(player)
	progress_point.set_task_active(true)
	player.global_position = progress_point.global_position
	player.velocity = Vector2.ZERO
	player.is_moving = false
	progress_point._on_work_area_body_entered(player)
	await get_tree().physics_frame
	_expect(progress_point.begin_interaction(), "long-hold progress fixture did not start")
	progress_point.advance_interaction(0.75)
	_expect(is_equal_approx(progress_point.get_interaction_progress(), 0.5), "work progress is not a read-only 0..1 ratio")
	GameManager.set_modal_open("WORK_ITEMS_SMOKE", true)
	progress_point.advance_interaction(0.01)
	_expect(not progress_point.is_interacting() and progress_point.get_interaction_progress() == 0.0, "modal did not cancel work progress")
	GameManager.set_modal_open("WORK_ITEMS_SMOKE", false)

	patrol.task_item_stolen.connect(_on_task_item_stolen)
	patrol.set_process(false)
	patrol.get_node("TurnTimer").stop()
	patrol.get_node("TurnWarningTimer").stop()
	player.global_position = patrol.global_position + Vector2(30.0 * patrol.facing_direction, 0.0)
	player.velocity = Vector2.ZERO
	player.is_moving = false
	patrol._on_steal_area_body_entered(player)
	await get_tree().physics_frame
	_expect(patrol.get_interaction_block_reason() == "FRONT", "front block reason is not readable")
	_expect(not patrol.begin_steal(), "front PATROL_RECORD steal should fail")
	_expect(GameManager.game_state == "FAILED", "front PATROL_RECORD steal did not report failure")
	test._on_recovery_timer_timeout()
	patrol.set_process(false)
	patrol.get_node("TurnTimer").stop()
	patrol.get_node("TurnWarningTimer").stop()
	player.global_position = patrol.global_position - Vector2(30.0 * patrol.facing_direction, 0.0)
	player.velocity = Vector2.ZERO
	player.is_moving = false
	patrol._on_steal_area_body_entered(player)
	await get_tree().physics_frame
	_expect(patrol.get_interaction_block_reason() == "READY", "rear-ready state is not readable")
	_expect(patrol.begin_steal(), "rear PATROL_RECORD steal did not start")
	_expect(patrol.get_interaction_block_reason() == "STEALING", "active steal state is not readable")
	patrol._process(0.4)
	_expect(is_equal_approx(patrol.get_interaction_progress(), 0.5), "staff progress is not a read-only 0..1 ratio")
	patrol.cancel_steal()
	_expect(patrol.get_interaction_progress() == 0.0, "cancelled staff progress did not reset")
	_expect(patrol.begin_steal(), "PATROL_RECORD steal did not restart")
	patrol._process(0.8)
	_expect(_patrol_events == [["PATROL_RECORD", "STAFF_PATROL_4F"]], "PATROL_RECORD event payload or count is wrong")
	_expect(not patrol.is_reward_available() and not CardManager.VALID_CARDS.has("PATROL_RECORD"), "task item leaked into card ownership")
	_expect(patrol.get_interaction_block_reason() == "INELIGIBLE", "collected task item block reason is not readable")
	_expect(not patrol.begin_steal(), "PATROL_RECORD repeated before restore")
	patrol.set_reward_available(true)
	_expect(patrol.is_reward_available(), "A restore hook did not make PATROL_RECORD available")

	if _failed:
		get_tree().quit(1)
		return
	print("PASS: PICKUP/AUTHORIZE identity gates, one-shot restore, PATROL_RECORD steal/failure, and read-only progress.")
	get_tree().quit(0)


func _on_task_item_stolen(item_id: String, target_id: String) -> void:
	_patrol_events.append([item_id, target_id])


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
