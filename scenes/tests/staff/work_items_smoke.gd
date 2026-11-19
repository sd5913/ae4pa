extends Node

var _failed := false
var _patrol_events: Array[Array] = []
var _work_state_events: Array[Dictionary] = []
var _staff_state_events: Array[Dictionary] = []


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
	var stain_201: CleaningSpot = test.get_node("Stain201")
	_expect(pickup.target_id == "PARCEL_CABINET_2F" and pickup.interaction_type == "PICKUP" and pickup.required_card == "SECURITY" and pickup.hold_duration == 0.0, "PARCEL_CABINET_2F scene configuration is incomplete")
	_expect(register_309.target_id == "REGISTER_309" and register_309.interaction_type == "AUTHORIZE" and register_309.required_card == "MANAGER" and register_309.hold_duration == 0.0, "REGISTER_309 scene configuration is incomplete")
	_expect(exit_register.target_id == "EXIT_REGISTER_5F" and exit_register.interaction_type == "AUTHORIZE" and exit_register.required_card == "MANAGER" and exit_register.hold_duration == 0.0, "EXIT_REGISTER_5F scene configuration is incomplete")
	_expect(patrol.target_id == "STAFF_PATROL_4F" and patrol.reward_type == "TASK_ITEM" and patrol.reward_id == "PATROL_RECORD" and patrol.requires_task_eligibility, "STAFF_PATROL_4F scene configuration is incomplete")
	_expect(stain_201.target_id == "STAIN_201" and stain_201.interaction_type == "CLEAN" and stain_201.required_card == "CLEANER" and stain_201.hold_duration == 1.5, "STAIN_201 scene configuration is incomplete")

	_expect(CardManager.active_card == "SECURITY", "SECURITY test fixture should start active")
	player.global_position = pickup.global_position
	player.velocity = Vector2.ZERO
	player.is_moving = false
	pickup._on_work_area_body_entered(player)
	await get_tree().physics_frame
	_expect(pickup.get_node("PersistentVisual").visible and not pickup.get_node("ItemVisual").visible and pickup.get_node("Hint").visible, "available parcel uses one envelope baked into the cabinet, without a duplicate small envelope")
	_expect(pickup.begin_interaction(), "SECURITY could not PICKUP PARCEL_CABINET_2F")
	_expect(pickup.is_completed(), "PICKUP should complete on one E press")
	_expect(pickup.get_node("PersistentVisual").visible and not pickup.get_node("ItemVisual").visible and not pickup.get_node("Hint").visible, "completed parcel scene did not preserve furniture or hide item/hint")
	_expect(register_309.get_node("PersistentVisual").visible, "REGISTER_309 did not reuse the formal registration desk asset")
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
	progress_point.interaction_state_changed.connect(_on_work_state_changed)
	player.global_position = progress_point.global_position
	player.velocity = Vector2.ZERO
	player.is_moving = false
	progress_point._on_work_area_body_entered(player)
	await get_tree().physics_frame
	_expect(progress_point.begin_interaction(), "long-hold progress fixture did not start")
	progress_point.advance_interaction(0.75)
	_expect(is_equal_approx(progress_point.get_interaction_progress(), 0.5), "work progress is not a read-only 0..1 ratio")
	var work_state: Dictionary = progress_point.get_interaction_state()
	_expect(work_state.target_id == progress_point.target_id and work_state.interaction_type == "CLEAN", "work state identity fields are wrong")
	_expect(work_state.status == "ACTIVE" and is_equal_approx(work_state.progress, 0.5), "work active state or progress is wrong")
	_expect(is_equal_approx(work_state.elapsed, 0.75) and is_equal_approx(work_state.required_time, 1.5), "work elapsed/required time is wrong")
	GameManager.set_modal_open("WORK_ITEMS_SMOKE", true)
	progress_point.advance_interaction(0.01)
	_expect(not progress_point.is_interacting() and progress_point.get_interaction_progress() == 0.0, "modal did not cancel work progress")
	_expect(_work_state_events.any(func(state: Dictionary) -> bool: return state.status == "CANCELLED"), "work cancellation did not notify UI")
	GameManager.set_modal_open("WORK_ITEMS_SMOKE", false)
	_expect(progress_point.begin_interaction(), "work progress did not restart after cancellation")
	progress_point.advance_interaction(1.5)
	_expect(_work_state_events.any(func(state: Dictionary) -> bool: return state.status == "COMPLETED" and is_equal_approx(state.progress, 1.0)), "work completion did not notify UI")
	progress_point.set_completed(false)
	_expect(_work_state_events.any(func(state: Dictionary) -> bool: return state.status == "RESET"), "work reset did not notify UI")

	patrol.task_item_stolen.connect(_on_task_item_stolen)
	patrol.interaction_state_changed.connect(_on_staff_state_changed)
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
	_expect(_staff_state_events.any(func(state: Dictionary) -> bool: return state.status == "CAUGHT"), "staff caught state did not notify UI")
	test._on_recovery_timer_timeout()
	_expect(_staff_state_events.any(func(state: Dictionary) -> bool: return state.status == "RESET"), "staff reset did not notify UI")
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
	var staff_state: Dictionary = patrol.get_interaction_state()
	_expect(staff_state.target_id == "STAFF_PATROL_4F" and staff_state.interaction_type == "STEAL", "staff state identity fields are wrong")
	_expect(staff_state.status == "ACTIVE" and is_equal_approx(staff_state.progress, 0.5), "staff active state or progress is wrong")
	_expect(is_equal_approx(staff_state.elapsed, 0.4) and is_equal_approx(staff_state.required_time, 0.8), "staff elapsed/required time is wrong")
	patrol.cancel_steal()
	_expect(patrol.get_interaction_progress() == 0.0, "cancelled staff progress did not reset")
	_expect(_staff_state_events.any(func(state: Dictionary) -> bool: return state.status == "CANCELLED"), "staff cancellation did not notify UI")
	_expect(patrol.begin_steal(), "PATROL_RECORD steal did not restart")
	patrol._process(0.8)
	_expect(_patrol_events == [["PATROL_RECORD", "STAFF_PATROL_4F"]], "PATROL_RECORD event payload or count is wrong")
	_expect(not patrol.is_reward_available() and not CardManager.VALID_CARDS.has("PATROL_RECORD"), "task item leaked into card ownership")
	_expect(not patrol.get_node("CardMarker").visible, "collected PATROL_RECORD marker remained visible")
	_expect(patrol.get_interaction_block_reason() == "INELIGIBLE", "collected task item block reason is not readable")
	_expect(_staff_state_events.any(func(state: Dictionary) -> bool: return state.status == "COMPLETED" and is_equal_approx(state.progress, 1.0)), "staff completion did not notify UI")
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


func _on_work_state_changed(_target_id: String, state: Dictionary) -> void:
	_work_state_events.append(state.duplicate(true))


func _on_staff_state_changed(_target_id: String, state: Dictionary) -> void:
	_staff_state_events.append(state.duplicate(true))


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
